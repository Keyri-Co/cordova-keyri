## **System Requirements**

* iOS 14+, Swift 5.3
* Android API level 23 or higher, target sdk 33 or higher AndroidX, Kotlin coroutines compatability

## **Interacting with the Plugin**

Please see the examples below as well as a full set of method examples
here: https://github.com/Keyri-Co/sample-cordova-app/blob/main/keyriSample/www/js/index.js

### Initialize Keyri

To initialize the Keyri object, simply call the initialize method, and pass in your app key and api key, generated in
the Keyri dashboard

```javascript
Keyri.initialize({
    appKey: appKey,
    publicApiKey: publicApiKey,
    serviceEncryptionKey: serviceEncryptionKey,
    blockEmulatorDetection: true
})
    .then((message) => {
        console.log('CordovaKeyri.initialize', message);
        isInitialized();
    })
    .catch((e) => {
        console.log('CordovaKeyri.initialize', e);
    });
```

### Generate and retrieve association key

The association key is the cryptographic identity we use to identify users. It sits in the Trusted Development
Environment, a hardware separated chip shielded from attacks to the main perating system. The key functions as a P256
Curve signing key. To generate:

```javascript
Keyri.generateAssociationKey('kuliahin.andrew@gmail.com')
    .then((key) => {
        console.log('CordovaKeyri.generateAssociationKey', key);
        alert('Key generated: ' + key)
    })
    .catch((e) => {
        console.log('CordovaKeyri.generateAssociationKey', e);
    });
```

To look up an existing user's key:

```javascript
Keyri.getAssociationKey('kuliahin.andrew@gmail.com')
    .then((key) => {
        console.log('CordovaKeyri.getAssociationKey', key);
        alert('Association key: ' + key);
    })
    .catch((e) => {
        console.log('CordovaKeyri.getAssociationKey', e);
    });
```

### Keyri QR Auth

QR Auth can be processed by Keyri with a single function call. This process handles scanning the code, generating the session info,
displaying a confirmation screen to the user, and, if the user confirms, sending the encrypted payload you provide to
the Keyri widget in your browser.

```javascript
Keyri.easyKeyriAuth('Payload', 'kulagin.andrew38@gmail.com')
    .then(() => {
        console.log('CordovaKeyri.easyKeyriAuth', 'ok');
        alert('Authorized');
    })
    .catch((e) => {
        console.log('CordovaKeyri.easyKeyriAuth', e);
    });
```

### User Signatures

The association keys can be used to sign data to send to a remote server. If the server has the user's public key (see
above), it can then verify the identity of the user as a security measure. Below is an example of how to create a
signature of some data, passed in as a string

```javascript
Keyri.generateUserSignature('kuliahin.andrew@gmail.com', 'Custom data')
    .then((signature) => {
        console.log('CordovaKeyri.generateUserSignature', signature);
        alert('Signature generated: ' + signature)
    })
    .catch((e) => {
        console.log('CordovaKeyri.generateUserSignature', e);
    });
```

### Fingerprint Events

You can send an event containing a device snapshot to our dashboard. The response you receive will be sent, as
is, to your own backend, where you can utilize our scripts to help you decrypt. See the code sample below
and https://docs.keyri.com/fraud-prevention for more

```javascript
Keyri.sendEvent({publicUserId: 'kuliahin.andrew@gmail.com', eventType: 'visits', success: true})
    .then(() => {
        console.log('CordovaKeyri.sendEvent', 'ok');
        alert('Event sent!');
    })
    .catch((e) => {
        console.log('CordovaKeyri.sendEvent', e);
    });
```

## License

This library is available under paid and free licenses.

* Details of licensing (pricing, etc) are available
  at [https://keyri.com/pricing](https://keyri.com/pricing), or you can contact us
  at [Sales@keyri.com](mailto:Sales@keyri.com).

### Details

What's allowed under the license:

* Free use for any app under the Keyri Developer plan.
* Any modifications as needed to work in your app

What's not allowed under the license:

* Redistribution under a different license
* Removing attribution
* Modifying logos
* Indemnification: using this free software is ‘at your own risk’, so you can’t sue Keyri, Inc. for
  problems caused by this library

### Disclaimer

We care deeply about the quality of our product and rigorously test every piece of functionality we offer. That said,
every integration is different. Every app on the App Store has a different permutation of build settings, compiler
flags, processor requirements, compatability issues etc and it's impossible for us to cover all of those bases, so we
strongly recommend thorough testing of your integration before shipping to production. Please feel free to file a bug
or issue if you notice anything that seems wrong or weird on GitHub 🙂
