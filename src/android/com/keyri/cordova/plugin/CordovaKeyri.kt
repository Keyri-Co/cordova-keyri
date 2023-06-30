package com.keyri.cordova.plugin

import android.net.Uri
import android.util.Log
import android.app.Activity
import android.content.Intent
import androidx.fragment.app.FragmentActivity
import com.keyrico.keyrisdk.Keyri
import com.keyrico.keyrisdk.entity.session.Session
import com.keyrico.keyrisdk.sec.fingerprint.enums.EventType
import com.google.gson.Gson
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaPlugin
import org.json.JSONArray
import org.json.JSONObject
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class CordovaKeyri : CordovaPlugin() {

    private val sessions = mutableListOf<Session>()

    private lateinit var keyri: Keyri

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
                val appKey = arguments?.getString(0)
                val publicApiKey = arguments?.getString(1)
                val serviceEncryptionKey = arguments?.getString(2)
                val payload = arguments?.getString(3)
                val publicUserId = arguments?.getString(4)

                easyKeyriAuth(appKey, publicApiKey, serviceEncryptionKey, payload, publicUserId, callbackContext)
            }

            "generateAssociationKey" -> {
                val publicUserId = arguments?.getString(0)

                generateAssociationKey(publicUserId, callbackContext)
            }

            "getUserSignature" -> {
                val publicUserId = arguments?.getString(0)
                val customSignedData = arguments?.getString(1)

                getUserSignature(publicUserId, customSignedData, callbackContext)
            }

            "listAssociationKey" -> listAssociationKey(callbackContext)
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
                val success = arguments?.getBoolean(2)

                sendEvent(publicUserId, eventType, success, callbackContext)
            }

            "initiateQrSession" -> {
                val sessionId = arguments?.getString(0)
                val publicUserId = arguments?.getString(1)

                initiateQrSession(sessionId, publicUserId, callbackContext)
            }

            "initializeDefaultScreen" -> {
                val sessionId = arguments?.getString(0)
                val payload = arguments?.getString(1)

                initializeDefaultScreen(sessionId, payload, callbackContext)
            }

            "processLink" -> {
                val link = arguments?.getString(0)
                val payload = arguments?.getString(1)
                val publicUserId = arguments?.getString(2)

                processLink(link, payload, publicUserId, callbackContext)
            }

            "confirmSession" -> {
                val sessionId = arguments?.getString(0)
                val payload = arguments?.getString(1)

                confirmSession(sessionId, payload, callbackContext)
            }

            "denySession" -> {
                val sessionId = arguments?.getString(0)
                val payload = arguments?.getString(1)

                denySession(sessionId, payload, callbackContext)
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
        appKey: String?,
        publicApiKey: String?,
        serviceEncryptionKey: String?,
        payload: String?,
        publicUserId: String?,
        callback: CallbackContext
    ) {
        if (appKey == null || payload == null) {
            callback.error("easyKeyriAuth, appKey and payload must not be null")
        } else {
            cordova.getActivity()?.let {
                cordova.setActivityResultCallback(this)
                easyKeyriAuth(it, AUTH_REQUEST_CODE, appKey, publicApiKey, serviceEncryptionKey, payload, publicUserId)

                easyKeyriAuthCallback = callback
            } ?: callback.error("initializeDefaultScreen, can't get cordova.getActivity()")
        }
    }

    private fun generateAssociationKey(publicUserId: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback::error).launch {
            val associationKey = publicUserId?.let {
                keyri.generateAssociationKey(publicUserId).getOrThrow()
            } ?: keyri.generateAssociationKey().getOrThrow()

            callback.success(associationKey)
        }
    }

    private fun getUserSignature(
        publicUserId: String?,
        customSignedData: String?,
        callback: CallbackContext
    ) {
        keyriCoroutineScope(callback::error).launch {
            if (customSignedData == null) {
                callback.error("getUserSignature, customSignedData must not be null")
            } else {
                val userSignature = publicUserId?.let {
                    keyri.generateUserSignature(it, customSignedData).getOrThrow()
                } ?: keyri.generateUserSignature(data = customSignedData).getOrThrow()

                callback.success(userSignature)
            }
        }
    }

    private fun listAssociationKey(callback: CallbackContext) {
        keyriCoroutineScope(callback::error).launch {
            val keys = keyri.listAssociationKey().getOrThrow()
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
        keyriCoroutineScope(callback::error).launch {
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
        keyriCoroutineScope(callback::error).launch {
            val associationKey = publicUserId?.let {
                keyri.getAssociationKey(publicUserId).getOrThrow()
            } ?: keyri.getAssociationKey().getOrThrow()

            callback.success(associationKey)
        }
    }

    private fun removeAssociationKey(publicUserId: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback::error).launch {
            if (publicUserId == null) {
                callback.error("removeAssociationKey, publicUserId must not be null")
            } else {
                keyri.removeAssociationKey(publicUserId).getOrThrow()
                callback.success()
            }
        }
    }

    private fun sendEvent(publicUserId: String?, eventType: String?, success: Boolean, callback: CallbackContext) {
        keyriCoroutineScope(callback::error).launch {
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

    private fun initiateQrSession(
        sessionId: String?,
        publicUserId: String?,
        callback: CallbackContext
    ) {
        keyriCoroutineScope(callback::error).launch {
            if (sessionId == null) {
                callback.error("initiateQrSession, sessionId must not be null")
            } else {
                keyri.initiateQrSession(sessionId, publicUserId).onSuccess { session ->
                    sessions.add(session)

                    callback.success(JSONObject(Gson().toJson(session)))
                }.onFailure {
                    callback.error("initiateQrSession, ${it.message}")
                }
            }
        }
    }

    private fun initializeDefaultScreen(
        sessionId: String?,
        payload: String?,
        callback: CallbackContext
    ) {
        keyriCoroutineScope(callback::error).launch {
            val session = findSession(sessionId)

            if (session == null) {
                callback.error("initializeDefaultScreen, can't find session")
            } else if (payload == null) {
                callback.error("initializeDefaultScreen, payload must not be null")
            } else {
                (cordova.getActivity() as? FragmentActivity)?.supportFragmentManager?.let { fm ->
                    keyri.initializeDefaultConfirmationScreen(fm, session, payload).onSuccess { authResult ->
                        callback.success(authResult)
                    }.onFailure {
                        callback.error("initializeDefaultScreen, ${it.message}")
                    }
                } ?: callback.error("initializeDefaultScreen, can't get supportFragmentManager")
            }
        }
    }

    private fun processLink(link: String?, payload: String?, publicUserId: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback::error).launch {
            if (link == null) {
                callback.error("processLink, link must not be null")
            } else if (payload == null) {
                callback.error("processLink, payload must not be null")
            } else {
                (cordova.getActivity() as? FragmentActivity)?.supportFragmentManager?.let { fm ->
                    keyri.processLink(fm, Uri.parse(link), payload, publicUserId).onSuccess { authResult ->
                        callback.success(authResult)
                    }.onFailure {
                        callback.error("processLink, ${it.message}")
                    }
                }
            }
        }
    }

    private fun confirmSession(sessionId: String?, payload: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback::error).launch {
            val session = findSession(sessionId)

            if (session == null) {
                callback.error("confirmSession, can't find session")
            } else if (payload == null) {
                callback.error("confirmSession, payload must not be null")
            } else {
                session.confirm(payload, requireNotNull(cordova.getActivity())).onSuccess {
                    callback.success()
                }.onFailure {
                    callback.error("confirmSession, ${it.message}")
                }
            }
        }
    }

    private fun denySession(sessionId: String?, payload: String?, callback: CallbackContext) {
        keyriCoroutineScope(callback::error).launch {
            val session = findSession(sessionId)

            if (session == null) {
                callback.error("denySession, can't find session")
            } else if (payload == null) {
                callback.error("denySession, payload must not be null")
            } else {
                session.deny(payload, requireNotNull(cordova.getActivity())).onSuccess {
                    callback.success()
                }.onFailure {
                    callback.error("denySession, ${it.message}")
                }
            }
        }
    }

    private fun keyriCoroutineScope(errorCallback: (e: Throwable) -> Unit): CoroutineScope {
        val exceptionHandler = CoroutineExceptionHandler { _, e ->
            errorCallback(e.message ?: "Error calling this method")
        }

        return CoroutineScope(Dispatchers.IO + exceptionHandler)
    }

    private fun findSession(sessionId: String?): Session? = sessions.firstOrNull { it.sessionId == sessionId }

    companion object {
        private const val AUTH_REQUEST_CODE = 2133
    }
}
