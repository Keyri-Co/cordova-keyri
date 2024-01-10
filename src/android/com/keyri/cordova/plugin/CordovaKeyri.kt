package com.keyri.cordova.plugin

import android.net.Uri
import android.util.Log
import android.app.Activity
import android.content.Intent
import androidx.fragment.app.FragmentActivity
import com.keyrico.keyrisdk.Keyri
import com.keyrico.keyrisdk.entity.session.Session
import com.keyrico.keyrisdk.sec.fraud.enums.EventType
import com.google.gson.Gson
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaPlugin
import org.json.JSONArray
import org.json.JSONObject
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import com.keyrico.scanner.easyKeyriAuth

class CordovaKeyri : CordovaPlugin() {

    private var activeSession: Session? = null

    private lateinit var keyri: Keyri
    private lateinit var appKey: String
    private var publicApiKey: String? = null
    private var serviceEncryptionKey: String? = null
    private var blockEmulatorDetection: Boolean = true

    private var easyKeyriAuthCallback: CallbackContext? = null

    override fun execute(action: String, arguments: JSONArray?, callbackContext: CallbackContext): Boolean {
        Log.e("Executing native method", "$action, $arguments")

        when (action) {
            "initialize" -> {
                val appKey = arguments?.getString(0)
                val publicApiKey = arguments?.getString(1)
                val serviceEncryptionKey = arguments?.getString(2)
                val blockEmulatorDetection = arguments?.getBoolean(3)

                initialize(appKey, publicApiKey, serviceEncryptionKey, blockEmulatorDetection ?: true, callbackContext)
            }

            "isInitialized" -> {
                if (this::keyri.isInitialized) {
                    callbackContext.success()
                } else {
                    callbackContext.error("isInitialized, Keyri is not initialized")
                }
            }

            "easyKeyriAuth" -> {
                val payload = arguments?.getString(0)
                val publicUserId = arguments?.getString(1)

                easyKeyriAuth(payload, publicUserId, callbackContext)
            }

            "generateAssociationKey" -> {
                val publicUserId = arguments?.getString(0)

                generateAssociationKey(publicUserId, callbackContext)
            }

            "generateUserSignature" -> {
                val publicUserId = arguments?.getString(0)
                val data = arguments?.getString(1)

                generateUserSignature(publicUserId, data, callbackContext)
            }

            "listAssociationKeys" -> listAssociationKeys(callbackContext)
            "listUniqueAccounts" -> listUniqueAccounts(callbackContext)
            "getAssociationKey" -> {
                val publicUserId = arguments?.getString(0)

                getAssociationKey(publicUserId, callbackContext)
            }

            "removeAssociationKey" -> {
                val publicUserId = arguments?.getString(0)

                removeAssociationKey(publicUserId, callbackContext)
            }

            "sendEvent" -> {
                val publicUserId = arguments?.getString(0)
                val eventType = arguments?.getString(1)
                val success = arguments?.getBoolean(2) ?: true

                sendEvent(publicUserId, eventType, success, callbackContext)
            }

            "initiateQrSession" -> {
                val sessionId = arguments?.getString(0)
                val publicUserId = arguments?.getString(1)

                initiateQrSession(sessionId, publicUserId, callbackContext)
            }

            "login" -> {
                val publicUserId = arguments?.getString(0)

                login(publicUserId, callbackContext)
            }

            "register" -> {
                val publicUserId = arguments?.getString(0)

                register(publicUserId, callbackContext)
            }

            "initializeDefaultConfirmationScreen" -> {
                val payload = arguments?.getString(1)

                initializeDefaultConfirmationScreen(payload, callbackContext)
            }

            "processLink" -> {
                val link = arguments?.getString(0)
                val payload = arguments?.getString(1)
                val publicUserId = arguments?.getString(2)

                processLink(link, payload, publicUserId, callbackContext)
            }

            "confirmSession" -> {
                val payload = arguments?.getString(0)
                val trustNewBrowser = arguments?.getBoolean(1) ?: false

                confirmSession(payload, trustNewBrowser, callbackContext)
            }

            "denySession" -> {
                val payload = arguments?.getString(0)

                denySession(payload, callbackContext)
            }

            else -> {
                callbackContext.error("Action $action not implemented")

                return false
            }
        }

        return true
    }

    private fun initialize(
        appKey: String?,
        publicApiKey: String?,
        serviceEncryptionKey: String?,
        blockEmulatorDetection: Boolean,
        callback: CallbackContext
    ) {
        cordova.threadPool.execute {
            try {
                if (appKey == null) {
                    callback.error("initialize, appKey must not be null")
                } else {
                    cordova.getActivity()?.let {
                        if (!this::keyri.isInitialized) {
                            this.appKey = appKey
                            this.publicApiKey = publicApiKey
                            this.serviceEncryptionKey = serviceEncryptionKey
                            this.blockEmulatorDetection = blockEmulatorDetection

                            keyri = Keyri(it, appKey, publicApiKey, serviceEncryptionKey, blockEmulatorDetection)
                        }

                        callback.success()
                    }
                }
            } catch (e: Exception) {
                callback.error(e.message)
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == AUTH_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                easyKeyriAuthCallback?.success()
            }
        }
    }

    private fun easyKeyriAuth(
        payload: String?,
        publicUserId: String?,
        callback: CallbackContext
    ) {
        if (payload == null) {
            callback.error("easyKeyriAuth, payload must not be null")
        } else {
            cordova.getActivity()?.let {
                cordova.setActivityResultCallback(this)
                easyKeyriAuth(it, AUTH_REQUEST_CODE, appKey, publicApiKey, serviceEncryptionKey, blockEmulatorDetection, payload, publicUserId)

                easyKeyriAuthCallback = callback
            } ?: callback.error("initializeDefaultScreen, can't get cordova.getActivity()")
        }
    }

    private fun generateAssociationKey(publicUserId: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            val associationKey = publicUserId?.let {
                keyri.generateAssociationKey(publicUserId).getOrThrow()
            } ?: keyri.generateAssociationKey().getOrThrow()

            callback.success(associationKey)
        }
    }

    private fun generateUserSignature(publicUserId: String?, data: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            if (data == null) {
                callback.error("generateUserSignature, data must not be null")
            } else {
                val userSignature = publicUserId?.let {
                    keyri.generateUserSignature(it, data).getOrThrow()
                } ?: keyri.generateUserSignature(data = data).getOrThrow()

                callback.success(userSignature)
            }
        }
    }

    private fun listAssociationKeys(callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            val keys = keyri.listAssociationKeys().getOrThrow()
            val resultArray = JSONArray()

            keys.map {
                val keyObject = JSONObject().apply {
                    put(it.key, it.value)
                }

                resultArray.put(keyObject)
            }

            callback.success(resultArray)
        }
    }

    private fun listUniqueAccounts(callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            val keys = keyri.listUniqueAccounts().getOrThrow()
            val resultArray = JSONArray()

            keys.map {
                val keyObject = JSONObject().apply {
                    put(it.key, it.value)
                }

                resultArray.put(keyObject)
            }

            callback.success(resultArray)
        }
    }

    private fun getAssociationKey(publicUserId: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            val associationKey = publicUserId?.let {
                keyri.getAssociationKey(publicUserId).getOrThrow()
            } ?: keyri.getAssociationKey().getOrThrow()

            callback.success(associationKey)
        }
    }

    private fun removeAssociationKey(publicUserId: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            if (publicUserId == null) {
                callback.error("removeAssociationKey, publicUserId must not be null")
            } else {
                keyri.removeAssociationKey(publicUserId).getOrThrow()
                callback.success()
            }
        }
    }

    private fun sendEvent(publicUserId: String?, eventType: String?, success: Boolean, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            val type = EventType.values().firstOrNull { it.type == eventType }

            if (type == null) {
                callback.error("sendEvent, eventType must not be null")
            } else {
                val userId = publicUserId ?: "ANON"

                keyri.sendEvent(userId, type, success).onSuccess {
                    callback.success()
                }.onFailure {
                    callback.error("sendEvent, ${it.message}")
                }
            }
        }
    }

    private fun initiateQrSession(sessionId: String?, publicUserId: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            if (sessionId == null) {
                callback.error("initiateQrSession, sessionId must not be null")
            } else {
                keyri.initiateQrSession(sessionId, publicUserId).onSuccess { session ->
                    activeSession = session

                    callback.success(JSONObject(Gson().toJson(session)))
                }.onFailure {
                    callback.error("initiateQrSession, ${it.message}")
                }
            }
        }
    }

    private fun login(publicUserId: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            keyri.login(publicUserId).onSuccess { loginObject ->
                callback.success(JSONObject(Gson().toJson(loginObject)))
            }.onFailure {
                callback.error("login, ${it.message}")
            }
        }
    }

    private fun register(publicUserId: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            keyri.register(publicUserId).onSuccess { registerObject ->
                callback.success(JSONObject(Gson().toJson(registerObject)))
            }.onFailure {
                callback.error("register, ${it.message}")
            }
        }
    }

    private fun initializeDefaultConfirmationScreen(payload: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            if (activeSession == null) {
                callback.error("initializeDefaultConfirmationScreen, can't find session")
            } else if (payload == null) {
                callback.error("initializeDefaultConfirmationScreen, payload must not be null")
            } else {
                (cordova.getActivity() as? FragmentActivity)?.supportFragmentManager?.let { fm ->
                    keyri.initializeDefaultConfirmationScreen(fm, requireNotNull(activeSession), payload).onSuccess { authResult ->
                        callback.success()
                    }.onFailure {
                        callback.error("initializeDefaultConfirmationScreen, ${it.message}")
                    }
                } ?: callback.error("initializeDefaultConfirmationScreen, can't get supportFragmentManager")
            }
        }
    }

    private fun processLink(link: String?, payload: String?, publicUserId: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            if (link == null) {
                callback.error("processLink, link must not be null")
            } else if (payload == null) {
                callback.error("processLink, payload must not be null")
            } else {
                (cordova.getActivity() as? FragmentActivity)?.supportFragmentManager?.let { fm ->
                    keyri.processLink(fm, Uri.parse(link), payload, publicUserId).onSuccess { authResult ->
                        callback.success()
                    }.onFailure {
                        callback.error("processLink, ${it.message}")
                    }
                }
            }
        }
    }

    private fun confirmSession(payload: String?, trustNewBrowser: Boolean, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            if (activeSession == null) {
                callback.error("confirmSession, can't find session")
            } else if (payload == null) {
                callback.error("confirmSession, payload must not be null")
            } else {
                activeSession?.confirm(payload, requireNotNull(cordova.getActivity()), trustNewBrowser)?.onSuccess {
                    callback.success()
                }?.onFailure {
                    callback.error("confirmSession, ${it.message}")
                }
            }
        }
    }

    private fun denySession(payload: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback).launch {
            if (activeSession == null) {
                callback.error("denySession, can't find session")
            } else if (payload == null) {
                callback.error("denySession, payload must not be null")
            } else {
                activeSession?.deny(payload, requireNotNull(cordova.getActivity()))?.onSuccess {
                    callback.success()
                }?.onFailure {
                    callback.error("denySession, ${it.message}")
                }
            }
        }
    }

    private fun keyriCoroutineScope(callback: CallbackContext): CoroutineScope {
        val exceptionHandler = CoroutineExceptionHandler { _, e ->
            callback.error(e.message ?: "Error calling this method")
        }

        return CoroutineScope(Dispatchers.IO + exceptionHandler)
    }

    companion object {
        private const val AUTH_REQUEST_CODE = 2133
    }
}
