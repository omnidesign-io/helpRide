# Superadmin Setup & Management

To ensure security and prevent exposing sensitive email addresses in the open-source codebase, Superadmin privileges are managed directly through the Firestore Database.

## Initial Setup (Required)

1.  Go to the [Firebase Console](https://console.firebase.google.com/project/helpride-omni/firestore).
2.  Navigate to **Firestore Database** -> **Data**.
3.  Click **Start collection**.
4.  **Collection ID**: `super_admins`
5.  **Document ID**: `your-email@example.com` (The email address to grant access).
6.  **Field**:
    -   Field: `active`
    -   Type: `boolean`
    -   Value: `true`
7.  Click **Save**.

## Adding New Superadmins

1.  Go to the `super_admins` collection in Firestore.
2.  Click **Add document**.
3.  **Document ID**: Enter the new Superadmin's email address.
4.  **Field**: `active` (boolean) = `true`.
5.  Save.

## How it Works
The application's Security Rules check this collection. When a user logs in with Google, if their email exists as a document ID in the `super_admins` collection, they are granted permission to write `role: 'superadmin'` to their user profile.
