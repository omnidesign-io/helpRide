# Mapbox Token Guide

This app keeps Mapbox tokens out of the source tree for security. Follow these steps to expose the public token to the Flutter client while keeping any secret tokens (download/protected tokens) off your mobile/web bundles.

1. **Store the public access token in Firestore**
   * Open your Firebase console, go to Firestore and create a collection named `config`.
   * Add a document with ID `mapbox` and a single field: `accessToken` = your `pk.*` Mapbox token.
   * Because the app reads this document through `request.auth != null`, the client needs to sign in (even anonymously) before `mapbox_gl` components can render.
   * The Firestore rule in `firestore.rules` restricts writes, so only you (via the Firebase console or a secure backend) can rotate the token.
2. **Keep protected download tokens secret**
   * If you ever need Mapbox download tokens (`sk.*`), expose them only in trusted build environments—e.g., set `MAPBOX_DOWNLOADS_TOKEN` in `~/.gradle/gradle.properties` or as a CI secret. Do **not** store them in Firestore or in your Flutter source.
3. **Update the app to use the Firestore-stored token**
   * Once the token is saved, the app fetches it inside `ConfigRepository` and passes it to the Mapbox view.
   * The web build will switch from a placeholder grid to a Mapbox map when the token loads, and the autocomplete/search requests also use that token.
4. **Verification**
   * Run `flutter pub get` → `flutter run -d chrome` after deploying the rules so the client can read `config/mapbox`.
   * If you see permission errors, ensure your emulator/device is signed in and the Firestore rule allows reads for authenticated clients.

Since this document lives in `docs/setup/mapbox.md`, it will remain in your repo even if the rest of the Mapbox implementation is temporarily removed.
