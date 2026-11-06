# Google Play closed-testing preparation

Application ID: `com.bilalyamin.pick_for_me`.
Initial release: **1.0.0**, version code **1**. Increase the version code for every later Play upload.
Public support email: **zulqarnain.tech9068@gmail.com**.
Privacy policy: https://bilalyamin127.github.io/PickForMe/privacy-policy/

For the Mac handoff, start with [BUILD-ON-MAC.md](BUILD-ON-MAC.md). Public SHA-1/SHA-256 values are in [SHA-FINGERPRINTS.txt](SHA-FINGERPRINTS.txt). The private upload key is not stored in GitHub.

## Build signing

Play bundles now require an upload key; there is no debug-signing fallback for `bundleRelease`. Copy `android/key.properties.example` to the ignored `android/key.properties` and set your private credentials, or supply these environment variables:

- `PICKFORME_KEYSTORE_PATH`
- `PICKFORME_STORE_PASSWORD`
- `PICKFORME_KEY_ALIAS`
- `PICKFORME_KEY_PASSWORD`

Then run:

```sh
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release --build-name 1.0.0 --build-number 1
jarsigner -verify build/app/outputs/bundle/release/app-release.aab
```

Upload `build/app/outputs/bundle/release/app-release.aab` to the closed-testing release. `upload-certificate.pem` is a **public certificate**, not the private key, and can identify the upload key during Play setup. Enable Play App Signing using the Console’s offered setup for a new app. The upload key signs bundles sent to Google; Play’s app-signing key signs the APKs delivered to testers.

The upload keystore and its passwords must be backed up privately. They are never committed or attached to a public release. Never share `android/key.properties`.

## Repeatable signed builds in GitHub Actions

The manual **Signed Play App Bundle** workflow produces an AAB artifact. It expects these repository Actions secrets:

- `PICKFORME_UPLOAD_KEYSTORE_BASE64`: base64-encoded private upload keystore.
- `PICKFORME_UPLOAD_STORE_PASSWORD`
- `PICKFORME_UPLOAD_KEY_ALIAS`
- `PICKFORME_UPLOAD_KEY_PASSWORD`

The workflow deletes its temporary key file and uploads only the AAB. The normal CI Android job remains an explicitly opted-in **debug-signed preview APK**, not a Play upload.

## Console handoff

1. Create/open PickForMe using the approved app name and English default language.
2. Copy the listing fields from `store/listing/metadata.json` and the description TXT files.
3. Upload the existing icon, feature graphic and seven phone screenshots under `store/`.
4. Set the public support email and verified privacy-policy URL above.
5. Complete App access, Ads, Data Safety, target audience and content rating using the actual app behavior and your intended audience; see `store/listing/play-console-guide.md`.
6. Create the closed-testing track and its email list. Tester addresses are kept privately and are not included in this public repository.
7. Upload the signed AAB, use `store/listing/release-notes.txt`, choose the intended test countries and review the Console’s validation results.
8. Submit/roll out **closed testing only**. Production release is a separate action.

Console creation, declarations, upload and rollout require an authenticated browser connection. Building this package or publishing the policy page does not perform those Console actions.
