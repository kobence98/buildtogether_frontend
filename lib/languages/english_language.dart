import 'languages.dart';

class LanguageEn extends Languages {
  @override
  String get countryCode => 'en';

  //GLOBAL
  @override
  String get globalErrorMessage =>
      'Something went wrong! Check your network connection!';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get closeLabel => 'Close';

  @override
  String get fillAllFieldsProperlyWarningMessage => 'Fill all fields properly!';

  @override
  String get sendLabel => 'Send';

  @override
  String get fillAllFieldsWarningMessage => 'Fill all of the fields!';

  //MAIN
  @override
  String get subscribeWarningMessage =>
      'Your company will be available for users only if you subscribe in the settings!';

  @override
  String get automaticLoginErrorMessage =>
      'Something went wrong with the automatic login, please try again!';

  //LOGIN PAGE
  @override
  String get loginLabel => 'Login';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passAgainLabel => 'Password again';

  @override
  String get emailLabel => 'Email';

  @override
  String get registrationLabel => 'Registration';

  @override
  String get forgottenPasswordLabel => 'Forgotten Password';

  @override
  String get confirmationWarningMessage => 'Confirm your email address!';

  @override
  String get spamFolderTipMessage =>
      'If you can\'t find it, check it in the spam folder, or request a new below.';

  @override
  String get requestNewVerificationEmailLabel =>
      'Request new verification email';

  @override
  String get wrongCredentialsErrorMessage => 'Wrong credentials!';

  @override
  String get nameLabel => 'Name';

  @override
  String switchBetweenCompanyAndSimpleUserLabel(company) =>
      "Switch if you are a " + (company ? "simple user." : "company.");

  @override
  String get companyDescriptionTipLabel => 'This is where you should write your company\'s description. Maximum of 256 characters.';

  @override
  String get addCompanyLogoLabel => 'Add company logo:';

  @override
  String get locationWithGlobalHintLabel => 'Location (if you are a global company choose global)';

  @override
  String get profanityWarningMessage => 'Please dont use bad language!';

  @override
  String get successfulRegistrationMessage => 'Successful registration, we sent you a confirmation email!';

  @override
  String get wrongEmailFormatWarningMessage => 'Wrong email format!';

  @override
  String get emailIsAlreadyInUseWarningMessage => 'This email address is already in use!';

  @override
  String get passwordsAreNotIdenticalWarningMessage => 'Passwords are not identical!';

  @override
  String get forgottenPasswordHintLabel => 'Write your email address and we will send you a new password.';

  @override
  String get forgottenPasswordSentMessage => 'We sent you an email with the new password!';

  @override
  String get forgottenPasswordErrorMessage => 'Something went wrong, check if you wrote your email address properly!';

  @override
  String get verificationEmailResentMessage => 'We sent you a new verification email!';

  //CHANGE LOCATION WIDGET

  @override
  String get countryCodesErrorMessage => 'Something went wrong with the countries! Check your network connection!';

  @override
  String get switchOffLocationUseLabel => 'Switch off if you don\'t want to use your location';

  @override
  String get switchOnLocationUseLabel => 'Switch on if you want to use your location';

  @override
  String get changeLocationLabel => 'Change location';

  @override
  String get chooseLocationWarningLabel => 'Choose a location!';

  @override
  String get successfulLocationChangeMessage => 'Successful location change!';

  //CHANGE PASSWORD WIDGET

  @override
  String get changePasswordLabel => 'Change password';

  @override
  String get successfulPasswordChangeMessage => 'Successful password change!';

  //CHANGE USER DATA WIDGET
  @override
  String get descriptionLabel => 'Description';

  @override
  String get logoLabel => 'Logo';

  @override
  String get likesNotificationEmailTipLabel => 'Switch on if your company want to get an email notification after a specified number of likes on a post:';

  @override
  String get changeDataLabel => 'Change data';

  @override
  String get successfulCompanyDataChangeLabel => 'Successful data change, restart the app for the logo change!';

  @override
  String get pictureUpdateErrorMessage => 'Something went wrong with the picture update!';

  @override
  String get successfulDataChangeLabel => 'Successful data change!';

  @override
  String get fillAllFieldsWithLocationWarningMessage => 'Fill all fields properly, choose a location as well!';

}
