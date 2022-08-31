import 'languages.dart';

class LanguageEn extends Languages {
  @override
  String get countryCode => 'en';

  //GLOBAL
  @override
  String get globalErrorMessage =>
      'Something went wrong! Check your network connection!';

  @override
  String get globalServerErrorMessage =>
      'Something went wrong! (Server error)';

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

  @override
  String get likeOwnPostWarningMessage => 'You can\'t like your own post!';

  @override
  String get likeOwnCommentWarningMessage => 'You can\'t like your own comment!';

  @override
  String get banUserLabel => 'Ban creator';

  @override
  String get successfulBanMessage => 'Successful ban!';

  @override
  String get banLabel => 'Ban';

  @override
  String get banCreatorConfirmQuestionLabel => 'If you ban the creator of this post you wont see his/her posts and comments until you unlock the ban in the settings. Are you sure you want to ban this user?';

  @override
  String get banOwnAccountWarningMessage => 'You can\'t ban your own account!';

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
  String get companyDescriptionTipLabel => 'This is where you should write your company\'s description. Maximum of 1024 characters.';

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

  @override
  String get acceptPolicyLabel => 'I read and agree to the INNO mobile application\'s ';

  @override
  String get userPolicyLabel => 'User Policy';

  @override
  String get acceptPolicyWarningMessage => 'You must accept to the User Policy to finish registration!';

  @override
  String get userPolicyTitle => 'User Policy';

  @override
  String get backLabel => 'Back';

  @override
  String get userPolicyText => 'In this application there is some user generated content, in form of posts and comments. The User Poloicy specifies, that posting offensive and profane content is not allowed. If the user break this rule, than the operator of the application has the right to remove the content, or in extreme situations the user as well.';

  @override
  String get imageFileSizeIsTooBigExceptionMessage => 'Image file size is too big, please upload an image less than 1 MB!';

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

  //COMMENTS WIDGET

  @override
  String get deleteLabel => 'Delete';

  @override
  String get successfulDeleteMessage => 'Successful delete!';

  @override
  String get addCommentLabel => 'Add comment';

  @override
  String get commentTipLabel => 'This is where you should write your comment. Maximum of 256 characters.';

  @override
  String get commentAddedMessage => 'Your comment is added!';

  @override
  String get emptyCommentWarningMessage => 'Don\'t let the comment empty!';

  @override
  String get reportUserAndCommentTitleLabel => 'To report this comment and the creator give us the reason please:';

  @override
  String get alreadyReportedCommentMessage => 'You already reported this comment!';

  @override
  String get banCommenterConfirmQuestionLabel => 'If you ban this commenter you wont see his/her posts and comments until you unlock the ban in the settings. Are you sure you want to ban this user?';

  //CREATE POST WIDGET

  @override
  String get newPollOptionLabel => 'New poll option (max 40 characters)';

  @override
  String get simplePostLabel => 'Simple post';

  @override
  String get pollPostLabel => 'Poll post';

  @override
  String get companyChooseHintLabel => 'Choose from the registered companies! If you start to write in it\'s name, it will appear in the list.';

  @override
  String get postIsOutMessage => 'Your post is out!';

  @override
  String get whatIsYourIdeaLabel => 'What is your idea?';

  @override
  String get noItemsFoundLabel => 'No items found!';

  @override
  String get companyNameLabel => 'Company name';

  @override
  String get titleOfIdeaLabel => 'Title of your idea';

  @override
  String get writeHereYourIdeaLabel => 'This is where you should write your idea. Maximum of 2048 characters.';

  @override
  String get POSTLabel => 'POST';

  @override
  String get pollShortDescriptionLabel => 'Short description for the poll (max 256 characters)';

  @override
  String get pollOptionsLabel => 'Poll options';

  @override
  String get addOptionLabel => 'Add option';

  @override
  String get fillAllFieldsWithPollOptionWarningMessage => 'Fill all of the fields. Delete the empty poll options!';

  @override
  String get yourPostIsOutMessage => 'Your post is out!';

  //FILTERED POST WIDGET

  @override
  String get ideaIsImplementedMessage => 'This idea is implemented!';

  @override
  String get clickHereToOpenThePollLabel => 'Click here to open the poll!';

  @override
  String get noPostWithFilters => 'There are no matching posts for your search! Please check to see if you misspelled anything!';

  //POSTS WIDGET

  @override
  String get searchLabel => 'Search';

  @override
  String get newLabel => 'New';

  @override
  String get bestLabel => 'Best';

  @override
  String get ownLabel => 'Own';

  @override
  String get notImplementedLabel => 'Not implemented';

  @override
  String get implementedLabel => 'Implemented';

  @override
  String get successLabel => 'Success';

  @override
  String get noPostInYourAreaLabel => 'There is no post in your area, please check your location settings or pull down to refresh!';

  @override
  String get contactCreatorLabel => 'Contact creator';

  @override
  String get thisIsTheContactEmailLabel => 'You can send a coupon to this email address here, or you can contact him by yourself:';

  @override
  String get couponCodeLabel => 'Coupon code';

  @override
  String get successfulCouponSendMessage => 'Successful coupon sending!';

  @override
  String get reportLabel => 'Report';

  @override
  String get reportUserAndPostTitleLabel => 'To report this post and the creator give us the reason please:';

  @override
  String get reportReasonHintLabel => 'Reason';

  @override
  String get successfulReportMessage => 'Successful report!';

  @override
  String get alreadyReportedPostMessage => 'You already reported this post!';

  @override
  String get fillTheSearchFieldWarningMessage => 'You shall write at least 1 character to the search field!';

  //SETTINGS WIDGET

  @override
  String get changeUserDataLabel => 'Change user data';

  @override
  String get subscriptionHandlingLabel => 'Subscription handling';

  @override
  String get logoutLabel => 'Logout';

  @override
  String get unsubscribeTipLabel => 'Tap the button below to unsubscribe!';

  @override
  String get subscribeTipLabel => 'Until 5000 users the app ensure free subscription for companies. After that it will cost about 30 euros monthly. Its necessary to subscribe if you want to get ideas from users.';

  @override
  String get unsubscribeLabel => 'Unsubscribe';

  @override
  String get subscribeLabel => 'Subscribe';

  @override
  String get successfulSubscriptionMessage => 'Successful subscription!';

  @override
  String get changeLanguageLabel => 'Change language';

  @override
  String get handleBansLabel => 'Handle user bans';

  @override
  String get deleteAccountLabel => 'Delete user account';

  @override
  String get deleteAccountWarningTitle => 'DELETE USER ACCOUNT!';

  @override
  String get deleteAccountWarningMessage => 'WARNING! IF YOU PUSH THE DELETE BUTTON, ALL OF YOUR CONTENT WILL BE DELETED FROM THE APPLICATION! DO YOU WANT TO CONTINUE?';

  @override
  String get successfulAccountDeleteMessage => 'Successful user account delete!';

  //DATE FORMATTER

  @override
  String get minuteLetter => 'm';

  @override
  String get now => 'now';

  @override
  String get hourLetter => 'h';

  @override
  String get dayLetter => 'd';

  //SINGLE POST WIDGET

  @override
  String get numberOfVotesLabel => 'Number of votes';

  @override
  String get removeMyVoteLabel => 'Remove my vote';

  //BANNED USERS WIDGET

  @override
  String get noBannedUsers => 'There is no banned users in the list!';

  @override
  String get idLabel => 'User id';

  @override
  String get successfulBanDeleteMessage => 'Successful remove!';

  //LIKED POSTS WIDGET

  @override
  String get likedPostsLabel => 'Liked posts';
}
