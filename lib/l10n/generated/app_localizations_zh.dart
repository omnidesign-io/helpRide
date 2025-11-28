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
  String get adminClaimFailed => '無法獲取管理員權限';

  @override
  String get profileTitle => '個人資料';

  @override
  String get logoutButton => '登出';

  @override
  String get searchCountry => '搜尋國家/地區';

  @override
  String get phoneNumberHint => '電話號碼';

  @override
  String get phoneInfoText => '您的電話號碼將用於 WhatsApp 和通話聯繫。配對成功後才會顯示給對方，僅供聯繫使用。';

  @override
  String get deleteAccountButton => '刪除帳戶';

  @override
  String get deleteAccountTitle => '刪除帳戶';

  @override
  String get deleteAccountMessage => '您確定要刪除您的帳戶嗎？此操作無法撤銷。您的所有資料將被永久刪除。';

  @override
  String get deleteAccountConfirmation => '輸入 DELETE 以確認';

  @override
  String get deleteAccountError => '刪除帳戶失敗，請重試。';

  @override
  String get deleteAccountActiveRideError => '您有進行中的行程，無法刪除帳戶。';

  @override
  String get deleteConfirmationKeyword => 'DELETE';

  @override
  String get usernameInfoText => '用戶名稱是應用程式中識別您的另一種方式。您可以使用任何喜歡的名稱。';

  @override
  String get telegramInfoText => '您的 Telegram 用戶名將作為配對後聯繫您的另一種方式。';

  @override
  String get privacyInfoText => '在尋找行程或乘客時，公開列表中僅顯示您的用戶名稱。您可以隨時在個人資料設定中刪除帳號。';

  @override
  String get backButton => '返回';

  @override
  String get usernameValidationError => '用戶名稱長度須為 1-20 個字元，僅包含字母、數字、漢字和單個空格。';

  @override
  String get phoneNumberChangeNotSupported => '暫時不支援更改電話號碼。';

  @override
  String get selectCountry => '選擇國家';

  @override
  String get editProfileTitle => '編輯個人資料';

  @override
  String get saveProfileButton => '儲存個人資料';

  @override
  String get profileUpdatedMessage => '個人資料已更新';

  @override
  String get requestRideTitle => '預約車輛';

  @override
  String get pickupLocationLabel => '上車地點';

  @override
  String get gettingLocationMessage => '正在獲取位置...';

  @override
  String get requestNowButton => '立即預約';

  @override
  String get rideRequestedMessage => '已發送預約請求！';

  @override
  String get locationNeededError => '需要位置信息才能預約';

  @override
  String get driverDashboardTitle => '司機儀表板';

  @override
  String get noRidesAvailableMessage => '暫無可用預約';

  @override
  String get riderLabel => '乘客';

  @override
  String get acceptRideButton => '接單';

  @override
  String get rideAcceptedMessage => '已接單！';

  @override
  String get searchingForDriverMessage => '正在尋找司機...';

  @override
  String get driverFoundMessage => '已找到司機！';

  @override
  String get driverLabel => '司機';

  @override
  String get cancelRideButton => '取消預約';

  @override
  String get requestRideButton => '預約車輛';

  @override
  String get destinationLabel => '目的地';

  @override
  String get vehicleTypeLabel => '車輛類型';

  @override
  String get selectVehicleLabel => '選擇車輛';

  @override
  String get youAreOnlineMessage => '您已上線';

  @override
  String get youAreOfflineMessage => '您已離線';

  @override
  String get goOnlineMessage => '上線以查看預約請求';

  @override
  String get noPendingRidesMessage => '附近暫無待處理預約';

  @override
  String get rideIdLabel => '行程 #';

  @override
  String get pickupProximityMessage => '上車點：2 分鐘路程';

  @override
  String get acceptButton => '接單';

  @override
  String get locationUpdatedMessage => '位置已更新！';

  @override
  String get updateMyLocationButton => '更新我的位置';

  @override
  String get homeLabel => '主頁';

  @override
  String get ordersLabel => '訂單';

  @override
  String get settingsLabel => '設定';

  @override
  String get driverSetupTitle => '司機設定';

  @override
  String get vehicleDetailsTitle => '車輛詳情';

  @override
  String get vehicleDetailsSubtitle => '請提供您的車輛詳情，以便乘客識別。';

  @override
  String get vehicleColorLabel => '車身顏色';

  @override
  String get vehicleColorHint => '例如：白色';

  @override
  String get enterColorError => '請輸入顏色';

  @override
  String get licensePlateLabel => '車牌號碼 (選填)';

  @override
  String get licensePlateHelper => '為保障私隱，您可以只輸入部分車牌 (例如：數字部分)。';

  @override
  String get capacityLabel => '載客量 (不含司機)';

  @override
  String get conditionsTitle => '服務選項';

  @override
  String get acceptPetsLabel => '接載寵物？';

  @override
  String get acceptWheelchairsLabel => '接載輪椅？';

  @override
  String get acceptCargoLabel => '接載貨物/行李？';

  @override
  String get cancelButton => '取消';

  @override
  String get saveAndContinueButton => '儲存並繼續';

  @override
  String get selectVehicleTypeError => '請選擇車輛類型';

  @override
  String get saveError => '儲存詳情時發生錯誤：';

  @override
  String get selectVehicleTypeTitle => '選擇車輛類型';

  @override
  String get switchRoleLabel => '切換身份';

  @override
  String get cannotSwitchRoleError => '您有進行中的行程，無法切換身份。';

  @override
  String get orderHistoryTitle => '訂單記錄';

  @override
  String get rideStatusPending => '待處理';

  @override
  String get rideStatusAccepted => '已接單';

  @override
  String get rideStatusArrived => '司機已到達';

  @override
  String get rideStatusRiding => '行程中';

  @override
  String get rideStatusCompleted => '已完成';

  @override
  String get rideStatusCancelled => '已取消';

  @override
  String get usernameChangeLimitError => '用戶名稱每小時只能更改一次。';

  @override
  String usernameChangeCooldownError(Object time) {
    return '您可以在 $time 後再次更改用戶名稱';
  }

  @override
  String get cannotEditProfileError => '您有進行中的行程，無法編輯個人資料。請先完成行程。';

  @override
  String get vehicleTypeSedan => '轎車';

  @override
  String get vehicleTypeVan => '客貨車';

  @override
  String get vehicleTypeSUV => 'SUV';

  @override
  String get vehicleTypeMotorcycle => '電單車';

  @override
  String get vehicleTypeAccessibleVan => '輪椅的士';

  @override
  String get rideOptionsTitle => '行程選項';

  @override
  String get passengerCountLabel => '乘客人數';

  @override
  String get conditionsLabel => '特別需求';

  @override
  String get conditionPets => '寵物';

  @override
  String get conditionWheelchair => '輪椅';

  @override
  String get conditionCargo => '貨物 / 行李';

  @override
  String get selectRideOptionsButton => '選擇選項';

  @override
  String get saveButton => '確認';

  @override
  String get loginRequiredMessage => '請先登入以繼續。';

  @override
  String get goToLoginButton => '前往登入';

  @override
  String get locationPermissionDenied => '需要位置權限才能預約車輛，請在設定中啟用。';

  @override
  String get locationFetchError => '無法取得您的位置，請再試一次。';

  @override
  String get noHistoryMessage => '暫時沒有行程記錄';

  @override
  String get settingsTitle => '設定';

  @override
  String get languageLabel => '語言';

  @override
  String get searchingLocations => '正在搜尋位置...';

  @override
  String get noSuggestionsFound => '沒有建議，您可以保留自己的輸入。';

  @override
  String get aboutTitle => '關於';

  @override
  String get languageTitle => '語言 / Language';

  @override
  String get rideDetailsTitle => '行程詳情';

  @override
  String get confirmCancelMessage => '您確定要取消此行程嗎？';

  @override
  String get yesButton => '是';

  @override
  String get noButton => '否';

  @override
  String get dateLabel => '日期';

  @override
  String get findingDriverMessage => '尋找中...';

  @override
  String get completeRideButton => '完成行程';

  @override
  String get originLabel => '出發地';

  @override
  String get activityHeader => '活動記錄';

  @override
  String get auditActionCreated => '已建立';

  @override
  String get auditActionAccepted => '已接單';

  @override
  String get auditActionArrived => '司機已到達';

  @override
  String get auditActionRiding => '行程中';

  @override
  String get auditActionCompleted => '已完成';

  @override
  String get auditActionCancelled => '已取消';
}
