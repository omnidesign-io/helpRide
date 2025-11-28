# App Theme Documentation

## Overview
The application uses a monochromatic theme based on **Teal** (`Colors.teal`), derived from the bottom navigation bar's primary color. The design philosophy emphasizes cleanliness, neutrality for containers, and strong semantic colors for actions and status.

## Color Palette

### Primary
- **Seed Color**: `Colors.teal`
- **Usage**: Primary actions, active states, key branding elements.

### Backgrounds & Surfaces
- **Scaffold Background**: `Color(0xFFFDFDFD)` (Almost White) - Used for the main page background.
- **Surface (Cards/Containers)**: `Color(0xFFF2F2F2)` (Light Grey) - Used for cards, input fields, and grouped content.
- **Navigation Bar**: `Colors.teal.withOpacity(0.05)` (Very Light Teal Tint) - Distinguishes the nav bar from the grey content containers while maintaining harmony.

### Text
- **On Surface**: Standard Material 3 text colors (Black/Dark Grey).
- **On Primary**: White (for buttons and active states).

### Status Colors
- **Pending**: Orange
- **Accepted/Arrived/Riding**: Blue/Green (Context dependent)
- **Completed**: Green
- **Cancelled**: Red

## Typography
Standard Material 3 typography scale.

## Components

### Buttons
- **ElevatedButton**: Flat style (elevation 0), rounded corners (`kInputBorderRadius`).
- **Input Fields**: Filled style (`Color(0xFFE6E6E6)`), rounded corners, no visible border lines (focus indicated by color/cursor).

### Active Ride Overlay
- **Background**: Saturated Green/Teal (Full width).
- **Text**: White (for high contrast).
- **Action Buttons**: Material 3 style, adapted for dark background.
