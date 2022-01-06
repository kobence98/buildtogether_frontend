import 'languages.dart';

class LanguageHu extends Languages {
  @override
  String get countryCode => 'hu';

  //GLOBAL
  @override
  String get globalErrorMessage => 'Valami hiba történt! Ellenőrizd az internetkapcsolatot!';

  @override
  String get cancelLabel => 'Mégse';

  @override
  String get closeLabel => 'Bezár';

  @override
  String get fillAllFieldsProperlyWarningMessage => 'Töltsd ki az összes mezőt megfelelően!';

  @override
  String get sendLabel => 'Küldés';

  @override
  String get fillAllFieldsWarningMessage => 'Töltsd ki az összes mezőt!';
  
  //MAIN
  @override
  String get subscribeWarningMessage => 'A céged csak akkor lesz elérhető a felhasználók számára, ha a beállításoknál feliratkozol!';

  @override
  String get automaticLoginErrorMessage => 'Valami hiba történt az automatikus bejelentkezés során, kérlek próbáld újra!';
  
  //LOGIN PAGE
  @override
  String get loginLabel => 'Bejelentkezés';

  @override
  String get passwordLabel => 'Jelszó';

  @override
  String get passAgainLabel => 'Jelszó ismét';

  @override
  String get emailLabel => 'Email cím';

  @override
  String get registrationLabel => 'Regisztráció';

  @override
  String get forgottenPasswordLabel => 'Elfelejtett jelszó';

  @override
  String get confirmationWarningMessage => 'Erősítsd meg az emaíl címedet!';

  @override
  String get spamFolderTipMessage => 'Ha nem találod, nézd meg a spam mappát is, vagy kérj egy újat a lenti gombbal.';

  @override
  String get requestNewVerificationEmailLabel => 'Új megerősítő email kérése';

  @override
  String get wrongCredentialsErrorMessage => 'Hibás felhasználónév vagy jelszó!';

  @override
  String get nameLabel => 'Név';

  @override
  String switchBetweenCompanyAndSimpleUserLabel(company) =>
      "Nyomd meg a kapcsolót, ha te egy " + (company ? "egyszerű felhasználó" : "céges felhasználó") + " vagy.";

  @override
  String get companyDescriptionTipLabel => 'Ide írjad a cégedet bemutató rövid leírást. Maximum 256 karakterből állhat.';

  @override
  String get addCompanyLogoLabel => 'Cég logó hozzáadása';

  @override
  String get locationWithGlobalHintLabel => 'Nemzetiség (ha globális a cég, akkor válasszad a global opciót)';

  @override
  String get profanityWarningMessage => 'Kérlek válogasd meg a szavaidat!';

  @override
  String get successfulRegistrationMessage => 'Sikeres regisztráció, küldtünk neked egy megerősítő emailt!';

  @override
  String get wrongEmailFormatWarningMessage => 'Rossz email formátum!';

  @override
  String get emailIsAlreadyInUseWarningMessage => 'Ez az email cím már foglalt!';

  @override
  String get passwordsAreNotIdenticalWarningMessage => 'A jelszavak nem egyeznek meg!';

  @override
  String get forgottenPasswordHintLabel => 'Írd ide az email címedet és elküldjük neked az új generált jelszavadat.';

  @override
  String get forgottenPasswordSentMessage => 'Küldtünk egy emailt az új jelszóval!';

  @override
  String get forgottenPasswordErrorMessage => 'Valami hiba történt, ellenőrizd hogy megfelelően írtad-e be az email címedet!';

  @override
  String get verificationEmailResentMessage => 'Elküldtük az új megerősítő emailt!';

  //CHANGE LOCATION WIDGET

  @override
  String get countryCodesErrorMessage => 'Valami hiba történt az országok lekérésével! Ellenőrizd az internetkapcsolatot!';

  @override
  String get switchOffLocationUseLabel => 'Kapcsold ki, ha nem akarod a helyzetedet használni';

  @override
  String get switchOnLocationUseLabel => 'Kapcsold be, ha akarod használni a helyzetedet';

  @override
  String get changeLocationLabel => 'Helyzet megváltoztatása';

  @override
  String get chooseLocationWarningLabel => 'Válassz országot!';

  @override
  String get successfulLocationChangeMessage => 'Sikeres helyzetváltoztatás!';

  //CHANGE PASSWORD WIDGET

  @override
  String get changePasswordLabel => 'Jelszó megváltoztatása';

  @override
  String get successfulPasswordChangeMessage => 'Sikeres jelszóváltoztatás!';

  //CHANGE USER DATA WIDGET
  @override
  String get descriptionLabel => 'Leírás';

  @override
  String get logoLabel => 'Logó';

  @override
  String get likesNotificationEmailTipLabel => 'Állítsd a kapcsolót, ha a céged értesítést akar kapni egy megadott számú like után a posztjairól.';

  @override
  String get changeDataLabel => 'Adatok megváltoztatása';

  @override
  String get successfulCompanyDataChangeLabel => 'Sikeres adatváltoztatás, logóváltoztatás esetén indítsd újra az alkalmazást!';

  @override
  String get pictureUpdateErrorMessage => 'Valami hiba történt a kép frissítésekor';

  @override
  String get successfulDataChangeLabel => 'Sikeres adatmódosítás!';

  @override
  String get fillAllFieldsWithLocationWarningMessage => 'Töltsd ki az összes mezőt megfelelően, még az országot is válaszd ki!';
}
