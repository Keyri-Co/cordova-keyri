import Foundation
import keyri_pod

@objc(CordovaKeyri) class CordovaKeyri : CDVPlugin {
    var keyri: Keyri?
    
    @objc(initialize:)
    func initialize(command: CDVInvokedUrlCommand) {
        guard let appKey = command.arguments[0] as? String else {
            let error = "No app key provided"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        let publicAPIKey = command.arguments[1] as? String
        
        keyri = Keyri(appKey: appKey, publicApiKey: publicAPIKey)
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
    }
    
    @objc(easyKeyriAuth:)
    func easyKeyriAuth(command: CDVInvokedUrlCommand) {
        guard let keyri = keyri else {
            let error = "Keyri object not initialized. Please call InitializeKeyri first"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let username = command.arguments[0] as? String,
              let payload = command.arguments[1] as? String else {
            let error = "Invalid arguments"
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        keyri.easyKeyriAuth(publicUserId: username, payload: payload) { result in
            switch result {
                
            case .success(_):
                self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
                return
            case .failure(_):
                self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_ERROR), callbackId: command.callbackId)
            }
            
        }
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
    
    @objc(generateAssociationKey:)
    func generateAssociationKey(command: CDVInvokedUrlCommand) {
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
            let key = try keyri.generateAssociationKey(username: username)

            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: key.rawRepresentation.base64EncodedString())
            commandDelegate.send(result, callbackId: command.callbackId)
            return

        } catch {
            print(error)
        }
        let error = "No key found for user"
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
        commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }
    
}

