# Architecture Overview

## Ride Lifecycle

The ride lifecycle in HelpRide follows a strict state machine to ensure consistency and reliability.

### States

1.  **Pending (`pending`)**
    *   **Trigger**: Rider requests a ride.
    *   **Description**: The ride is created in Firestore and is visible to all available drivers.
    *   **Allowed Actions**:
        *   Rider: Cancel.
        *   Driver: Accept.

2.  **Accepted (`accepted`)**
    *   **Trigger**: A driver accepts a pending ride.
    *   **Description**: The ride is assigned to a specific driver. Contact details are exchanged.
    *   **Allowed Actions**:
        *   Rider: Cancel (Audit trail updated).
        *   Driver: Cancel (Audit trail updated), Arrive.

3.  **Arrived (`arrived`)**
    *   **Trigger**: Driver marks themselves as arrived at the pickup location.
    *   **Description**: Driver is waiting for the passenger.
    *   **Allowed Actions**:
        *   Rider: Cancel.
        *   Driver: Cancel, Start Ride (Move to `riding`).

4.  **Riding (`riding`)**
    *   **Trigger**: Driver starts the trip.
    *   **Description**: The ride is in progress.
    *   **Allowed Actions**:
        *   Driver: Complete.

5.  **Completed (`completed`)**
    *   **Trigger**: Driver marks the ride as finished.
    *   **Description**: The ride has successfully ended. This is a terminal state.
    *   **Allowed Actions**: None (Review/Rating in future).

6.  **Cancelled (`cancelled`)**
    *   **Trigger**: Rider or Driver cancels the ride.
    *   **Description**: The ride was terminated before completion. This is a terminal state.
    *   **Allowed Actions**: None.

### Status Colors
To ensure consistency across the app, the following colors are used for each ride status:

| Status | Color | Hex Code |
| :--- | :--- | :--- |
| **Pending** | Orange | `#FF9800` |
| **Accepted** | Blue | `#2196F3` |
| **Arrived** | Purple | `#9C27B0` |
| **Riding** | Green | `#4CAF50` |
| **Completed** | Grey | `#9E9E9E` |
| **Cancelled** | Red | `#F44336` |

## Critical Action Handling
For critical actions (e.g., booking a ride, payments), we implement a **"Disable-on-Click"** pattern:
1.  **Immediate Feedback**: Set a local loading state (e.g., `_isBooking = true`) *immediately* when the button is pressed.
2.  **Disable UI**: Disable the button to prevent double-clicks while the async operation is starting.
3.  **Reset**: Reset the state in a `finally` block to ensure the UI recovers even if the operation fails.

This is a frontend safeguard that complements backend idempotency checks (like Firestore Transactions).

### Constraints & Invariants

*   **Role Switching**: A user **cannot** switch between Rider and Driver roles if they have an active ride (any state other than `completed` or `cancelled`). This prevents data inconsistency and UI confusion.
*   **Active Ride Limit**: A rider can only have **one** active ride at a time.
*   **Driver Availability**: Drivers are considered "available" whenever they are in Driver Mode and do not have an active ride.

## UX Guidelines

### Navigation
*   **Bottom Navigation Visibility**: The bottom navigation bar should **only** be visible on the top-level screens (e.g., Home, Orders, Settings). For any sub-screens or detailed views (e.g., Ride Details, Vehicle Settings), the bottom navigation must be hidden to focus the user on the current task. Use `rootNavigator: true` when pushing these routes or configure them outside the `ShellRoute`.
