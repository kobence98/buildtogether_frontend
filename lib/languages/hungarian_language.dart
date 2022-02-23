import 'languages.dart';

class LanguageHu extends Languages {
  @override
  String get countryCode => 'hu';

  //GLOBAL
  @override
  String get globalErrorMessage => 'Valami hiba történt! Ellenőrizd az internetkapcsolatot!';

  @override
  String get globalServerErrorMessage =>
      'Valami hiba történt! (Szerver hiba)';

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

  //COMMENTS WIDGET

  @override
  String get deleteLabel => 'Törlés';

  @override
  String get successfulDeleteMessage => 'Sikeres törlés!';

  @override
  String get addCommentLabel => 'Komment hozzáadása';

  @override
  String get commentTipLabel => 'Ide írjad a kommentet. Maximum 256 karakterből állhat.';

  @override
  String get commentAddedMessage => 'Komment hozzáadva!';

  @override
  String get emptyCommentWarningMessage => 'Ne hagyd üresen a kommentet!';

  //CREATE POST WIDGET

  @override
  String get newPollOptionLabel => 'Új szavazási lehetőség';

  @override
  String get simplePostLabel => 'Egyszerű poszt';

  @override
  String get pollPostLabel => 'Szavazós poszt';

  @override
  String get companyChooseHintLabel => 'Válassz a regisztrált cégek közül! Ha elkezded beírni a nevét, akkor meg fog jelenni egy listában.';

  @override
  String get postIsOutMessage => 'A posztod kikerült!';

  @override
  String get whatIsYourIdeaLabel => 'Mi az ötleted?';

  @override
  String get noItemsFoundLabel => 'Nincs ilyen elem';

  @override
  String get companyNameLabel => 'Cég neve';

  @override
  String get titleOfIdeaLabel => 'Az ötleted címe';

  @override
  String get writeHereYourIdeaLabel => 'Ide írjad le az ötletedet. Maximum 2048 keraktert használhatsz.';

  @override
  String get POSTLabel => 'POSZTOLÁS';

  @override
  String get pollShortDescriptionLabel => 'Szavazás rövid leírása';

  @override
  String get pollOptionsLabel => 'Szavazási lehetőségek';

  @override
  String get addOptionLabel => 'Opció hozzáadása';

  @override
  String get fillAllFieldsWithPollOptionWarningMessage => 'Töltsd ki az összes mezőt. Töröld ki az üres szavazási lehetőségeket!';

  @override
  String get yourPostIsOutMessage => 'A posztod kikerült!';

  //FILTERED POST WIDGET

  @override
  String get ideaIsImplementedMessage => 'This idea is implemented!';

  @override
  String get clickHereToOpenThePollLabel => 'Kattints ide a szavazás megnyitásához!';

  //POSTS WIDGET

  @override
  String get searchLabel => 'Keresés';

  @override
  String get newLabel => 'Új';

  @override
  String get bestLabel => 'Legjobb';

  @override
  String get ownLabel => 'Saját';

  @override
  String get notImplementedLabel => 'Nincs megvalósítva';

  @override
  String get implementedLabel => 'Meg van valósítva';

  @override
  String get successLabel => 'Siker';

  @override
  String get noPostInYourAreaLabel => 'A te országodban nincsenek posztok, légyszíves ellenőrizd a helyzetmeghatározási beállításokat vagy húzd le a képernyőt a frissítéshez!';

  @override
  String get contactCreatorLabel => 'Kapcsolatfelvétel a készítővel';

  @override
  String get thisIsTheContactEmailLabel => 'Erre az email címre tudsz itt egy kuponszámot küldeni, vagy írhatsz neki személyesen is:';

  @override
  String get couponCodeLabel => 'Kupon kód';

  @override
  String get successfulCouponSendMessage => 'Sikeres kuponküldés!';

  //SETTINGS WIDGET

  @override
  String get changeUserDataLabel => 'Felhasználó adatok megváltoztatása';

  @override
  String get subscriptionHandlingLabel => 'Feliratkozás kezelése';

  @override
  String get logoutLabel => 'Kijelentkezés';

  @override
  String get unsubscribeTipLabel => 'Nyomd meg a lenti gombot a leiratkozáshoz!';

  @override
  String get subscribeTipLabel => 'Az alkalmazás 5000 felhasználóig ingyenes feliratkozást biztosít a cégeknek. Miután elérte ezt a letöltésszámot az alkalmazás, körülbelül 30 eurós, azaz nagyjából 10000 forintos díjra lehet majd számítani havonta. A feliratkozás szükséges ahhoz, hogy a felhasználók posztolhassanak a céget megjelölve.';

  @override
  String get unsubscribeLabel => 'Leiratkozás';

  @override
  String get subscribeLabel => 'Feliratkozás';

  @override
  String get successfulSubscriptionMessage => 'Sikeres feliratkozás!';

  @override
  String get changeLanguageLabel => 'Nyelv megváltoztatása';

  //DATE FORMATTER

  @override
  String get minuteLetter => 'p';

  @override
  String get now => 'most';

  @override
  String get hourLetter => 'ó';

  @override
  String get dayLetter => 'n';
}
