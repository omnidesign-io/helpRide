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

  @override
  String get requestRideButton => 'Request Ride';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get vehicleTypeLabel => 'Vehicle Type';

  @override
  String get selectVehicleLabel => 'Select Vehicle';

  @override
  String get passengerCountLabel => 'Passengers';

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
}
