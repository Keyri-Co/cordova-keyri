import Foundation
@objc(CordovaKeyri) class CordovaKeyri : CDVPlugin {
    @objc(listAssociationKey:)
    func listAssociationKey(command : CDVInvokedUrlCommand) {
        print("called function from cordova")
        let alert = UIAlertView()
        alert.title = "Title"
        alert.message = "My message"
        alert.addButton(withTitle: "Ok")
        alert.show()
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "hi")
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }
}
