import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HelpRide'**
  String get appTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login / Sign Up'**
  String get loginButton;

  /// No description provided for @updateLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get updateLocationButton;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Connecting communities in times of need.'**
  String get welcomeMessage;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @captchaLabel.
  ///
  /// In en, this message translates to:
  /// **'Verify you are human'**
  String get captchaLabel;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username (Required)'**
  String get usernameLabel;

  /// No description provided for @telegramHandleLabel.
  ///
  /// In en, this message translates to:
  /// **'Telegram Handle (Optional)'**
  String get telegramHandleLabel;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @welcomeBackMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBackMessage;

  /// No description provided for @accountCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Account Created!'**
  String get accountCreatedMessage;

  /// No description provided for @enterPhoneFirstError.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number first'**
  String get enterPhoneFirstError;

  /// No description provided for @adminLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Admin Login (Google)'**
  String get adminLoginButton;

  /// No description provided for @adminAccessGranted.
  ///
  /// In en, this message translates to:
  /// **'Admin Access Granted!'**
  String get adminAccessGranted;

  /// No description provided for @adminClaimFailed.
  ///
  /// In en, this message translates to:
  /// **'Admin Claim Failed (Are you a Superadmin?)'**
  String get adminClaimFailed;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @saveProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfileButton;

  /// No description provided for @profileUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated'**
  String get profileUpdatedMessage;

  /// No description provided for @requestRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Request a Ride'**
  String get requestRideTitle;

  /// No description provided for @pickupLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocationLabel;

  /// No description provided for @gettingLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get gettingLocationMessage;

  /// No description provided for @requestNowButton.
  ///
  /// In en, this message translates to:
  /// **'Request Now'**
  String get requestNowButton;

  /// No description provided for @rideRequestedMessage.
  ///
  /// In en, this message translates to:
  /// **'Ride Requested!'**
  String get rideRequestedMessage;

  /// No description provided for @locationNeededError.
  ///
  /// In en, this message translates to:
  /// **'Location needed to request ride'**
  String get locationNeededError;

  /// No description provided for @driverDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Dashboard'**
  String get driverDashboardTitle;

  /// No description provided for @noRidesAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'No rides available'**
  String get noRidesAvailableMessage;

  /// No description provided for @riderLabel.
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get riderLabel;

  /// No description provided for @acceptRideButton.
  ///
  /// In en, this message translates to:
  /// **'Accept Ride'**
  String get acceptRideButton;

  /// No description provided for @rideAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Ride Accepted!'**
  String get rideAcceptedMessage;

  /// No description provided for @searchingForDriverMessage.
  ///
  /// In en, this message translates to:
  /// **'Searching for driver...'**
  String get searchingForDriverMessage;

  /// No description provided for @driverFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver Found!'**
  String get driverFoundMessage;

  /// No description provided for @driverLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverLabel;

  /// No description provided for @cancelRideButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancelRideButton;

  /// No description provided for @requestRideButton.
  ///
  /// In en, this message translates to:
  /// **'Request Ride'**
  String get requestRideButton;

  /// No description provided for @destinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destinationLabel;

  /// No description provided for @vehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleTypeLabel;

  /// No description provided for @selectVehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicleLabel;

  /// No description provided for @passengerCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengerCountLabel;

  /// No description provided for @youAreOnlineMessage.
  ///
  /// In en, this message translates to:
  /// **'You are ONLINE'**
  String get youAreOnlineMessage;

  /// No description provided for @youAreOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'You are OFFLINE'**
  String get youAreOfflineMessage;

  /// No description provided for @goOnlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Go online to see requests'**
  String get goOnlineMessage;

  /// No description provided for @noPendingRidesMessage.
  ///
  /// In en, this message translates to:
  /// **'No pending rides nearby'**
  String get noPendingRidesMessage;

  /// No description provided for @rideIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Ride #'**
  String get rideIdLabel;

  /// No description provided for @pickupProximityMessage.
  ///
  /// In en, this message translates to:
  /// **'Pickup: 2 mins away'**
  String get pickupProximityMessage;

  /// No description provided for @acceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptButton;

  /// No description provided for @locationUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Location Updated!'**
  String get locationUpdatedMessage;

  /// No description provided for @updateMyLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Update My Location'**
  String get updateMyLocationButton;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @ordersLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersLabel;

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @driverSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Setup'**
  String get driverSetupTitle;

  /// No description provided for @vehicleDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetailsTitle;

  /// No description provided for @vehicleDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please provide some details about your vehicle to help riders identify you.'**
  String get vehicleDetailsSubtitle;

  /// No description provided for @vehicleColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Color'**
  String get vehicleColorLabel;

  /// No description provided for @vehicleColorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. White'**
  String get vehicleColorHint;

  /// No description provided for @enterColorError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a color'**
  String get enterColorError;

  /// No description provided for @licensePlateLabel.
  ///
  /// In en, this message translates to:
  /// **'License Plate (Optional)'**
  String get licensePlateLabel;

  /// No description provided for @licensePlateHelper.
  ///
  /// In en, this message translates to:
  /// **'For privacy, you may enter only part of the plate (e.g., numbers only).'**
  String get licensePlateHelper;

  /// No description provided for @capacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity (excluding driver)'**
  String get capacityLabel;

  /// No description provided for @conditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditionsTitle;

  /// No description provided for @acceptPetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept Pets?'**
  String get acceptPetsLabel;

  /// No description provided for @acceptWheelchairsLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept Wheelchairs?'**
  String get acceptWheelchairsLabel;

  /// No description provided for @acceptCargoLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept Cargo/Luggage?'**
  String get acceptCargoLabel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveAndContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinueButton;

  /// No description provided for @selectVehicleTypeError.
  ///
  /// In en, this message translates to:
  /// **'Please select a vehicle type'**
  String get selectVehicleTypeError;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving details: '**
  String get saveError;

  /// No description provided for @selectVehicleTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Type'**
  String get selectVehicleTypeTitle;

  /// No description provided for @switchRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Switch Role'**
  String get switchRoleLabel;

  /// No description provided for @cannotSwitchRoleError.
  ///
  /// In en, this message translates to:
  /// **'Cannot switch role while you have an active ride.'**
  String get cannotSwitchRoleError;

  /// No description provided for @orderHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistoryTitle;

  /// No description provided for @rideStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get rideStatusPending;

  /// No description provided for @rideStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'ACCEPTED'**
  String get rideStatusAccepted;

  /// No description provided for @rideStatusArrived.
  ///
  /// In en, this message translates to:
  /// **'ARRIVED'**
  String get rideStatusArrived;

  /// No description provided for @rideStatusRiding.
  ///
  /// In en, this message translates to:
  /// **'RIDING'**
  String get rideStatusRiding;

  /// No description provided for @rideStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get rideStatusCompleted;

  /// No description provided for @rideStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get rideStatusCancelled;

  /// No description provided for @usernameChangeLimitError.
  ///
  /// In en, this message translates to:
  /// **'Username can be changed once every hour.'**
  String get usernameChangeLimitError;

  /// No description provided for @usernameChangeCooldownError.
  ///
  /// In en, this message translates to:
  /// **'You can change your username again in {time}'**
  String usernameChangeCooldownError(Object time);

  /// No description provided for @cannotEditProfileError.
  ///
  /// In en, this message translates to:
  /// **'You cannot edit your profile while you have an active ride. Please complete your ride first.'**
  String get cannotEditProfileError;

  /// No description provided for @vehicleTypeSedan.
  ///
  /// In en, this message translates to:
  /// **'Sedan'**
  String get vehicleTypeSedan;

  /// No description provided for @vehicleTypeVan.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get vehicleTypeVan;

  /// No description provided for @vehicleTypeSUV.
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get vehicleTypeSUV;

  /// No description provided for @vehicleTypeMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get vehicleTypeMotorcycle;

  /// No description provided for @vehicleTypeAccessibleVan.
  ///
  /// In en, this message translates to:
  /// **'Wheelchair Accessible Van'**
  String get vehicleTypeAccessibleVan;

  /// No description provided for @rideOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride Options'**
  String get rideOptionsTitle;

  /// No description provided for @conditionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditionsLabel;

  /// No description provided for @conditionPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get conditionPets;

  /// No description provided for @conditionWheelchair.
  ///
  /// In en, this message translates to:
  /// **'Wheelchair'**
  String get conditionWheelchair;

  /// No description provided for @conditionCargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo / Luggage'**
  String get conditionCargo;

  /// No description provided for @selectRideOptionsButton.
  ///
  /// In en, this message translates to:
  /// **'Select Options'**
  String get selectRideOptionsButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get saveButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
