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

  @override
  String get likeOwnPostWarningMessage => 'Nem like-olhatod a saját posztodat!';

  @override
  String get likeOwnCommentWarningMessage => 'Nem like-olhatod a saját kommentedet!';

  @override
  String get banUserLabel => 'Készítő tiltása';

  @override
  String get successfulBanMessage => 'Sikeres tiltás!';

  @override
  String get banLabel => 'Tiltás';

  @override
  String get banCreatorConfirmQuestionLabel => 'Ha tiltod a poszt készítőjét, akkor semmilyen posztot és kommentet nem fogsz tőle látni, ameddig ki nem veszed a tiltást a beállításokban. Biztosan akarod tiltani?';

  @override
  String get banOwnAccountWarningMessage => 'Nem tilthatod a saját fiókodat!';

  @override
  String get locationErrorMessage => 'Valami hiba van a helyzet felismeréssel! A beállításoknál kézzel is beállíthatod a helyzetedet!';

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
  String get maxThirtyLengthLabel => ' (max 30 karakter)';

  @override
  String switchBetweenCompanyAndSimpleUserLabel(company) =>
      "Nyomd meg a kapcsolót, ha te egy " + (company ? "egyszerű felhasználó" : "céges felhasználó") + " vagy.";

  @override
  String get companyDescriptionTipLabel => 'Ide írjad a cégedet bemutató rövid leírást. Maximum 1024 karakterből állhat.';

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

  @override
  String get acceptPolicyLabel => 'Elolvastam és egyetértek az INNO mobilapplikáció ';

  @override
  String get userPolicyLabel => 'Felhasználói Szabályzatával';

  @override
  String get acceptPolicyWarningMessage => 'A regisztráció befejezéséhez el kell fogadnod a Felhasználói Szabályzatot!';

  @override
  String get userPolicyTitle => 'Felhasználói Szabályzat';

  @override
  String get backLabel => 'Vissza';

  @override
  String get userPolicyText => 'Ebben az applikációban felhasználók által generált tartalom van, posztok és kommentek formájában. A Felhasználói Szabályzat előírja, hogy nem szabad sem offenzív, sem trágár tartalmat poszolni és kommentelni. Ha ezt a felhasználó nem tartja be, akkor az alkalmazás üzemeltetője jogosult eltávolítani a tartalmat, szélsőséges esetben akár a felhasználót is.';

  @override
  String get imageFileSizeIsTooBigExceptionMessage => 'Túl nagy a kép fájl mérete, légyszíves töltsél fel egy 1 MB-nál kisebb képet!';

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
  String get likesNotificationEmailTipLabel => 'Állítsd a kapcsolót, ha a céged értesítést akar kapni egy megadott számú like után a posztjairól:';

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

  @override
  String get numberOfHouseholdMembersLabel => 'Háztartásbeliek száma:';

  @override
  String get ageLabel => 'Kor:';

  @override
  String get genderLabel => 'Nem:';

  @override
  String get livingPlaceTypeLabel => 'Lakhely:';

  @override
  String get salaryTypeLabel => 'Kereset:';

  @override
  String get nationalityLabel => 'Nemzetiség:';

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

  @override
  String get reportUserAndCommentTitleLabel => 'A poszt és a készítője jelentéséhez kérünk add meg a jelentés okát:';

  @override
  String get alreadyReportedCommentMessage => 'Már jelentetted ezt a posztot!';

  @override
  String get banCommenterConfirmQuestionLabel => 'Ha tiltod ezt a kommentelőt, akkor semmilyen posztot és kommentet nem fogsz tőle látni, ameddig ki nem veszed a tiltást a beállításokban. Biztosan akarod tiltani?';

  @override
  String get replyLabel => 'Válasz';

  @override
  String get removedLabel => '[Törölve]';

  @override
  String get tooDeepToDisplayMessage => 'The comment tree would be too deep to display, so further replies are not allowed for now!';

  //CREATE POST WIDGET

  @override
  String get newPollOptionLabel => 'Új szavazási lehetőség (max 40 karakter)';

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
  String get writeHereYourIdeaLabel => 'Leírás (Max 2048 kerakter)';

  @override
  String get POSTLabel => 'POSZTOLÁS';

  @override
  String get pollShortDescriptionLabel => 'Rövid leírás (max 256 karakter)';

  @override
  String get pollOptionsLabel => 'Szavazási lehetőségek';

  @override
  String get addOptionLabel => 'Opció hozzáadása';

  @override
  String get fillAllFieldsWithPollOptionWarningMessage => 'Töltsd ki az összes mezőt. Töröld ki az üres szavazási lehetőségeket!';

  @override
  String get yourPostIsOutMessage => 'A posztod kikerült!';

  @override
  String get addPictureLabel => 'Kép hozzáadása';

  //FILTERED POST WIDGET

  @override
  String get ideaIsImplementedMessage => 'Ez az ötlet meg lett valósítva!';

  @override
  String get clickHereToOpenThePollLabel => 'Kattints ide a szavazás megnyitásához!';

  @override
  String get noPostWithFilters => 'Nincsen a keresésednek megfelelő találat! Kérlek ellenőrizd, hogy nem írtál-e félre valamit!';

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

  @override
  String get reportLabel => 'Jelentés';


  @override
  String get reportUserAndPostTitleLabel => 'A poszt és a készítője jelentéséhez kérünk add meg a jelentés okát:';

  @override
  String get reportReasonHintLabel => 'Indok';

  @override
  String get successfulReportMessage => 'Sikeres jelentés!';

  @override
  String get alreadyReportedPostMessage => 'Már jelentetted ezt a posztot!';

  @override
  String get fillTheSearchFieldWarningMessage => 'Írj be legalább 1 karaktert a kereséshez!';

  @override
  String get noMoreItemsLabel => 'Nincs több megjeleníthető poszt!';

  @override
  String get errorLoadPostsLabel => 'Hiba történt a posztok betöltésekor, a képernyőt felfele húzva tudod frissíteni a posztokat! Ha ez sem segít ellenőrizd kérlek az internetkapcsolatot vagy jelezd az alkalmazás üzemeltetőjének.';

  @override
  String get explainPermissionDialogTitle => 'A mobilappnak szüksége van a helyzetedre, hogy behatárolja a nemzetiségedet, annak érdekében, hogy csak a te országod posztjai jelenjenek meg neked. Erre csak az alkalmazás használata közben van szükség, a háttérben nem használjuk a helyzetedet, csak akkor amikor a posztokat töltjük be. Ha nem akarod engedélyezni a helyzeted megosztását, semmi gond nincsen, a beállításoknál ezt kézzel is megteheted. Ha tehát ezt az opciót választod, azaz elutasítod az engedélyt, akkor is elérsz minden funkciót és ugynazt a felhasználói élményt kapod.';

  @override
  String get OKLabel => 'OK';

  @override
  String get thisPostHasPicture => 'Ehhez a poszthoz kép van csatolva';

  @override
  String get mainPageLabel => 'Főoldal';

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
  String get successfulSubscriptionCancelMessage => 'Sikeres leiratkozás!';

  @override
  String get changeLanguageLabel => 'Nyelv megváltoztatása';

  @override
  String get handleBansLabel => 'Felhasználói tiltások kezelése';

  @override
  String get deleteAccountLabel => 'Felhasználói fiók törlése';

  @override
  String get deleteAccountWarningTitle => 'FELHASZNÁLÓI FIÓK TÖRLÉSE!';

  @override
  String get deleteAccountWarningMessage => 'FIGYELEM, HA MEGNYOMOD A TÖRLÉS GOMBOT, AKKOR AZ ÖSSZES HOZZÁD TARTOZÓ KONTENT TÖRLŐDNI FOG AZ ALKALMAZÁSBÓL! BIZTOSAN AKAROD FOLYTATNI?';

  @override
  String get successfulAccountDeleteMessage => 'Sikeres felhasználói fiók törlés!';

  @override
  String get companiesLabel => 'Regisztrált cégek';

  @override
  String get myAccountLabel => 'Fiókom';

  //DATE FORMATTER

  @override
  String get minuteLetter => 'p';

  @override
  String get now => 'most';

  @override
  String get hourLetter => 'ó';

  @override
  String get dayLetter => 'n';

  //SINGLE POST WIDGET

  @override
  String get numberOfVotesLabel => 'Szavazatok száma';

  @override
  String get removeMyVoteLabel => 'Szavazat visszavonása';

  @override
  String get editTitleConfirmLabel => 'Biztosan végre akarod hajtani ezt a módosítást a címen?';

  @override
  String get titleNotEditedMessage => 'A cím nem lett módosítva.';

  @override
  String get titleTooLongWarningMessage => 'Túl hosszú a cím amit megadtál! Maximum 256 karakter lehet.';

  @override
  String get editDescriptionConfirmLabel => 'Biztosan végre akarod hajtani ezt a módosítást a leíráson?';

  @override
  String get descriptionNotEditedMessage => 'A leírás nem lett módosítva.';

  @override
  String get descriptionTooLongWarningMessage => 'Túl hosszú a leírás amit megadtál! Maximum 2048 karakter lehet.';

  @override
  String get votesText => 'szavazat';

  //BANNED USERS WIDGET

  @override
  String get noBannedUsers => 'Nincsenek tiltott felhasználók a listában!';

  @override
  String get idLabel => 'Felhasználó azonosító';

  @override
  String get successfulBanDeleteMessage => 'Sikeres eltávolítás!';

  //LIKED POSTS WIDGET

  @override
  String get likedPostsLabel => 'Likeolt posztok';

  //COMPANIES WIDGET

  @override
  String get companiesInfoWindowDescription => 'Az aktív feliratkozással rendelkező cégek sárga, az inaktívak pedig piros színnel jelennek meg.';

  @override
  String get activeCompany => 'Aktív cég';

  @override
  String get inactiveCompany => 'Inaktív cég';

  //GENDER ENUM

  @override
  String get manLabel => 'FÉRFI';

  @override
  String get womanLabel => 'NŐ';

  @override
  String get otherLabel => 'EGYÉB';

  //LIVING PLACE TYPE ENUM

  @override
  String get capitalCity => 'FŐVÁROS';

  @override
  String get town => 'KISVÁROS';

  @override
  String get village => 'FALU';

  //STATISTIC PAGE

  @override
  String get statisticLabel => 'Statisztika a kedvelésekről';

  //SALARY TYPE ENUM

  @override
  String get BELOW_300K => '< 300.000 FT';

  @override
  String get FROM300K_TO_500K => '300.000 - 500.000 FT';

  @override
  String get FROM500K_TO_700K => '500.000 - 700.000 FT';

  @override
  String get FROM700K_TO_1M => '700.000 - 1.000.000 FT';

  @override
  String get FROM1M_TO_1_5M => '1.000.000 - 1.500.000 FT';

  @override
  String get FROM1_5M_TO_2M => '1.500.000 - 2.000.000 FT';

  @override
  String get ABOVE_2M => '2.000.000+ FT';
}
