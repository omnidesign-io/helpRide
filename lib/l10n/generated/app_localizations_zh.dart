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

  @override
  String get usernameLabel => '用戶名稱 (必填)';

  @override
  String get telegramHandleLabel => 'Telegram 用戶名 (選填)';

  @override
  String get signUpButton => '註冊';

  @override
  String get welcomeBackMessage => '歡迎回來！';

  @override
  String get accountCreatedMessage => '帳戶已建立！';

  @override
  String get enterPhoneFirstError => '請先輸入電話號碼';

  @override
  String get adminLoginButton => '管理員登入 (Google)';

  @override
  String get adminAccessGranted => '已獲得管理員權限！';

  @override
  String get adminClaimFailed => '無法獲得管理員權限 (您是超級管理員嗎？)';

  @override
  String get editProfileTitle => '編輯個人資料';

  @override
  String get saveProfileButton => '儲存個人資料';

  @override
  String get profileUpdatedMessage => '個人資料已更新';
}
