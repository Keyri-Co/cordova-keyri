import Foundation
import keyri_pod

@objc(CordovaKeyri) class CordovaKeyri : CDVPlugin {
    var keyri: KeyriInterface?

    @objc(initialize:)
    func initialize(command: CDVInvokedUrlCommand) {
        guard let appKey = command.arguments[0] as? String else {
            let error = "initialize, No app key provided"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        let publicApiKey = command.arguments[1] as? String
        let serviceEncryptionKey = command.arguments[2] as? String
        let blockEmulatorDetection = command.arguments[3] as? Boolean

        keyri = KeyriInterface(appKey: appKey, publicApiKey: publicApiKey, serviceEncryptionKey: serviceEncryptionKey, blockEmulatorDetection: blockEmulatorDetection ?? true)
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
    }

    @objc(isInitialized:)
    func isInitialized(command: CDVInvokedUrlCommand) {
         if (keyri != nil) {
             commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
         } else {
             let error = "isInitialized, Keyri is not initialized"
             let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
             commandDelegate.send(pluginResult, callbackId: command.callbackId)
         }
    }

    @objc(easyKeyriAuth:)
    func easyKeyriAuth(command: CDVInvokedUrlCommand) {
        guard let payload = command.arguments[0] as? String else {
            let error = "easyKeyriAuth, payload must not be nil"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        let publicUserId = command.arguments[1] as? String

        keyri.easyKeyriAuth(publicUserId: publicUserId, payload: payload) { result in
            switch result {
                case .success(_):
                    self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
                    return
                case .failure(_):
                    self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_ERROR), callbackId: command.callbackId)
            }
        }
    }

// TODO: Review and test
    @objc(generateAssociationKey:)
    func generateAssociationKey(command: CDVInvokedUrlCommand) {
        guard let publicUserId = command.arguments[0] as? String else {
            let error = "generateAssociationKey, no publicUserId provided"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        keyri.generateAssociationKey(publicUserId: publicUserId) { result in
            switch result {
                case .success(let key):
                    self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), messageAs: key.rawRepresentation.base64EncodedString())
                case .failure(_):
                    self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_ERROR), callbackId: command.callbackId)
            }
        }

        return
    }

    @objc(listAssociationKey:)
    func listAssociationKey(command: CDVInvokedUrlCommand) {
        guard let keyri = keyri else {
            let error = "Keyri object not initialized. Please call InitializeKeyri first"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        let list = keyri.listAssociactionKeys()
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: list ?? [:])
        commandDelegate.send(result, callbackId: command.callbackId)
    }

    @objc(listUniqueAccounts:)
    func listUniqueAccounts(command: CDVInvokedUrlCommand) {
        guard let keyri = keyri else {
            let error = "Keyri object not initialized. Please call InitializeKeyri first"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        let list = keyri.listUniqueAccounts()
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: list ?? [:])
        commandDelegate.send(result, callbackId: command.callbackId)
    }

    @objc(getAssociationKey:)
    func getAssociationKey(command: CDVInvokedUrlCommand) {
        guard let keyri = keyri else {
            let error = "Keyri object not initialized. Please call InitializeKeyri first"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        guard let username = command.arguments[0] as? String else {
            let error = "No username provided"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        do {
            let key = try keyri.getAssociationKey(username: username)
            if let key = key {
                let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: key.rawRepresentation.base64EncodedString())
                commandDelegate.send(result, callbackId: command.callbackId)
                return
            }
        } catch {
            print(error)
        }
        let error = "No key found for user"
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
        commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }

    @objc(removeAssociationKey:)
    func removeAssociationKey(command: CDVInvokedUrlCommand) {
        guard let keyri = keyri else {
            let error = "Keyri object not initialized. Please call InitializeKeyri first"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        guard let username = command.arguments[0] as? String else {
            let error = "Invalid arguments"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        do {
            try keyri.removeAssociationKey(publicUserId: username)
            let result = CDVPluginResult(status: CDVCommandStatus_OK)
            commandDelegate.send(result, callbackId: command.callbackId)
        } catch {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR)
            commandDelegate.send(result, callbackId: command.callbackId)
        }
    }

    @objc(getUserSignature:)
    func getUserSignature(command: CDVInvokedUrlCommand) {
        guard let keyri = keyri else {
            let error = "Keyri object not initialized. Please call InitializeKeyri first"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        guard let username = command.arguments[0] as? String,
              let dataStr = command.arguments[1] as? String,
              let customData = dataStr.data(using: .utf8) else {
            let error = "Invalid arguments"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        do {
            let signature = try keyri.generateUserSignature(for: username, data: customData)
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: signature.rawRepresentation.base64EncodedString())
            commandDelegate.send(result, callbackId: command.callbackId)
        } catch {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "User not found")
            commandDelegate.send(result, callbackId: command.callbackId)
        }
    }
}

