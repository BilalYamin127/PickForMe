# Play Console handoff

Prepared for the current native PickForMe app, version 1.0.0. This is an upload guide, not a completed Console submission. Recheck answers against the exact binary and any SDKs you add before publishing.

## Listing fields

- Default language: English (United States), en-US.
- Name: use `app-name.txt` (30-character maximum).
- Short description: use `short-description.txt` (80-character maximum).
- Full description: use `full-description.txt` (4,000-character maximum).
- App type: App. Suggested category: Tools.
- Price: Free. Current version has no ads or in-app purchases.
- Support email: replace `support@pickforme.example` with a working monitored address. The example address cannot receive email.
- Developer display name: confirm against your own Play Console profile. The policy currently identifies Bilal Yamin.
- Website: optional; leave blank unless you have a real public website.
- Privacy policy: host `../privacy-policy/index.html` at a public HTTPS URL accessible without login. Put that live URL into the Console. A GitHub file-view URL, Word document or PDF download is not a substitute for a public privacy-policy webpage.

## Upload-ready images

| Console field | File | Size |
| --- | --- | --- |
| App icon | `../branding/app-icon-512.png` | 512 × 512 PNG, full bleed |
| Feature graphic | `../branding/feature-graphic-1024x500.png` | 1024 × 500 PNG, opaque |
| Phone screenshots | All seven numbered files in `../screenshots/` | 1080 × 1920 PNG each, 9:16 |

Upload the screenshots in numerical order. Do not upload `asset-overview.jpg` as a screenshot; it is a review contact sheet. Raw unframed screenshots are also available in `../raw-screenshots/` at 1170 × 2532. No tablet, TV, Wear OS or iOS-specific screenshot set is included.

## App access

All features are accessible without login, account, subscription, payment or restricted credentials. Select the unrestricted-access answer matching this behavior. No review account is needed.

## Ads and monetization

Select “No” for contains ads for the current version. There is no billing integration. Do not add claims about future pricing or future absence of ads to the listing.

## Data Safety working answers

- Does the app collect or share any of the required user data types? For the current native binary: **No**, based on its local-only storage and absence of backend, analytics, advertising and tracking SDKs.
- Decision titles/options, saved lists, history and settings are processed on the device and are not transmitted to the developer.
- Sharing only occurs through an explicit user action in the native share sheet. The user selects the recipient app; evaluate it under Google's user-initiated sharing exception rather than declaring automatic developer sharing.
- Email sent voluntarily outside the app to support is processed by the email providers. The privacy policy explains this separately.
- The app has no account-creation feature. Account deletion questions should reflect that. Do not invent an account-deletion URL for an app without accounts.
- If additional encryption, transfer, retention or deletion questions appear conditionally, answer the exact wording. Do not claim app-level database encryption, security certification or independent security review.
- Reassess if you add crash reporting, analytics, ads, cloud backups under your control, authentication, or any new SDK that transmits data.

Google Play definitions and questionnaire wording can change. The developer must verify the final declaration; local storage alone is not developer collection under the current definitions. OS-managed backups and device transfers depend on user/device settings and are explained in the privacy policy.

## Other content declarations

- Content rating: complete the IARC questionnaire truthfully for this general-purpose decision tool. Do not treat any suggested age rating as an issued rating.
- Target audience: choose the actual audience you intend to serve. This package does not make a child-directed/Families declaration on your behalf.
- There is no public user-generated-content feed, messaging community or user account. Users can enter their own text locally.
- There are no cash prizes, betting, wagering, financial services, medical functionality or government affiliation. The wheel is for ordinary random choices, not gambling.
- Complete any Console-specific financial, health, news, government or other declarations using the actual app behavior; these features are not present.

## Release preparation

1. Replace temporary contact details and confirm developer name/policy date.
2. Publish the privacy-policy HTML and verify its URL from another device.
3. Configure your private Android upload keystore; never commit it or its passwords.
4. Build a signed release AAB (`flutter build appbundle --release`). The existing default debug-signed configuration is for previews and must be replaced before Play distribution.
5. Test the final signed build on physical Android devices, including offline use, wheel landing, list selection, sharing and persistence.
6. Upload to an internal testing track, finish Console declarations and review the actual device screenshots.
7. Check current target SDK, testing and account verification requirements shown by Play Console, then submit for review when ready.

## Privacy policy hosting

The policy HTML is standalone and works on ordinary static hosting. If you prefer GitHub Pages, choose a valid Pages source in repository Settings and copy the policy to that source, or add a Pages deployment workflow. Pages has not been enabled or published by this asset task. Keep the hosted page in sync with the editable policy source after replacing the email.
