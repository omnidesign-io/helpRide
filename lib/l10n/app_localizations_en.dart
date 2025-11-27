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
}
