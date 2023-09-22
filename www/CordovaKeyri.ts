import type {
    KeyriModule,
    ProcessLinkOptions,
    InitializeKeyriOptions,
    SendEventOptions,
} from './types';

declare let window: any;

function asPromise<Type> (action: string, args: any[] = []): Promise<Type> {
    return new Promise((resolve, reject) => {
        console.log('Executing interface method', action, args);
        window.cordova.exec(resolve, reject, 'CordovaKeyri', action, args);
    });
}

const Keyri: KeyriModule = {
    initialize: (options: InitializeKeyriOptions) => {
        return asPromise('initialize', [options.appKey, options.publicApiKey, options.serviceEncryptionKey, options.blockEmulatorDetection]);
    },

    isInitialized: () => {
        return asPromise('isInitialized');
    },

    generateAssociationKey: (publicUserId?: string) => {
        return asPromise('generateAssociationKey', [publicUserId]);
    },

    generateUserSignature: (publicUserId?: string, data?: string) => {
        return asPromise('generateUserSignature', [publicUserId, data]);
    },

    listAssociationKeys: () => {
        return asPromise('listAssociationKeys');
    },

    listUniqueAccounts: () => {
        return asPromise('listUniqueAccounts');
    },

    getAssociationKey: (publicUserId?: string) => {
        return asPromise('getAssociationKey', [publicUserId]);
    },

    removeAssociationKey: (publicUserId: string) => {
        return asPromise('removeAssociationKey', [publicUserId]);
    },

    sendEvent: (data: SendEventOptions) => {
        return asPromise('sendEvent', [data.publicUserId, data.eventType, data.success]);
    },

    initiateQrSession: (sessionId: string, publicUserId?: string) => {
        return  asPromise('initiateQrSession', [sessionId, publicUserId]);
    },

    initializeDefaultConfirmationScreen: (payload: string) => {
        return asPromise('initializeDefaultConfirmationScreen', [payload]);
    },

    confirmSession: (payload: string, trustNewBrowser?: boolean) => {
        return asPromise('confirmSession', [payload, trustNewBrowser]);
    },

    denySession: (payload: string) => {
        return asPromise('denySession', [payload]);
    },

    easyKeyriAuth: (publicUserId: string, payload: string) => {
        return asPromise('easyKeyriAuth', [publicUserId, payload]);
    },

    processLink: (options: ProcessLinkOptions) => {
        return asPromise('processLink', [options.link, options.payload, options.publicUserId]);
    },
};

export default Keyri;

export * from './types';
