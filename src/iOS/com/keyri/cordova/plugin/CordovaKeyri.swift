import Foundation
import Keyri

@objc(CordovaKeyri) class CordovaKeyri : CDVPlugin {
    var keyri: KeyriInterface?
    var activeSession: Session?

    @objc(initialize:)
    func initialize(command: CDVInvokedUrlCommand) {
        guard let arguments = command.arguments else {
            processError(error: "initialize, no arguments provided", command: command)
            return
        }

        if arguments.count < 1 || !(arguments[0] is String) {
            processError(error: "initialize, first parameter must be a String", command: command)
            return
        }

        let appKey = arguments[0] as! String
        let publicApiKey = arguments[1] as? String
        let serviceEncryptionKey = arguments[2] as? String
        let blockEmulatorDetection = arguments[3] as? Bool ?? true

        keyri = KeyriInterface(appKey: appKey, publicApiKey: publicApiKey, serviceEncryptionKey: serviceEncryptionKey, blockEmulatorDetection: blockEmulatorDetection)

        processResult(command: command)
    }

    @objc(isInitialized:)
    func isInitialized(command: CDVInvokedUrlCommand) {
        if (keyri != nil) {
            processResult(command: command)
        } else {
            sendIsNotInitialized(methodName: "isInitialized", command: command)
        }
    }

    @objc(easyKeyriAuth:)
    func easyKeyriAuth(command: CDVInvokedUrlCommand) {
        guard let payload = command.arguments[0] as? String else {
            processError(error: "easyKeyriAuth, payload must not be nil", command: command)
            return
        }

        let publicUserId = command.arguments[1] as? String

        keyri?.easyKeyriAuth(payload: payload, publicUserId: publicUserId) { result in
            switch result {
            case .success:
                self.processResult(command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "easyKeyriAuth", command: command)
    }

    @objc(generateAssociationKey:)
    func generateAssociationKey(command: CDVInvokedUrlCommand) {
        guard let publicUserId = command.arguments[0] as? String else {
            processError(error: "generateAssociationKey, publicUserId must not be nil", command: command)
            return
        }

        keyri?.generateAssociationKey(publicUserId: publicUserId) { result in
            switch result {
            case .success(let key):
                self.processResult(message: key.rawRepresentation.base64EncodedString(), command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "generateAssociationKey", command: command)
    }

    @objc(generateUserSignature:)
    func generateUserSignature(command: CDVInvokedUrlCommand) {
        guard let publicUserId = command.arguments[0] as? String else {
            processError(error: "generateUserSignature, publicUserId must not be nil", command: command)
            return
        }

        guard let dataStr = command.arguments[1] as? String,
              let data = dataStr.data(using: .utf8) else {
            processError(error: "generateUserSignature, data must not be nil", command: command)
            return
        }

        keyri?.generateUserSignature(publicUserId: publicUserId, data: data) { result in
            switch result {
            case .success(let signature):
                self.processResult(message: signature.derRepresentation.base64EncodedString(), command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "generateUserSignature", command: command)
    }

    @objc(listAssociationKeys:)
    func listAssociationKeys(command: CDVInvokedUrlCommand) {
        keyri?.listAssociationKeys() { result in
            switch result {
            case .success(let list):
                self.processResult(message: list ?? [:], command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "listAssociationKeys", command: command)
    }

    @objc(listUniqueAccounts:)
    func listUniqueAccounts(command: CDVInvokedUrlCommand) {
        keyri?.listUniqueAccounts() { result in
            switch result {
            case .success(let list):
                self.processResult(message: list ?? [:], command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "listUniqueAccounts", command: command)
    }

    @objc(getAssociationKey:)
    func getAssociationKey(command: CDVInvokedUrlCommand) {
        let publicUserId = command.arguments[0] as? String

        keyri?.getAssociationKey(publicUserId: publicUserId ?? "") { result in
            switch result {
            case .success(let key):
                self.processResult(message: key?.rawRepresentation.base64EncodedString(), command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "getAssociationKey", command: command)
    }

    @objc(removeAssociationKey:)
    func removeAssociationKey(command: CDVInvokedUrlCommand) {
        guard let publicUserId = command.arguments[0] as? String else {
            processError(error: "removeAssociationKey, publicUserId must not be nil", command: command)
            return
        }

        keyri?.removeAssociationKey(publicUserId: publicUserId) { result in
            switch result {
            case .success:
                self.processResult(command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "removeAssociationKey", command: command)
    }

    @objc(sendEvent:)
    func sendEvent(command: CDVInvokedUrlCommand) {
        guard let publicUserId = command.arguments[0] as? String else {
            processError(error: "sendEvent, publicUserId must not be nil", command: command)
            return
        }

        guard let eventType = command.arguments[1] as? String else {
                processError(error: "sendEvent, eventType must not be nil", command: command)
                return
            }

        let eventMetadata = command.arguments[2] as? String
        let success = command.arguments[3] as? String ?? "true"

        keyri?.sendEvent(publicUserId: publicUserId, eventType: EventType.custom(name: eventType, metadata: eventMetadata), success: Bool(success) ?? true) { result in
            switch result {
            case .success(let fingerprintResponse):
                self.processResult(message: fingerprintResponse.asDictionary(), command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "sendEvent", command: command)
    }

    @objc(createFingerprint)
    func createFingerprint(command: CDVInvokedUrlCommand) {
        keyri?.createFingerprint() { result in
            switch result {
            case .success(let fingerprintRequest):
                self.processResult(message: fingerprintRequest.asDictionary(), command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "createFingerprint", command: command)
    }

    @objc(initiateQrSession:)
    func initiateQrSession(command: CDVInvokedUrlCommand) {
        guard let sessionId = command.arguments[0] as? String else {
            processError(error: "initiateQrSession, sessionId must not be nil", command: command)
            return
        }

        let publicUserId = command.arguments[1] as? String

        keyri?.initiateQrSession(sessionId: sessionId, publicUserId: publicUserId) { result in
            switch result {
            case .success(let session):
                self.activeSession = session
                self.processResult(message: session.asDictionary(), command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "initiateQrSession", command: command)
    }

    @objc(login:)
    func login(command: CDVInvokedUrlCommand) {
        let publicUserId = command.arguments[1] as? String

        keyri?.login(publicUserId: publicUserId) { result in
            switch result {
            case .success(let loginObject):
                self.processResult(message: loginObject.asDictionary(), command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "login", command: command)
    }

    @objc(register:)
    func register(command: CDVInvokedUrlCommand) {
        let publicUserId = command.arguments[1] as? String

        keyri?.register(publicUserId: publicUserId) { result in
            switch result {
            case .success(let registerObject):
                self.processResult(message: registerObject.asDictionary(), command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "register", command: command)
    }

    @objc(initializeDefaultConfirmationScreen:)
    func initializeDefaultConfirmationScreen(command: CDVInvokedUrlCommand) {
        guard let session = activeSession else {
            processError(error: "initializeDefaultConfirmationScreen, activeSession must not be nil", command: command)
            return
        }

        guard let payload = command.arguments[0] as? String else {
            processError(error: "initializeDefaultConfirmationScreen, payload must not be nil", command: command)
            return
        }

        keyri?.initializeDefaultConfirmationScreen(session: session, payload: payload) { result in
            switch result {
            case .success:
                self.processResult(command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "initializeDefaultConfirmationScreen", command: command)
    }

    @objc(processLink:)
    func processLink(command: CDVInvokedUrlCommand) {
        guard let link = command.arguments[0] as? String,
          let url = URL(string: link) else {
            processError(error: "processLink, link must not be nil", command: command)
            return
        }

        guard let payload = command.arguments[1] as? String else {
            processError(error: "processLink, payload must not be nil", command: command)
            return
        }

        guard let publicUserId = command.arguments[2] as? String else {
            processError(error: "processLink, publicUserId must not be nil", command: command)
            return
        }

        keyri?.processLink(url: url, payload: payload, publicUserId: publicUserId) { result in
            switch result {
            case .success:
                self.processResult(command: command)
            case .failure(let error):
                self.processError(error: error, command: command)
            }
        } ?? sendIsNotInitialized(methodName: "processLink", command: command)
    }

    @objc(confirmSession:)
    func confirmSession(command: CDVInvokedUrlCommand) {
        guard let payload = command.arguments[0] as? String,
            let trustNewBrowserString = command.arguments[1] as? String,
            let trustNewBrowser = Bool(trustNewBrowserString) else {
            processError(error: "confirmSession, payload must not be nil", command: command)
            return
        }

        activeSession?.confirm(payload: payload, trustNewBrowser: trustNewBrowser) { result in
            switch result {
            case .some(let error):
                self.processError(error: error, command: command)
            case .none:
                self.processResult(command: command)
            }
        } ?? processError(error: "confirmSession, activeSession is nil", command: command)
    }

    @objc(denySession:)
    func denySession(command: CDVInvokedUrlCommand) {
        guard let payload = command.arguments[0] as? String else {
            processError(error: "denySession, payload must not be nil", command: command)
            return
        }

        activeSession?.deny(payload: payload) { result in
            switch result {
            case .some(let error):
                self.processError(error: error, command: command)
            case .none:
                self.processResult(command: command)
            }
        } ?? processError(error: "denySession, activeSession is nil", command: command)
    }

    private func processResult(message: String?, command: CDVInvokedUrlCommand) {
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message), callbackId: command.callbackId)
    }

    private func processResult(message: [String : String]?, command: CDVInvokedUrlCommand) {
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message), callbackId: command.callbackId)
    }

    private func processResult(command: CDVInvokedUrlCommand) {
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
    }

    private func processError(error: String, command: CDVInvokedUrlCommand) {
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error), callbackId: command.callbackId)
    }

    private func sendIsNotInitialized(methodName: String, command: CDVInvokedUrlCommand) {
        processError(error: methodName + ", Keyri is not initialized", command: command)
    }

    private func processError(error: Error, command: CDVInvokedUrlCommand) {
        processError(error: error.localizedDescription, command: command)
    }
}

extension Encodable {
    func asDictionary() -> [String: String]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String] else {
            return nil
        }
        return dictionary
    }
}
