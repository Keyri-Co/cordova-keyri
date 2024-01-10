import type {
    ProcessLinkOptions,
    InitializeKeyriOptions,
    SendEventOptions, LoginObject, RegisterObject,
} from './types';
import {KeyriFingerprintEventResponse, KeyriSession} from "./types";

declare let window: any;

function asPromise<Type>(action: string, args: any[] = []): Promise<Type> {
    return new Promise((resolve, reject) => {
        console.log('Executing interface method', action, args);
        window.cordova.exec(resolve, reject, 'CordovaKeyri', action, args);
    });
}

export class CordovaKeyriPlugin {
    initialize(options: InitializeKeyriOptions): Promise<boolean> {
        return asPromise('initialize', [options.appKey, options.publicApiKey, options.serviceEncryptionKey, String(options.blockEmulatorDetection)]);
    };

    isInitialized(): Promise<boolean> {
        return asPromise('isInitialized');
    };

    generateAssociationKey(publicUserId?: string): Promise<string> {
        return asPromise('generateAssociationKey', [publicUserId]);
    };

    generateUserSignature(publicUserId?: string, data?: string): Promise<string> {
        return asPromise('generateUserSignature', [publicUserId, data]);
    };

    listAssociationKeys(): Promise<Map<string, string>> {
        return asPromise('listAssociationKeys');
    };

    listUniqueAccounts(): Promise<Map<string, string>> {
        return asPromise('listUniqueAccounts');
    };

    getAssociationKey(publicUserId?: string): Promise<string | undefined> {
        return asPromise('getAssociationKey', [publicUserId]);
    };

    removeAssociationKey(publicUserId: string): Promise<boolean> {
        return asPromise('removeAssociationKey', [publicUserId]);
    };

    sendEvent(data: SendEventOptions): Promise<KeyriFingerprintEventResponse> {
        return asPromise('sendEvent', [data.publicUserId, data.eventType, String(data.success)]);
    };

    initiateQrSession(sessionId: string, publicUserId?: string): Promise<KeyriSession> {
        return  asPromise('initiateQrSession', [sessionId, publicUserId]);
    };

    login(publicUserId?: string): Promise<LoginObject> {
        return asPromise('login', [publicUserId]);
    };

    register(publicUserId?: string): Promise<RegisterObject> {
        return asPromise('register', [publicUserId]);
    };

    initializeDefaultConfirmationScreen(payload: string): Promise<boolean> {
        return asPromise('initializeDefaultConfirmationScreen', [payload]);
    };

    confirmSession(payload: string, trustNewBrowser?: boolean): Promise<boolean> {
        return asPromise('confirmSession', [payload, trustNewBrowser]);
    };

    denySession(payload: string): Promise<boolean> {
        return asPromise('denySession', [payload]);
    };

    easyKeyriAuth(publicUserId: string, payload: string): Promise<boolean> {
        return asPromise('easyKeyriAuth', [publicUserId, payload]);
    };

    processLink(options: ProcessLinkOptions): Promise<boolean> {
        return asPromise('processLink', [options.link, options.payload, options.publicUserId]);
    };
}

const CordovaKeyri = new CordovaKeyriPlugin();

if (!window.plugins) {
    window.plugins = {};
}

if (!window.plugins.CordovaKeyri) {
    window.plugins.CordovaKeyri = CordovaKeyri;
}
