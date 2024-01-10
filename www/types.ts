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

export enum EventType {
    Visits = 'visits',
    Login = 'login',
    Signup = 'signup',
    AttachNewDevice = 'attach_new_device',
    EmailChange = 'email_change',
    ProfileUpdate = 'profile_update',
    PasswordReset = 'password_reset',
    Withdrawal = 'withdrawal',
    Deposit = 'deposit',
    Purchase = 'purchase',
}
