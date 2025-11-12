import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'messages_ar.dart';
import 'messages_en.dart';
import 'messages_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/messages.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
    Locale('ar'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ThingsBoard'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @alarms.
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get alarms;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @auditLogs.
  ///
  /// In en, this message translates to:
  /// **'Audit Logs'**
  String get auditLogs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @logoDefaultValue.
  ///
  /// In en, this message translates to:
  /// **'ThingsBoard Logo'**
  String get logoDefaultValue;

  /// No description provided for @loginNotification.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginNotification;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailRequireText.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get emailRequireText;

  /// No description provided for @emailInvalidText.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format.'**
  String get emailInvalidText;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequireText.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get passwordRequireText;

  /// No description provided for @passwordForgotText.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get passwordForgotText;

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get passwordReset;

  /// No description provided for @passwordResetText.
  ///
  /// In en, this message translates to:
  /// **'Enter the email associated with your account and we\'ll send an email with password reset link'**
  String get passwordResetText;

  /// No description provided for @requestPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Request password reset'**
  String get requestPasswordReset;

  /// No description provided for @passwordResetLinkSuccessfullySentNotification.
  ///
  /// In en, this message translates to:
  /// **'Password reset link was successfully sent!'**
  String get passwordResetLinkSuccessfullySentNotification;

  /// No description provided for @emailVersificationSuccessfullySentNotification.
  ///
  /// In en, this message translates to:
  /// **'Email verification link was successfully sent!'**
  String get emailVersificationSuccessfullySentNotification;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @stateOrProvince.
  ///
  /// In en, this message translates to:
  /// **'State / Province'**
  String get stateOrProvince;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Zip / Postal Code'**
  String get postalCode;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @address2.
  ///
  /// In en, this message translates to:
  /// **'Address 2'**
  String get address2;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @alarmClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Alarm'**
  String get alarmClearTitle;

  /// No description provided for @alarmClearText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear Alarm?'**
  String get alarmClearText;

  /// No description provided for @alarmAcknowledgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge Alarm'**
  String get alarmAcknowledgeTitle;

  /// No description provided for @alarmAcknowledgeText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to acknowledge Alarm?'**
  String get alarmAcknowledgeText;

  /// No description provided for @assetName.
  ///
  /// In en, this message translates to:
  /// **'Asset name'**
  String get assetName;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get label;

  /// No description provided for @assignedToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Assigned to customer'**
  String get assignedToCustomer;

  /// No description provided for @auditLogDetails.
  ///
  /// In en, this message translates to:
  /// **'Audit log details'**
  String get auditLogDetails;

  /// No description provided for @entityType.
  ///
  /// In en, this message translates to:
  /// **'Entity Type'**
  String get entityType;

  /// No description provided for @actionData.
  ///
  /// In en, this message translates to:
  /// **'Action data'**
  String get actionData;

  /// No description provided for @failureDetails.
  ///
  /// In en, this message translates to:
  /// **'Failure details'**
  String get failureDetails;

  /// No description provided for @allDevices.
  ///
  /// In en, this message translates to:
  /// **'All devices'**
  String get allDevices;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @systemAdministrator.
  ///
  /// In en, this message translates to:
  /// **'System Administrator'**
  String get systemAdministrator;

  /// No description provided for @tenantAdministrator.
  ///
  /// In en, this message translates to:
  /// **'Tenant Administrator'**
  String get tenantAdministrator;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'currentPassword'**
  String get currentPassword;

  /// No description provided for @currentPasswordRequireText.
  ///
  /// In en, this message translates to:
  /// **'Current password is required.'**
  String get currentPasswordRequireText;

  /// No description provided for @currentPasswordStar.
  ///
  /// In en, this message translates to:
  /// **'Current password *'**
  String get currentPasswordStar;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'newPassword'**
  String get newPassword;

  /// No description provided for @newPasswordRequireText.
  ///
  /// In en, this message translates to:
  /// **'New password is required.'**
  String get newPasswordRequireText;

  /// No description provided for @newPasswordStar.
  ///
  /// In en, this message translates to:
  /// **'New password *'**
  String get newPasswordStar;

  /// No description provided for @newPassword2.
  ///
  /// In en, this message translates to:
  /// **'newPassword2'**
  String get newPassword2;

  /// No description provided for @newPassword2RequireText.
  ///
  /// In en, this message translates to:
  /// **'New password again is required.'**
  String get newPassword2RequireText;

  /// No description provided for @newPassword2Star.
  ///
  /// In en, this message translates to:
  /// **'New password again *'**
  String get newPassword2Star;

  /// No description provided for @passwordErrorNotification.
  ///
  /// In en, this message translates to:
  /// **'Entered passwords must be same!'**
  String get passwordErrorNotification;

  /// No description provided for @emailStar.
  ///
  /// In en, this message translates to:
  /// **'Email *'**
  String get emailStar;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'firstName'**
  String get firstName;

  /// No description provided for @firstNameUpper.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameUpper;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'lastName'**
  String get lastName;

  /// No description provided for @lastNameUpper.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameUpper;

  /// No description provided for @profileSuccessNotification.
  ///
  /// In en, this message translates to:
  /// **'Profile successfully updated'**
  String get profileSuccessNotification;

  /// No description provided for @passwordSuccessNotification.
  ///
  /// In en, this message translates to:
  /// **'Password successfully changed'**
  String get passwordSuccessNotification;

  /// No description provided for @notImplemented.
  ///
  /// In en, this message translates to:
  /// **'Not implemented!'**
  String get notImplemented;

  /// No description provided for @listIsEmptyText.
  ///
  /// In en, this message translates to:
  /// **'The list is currently empty.'**
  String get listIsEmptyText;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @verifyYourIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get verifyYourIdentity;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendCodeWait.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {time,plural, =1{1 second}other{{time} seconds}}'**
  String resendCodeWait(num time);

  /// No description provided for @totpAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter the security code from your authenticator app.'**
  String get totpAuthDescription;

  /// No description provided for @smsAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'A security code has been sent to your phone at {contact}.'**
  String smsAuthDescription(Object contact);

  /// No description provided for @emailAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'A security code has been sent to your email address at {contact}.'**
  String emailAuthDescription(Object contact);

  /// No description provided for @backupCodeAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter one of your backup codes.'**
  String get backupCodeAuthDescription;

  /// No description provided for @verificationCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code format'**
  String get verificationCodeInvalid;

  /// No description provided for @toptAuthPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get toptAuthPlaceholder;

  /// No description provided for @smsAuthPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'SMS code'**
  String get smsAuthPlaceholder;

  /// No description provided for @emailAuthPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Email code'**
  String get emailAuthPlaceholder;

  /// No description provided for @backupCodeAuthPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Backup code'**
  String get backupCodeAuthPlaceholder;

  /// No description provided for @verificationCodeIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Verification code is incorrect'**
  String get verificationCodeIncorrect;

  /// No description provided for @verificationCodeManyRequest.
  ///
  /// In en, this message translates to:
  /// **'Too many requests check verification code'**
  String get verificationCodeManyRequest;

  /// No description provided for @tryAnotherWay.
  ///
  /// In en, this message translates to:
  /// **'Try another way'**
  String get tryAnotherWay;

  /// No description provided for @selectWayToVerify.
  ///
  /// In en, this message translates to:
  /// **'Select a way to verify'**
  String get selectWayToVerify;

  /// No description provided for @mfaProviderTopt.
  ///
  /// In en, this message translates to:
  /// **'Authenticator app'**
  String get mfaProviderTopt;

  /// No description provided for @mfaProviderSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get mfaProviderSms;

  /// No description provided for @mfaProviderEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get mfaProviderEmail;

  /// No description provided for @mfaProviderBackupCode.
  ///
  /// In en, this message translates to:
  /// **'Backup code'**
  String get mfaProviderBackupCode;

  /// No description provided for @newUserText.
  ///
  /// In en, this message translates to:
  /// **'New User?'**
  String get newUserText;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get emailVerification;

  /// No description provided for @emailVerificationSentText.
  ///
  /// In en, this message translates to:
  /// **'An email with verification details was sent to the specified email address '**
  String get emailVerificationSentText;

  /// No description provided for @emailVerificationInstructionsText.
  ///
  /// In en, this message translates to:
  /// **'Please follow instructions provided in the email in order to complete your sign up procedure. Note: if you haven\'t seen the email for a while, please check your \'spam\' folder or try to resend email by clicking \'Resend\' button.'**
  String get emailVerificationInstructionsText;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @activatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Activating account...'**
  String get activatingAccount;

  /// No description provided for @accountActivated.
  ///
  /// In en, this message translates to:
  /// **'Account successfully activated!'**
  String get accountActivated;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// No description provided for @activatingAccountText.
  ///
  /// In en, this message translates to:
  /// **'Your account is currently activating.\nPlease wait...'**
  String get activatingAccountText;

  /// No description provided for @accountActivatedText.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!\nYour {appTitle} account has been activated.\nNow you can login to your {appTitle} space.'**
  String accountActivatedText(Object appTitle);

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @firstNameStar.
  ///
  /// In en, this message translates to:
  /// **'First name *'**
  String get firstNameStar;

  /// No description provided for @firstNameRequireText.
  ///
  /// In en, this message translates to:
  /// **'First name is required.'**
  String get firstNameRequireText;

  /// No description provided for @lastNameStar.
  ///
  /// In en, this message translates to:
  /// **'Last name *'**
  String get lastNameStar;

  /// No description provided for @lastNameRequireText.
  ///
  /// In en, this message translates to:
  /// **'Last name is required.'**
  String get lastNameRequireText;

  /// No description provided for @createPasswordStar.
  ///
  /// In en, this message translates to:
  /// **'Create a password *'**
  String get createPasswordStar;

  /// No description provided for @repeatPasswordStar.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password *'**
  String get repeatPasswordStar;

  /// No description provided for @imNotARobot.
  ///
  /// In en, this message translates to:
  /// **'I\'m not a robot'**
  String get imNotARobot;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @invalidPasswordLengthMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password must be at least 6 characters long'**
  String get invalidPasswordLengthMessage;

  /// No description provided for @confirmNotRobotMessage.
  ///
  /// In en, this message translates to:
  /// **'You must confirm that you are not a robot'**
  String get confirmNotRobotMessage;

  /// No description provided for @acceptPrivacyPolicyMessage.
  ///
  /// In en, this message translates to:
  /// **'You must accept our Privacy Policy'**
  String get acceptPrivacyPolicyMessage;

  /// No description provided for @acceptTermsOfUseMessage.
  ///
  /// In en, this message translates to:
  /// **'You must accept our Terms of Use'**
  String get acceptTermsOfUseMessage;

  /// No description provided for @inactiveUserAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Inactive user already exists'**
  String get inactiveUserAlreadyExists;

  /// No description provided for @inactiveUserAlreadyExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'There is already registered user with unverified email address.\nClick \'Resend\' button if you wish to resend verification email.'**
  String get inactiveUserAlreadyExistsMessage;

  /// No description provided for @assignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get assignee;

  /// No description provided for @alarmTypes.
  ///
  /// In en, this message translates to:
  /// **'Alarm types'**
  String get alarmTypes;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @originator.
  ///
  /// In en, this message translates to:
  /// **'Originator'**
  String get originator;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @viewDashboard.
  ///
  /// In en, this message translates to:
  /// **'View Dashboard'**
  String get viewDashboard;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @addCommentMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addCommentMessage;

  /// No description provided for @selectUser.
  ///
  /// In en, this message translates to:
  /// **'Select users'**
  String get selectUser;

  /// No description provided for @assignedToMe.
  ///
  /// In en, this message translates to:
  /// **'Assigned to me'**
  String get assignedToMe;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @acknowledge.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get acknowledge;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get deleteComment;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryRefiningYourQuery.
  ///
  /// In en, this message translates to:
  /// **'Please try refining your query'**
  String get tryRefiningYourQuery;

  /// No description provided for @failedToLoadTheList.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the list'**
  String get failedToLoadTheList;

  /// No description provided for @tryRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Please try refreshing'**
  String get tryRefreshing;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @failedToLoadAlarmDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load alarm details'**
  String get failedToLoadAlarmDetails;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get somethingWentWrong;

  /// No description provided for @chooseRegion.
  ///
  /// In en, this message translates to:
  /// **'Choose region'**
  String get chooseRegion;

  /// No description provided for @selectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get selectRegion;

  /// No description provided for @northAmerica.
  ///
  /// In en, this message translates to:
  /// **'North America'**
  String get northAmerica;

  /// No description provided for @europe.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get europe;

  /// No description provided for @northAmericaRegionShort.
  ///
  /// In en, this message translates to:
  /// **'N. Virginia'**
  String get northAmericaRegionShort;

  /// No description provided for @europeRegionShort.
  ///
  /// In en, this message translates to:
  /// **'Frankfurt'**
  String get europeRegionShort;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @deviceList.
  ///
  /// In en, this message translates to:
  /// **'Device list'**
  String get deviceList;

  /// No description provided for @dashboards.
  ///
  /// In en, this message translates to:
  /// **'Dashboards'**
  String get dashboards;

  /// No description provided for @isRequiredText.
  ///
  /// In en, this message translates to:
  /// **'is required.'**
  String get isRequiredText;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequired;

  /// No description provided for @updateTo.
  ///
  /// In en, this message translates to:
  /// **'Update to {version}'**
  String updateTo(Object version);

  /// No description provided for @popTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN of {deviceName} to confirm proof of possession'**
  String popTitle(Object deviceName);

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @bleHelpMessage.
  ///
  /// In en, this message translates to:
  /// **'To provision your new device, please make sure that your phone’s Bluetooth is turned on and within range of your new device'**
  String get bleHelpMessage;

  /// No description provided for @wifiPassword.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi password'**
  String get wifiPassword;

  /// No description provided for @wifiHelpMessage.
  ///
  /// In en, this message translates to:
  /// **'To continue setup of your device {deviceName}, please provide your Network\'s credentials.'**
  String wifiHelpMessage(Object deviceName);

  /// No description provided for @wifiPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter password for {network}'**
  String wifiPasswordMessage(Object network);

  /// No description provided for @deviceNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Devices not found. Please make sure that your phone’s Bluetooth is turned on and within range of your new device.'**
  String get deviceNotFoundMessage;

  /// No description provided for @permissionsNotEnoughMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough permissions for \"{permissions}\" to proceed. Please grant the required permissions and tap \"Try Again\".'**
  String permissionsNotEnoughMessage(Object permissions);

  /// No description provided for @sendingWifiCredentials.
  ///
  /// In en, this message translates to:
  /// **'Sending Wi-Fi credentials'**
  String get sendingWifiCredentials;

  /// No description provided for @confirmingWifiConnection.
  ///
  /// In en, this message translates to:
  /// **'Confirming Wi-Fi connection'**
  String get confirmingWifiConnection;

  /// No description provided for @provisionedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Device has been successfully provisioned'**
  String get provisionedSuccessfully;

  /// No description provided for @returnToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Return to dashboard'**
  String get returnToDashboard;

  /// No description provided for @cannotEstablishSession.
  ///
  /// In en, this message translates to:
  /// **'Cannot establish session with device {deviceName}. Please try again'**
  String cannotEstablishSession(Object deviceName);

  /// No description provided for @claimingDevice.
  ///
  /// In en, this message translates to:
  /// **'Claiming device'**
  String get claimingDevice;

  /// No description provided for @claimingDeviceDone.
  ///
  /// In en, this message translates to:
  /// **'Device claiming done'**
  String get claimingDeviceDone;

  /// No description provided for @claimingMessageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device has been\nsuccessfully claimed'**
  String get claimingMessageSuccess;

  /// No description provided for @openAppSettingsToGrantPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough permissions for \"{permissions}\" to proceed. Please open app settings, grant permissions and trap \"Try Again\".'**
  String openAppSettingsToGrantPermissionMessage(Object permissions);
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return SZhCn();
          case 'TW':
            return SZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
    case 'zh':
      return SZh();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
