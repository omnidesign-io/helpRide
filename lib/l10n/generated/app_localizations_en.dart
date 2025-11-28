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
  String get adminClaimFailed => 'Failed to claim admin access';

  @override
  String get profileTitle => 'Profile';

  @override
  String get logoutButton => 'Logout';

  @override
  String get searchCountry => 'Search country';

  @override
  String get phoneNumberHint => 'Phone Number';

  @override
  String get phoneInfoText =>
      'Your number will be used for WhatsApp and calls from the people you match. It will only be displayed to the other party after matching, for contact purposes.';

  @override
  String get deleteAccountButton => 'Delete Account';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountMessage =>
      'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently removed.';

  @override
  String get deleteAccountConfirmation => 'Type DELETE to confirm';

  @override
  String get deleteAccountError =>
      'Failed to delete account. Please try again.';

  @override
  String get deleteAccountActiveRideError =>
      'Cannot delete account while you have active rides.';

  @override
  String get deleteConfirmationKeyword => 'DELETE';

  @override
  String get usernameInfoText =>
      'Username is another way to quickly identify you inside the app. It can be anything you prefer.';

  @override
  String get telegramInfoText =>
      'Your Telegram handle will be an alternative way to contact you after matching you with another party.';

  @override
  String get privacyInfoText =>
      'Only your username will be visible on public listings when looking for a ride or looking for passengers. You may delete your account entirely anytime inside profile settings.';

  @override
  String get backButton => 'Back';

  @override
  String get usernameValidationError =>
      'Username must be 1-20 characters long, containing only letters, numbers, Chinese characters, and single spaces.';

  @override
  String get phoneNumberChangeNotSupported =>
      'Changing phone number is not supported at the moment.';

  @override
  String get selectCountry => 'Select Country';

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

  @override
  String get requestRideButton => 'Request Ride';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get vehicleTypeLabel => 'Vehicle Type';

  @override
  String get selectVehicleLabel => 'Select Vehicle';

  @override
  String get youAreOnlineMessage => 'You are ONLINE';

  @override
  String get youAreOfflineMessage => 'You are OFFLINE';

  @override
  String get goOnlineMessage => 'Go online to see requests';

  @override
  String get noPendingRidesMessage => 'No pending rides nearby';

  @override
  String get rideIdLabel => 'Ride #';

  @override
  String get pickupProximityMessage => 'Pickup: 2 mins away';

  @override
  String get acceptButton => 'Accept';

  @override
  String get locationUpdatedMessage => 'Location Updated!';

  @override
  String get updateMyLocationButton => 'Update My Location';

  @override
  String get homeLabel => 'Home';

  @override
  String get ordersLabel => 'Orders';

  @override
  String get settingsLabel => 'Settings';

  @override
  String get driverSetupTitle => 'Driver Setup';

  @override
  String get vehicleDetailsTitle => 'Vehicle Details';

  @override
  String get vehicleDetailsSubtitle =>
      'Please provide some details about your vehicle to help riders identify you.';

  @override
  String get vehicleColorLabel => 'Vehicle Color';

  @override
  String get vehicleColorHint => 'e.g. White';

  @override
  String get enterColorError => 'Please enter a color';

  @override
  String get licensePlateLabel => 'License Plate (Optional)';

  @override
  String get licensePlateHelper =>
      'For privacy, you may enter only part of the plate (e.g., numbers only).';

  @override
  String get capacityLabel => 'Capacity (excluding driver)';

  @override
  String get conditionsTitle => 'Conditions';

  @override
  String get acceptPetsLabel => 'Accept Pets?';

  @override
  String get acceptWheelchairsLabel => 'Accept Wheelchairs?';

  @override
  String get acceptCargoLabel => 'Accept Cargo/Luggage?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveAndContinueButton => 'Save & Continue';

  @override
  String get selectVehicleTypeError => 'Please select a vehicle type';

  @override
  String get saveError => 'Error saving details: ';

  @override
  String get selectVehicleTypeTitle => 'Select Vehicle Type';

  @override
  String get switchRoleLabel => 'Switch Role';

  @override
  String get cannotSwitchRoleError =>
      'Cannot switch role while you have an active ride.';

  @override
  String get orderHistoryTitle => 'Order History';

  @override
  String get rideStatusPending => 'PENDING';

  @override
  String get rideStatusAccepted => 'ACCEPTED';

  @override
  String get rideStatusArrived => 'ARRIVED';

  @override
  String get rideStatusRiding => 'RIDING';

  @override
  String get rideStatusCompleted => 'COMPLETED';

  @override
  String get rideStatusCancelled => 'CANCELLED';

  @override
  String get usernameChangeLimitError =>
      'Username can be changed once every hour.';

  @override
  String usernameChangeCooldownError(Object time) {
    return 'You can change your username again in $time';
  }

  @override
  String get cannotEditProfileError =>
      'You cannot edit your profile while you have an active ride. Please complete your ride first.';

  @override
  String get vehicleTypeSedan => 'Sedan';

  @override
  String get vehicleTypeVan => 'Van';

  @override
  String get vehicleTypeSUV => 'SUV';

  @override
  String get vehicleTypeMotorcycle => 'Motorcycle';

  @override
  String get vehicleTypeAccessibleVan => 'Wheelchair Accessible Van';

  @override
  String get rideOptionsTitle => 'Ride Options';

  @override
  String get passengerCountLabel => 'Passengers';

  @override
  String get conditionsLabel => 'Conditions';

  @override
  String get conditionPets => 'Pets';

  @override
  String get conditionWheelchair => 'Wheelchair';

  @override
  String get conditionCargo => 'Cargo / Luggage';

  @override
  String get selectRideOptionsButton => 'Select Options';

  @override
  String get saveButton => 'Confirm';

  @override
  String get loginRequiredMessage => 'Please log in to continue.';

  @override
  String get goToLoginButton => 'Go to Login';

  @override
  String get locationPermissionDenied =>
      'Location permission is required to request rides. Please enable it in settings.';

  @override
  String get locationFetchError =>
      'Unable to fetch your location. Please try again.';

  @override
  String get noHistoryMessage => 'No ride history yet';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get searchingLocations => 'Searching locations...';

  @override
  String get noSuggestionsFound => 'No suggestions. You can keep your input.';

  @override
  String get aboutTitle => 'About';

  @override
  String get languageTitle => 'Language / 語言';

  @override
  String get rideDetailsTitle => 'Ride Details';

  @override
  String get confirmCancelMessage =>
      'Are you sure you want to cancel this ride?';

  @override
  String get yesButton => 'Yes';

  @override
  String get noButton => 'No';

  @override
  String get dateLabel => 'Date';

  @override
  String get findingDriverMessage => 'Finding...';

  @override
  String get completeRideButton => 'Complete Ride';

  @override
  String get originLabel => 'Origin';

  @override
  String get activityHeader => 'Activity';

  @override
  String get auditActionCreated => 'Created';

  @override
  String get auditActionAccepted => 'Accepted';

  @override
  String get auditActionArrived => 'Arrived';

  @override
  String get auditActionRiding => 'Riding';

  @override
  String get auditActionCompleted => 'Completed';

  @override
  String get auditActionCancelled => 'Cancelled';
}
