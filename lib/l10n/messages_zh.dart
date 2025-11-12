// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messages.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Thingsboard';

  @override
  String get home => '主页';

  @override
  String get alarms => '告警';

  @override
  String get devices => '设备';

  @override
  String get more => '更多';

  @override
  String get customers => '客户';

  @override
  String get assets => 'Assets';

  @override
  String get auditLogs => '审计报告';

  @override
  String get logout => '登出';

  @override
  String get login => '登录';

  @override
  String get logoDefaultValue => 'Thingsboard Logo';

  @override
  String get loginNotification => '登录你的账号';

  @override
  String get email => 'Email';

  @override
  String get emailRequireText => '输入Email';

  @override
  String get emailInvalidText => 'Email格式错误';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get passwordRequireText => '输入密码';

  @override
  String get passwordForgotText => '忘记密码?';

  @override
  String get passwordReset => '重置密码';

  @override
  String get passwordResetText => '输入和账号关联的Email，我们将发送一个密码重置链接到的Email';

  @override
  String get requestPasswordReset => '要求重置密码';

  @override
  String get passwordResetLinkSuccessfullySentNotification => '密码重置链接已发送';

  @override
  String get emailVersificationSuccessfullySentNotification =>
      'Email verification link was successfully sent!';

  @override
  String get or => '或';

  @override
  String get no => '否';

  @override
  String get yes => '是';

  @override
  String get title => '标题';

  @override
  String get country => '国家';

  @override
  String get city => '城市';

  @override
  String get stateOrProvince => '州 / 省';

  @override
  String get postalCode => '邮编';

  @override
  String get address => '地址';

  @override
  String get address2 => '地址 2';

  @override
  String get phone => '电话';

  @override
  String get alarmClearTitle => '清除告警';

  @override
  String get alarmClearText => '你确定要清除告警吗?';

  @override
  String get alarmAcknowledgeTitle => '确认告警';

  @override
  String get alarmAcknowledgeText => '你确定要确认告警吗?';

  @override
  String get assetName => '资产名';

  @override
  String get type => '类型';

  @override
  String get label => '标签';

  @override
  String get assignedToCustomer => '分配给客户';

  @override
  String get auditLogDetails => '审计日志详情';

  @override
  String get entityType => '实体类型';

  @override
  String get actionData => '动作数据';

  @override
  String get failureDetails => '失败详情';

  @override
  String get allDevices => '所有设备';

  @override
  String get active => '激活';

  @override
  String get inactive => '失活';

  @override
  String get systemAdministrator => '系统管理员';

  @override
  String get tenantAdministrator => '租户管理员';

  @override
  String get customer => '客户';

  @override
  String get changePassword => '修改密码';

  @override
  String get currentPassword => '当前密码';

  @override
  String get currentPasswordRequireText => '输入当前密码';

  @override
  String get currentPasswordStar => '当前密码 *';

  @override
  String get newPassword => '新密码';

  @override
  String get newPasswordRequireText => '输入新密码';

  @override
  String get newPasswordStar => '新密码 *';

  @override
  String get newPassword2 => '新密码2';

  @override
  String get newPassword2RequireText => '再次输入新密码';

  @override
  String get newPassword2Star => '再次输入新密码 *';

  @override
  String get passwordErrorNotification => '输入的密码必须相同';

  @override
  String get emailStar => 'Email *';

  @override
  String get firstName => '名';

  @override
  String get firstNameUpper => '名';

  @override
  String get lastName => '姓';

  @override
  String get lastNameUpper => '姓';

  @override
  String get profileSuccessNotification => '配置更新成功';

  @override
  String get passwordSuccessNotification => '密码修改成功';

  @override
  String get notImplemented => '未实现!';

  @override
  String get listIsEmptyText => '列表当前为空';

  @override
  String get tryAgain => '再试一次';

  @override
  String get verifyYourIdentity => 'Verify your identity';

  @override
  String get continueText => 'Continue';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCodeWait(num time) {
    String _temp0 = intl.Intl.pluralLogic(
      time,
      locale: localeName,
      other: '$time seconds',
      one: '1 second',
    );
    return 'Resend code in $_temp0';
  }

  @override
  String get totpAuthDescription =>
      'Please enter the security code from your authenticator app.';

  @override
  String smsAuthDescription(Object contact) {
    return 'A security code has been sent to your phone at $contact.';
  }

  @override
  String emailAuthDescription(Object contact) {
    return 'A security code has been sent to your email address at $contact.';
  }

  @override
  String get backupCodeAuthDescription =>
      'Please enter one of your backup codes.';

  @override
  String get verificationCodeInvalid => 'Invalid verification code format';

  @override
  String get toptAuthPlaceholder => 'Code';

  @override
  String get smsAuthPlaceholder => 'SMS code';

  @override
  String get emailAuthPlaceholder => 'Email code';

  @override
  String get backupCodeAuthPlaceholder => 'Backup code';

  @override
  String get verificationCodeIncorrect => 'Verification code is incorrect';

  @override
  String get verificationCodeManyRequest =>
      'Too many requests check verification code';

  @override
  String get tryAnotherWay => 'Try another way';

  @override
  String get selectWayToVerify => 'Select a way to verify';

  @override
  String get mfaProviderTopt => 'Authenticator app';

  @override
  String get mfaProviderSms => 'SMS';

  @override
  String get mfaProviderEmail => 'Email';

  @override
  String get mfaProviderBackupCode => 'Backup code';

  @override
  String get newUserText => 'New User?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get emailVerification => 'Email verification';

  @override
  String get emailVerificationSentText =>
      'An email with verification details was sent to the specified email address ';

  @override
  String get emailVerificationInstructionsText =>
      'Please follow instructions provided in the email in order to complete your sign up procedure. Note: if you haven\'t seen the email for a while, please check your \'spam\' folder or try to resend email by clicking \'Resend\' button.';

  @override
  String get resend => 'Resend';

  @override
  String get activatingAccount => 'Activating account...';

  @override
  String get accountActivated => 'Account successfully activated!';

  @override
  String get emailVerified => 'Email verified';

  @override
  String get activatingAccountText =>
      'Your account is currently activating.\nPlease wait...';

  @override
  String accountActivatedText(Object appTitle) {
    return 'Congratulations!\nYour $appTitle account has been activated.\nNow you can login to your $appTitle space.';
  }

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get cancel => 'Cancel';

  @override
  String get accept => 'Accept';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get firstNameStar => 'First name *';

  @override
  String get firstNameRequireText => 'First name is required.';

  @override
  String get lastNameStar => 'Last name *';

  @override
  String get lastNameRequireText => 'Last name is required.';

  @override
  String get createPasswordStar => 'Create a password *';

  @override
  String get repeatPasswordStar => 'Repeat your password *';

  @override
  String get imNotARobot => 'I\'m not a robot';

  @override
  String get signUp => 'Sign up';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get invalidPasswordLengthMessage =>
      'Your password must be at least 6 characters long';

  @override
  String get confirmNotRobotMessage =>
      'You must confirm that you are not a robot';

  @override
  String get acceptPrivacyPolicyMessage => 'You must accept our Privacy Policy';

  @override
  String get acceptTermsOfUseMessage => 'You must accept our Terms of Use';

  @override
  String get inactiveUserAlreadyExists => 'Inactive user already exists';

  @override
  String get inactiveUserAlreadyExistsMessage =>
      'There is already registered user with unverified email address.\nClick \'Resend\' button if you wish to resend verification email.';

  @override
  String get assignee => 'Assignee';

  @override
  String get alarmTypes => 'Alarm types';

  @override
  String get details => 'Details';

  @override
  String get status => 'Status';

  @override
  String get severity => 'Severity';

  @override
  String get originator => 'Originator';

  @override
  String get startTime => 'Start time';

  @override
  String get duration => 'Duration';

  @override
  String get days => 'days';

  @override
  String get hours => 'hours';

  @override
  String get minutes => 'minutes';

  @override
  String get seconds => 'seconds';

  @override
  String get viewDashboard => 'View Dashboard';

  @override
  String get activity => 'Activity';

  @override
  String get addCommentMessage => 'Add a comment...';

  @override
  String get selectUser => 'Select users';

  @override
  String get assignedToMe => 'Assigned to me';

  @override
  String get clear => 'Clear';

  @override
  String get acknowledge => 'Acknowledge';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get edited => 'Edited';

  @override
  String get deleteComment => 'Delete comment';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryRefiningYourQuery => 'Please try refining your query';

  @override
  String get failedToLoadTheList => 'Failed to load the list';

  @override
  String get tryRefreshing => 'Please try refreshing';

  @override
  String get refresh => 'Refresh';

  @override
  String get users => 'Users';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get failedToLoadAlarmDetails => 'Failed to load alarm details';

  @override
  String get somethingWentWrong => 'Something Went Wrong';

  @override
  String get chooseRegion => 'Choose region';

  @override
  String get selectRegion => 'Select region';

  @override
  String get northAmerica => 'North America';

  @override
  String get europe => 'Europe';

  @override
  String get northAmericaRegionShort => 'N. Virginia';

  @override
  String get europeRegionShort => 'Frankfurt';

  @override
  String get notifications => 'Notifications';

  @override
  String get deviceList => 'Device list';

  @override
  String get dashboards => 'Dashboards';

  @override
  String get isRequiredText => 'is required.';

  @override
  String get updateRequired => 'Update required';

  @override
  String updateTo(Object version) {
    return 'Update to $version';
  }

  @override
  String popTitle(Object deviceName) {
    return 'Enter PIN of $deviceName to confirm proof of possession';
  }

  @override
  String get next => 'Next';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get bleHelpMessage =>
      'To provision your new device, please make sure that your phone’s Bluetooth is turned on and within range of your new device';

  @override
  String get wifiPassword => 'Wi-Fi password';

  @override
  String wifiHelpMessage(Object deviceName) {
    return 'To continue setup of your device $deviceName, please provide your Network\'s credentials.';
  }

  @override
  String wifiPasswordMessage(Object network) {
    return 'Enter password for $network';
  }

  @override
  String get deviceNotFoundMessage =>
      'Devices not found. Please make sure that your phone’s Bluetooth is turned on and within range of your new device.';

  @override
  String permissionsNotEnoughMessage(Object permissions) {
    return 'You don\'t have enough permissions for \"$permissions\" to proceed. Please grant the required permissions and tap \"Try Again\".';
  }

  @override
  String get sendingWifiCredentials => 'Sending Wi-Fi credentials';

  @override
  String get confirmingWifiConnection => 'Confirming Wi-Fi connection';

  @override
  String get provisionedSuccessfully =>
      'Device has been successfully provisioned';

  @override
  String get returnToDashboard => 'Return to dashboard';

  @override
  String cannotEstablishSession(Object deviceName) {
    return 'Cannot establish session with device $deviceName. Please try again';
  }

  @override
  String get claimingDevice => 'Claiming device';

  @override
  String get claimingDeviceDone => 'Device claiming done';

  @override
  String get claimingMessageSuccess => 'Device has been\nsuccessfully claimed';

  @override
  String openAppSettingsToGrantPermissionMessage(Object permissions) {
    return 'You don\'t have enough permissions for \"$permissions\" to proceed. Please open app settings, grant permissions and trap \"Try Again\".';
  }
}

/// The translations for Chinese, as used in China (`zh_CN`).
class SZhCn extends SZh {
  SZhCn() : super('zh_CN');

  @override
  String get appTitle => 'Thingsboard';

  @override
  String get home => '主页';

  @override
  String get alarms => '告警';

  @override
  String get devices => '设备';

  @override
  String get more => '更多';

  @override
  String get customers => '客户';

  @override
  String get auditLogs => '审计报告';

  @override
  String get logout => '登出';

  @override
  String get login => '登录';

  @override
  String get logoDefaultValue => 'Thingsboard Logo';

  @override
  String get loginNotification => '登录你的账号';

  @override
  String get email => 'Email';

  @override
  String get emailRequireText => '输入Email';

  @override
  String get emailInvalidText => 'Email格式错误';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get passwordRequireText => '输入密码';

  @override
  String get passwordForgotText => '忘记密码?';

  @override
  String get passwordReset => '重置密码';

  @override
  String get passwordResetText => '输入和账号关联的Email，我们将发送一个密码重置链接到的Email';

  @override
  String get requestPasswordReset => '要求重置密码';

  @override
  String get passwordResetLinkSuccessfullySentNotification => '密码重置链接已发送';

  @override
  String get or => '或';

  @override
  String get no => '否';

  @override
  String get yes => '是';

  @override
  String get title => '标题';

  @override
  String get country => '国家';

  @override
  String get city => '城市';

  @override
  String get stateOrProvince => '州 / 省';

  @override
  String get postalCode => '邮编';

  @override
  String get address => '地址';

  @override
  String get address2 => '地址 2';

  @override
  String get phone => '电话';

  @override
  String get alarmClearTitle => '清除告警';

  @override
  String get alarmClearText => '你确定要清除告警吗?';

  @override
  String get alarmAcknowledgeTitle => '确认告警';

  @override
  String get alarmAcknowledgeText => '你确定要确认告警吗?';

  @override
  String get assetName => '资产名';

  @override
  String get type => '类型';

  @override
  String get label => '标签';

  @override
  String get assignedToCustomer => '分配给客户';

  @override
  String get auditLogDetails => '审计日志详情';

  @override
  String get entityType => '实体类型';

  @override
  String get actionData => '动作数据';

  @override
  String get failureDetails => '失败详情';

  @override
  String get allDevices => '所有设备';

  @override
  String get active => '激活';

  @override
  String get inactive => '失活';

  @override
  String get systemAdministrator => '系统管理员';

  @override
  String get tenantAdministrator => '租户管理员';

  @override
  String get customer => '客户';

  @override
  String get changePassword => '修改密码';

  @override
  String get currentPassword => '当前密码';

  @override
  String get currentPasswordRequireText => '输入当前密码';

  @override
  String get currentPasswordStar => '当前密码 *';

  @override
  String get newPassword => '新密码';

  @override
  String get newPasswordRequireText => '输入新密码';

  @override
  String get newPasswordStar => '新密码 *';

  @override
  String get newPassword2 => '新密码2';

  @override
  String get newPassword2RequireText => '再次输入新密码';

  @override
  String get newPassword2Star => '再次输入新密码 *';

  @override
  String get passwordErrorNotification => '输入的密码必须相同';

  @override
  String get emailStar => 'Email *';

  @override
  String get firstName => '名';

  @override
  String get firstNameUpper => '名';

  @override
  String get lastName => '姓';

  @override
  String get lastNameUpper => '姓';

  @override
  String get profileSuccessNotification => '配置更新成功';

  @override
  String get passwordSuccessNotification => '密码修改成功';

  @override
  String get notImplemented => '未实现!';

  @override
  String get listIsEmptyText => '列表当前为空';

  @override
  String get tryAgain => '再试一次';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class SZhTw extends SZh {
  SZhTw() : super('zh_TW');

  @override
  String get appTitle => 'Thingsboard';

  @override
  String get home => '首頁';

  @override
  String get alarms => '警報';

  @override
  String get devices => '設備';

  @override
  String get more => '更多';

  @override
  String get customers => '客戶';

  @override
  String get assets => '資產';

  @override
  String get auditLogs => '審計日誌';

  @override
  String get logout => '登出';

  @override
  String get login => '登入';

  @override
  String get logoDefaultValue => 'Thingsboard Logo';

  @override
  String get loginNotification => '登入你的帳號';

  @override
  String get email => '電子郵件';

  @override
  String get emailRequireText => '輸入電子郵件';

  @override
  String get emailInvalidText => '電子郵件格式錯誤';

  @override
  String get username => '使用者名稱';

  @override
  String get password => '密碼';

  @override
  String get passwordRequireText => '輸入密碼';

  @override
  String get passwordForgotText => '忘記密碼?';

  @override
  String get passwordReset => '重設密碼';

  @override
  String get passwordResetText => '輸入和帳號關聯的電子郵件，我們將發送一個包含密碼重設連結的電子郵件';

  @override
  String get requestPasswordReset => '要求重設密碼';

  @override
  String get passwordResetLinkSuccessfullySentNotification => '密碼重設連結已發送';

  @override
  String get or => '或';

  @override
  String get no => '否';

  @override
  String get yes => '是';

  @override
  String get title => '標題';

  @override
  String get country => '國家';

  @override
  String get city => '城市';

  @override
  String get stateOrProvince => '州 / 省';

  @override
  String get postalCode => '郵遞區號';

  @override
  String get address => '地址';

  @override
  String get address2 => '地址 2';

  @override
  String get phone => '電話';

  @override
  String get alarmClearTitle => '清除警報';

  @override
  String get alarmClearText => '你確定要清除警報嗎?';

  @override
  String get alarmAcknowledgeTitle => '確認警報';

  @override
  String get alarmAcknowledgeText => '你確定要確認警報嗎?';

  @override
  String get assetName => '資產名稱';

  @override
  String get type => '類型';

  @override
  String get label => '標籤';

  @override
  String get assignedToCustomer => '分派給客戶';

  @override
  String get auditLogDetails => '審計日誌詳情';

  @override
  String get entityType => '實體類型';

  @override
  String get actionData => '動作數據';

  @override
  String get failureDetails => '失敗詳情';

  @override
  String get allDevices => '所有設備';

  @override
  String get active => 'active';

  @override
  String get inactive => 'inactive';

  @override
  String get systemAdministrator => '系統管理員';

  @override
  String get tenantAdministrator => '租戶管理員';

  @override
  String get customer => '客戶';

  @override
  String get changePassword => '修改密碼';

  @override
  String get currentPassword => '目前密碼';

  @override
  String get currentPasswordRequireText => '輸入新密碼';

  @override
  String get currentPasswordStar => '目前密碼 *';

  @override
  String get newPassword => '新密碼';

  @override
  String get newPasswordRequireText => '輸入新密碼';

  @override
  String get newPasswordStar => '新密碼 *';

  @override
  String get newPassword2 => '新密碼2';

  @override
  String get newPassword2RequireText => '再次輸入新密碼';

  @override
  String get newPassword2Star => '再次輸入新密碼 *';

  @override
  String get passwordErrorNotification => '輸入的密碼必須相同';

  @override
  String get emailStar => '電子郵件 *';

  @override
  String get firstName => '名';

  @override
  String get firstNameUpper => '名';

  @override
  String get lastName => '姓';

  @override
  String get lastNameUpper => '姓';

  @override
  String get profileSuccessNotification => '配置更新成功';

  @override
  String get passwordSuccessNotification => '密碼修改成功';

  @override
  String get notImplemented => '未實現!';

  @override
  String get listIsEmptyText => '列表當前為空';

  @override
  String get tryAgain => '再試一次';
}
