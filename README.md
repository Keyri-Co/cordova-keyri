## **System Requirements**

*   iOS 14+, Swift 5.3
*   Android API level 23 or higher, AndroidX, Kotlin coroutines compatability


For detailed documentation on how to set up Deeplinking


## **Interacting with the Plugin**


### Initialize Keyri
To initialize the object, simply call the initialize method, and pass in your app key and api key, generated in the Keyri dashboard
```JS
let Keyri;
Keyri.initialize(appKey, publicApiKey, true, (message) => {
    console.log('CordovaKeyri.initialize', message);
}, (e) => {
    console.log('CordovaKeyri.initialize', e);
})
```

### Generate and retrieve association key
The association key is the cryptographic identity we use to identify users. It sits in the Trusted Development Environment, a hardware separated chip shielded from attacks to the main perating system. The key functions as a P256 Curve signing key. To generate:
```JS
Keyri.generateAssociationKey('kuliahin.andrew@gmail.com', (key) => {
    console.log('CordovaKeyri.generateAssociationKey', key);
    alert('Key generated: ' + key)
}, (e) => {
    console.log('CordovaKeyri.generateAssociationKey', e);
})
```

To look up an existing user's key:
```JS
  Keyri.getAssociationKey('kuliahin.andrew@gmail.com', (key) => {
      console.log('CordovaKeyri.getAssociationKey', key);
      alert('Association key: ' + key);
  }, (e) => {
      console.log('CordovaKeyri.getAssociationKey', e);
  })
```

### Enable QR Auth
QR Auth can be enabled with a single function call. This process handles scanning the code, generating the session info, displaying a confirmation screen to the user, and, should the user confirm, sending the encrypted payload the developer provides to the Keyri widget in your browser.
```JS
  Keyri.easyKeyriAuth(appKey, publicAppKey, 'Payload', 'kulagin.andrew38@gmail.com', () => {
      console.log('CordovaKeyri.easyKeyriAuth', 'ok');
      alert('Authorized');
  }, (e) => {
      console.log('CordovaKeyri.easyKeyriAuth', e);
  })
```

### User Signatures
The association keys can be used to sign data to send to a remote server. If the server has the user's public key (see above), it can then verify the identity of the user as a security measure. Below is an example of how to create a signature of some data, passed in as a string
```JS
  Keyri.getUserSignature('kuliahin.andrew@gmail.com', 'Custom data', (signature) => {
      console.log('CordovaKeyri.getUserSignature', signature);
      alert('Signature generated: ' + signature);
  }, (e) => {
      console.log('CordovaKeyri.getUserSignature', e);
  })
```

## License

This library is available under paid and free licenses. See the [LICENSE](LICENSE.txt) file for the
full license text.

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

We care deeply about the quality of our product and rigorously test every piece of functionality we offer. That said, every integration is different. Every app on the App Store has a different permutation of build settings, compiler flags, processor requirements, compatability issues etc and it's impossible for us to cover all of those bases, so we strongly recommend thourough testing of your integration before shipping to production. Please feel free to file a bug or issue if you notice anything that seems wrong or weird on GitHub 🙂

<https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk/issues>
