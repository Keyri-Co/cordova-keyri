export interface KeyriSession {
    sessionId: string;
    publicUserId: string;
    userParameters?: KeyriUserParameters;
    iPAddressMobile: string;
    iPAddressWidget: string;
    widgetOrigin?: string;
    widgetUserAgent?: KeyriWidgetUserAgent;
    riskAnalytics?: KeyriRiskAnalytics;
    mobileTemplateResponse?: KeyriMobileTemplateResponse;
}

export interface LoginObject {
    timestampNonce: string,
    signature: string,
    publicKey: string,
    userId: string,
}

export interface RegisterObject {
    publicKey: string,
    userId: string,
}

export interface KeyriFingerprintEventResponse {
    apiCiphertextSignature: string;
    publicEncryptionKey: string;
    ciphertext: string;
    iv: string;
    salt: string;
}

export interface KeyriFingerprintRequest {
    clientEncryptionKey: string;
    encryptedPayload: string;
    salt: string;
    iv: string;
}

export interface KeyriUserParameters {
    base64EncodedData?: string;
}

export interface KeyriWidgetUserAgent {
    os: string;
    browser: string;
}

export interface KeyriRiskAnalytics {
    riskStatus?: string;
    riskFlagString?: string;
    geoData: {
        mobile?: KeyriGeoData;
        browser?: KeyriGeoData;
    };
}

export interface KeyriMobileTemplateResponse {
    title: string;
    message?: string;
    widget?: KeyriTemplate;
    mobile?: KeyriTemplate;
    userAgent?: KeyriUserAgent;
}

export interface KeyriTemplate {
    location?: string;
    issue?: string;
}

export interface KeyriUserAgent {
    name?: string;
    issue?: string;
}

export interface KeyriGeoData {
    continentCode?: string;
    countryCode?: string;
    city?: string;
    regionCode?: string;
}

export interface ProcessLinkOptions {
    link: string;
    payload: string;
    publicUserId?: string;
}

export interface InitializeKeyriOptions {
    appKey: string;
    publicApiKey?: string;
    serviceEncryptionKey?: string;
    blockEmulatorDetection?: boolean;
}

export interface SendEventOptions {
    publicUserId?: string;
    eventType: EventType;
    success: boolean;
}

export class EventType {
    name: string;
    metadata?: object;

    constructor(name: string, metadata?: object) {
        this.name = name;
        this.metadata = metadata;
    }

    static visits(metadata?: object): EventType {
        return new EventType('visits', metadata);
    }

    static login(metadata?: object): EventType {
        return new EventType('login', metadata);
    }

    static signup(metadata?: object): EventType {
        return new EventType('signup', metadata);
    }

    static attachNewDevice(metadata?: object): EventType {
        return new EventType('attach_new_device', metadata);
    }

    static emailChange(metadata?: object): EventType {
        return new EventType('email_change', metadata);
    }

    static profileUpdate(metadata?: object): EventType {
        return new EventType('profile_update', metadata);
    }

    static passwordReset(metadata?: object): EventType {
        return new EventType('password_reset', metadata);
    }

    static withdrawal(metadata?: object): EventType {
        return new EventType('withdrawal', metadata);
    }

    static deposit(metadata?: object): EventType {
        return new EventType('deposit', metadata);
    }

    static purchase(metadata?: object): EventType {
        return new EventType('purchase', metadata);
    }

    static custom(name: string, metadata?: object): EventType {
        return new EventType(name, metadata);
    }
}
