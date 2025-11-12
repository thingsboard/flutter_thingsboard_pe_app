// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messages.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ThingsBoard';

  @override
  String get home => 'Home';

  @override
  String get alarms => 'Alarms';

  @override
  String get devices => 'Devices';

  @override
  String get more => 'More';

  @override
  String get customers => 'Customers';

  @override
  String get assets => 'Assets';

  @override
  String get auditLogs => 'Audit Logs';

  @override
  String get logout => 'Log Out';

  @override
  String get login => 'Log In';

  @override
  String get logoDefaultValue => 'ThingsBoard Logo';

  @override
  String get loginNotification => 'Login to your account';

  @override
  String get email => 'Email';

  @override
  String get emailRequireText => 'Email is required.';

  @override
  String get emailInvalidText => 'Invalid email format.';

  @override
  String get username => 'username';

  @override
  String get password => 'Password';

  @override
  String get passwordRequireText => 'Password is required.';

  @override
  String get passwordForgotText => 'Forgot Password?';

  @override
  String get passwordReset => 'Reset password';

  @override
  String get passwordResetText =>
      'Enter the email associated with your account and we\'ll send an email with password reset link';

  @override
  String get requestPasswordReset => 'Request password reset';

  @override
  String get passwordResetLinkSuccessfullySentNotification =>
      'Password reset link was successfully sent!';

  @override
  String get emailVersificationSuccessfullySentNotification =>
      'Email verification link was successfully sent!';

  @override
  String get or => 'OR';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get title => 'Title';

  @override
  String get country => 'Country';

  @override
  String get city => 'City';

  @override
  String get stateOrProvince => 'State / Province';

  @override
  String get postalCode => 'Zip / Postal Code';

  @override
  String get address => 'Address';

  @override
  String get address2 => 'Address 2';

  @override
  String get phone => 'Phone';

  @override
  String get alarmClearTitle => 'Clear Alarm';

  @override
  String get alarmClearText => 'Are you sure you want to clear Alarm?';

  @override
  String get alarmAcknowledgeTitle => 'Acknowledge Alarm';

  @override
  String get alarmAcknowledgeText =>
      'Are you sure you want to acknowledge Alarm?';

  @override
  String get assetName => 'Asset name';

  @override
  String get type => 'Type';

  @override
  String get label => 'Label';

  @override
  String get assignedToCustomer => 'Assigned to customer';

  @override
  String get auditLogDetails => 'Audit log details';

  @override
  String get entityType => 'Entity Type';

  @override
  String get actionData => 'Action data';

  @override
  String get failureDetails => 'Failure details';

  @override
  String get allDevices => 'All devices';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get systemAdministrator => 'System Administrator';

  @override
  String get tenantAdministrator => 'Tenant Administrator';

  @override
  String get customer => 'Customer';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'currentPassword';

  @override
  String get currentPasswordRequireText => 'Current password is required.';

  @override
  String get currentPasswordStar => 'Current password *';

  @override
  String get newPassword => 'newPassword';

  @override
  String get newPasswordRequireText => 'New password is required.';

  @override
  String get newPasswordStar => 'New password *';

  @override
  String get newPassword2 => 'newPassword2';

  @override
  String get newPassword2RequireText => 'New password again is required.';

  @override
  String get newPassword2Star => 'New password again *';

  @override
  String get passwordErrorNotification => 'Entered passwords must be same!';

  @override
  String get emailStar => 'Email *';

  @override
  String get firstName => 'firstName';

  @override
  String get firstNameUpper => 'First Name';

  @override
  String get lastName => 'lastName';

  @override
  String get lastNameUpper => 'Last Name';

  @override
  String get profileSuccessNotification => 'Profile successfully updated';

  @override
  String get passwordSuccessNotification => 'Password successfully changed';

  @override
  String get notImplemented => 'Not implemented!';

  @override
  String get listIsEmptyText => 'The list is currently empty.';

  @override
  String get tryAgain => 'Try again';

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
