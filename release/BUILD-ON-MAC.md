# Build the signed Android App Bundle on your Mac

Git commit identity for this handoff: **bilal <bilal@appstree.io>**.
Upload certificate identity: **bilal <bilal@appstree.io>**.
The app’s separately approved public support email remains **zulqarnain.tech9068@gmail.com**.

## Get the project and Android tools

Install the Flutter version pinned in this repository (3.47.9), JDK 17 and Android Studio with the Android SDK. Xcode signing is not required to build an Android AAB.

```sh
git clone https://github.com/BilalYamin127/PickForMe.git
cd PickForMe
git config user.name bilal
git config user.email bilal@appstree.io
flutter doctor --android-licenses
flutter doctor
flutter pub get
```

## Transfer the private upload key securely

A new **RSA-4096** Android upload key has already been created, alias `pickforme-upload`. Only its public certificate and SHA fingerprints are in GitHub:

- `release/upload-certificate.pem`
- `release/SHA-FINGERPRINTS.txt`
- `release/signing-certificate.txt`

The private keystore and password backup are held outside the repository in the current cloud machine’s private shared folder, `/workspace/shared/pickforme-private-signing/`. Download `pickforme-upload-backup.zip` through a private file-transfer mechanism available to you, then store/extract it in a private folder on the Mac. The archive contains passwords; treat the entire archive as confidential. Do not commit it, attach it to a public release, or send its password in chat.

**A Git clone alone does not contain the private key needed to sign.** If you cannot access the private backup, arrange its transfer before building. Do not create a different key for later updates after Play has registered this key.

Once the key is on your Mac:

```sh
python3 tools/configure_android_signing.py \
  --keystore "$HOME/Private/PickForMe/pickforme-upload.jks"
```

The helper prompts for the passwords, verifies that the certificate matches the repository, and writes an ignored `android/key.properties` with owner-only file permissions. Alternatively, fill out `android/key.properties.example` locally. Keep the original backup in private storage.

## Validate and build

```sh
flutter analyze
flutter test
flutter build appbundle --release --build-name 1.0.0 --build-number 1
jarsigner -verify build/app/outputs/bundle/release/app-release.aab
```

Your AAB will be at `build/app/outputs/bundle/release/app-release.aab`. Use version code `1` only for the first upload; increase it for later uploads. No completed AAB from this cloud session is included in this handoff; the local build was stopped at your request.

The signing certificate is self-signed; a trust-chain warning from `jarsigner` is expected for an Android upload key. It must still report that the archive’s signature verifies. The Play Console performs the final validation.

## Remaining Play Console steps

- Enable GitHub Pages using **Settings → Pages → Deploy from a branch → main → /docs → Save**. The intended policy URL is `https://bilalyamin127.github.io/PickForMe/privacy-policy/`; hosting activation was blocked for this integration, so verify the URL after enabling Pages.
- The signed GitHub Actions workflow is available, but its four private signing secrets are **not configured**; the integration received HTTP 403. Configure them yourself if you want CI-signed builds. Local Mac signing does not require those secrets.
- Upload the AAB and the existing store assets to the closed-testing track. The app has not been submitted to Play from this session because browser access was unavailable.
