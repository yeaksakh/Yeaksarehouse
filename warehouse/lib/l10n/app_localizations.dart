import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('km')
  ];

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @hrm.
  ///
  /// In en, this message translates to:
  /// **'HRM'**
  String get hrm;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @stageOrdered.
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get stageOrdered;

  /// No description provided for @stagePacked.
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get stagePacked;

  /// No description provided for @stageAudited.
  ///
  /// In en, this message translates to:
  /// **'Audited'**
  String get stageAudited;

  /// No description provided for @couldNotLoadShipments.
  ///
  /// In en, this message translates to:
  /// **'Could not load shipments'**
  String get couldNotLoadShipments;

  /// No description provided for @pullDownToTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Pull down to try again.'**
  String get pullDownToTryAgain;

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHere;

  /// No description provided for @notAccepted.
  ///
  /// In en, this message translates to:
  /// **'Not accepted'**
  String get notAccepted;

  /// No description provided for @collectCash.
  ///
  /// In en, this message translates to:
  /// **'Collect cash'**
  String get collectCash;

  /// No description provided for @hasANote.
  ///
  /// In en, this message translates to:
  /// **'Has a note'**
  String get hasANote;

  /// No description provided for @withStaff.
  ///
  /// In en, this message translates to:
  /// **'With {name}'**
  String withStaff(String name);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 item} other{{count} items}}'**
  String itemsCount(num count);

  /// No description provided for @unitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 unit} other{{count} units}}'**
  String unitsCount(num count);

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @packedOf.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} packed'**
  String packedOf(String done, String total);

  /// No description provided for @noRackLocation.
  ///
  /// In en, this message translates to:
  /// **'No rack location set'**
  String get noRackLocation;

  /// No description provided for @collectOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Collect on delivery'**
  String get collectOnDelivery;

  /// No description provided for @collectOnDeliveryBody.
  ///
  /// In en, this message translates to:
  /// **'Put the invoice in the box. The rider collects at the door.'**
  String get collectOnDeliveryBody;

  /// No description provided for @notPaidCollect.
  ///
  /// In en, this message translates to:
  /// **'Not paid — collect on delivery'**
  String get notPaidCollect;

  /// No description provided for @acceptToPack.
  ///
  /// In en, this message translates to:
  /// **'Accept to pack'**
  String get acceptToPack;

  /// No description provided for @markPacked.
  ///
  /// In en, this message translates to:
  /// **'Mark packed'**
  String get markPacked;

  /// No description provided for @markAudited.
  ///
  /// In en, this message translates to:
  /// **'Mark audited'**
  String get markAudited;

  /// No description provided for @releaseShipment.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get releaseShipment;

  /// No description provided for @waitingForRider.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the rider'**
  String get waitingForRider;

  /// No description provided for @waitingForRiderBody.
  ///
  /// In en, this message translates to:
  /// **'The rider marks it picked up from the rider app.'**
  String get waitingForRiderBody;

  /// No description provided for @printBoxLabels.
  ///
  /// In en, this message translates to:
  /// **'Print box labels'**
  String get printBoxLabels;

  /// No description provided for @preparingLabels.
  ///
  /// In en, this message translates to:
  /// **'Preparing labels…'**
  String get preparingLabels;

  /// No description provided for @labelPrinter.
  ///
  /// In en, this message translates to:
  /// **'Label printer'**
  String get labelPrinter;

  /// No description provided for @chooseBluetoothPrinter.
  ///
  /// In en, this message translates to:
  /// **'Choose the Bluetooth sticker printer'**
  String get chooseBluetoothPrinter;

  /// No description provided for @bluetoothLabelPrinter.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth label printer'**
  String get bluetoothLabelPrinter;

  /// No description provided for @theWarehouseStickerPrinter.
  ///
  /// In en, this message translates to:
  /// **'The warehouse sticker printer'**
  String get theWarehouseStickerPrinter;

  /// No description provided for @otherPrinterOrPdf.
  ///
  /// In en, this message translates to:
  /// **'Other printer, or save as PDF'**
  String get otherPrinterOrPdf;

  /// No description provided for @wifiUsbOrKeepCopy.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi, USB, or keep a copy'**
  String get wifiUsbOrKeepCopy;

  /// No description provided for @chooseTheLabelPrinter.
  ///
  /// In en, this message translates to:
  /// **'Choose the label printer'**
  String get chooseTheLabelPrinter;

  /// No description provided for @pairedPrinters.
  ///
  /// In en, this message translates to:
  /// **'Paired printers'**
  String get pairedPrinters;

  /// No description provided for @printATestLabel.
  ///
  /// In en, this message translates to:
  /// **'Print a test label'**
  String get printATestLabel;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get sending;

  /// No description provided for @forgetThisPrinter.
  ///
  /// In en, this message translates to:
  /// **'Forget this printer'**
  String get forgetThisPrinter;

  /// No description provided for @testLabelSent.
  ///
  /// In en, this message translates to:
  /// **'Test label sent.'**
  String get testLabelSent;

  /// No description provided for @bluetoothIsOff.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is off'**
  String get bluetoothIsOff;

  /// No description provided for @bluetoothIsOffBody.
  ///
  /// In en, this message translates to:
  /// **'Switch Bluetooth on, then tap refresh.'**
  String get bluetoothIsOffBody;

  /// No description provided for @noPrintersPaired.
  ///
  /// In en, this message translates to:
  /// **'No printers paired'**
  String get noPrintersPaired;

  /// No description provided for @noPrintersPairedBody.
  ///
  /// In en, this message translates to:
  /// **'Pair the printer in Android Settings > Bluetooth first, then come back and tap refresh.'**
  String get noPrintersPairedBody;

  /// No description provided for @nothingToLabel.
  ///
  /// In en, this message translates to:
  /// **'This shipment has nothing to label.'**
  String get nothingToLabel;

  /// No description provided for @labelsSent.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 label sent.} other{{count} labels sent.}}'**
  String labelsSent(num count);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @unnamedPrinter.
  ///
  /// In en, this message translates to:
  /// **'Unnamed printer'**
  String get unnamedPrinter;

  /// No description provided for @whatYouCanDo.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get whatYouCanDo;

  /// No description provided for @acceptAndPack.
  ///
  /// In en, this message translates to:
  /// **'Accept and pack shipments'**
  String get acceptAndPack;

  /// No description provided for @markShipmentsAudited.
  ///
  /// In en, this message translates to:
  /// **'Mark shipments audited'**
  String get markShipmentsAudited;

  /// No description provided for @changeStockNumbers.
  ///
  /// In en, this message translates to:
  /// **'Change stock numbers'**
  String get changeStockNumbers;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @handsetsAreShared.
  ///
  /// In en, this message translates to:
  /// **'Handsets are shared. Sign out at the end of your shift.'**
  String get handsetsAreShared;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageKhmer.
  ///
  /// In en, this message translates to:
  /// **'ភាសាខ្មែរ'**
  String get languageKhmer;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @signInWithStaffAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your yeaksa.com staff account.'**
  String get signInWithStaffAccount;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverAddress;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @defaultChoice.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultChoice;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @couldNotReachServer.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server.'**
  String get couldNotReachServer;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'That did not work.'**
  String get somethingWentWrong;

  /// No description provided for @printerSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. Labels will print to {name}.'**
  String printerSaved(String name);

  /// No description provided for @inUse.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get inUse;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
