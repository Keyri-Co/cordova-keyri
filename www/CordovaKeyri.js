var exec = require('cordova/exec');

exports.isInitialized = false;

exports.initialize = function (appKey, publicApiKey, blockEmulatorDetection, success, error) {
    exec(
        function (result) {
            self.isInitialized = result;

            exec(success, error, 'CordovaKeyri', 'initialize', [appKey, publicApiKey, blockEmulatorDetection]);
        },
        error, 'CordovaKeyri', 'isInitialized', [appKey, publicApiKey, blockEmulatorDetection]
    );
};

exports.easyKeyriAuth = function (appKey, publicApiKey, payload, publicUserId, success, error) {
    exec(success, error, 'CordovaKeyri', 'easyKeyriAuth', [appKey, publicApiKey, payload, publicUserId]);
};

exports.generateAssociationKey = function (publicUserId, success, error) {
    exec(success, error, 'CordovaKeyri', 'generateAssociationKey', [publicUserId]);
};

exports.getUserSignature = function (publicUserId, customSignedData, success, error) {
    exec(success, error, 'CordovaKeyri', 'getUserSignature', [publicUserId, customSignedData]);
};

exports.listAssociationKey = function (success, error) {
    alert("called in module");
    exec(success, error, 'CordovaKeyri', 'listAssociationKey', []);
};

exports.listUniqueAccounts = function (success, error) {
    exec(success, error, 'CordovaKeyri', 'listUniqueAccounts', []);
};

exports.getAssociationKey = function (publicUserId, success, error) {
    exec(success, error, 'CordovaKeyri', 'getAssociationKey', [publicUserId]);
};

exports.removeAssociationKey = function (publicUserId, success, error) {
    exec(success, error, 'CordovaKeyri', 'removeAssociationKey', [publicUserId]);
};

exports.sendEvent = function (publicUserId, eventType, eventResult, success, error) {
    exec(success, error, 'CordovaKeyri', 'sendEvent', [publicUserId, eventType, eventResult]);
};

exports.initiateQrSession = function (sessionId, publicUserId, success, error) {
    exec(success, error, 'CordovaKeyri', 'initiateQrSession', [sessionId, publicUserId]);
};

exports.initializeDefaultScreen = function (sessionId, payload, success, error) {
    exec(success, error, 'CordovaKeyri', 'initializeDefaultScreen', [sessionId, payload]);
};

exports.confirmSession = function (sessionId, payload, success, error) {
    exec(success, error, 'CordovaKeyri', 'confirmSession', [sessionId, payload]);
};

exports.denySession = function (sessionId, payload, success, error) {
    exec(success, error, 'CordovaKeyri', 'denySession', [sessionId, payload]);
};

exports.processLink = function (url, payload, publicUserId, success, error) {
    exec(success, error, 'CordovaKeyri', 'processLink', [url, payload, publicUserId]);
};
