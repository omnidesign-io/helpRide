// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HelpRide';

  @override
  String get loginButton => 'Login / Sign Up';

  @override
  String get updateLocationButton => 'Update Location';

  @override
  String get welcomeMessage => 'Connecting communities in times of need.';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get captchaLabel => 'Verify you are human';

  @override
  String get submitButton => 'Submit';

  @override
  String get usernameLabel => 'Username (Required)';

  @override
  String get telegramHandleLabel => 'Telegram Handle (Optional)';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get welcomeBackMessage => 'Welcome back!';

  @override
  String get accountCreatedMessage => 'Account Created!';

  @override
  String get enterPhoneFirstError => 'Please enter phone number first';

  @override
  String get adminLoginButton => 'Admin Login (Google)';

  @override
  String get adminAccessGranted => 'Admin Access Granted!';

  @override
  String get adminClaimFailed => 'Admin Claim Failed (Are you a Superadmin?)';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get saveProfileButton => 'Save Profile';

  @override
  String get profileUpdatedMessage => 'Profile Updated';

  @override
  String get requestRideTitle => 'Request a Ride';

  @override
  String get pickupLocationLabel => 'Pickup Location';

  @override
  String get gettingLocationMessage => 'Getting location...';

  @override
  String get requestNowButton => 'Request Now';

  @override
  String get rideRequestedMessage => 'Ride Requested!';

  @override
  String get locationNeededError => 'Location needed to request ride';

  @override
  String get driverDashboardTitle => 'Driver Dashboard';

  @override
  String get noRidesAvailableMessage => 'No rides available';

  @override
  String get riderLabel => 'Rider';

  @override
  String get acceptRideButton => 'Accept Ride';

  @override
  String get rideAcceptedMessage => 'Ride Accepted!';

  @override
  String get searchingForDriverMessage => 'Searching for driver...';

  @override
  String get driverFoundMessage => 'Driver Found!';

  @override
  String get driverLabel => 'Driver';

  @override
  String get cancelRideButton => 'Cancel Ride';
}
