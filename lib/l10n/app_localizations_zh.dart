// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'HelpRide';

  @override
  String get loginButton => '登入 / 註冊';

  @override
  String get updateLocationButton => '更新位置';

  @override
  String get welcomeMessage => '危難時刻，連結社區。';

  @override
  String get phoneNumberLabel => '電話號碼';

  @override
  String get captchaLabel => '驗證';

  @override
  String get submitButton => '提交';
}
