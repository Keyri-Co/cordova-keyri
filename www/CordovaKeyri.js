var exec = require('cordova/exec');

const asPromise = (action, args = []) =>
    new Promise((resolve, reject) => {
        console.log('Executing interface method', action, args);
        exec(resolve, reject, 'CordovaKeyri', action, args);
    });

const initialize = (appKey, publicApiKey, serviceEncryptionKey, blockEmulatorDetection) =>
    asPromise('initialize', [appKey, publicApiKey, serviceEncryptionKey, blockEmulatorDetection]);

const isInitialized = () => asPromise('isInitialized');

const easyKeyriAuth = (appKey, publicApiKey, serviceEncryptionKey, payload, publicUserId) =>
    asPromise('easyKeyriAuth', [appKey, publicApiKey, serviceEncryptionKey, payload, publicUserId]);

const generateAssociationKey = (publicUserId) => asPromise('generateAssociationKey', [publicUserId]);

const getUserSignature = (publicUserId, customSignedData) =>
    asPromise('getUserSignature', [publicUserId, customSignedData]);

const listAssociationKey = () => asPromise('listAssociationKey');

const listUniqueAccounts = () => asPromise('listUniqueAccounts');

const getAssociationKey = (publicUserId) => asPromise('getAssociationKey', [publicUserId]);

const removeAssociationKey = (publicUserId) => asPromise('removeAssociationKey', [publicUserId]);

const sendEvent = (publicUserId, eventType, success) =>
    asPromise('sendEvent', [publicUserId, eventType, success]);

const initiateQrSession = (sessionId, publicUserId) =>
    asPromise('initiateQrSession', [sessionId, publicUserId]);

const initializeDefaultScreen = (sessionId, payload) =>
    asPromise('initializeDefaultScreen', [sessionId, payload]);

const confirmSession = (sessionId, payload) =>
    asPromise('confirmSession', [sessionId, payload]);

const denySession = (sessionId, payload) =>
    asPromise('denySession', [sessionId, payload]);

const processLink = (url, payload, publicUserId) =>
    asPromise('processLink', [url, payload, publicUserId]);

// Export all methods in one block
module.exports = {
    initialize,
    isInitialized,
    easyKeyriAuth,
    generateAssociationKey,
    getUserSignature,
    listAssociationKey,
    listUniqueAccounts,
    getAssociationKey,
    removeAssociationKey,
    sendEvent,
    initiateQrSession,
    initializeDefaultScreen,
    confirmSession,
    denySession,
    processLink
};
