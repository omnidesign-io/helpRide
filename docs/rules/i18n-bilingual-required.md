# Workspace Rule - Bilingual Support Required (English & HK Traditional Chinese)

You are an Antigravity workspace agent working on the HelpRide app.

**Rule: All user-facing text must be localized in both English and Hong Kong Traditional Chinese.**

## 1. No Hardcoded Strings
-   **NEVER** use hardcoded string literals in UI widgets (e.g., `Text('Hello')`).
-   **ALWAYS** use `AppLocalizations.of(context)!.key` (or `l10n.key`).

## 2. Dual-Language Implementation
-   When adding a new feature or UI element, you **MUST** add the corresponding translation keys to **BOTH**:
    -   `lib/l10n/app_en.arb` (English)
    -   `lib/l10n/app_zh.arb` (or `app_zh_HK.arb`) (Traditional Chinese)
-   For Chinese, use **Hong Kong Traditional Chinese** phrasing (e.g., "的士" instead of "出租车", "登入" instead of "登录").

## 3. Verification
-   After implementing a feature, verify that switching the app language to Chinese updates **ALL** related text.
-   If you see English text while in Chinese mode, it is a **BUG** that must be fixed immediately.

## 4. Context Retention
-   If you are unsure about a translation, ask the user or use a placeholder, but **DO NOT** leave it as hardcoded English.
