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

  /// No description provided for @stagePacking.
  ///
  /// In en, this message translates to:
  /// **'Packing'**
  String get stagePacking;

  /// No description provided for @searchOrders.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchOrders;

  /// No description provided for @searchOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'Invoice, customer or phone'**
  String get searchOrdersHint;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @noMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get noMatchTitle;

  /// No description provided for @noMatchBody.
  ///
  /// In en, this message translates to:
  /// **'No order matches “{query}”.'**
  String noMatchBody(String query);

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
  /// **'Packer: {name}'**
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

  /// No description provided for @yours.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get yours;

  /// No description provided for @nothingHereTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get nothingHereTitle;

  /// No description provided for @nothingToPack.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pack'**
  String get nothingToPack;

  /// No description provided for @nothingWaitingForAudit.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting for audit'**
  String get nothingWaitingForAudit;

  /// No description provided for @nothingWaitingForRider.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting for a rider'**
  String get nothingWaitingForRider;

  /// No description provided for @noShipmentsAtStatus.
  ///
  /// In en, this message translates to:
  /// **'No shipments at this status.'**
  String get noShipmentsAtStatus;

  /// No description provided for @newOrdersLandHere.
  ///
  /// In en, this message translates to:
  /// **'New orders land here. Accept one to start packing it.'**
  String get newOrdersLandHere;

  /// No description provided for @packedWaitForSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Packed shipments wait here until a supervisor checks them.'**
  String get packedWaitForSupervisor;

  /// No description provided for @auditedWaitForRider.
  ///
  /// In en, this message translates to:
  /// **'Audited shipments sit here until the rider picks them up.'**
  String get auditedWaitForRider;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @handBack.
  ///
  /// In en, this message translates to:
  /// **'Hand back'**
  String get handBack;

  /// No description provided for @notAcceptedYet.
  ///
  /// In en, this message translates to:
  /// **'Not accepted yet'**
  String get notAcceptedYet;

  /// No description provided for @waitingForAudit.
  ///
  /// In en, this message translates to:
  /// **'Waiting for audit'**
  String get waitingForAudit;

  /// No description provided for @acceptItToStartPacking.
  ///
  /// In en, this message translates to:
  /// **'Accept it to start packing. The website shows you as the packer.'**
  String get acceptItToStartPacking;

  /// No description provided for @supervisorChecksFirst.
  ///
  /// In en, this message translates to:
  /// **'A supervisor checks the packed shipment before the rider takes it.'**
  String get supervisorChecksFirst;

  /// No description provided for @onlyAccepterTicks.
  ///
  /// In en, this message translates to:
  /// **'Only the person who accepted a shipment ticks its items.'**
  String get onlyAccepterTicks;

  /// No description provided for @tapAnItemToTick.
  ///
  /// In en, this message translates to:
  /// **'Tap an item to tick it, or scan its SKU.'**
  String get tapAnItemToTick;

  /// No description provided for @scanOrTypeSku.
  ///
  /// In en, this message translates to:
  /// **'Scan or type a SKU'**
  String get scanOrTypeSku;

  /// No description provided for @shipmentNoLongerHere.
  ///
  /// In en, this message translates to:
  /// **'That shipment is no longer here.'**
  String get shipmentNoLongerHere;

  /// No description provided for @shipmentHasLeft.
  ///
  /// In en, this message translates to:
  /// **'This shipment has left the warehouse.'**
  String get shipmentHasLeft;

  /// No description provided for @packedByName.
  ///
  /// In en, this message translates to:
  /// **'Packed by {name}'**
  String packedByName(String name);

  /// No description provided for @riderName.
  ///
  /// In en, this message translates to:
  /// **'Rider: {name}'**
  String riderName(String name);

  /// No description provided for @auditedByName.
  ///
  /// In en, this message translates to:
  /// **'Audited by {name}'**
  String auditedByName(String name);

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @stockCount.
  ///
  /// In en, this message translates to:
  /// **'Stock count'**
  String get stockCount;

  /// No description provided for @noStockYet.
  ///
  /// In en, this message translates to:
  /// **'No stock yet'**
  String get noStockYet;

  /// No description provided for @productsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Products appear here once the catalogue loads.'**
  String get productsAppearHere;

  /// No description provided for @nothingMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get nothingMatches;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different name, SKU or bin.'**
  String get tryDifferentSearch;

  /// No description provided for @searchNameSkuBin.
  ///
  /// In en, this message translates to:
  /// **'Search name, SKU or bin'**
  String get searchNameSkuBin;

  /// No description provided for @scanAProduct.
  ///
  /// In en, this message translates to:
  /// **'Scan a product'**
  String get scanAProduct;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @closeScanner.
  ///
  /// In en, this message translates to:
  /// **'Close scanner'**
  String get closeScanner;

  /// No description provided for @onHand.
  ///
  /// In en, this message translates to:
  /// **'On hand'**
  String get onHand;

  /// No description provided for @reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// No description provided for @freeToSell.
  ///
  /// In en, this message translates to:
  /// **'Free to sell'**
  String get freeToSell;

  /// No description provided for @adjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get adjust;

  /// No description provided for @saveAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Save adjustment'**
  String get saveAdjustment;

  /// No description provided for @noChange.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get noChange;

  /// No description provided for @recordWhatChanged.
  ///
  /// In en, this message translates to:
  /// **'Record what changed, not what the total became.'**
  String get recordWhatChanged;

  /// No description provided for @neverCounted.
  ///
  /// In en, this message translates to:
  /// **'Never counted'**
  String get neverCounted;

  /// No description provided for @noBinAssigned.
  ///
  /// In en, this message translates to:
  /// **'No bin assigned'**
  String get noBinAssigned;

  /// No description provided for @noBarcodeOnFile.
  ///
  /// In en, this message translates to:
  /// **'No barcode on file'**
  String get noBarcodeOnFile;

  /// No description provided for @productNoLongerListed.
  ///
  /// In en, this message translates to:
  /// **'That product is no longer listed.'**
  String get productNoLongerListed;

  /// No description provided for @roleCannotChangeStock.
  ///
  /// In en, this message translates to:
  /// **'Your role can view stock but not change it.'**
  String get roleCannotChangeStock;

  /// No description provided for @countLines.
  ///
  /// In en, this message translates to:
  /// **'Lines counted'**
  String get countLines;

  /// No description provided for @startCount.
  ///
  /// In en, this message translates to:
  /// **'Start a count'**
  String get startCount;

  /// No description provided for @finishCount.
  ///
  /// In en, this message translates to:
  /// **'Finish count'**
  String get finishCount;

  /// No description provided for @discardCount.
  ///
  /// In en, this message translates to:
  /// **'Discard count'**
  String get discardCount;

  /// No description provided for @counted.
  ///
  /// In en, this message translates to:
  /// **'Counted'**
  String get counted;

  /// No description provided for @expected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get expected;

  /// No description provided for @difference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get difference;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @holidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get holidays;

  /// No description provided for @leaveApprovals.
  ///
  /// In en, this message translates to:
  /// **'Leave approvals'**
  String get leaveApprovals;

  /// No description provided for @payroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get payroll;

  /// No description provided for @yourClockInsAndHours.
  ///
  /// In en, this message translates to:
  /// **'Your clock-ins and hours'**
  String get yourClockInsAndHours;

  /// No description provided for @yourRequestsAndAsk.
  ///
  /// In en, this message translates to:
  /// **'Your requests, and ask for leave'**
  String get yourRequestsAndAsk;

  /// No description provided for @shopDaysOff.
  ///
  /// In en, this message translates to:
  /// **'The shop\'s days off this year'**
  String get shopDaysOff;

  /// No description provided for @approveOrReject.
  ///
  /// In en, this message translates to:
  /// **'Approve or reject staff requests'**
  String get approveOrReject;

  /// No description provided for @yourPayslips.
  ///
  /// In en, this message translates to:
  /// **'Your payslips'**
  String get yourPayslips;

  /// No description provided for @clockedIn.
  ///
  /// In en, this message translates to:
  /// **'Clocked in'**
  String get clockedIn;

  /// No description provided for @notClockedIn.
  ///
  /// In en, this message translates to:
  /// **'Not clocked in'**
  String get notClockedIn;

  /// No description provided for @tapWhenYouStart.
  ///
  /// In en, this message translates to:
  /// **'Tap the button when you start.'**
  String get tapWhenYouStart;

  /// No description provided for @clockIn.
  ///
  /// In en, this message translates to:
  /// **'Clock in'**
  String get clockIn;

  /// No description provided for @clockOut.
  ///
  /// In en, this message translates to:
  /// **'Clock out'**
  String get clockOut;

  /// No description provided for @startShiftNow.
  ///
  /// In en, this message translates to:
  /// **'Start your shift now?'**
  String get startShiftNow;

  /// No description provided for @endShiftNow.
  ///
  /// In en, this message translates to:
  /// **'End your shift now?'**
  String get endShiftNow;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @addAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addAPhoto;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get retakePhoto;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @daysWorked.
  ///
  /// In en, this message translates to:
  /// **'Days worked'**
  String get daysWorked;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @openShift.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openShift;

  /// No description provided for @noShiftsHere.
  ///
  /// In en, this message translates to:
  /// **'No shifts here'**
  String get noShiftsHere;

  /// No description provided for @clockInFromHrm.
  ///
  /// In en, this message translates to:
  /// **'Clock in from the HRM tab and it will show here.'**
  String get clockInFromHrm;

  /// No description provided for @positionRecorded.
  ///
  /// In en, this message translates to:
  /// **'Position recorded'**
  String get positionRecorded;

  /// No description provided for @requestLeave.
  ///
  /// In en, this message translates to:
  /// **'Request leave'**
  String get requestLeave;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @kindOfLeave.
  ///
  /// In en, this message translates to:
  /// **'Kind of leave'**
  String get kindOfLeave;

  /// No description provided for @chooseKindOfLeave.
  ///
  /// In en, this message translates to:
  /// **'Choose the kind of leave.'**
  String get chooseKindOfLeave;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDate;

  /// No description provided for @halfDay.
  ///
  /// In en, this message translates to:
  /// **'Half day'**
  String get halfDay;

  /// No description provided for @halfADay.
  ///
  /// In en, this message translates to:
  /// **'Half a day'**
  String get halfADay;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @leaveRequested.
  ///
  /// In en, this message translates to:
  /// **'Leave requested — waiting for approval.'**
  String get leaveRequested;

  /// No description provided for @noLeaveRequests.
  ///
  /// In en, this message translates to:
  /// **'No leave requests'**
  String get noLeaveRequests;

  /// No description provided for @askForLeaveBelow.
  ///
  /// In en, this message translates to:
  /// **'Ask for leave with the button below. A manager approves it.'**
  String get askForLeaveBelow;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @backToPending.
  ///
  /// In en, this message translates to:
  /// **'Back to pending'**
  String get backToPending;

  /// No description provided for @noRequestsMatch.
  ///
  /// In en, this message translates to:
  /// **'No leave requests match this filter.'**
  String get noRequestsMatch;

  /// No description provided for @couldNotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'That could not be changed.'**
  String get couldNotBeChanged;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @comingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get comingUp;

  /// No description provided for @alreadyPassed.
  ///
  /// In en, this message translates to:
  /// **'Already passed'**
  String get alreadyPassed;

  /// No description provided for @noHolidays.
  ///
  /// In en, this message translates to:
  /// **'No holidays'**
  String get noHolidays;

  /// No description provided for @noHolidaysSet.
  ///
  /// In en, this message translates to:
  /// **'None are set for this year on the website.'**
  String get noHolidaysSet;

  /// No description provided for @noCountOpen.
  ///
  /// In en, this message translates to:
  /// **'No count open'**
  String get noCountOpen;

  /// No description provided for @startOneWalkShelves.
  ///
  /// In en, this message translates to:
  /// **'Start one, walk the shelves, and submit when you are done.'**
  String get startOneWalkShelves;

  /// No description provided for @countedLabel.
  ///
  /// In en, this message translates to:
  /// **'Counted'**
  String get countedLabel;

  /// No description provided for @notCountedYet.
  ///
  /// In en, this message translates to:
  /// **'Not counted yet'**
  String get notCountedYet;

  /// No description provided for @onlyUncounted.
  ///
  /// In en, this message translates to:
  /// **'Only uncounted'**
  String get onlyUncounted;

  /// No description provided for @everyLineCounted.
  ///
  /// In en, this message translates to:
  /// **'Every line counted'**
  String get everyLineCounted;

  /// No description provided for @leftToCount.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get leftToCount;

  /// No description provided for @variance.
  ///
  /// In en, this message translates to:
  /// **'Variance'**
  String get variance;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @nothingLowOrOut.
  ///
  /// In en, this message translates to:
  /// **'Nothing low or out'**
  String get nothingLowOrOut;

  /// No description provided for @scanAShelfItem.
  ///
  /// In en, this message translates to:
  /// **'Scan a shelf item'**
  String get scanAShelfItem;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @submitWhenReady.
  ///
  /// In en, this message translates to:
  /// **'Submit when you are ready.'**
  String get submitWhenReady;

  /// No description provided for @countSomethingFirst.
  ///
  /// In en, this message translates to:
  /// **'Count something to submit'**
  String get countSomethingFirst;

  /// No description provided for @submitThisCount.
  ///
  /// In en, this message translates to:
  /// **'Submit this count?'**
  String get submitThisCount;

  /// No description provided for @countedLinesOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Counted lines overwrite the shelf.'**
  String get countedLinesOverwrite;

  /// No description provided for @discardCountQ.
  ///
  /// In en, this message translates to:
  /// **'Discard this count?'**
  String get discardCountQ;

  /// No description provided for @everythingThrownAway.
  ///
  /// In en, this message translates to:
  /// **'Everything counted so far is thrown away. The shelf is untouched.'**
  String get everythingThrownAway;

  /// No description provided for @keepCounting.
  ///
  /// In en, this message translates to:
  /// **'Keep counting'**
  String get keepCounting;

  /// No description provided for @keepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepIt;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @countKeptOnDevice.
  ///
  /// In en, this message translates to:
  /// **'A count in progress is kept on this device, so it survives a restart.'**
  String get countKeptOnDevice;

  /// No description provided for @serverUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The server sent something the app could not read.'**
  String get serverUnreadable;

  /// No description provided for @printerLanguage.
  ///
  /// In en, this message translates to:
  /// **'Printer language'**
  String get printerLanguage;

  /// No description provided for @printerLanguageBody.
  ///
  /// In en, this message translates to:
  /// **'A label printer and a till printer speak different languages. If nothing comes out of a label printer, this is almost always why.'**
  String get printerLanguageBody;

  /// No description provided for @labelPrinterTspl.
  ///
  /// In en, this message translates to:
  /// **'Label printer (TSPL)'**
  String get labelPrinterTspl;

  /// No description provided for @labelPrinterTsplBody.
  ///
  /// In en, this message translates to:
  /// **'Vigo, TSC, Xprinter and most sticker-roll machines'**
  String get labelPrinterTsplBody;

  /// No description provided for @receiptPrinterEscPos.
  ///
  /// In en, this message translates to:
  /// **'Receipt printer (ESC/POS)'**
  String get receiptPrinterEscPos;

  /// No description provided for @receiptPrinterEscPosBody.
  ///
  /// In en, this message translates to:
  /// **'Till printers on continuous paper'**
  String get receiptPrinterEscPosBody;

  /// No description provided for @checkTheLanguage.
  ///
  /// In en, this message translates to:
  /// **'Check the language'**
  String get checkTheLanguage;

  /// No description provided for @languageTestSent.
  ///
  /// In en, this message translates to:
  /// **'Sent. If a framed \"TSPL OK\" comes out, this printer speaks TSPL.'**
  String get languageTestSent;

  /// No description provided for @ridersTab.
  ///
  /// In en, this message translates to:
  /// **'Riders'**
  String get ridersTab;

  /// No description provided for @riderStageAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get riderStageAccepted;

  /// No description provided for @riderStagePickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get riderStagePickedUp;

  /// No description provided for @riderStageOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get riderStageOnTheWay;

  /// No description provided for @riderStageDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get riderStageDelivered;

  /// No description provided for @noRidersTitle.
  ///
  /// In en, this message translates to:
  /// **'No rider has an order'**
  String get noRidersTitle;

  /// No description provided for @noRidersBody.
  ///
  /// In en, this message translates to:
  /// **'Shipments a rider accepts appear here, with where they have got to.'**
  String get noRidersBody;

  /// No description provided for @workTab.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get workTab;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @seeAllCount.
  ///
  /// In en, this message translates to:
  /// **'See all ({count})'**
  String seeAllCount(int count);

  /// No description provided for @nextAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept to pack'**
  String get nextAccept;

  /// No description provided for @nextPack.
  ///
  /// In en, this message translates to:
  /// **'Confirm packed'**
  String get nextPack;

  /// No description provided for @nextAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get nextAudit;

  /// No description provided for @nothingToDoTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do'**
  String get nothingToDoTitle;

  /// No description provided for @nothingToDoBody.
  ///
  /// In en, this message translates to:
  /// **'New orders, packing and checks will appear here.'**
  String get nothingToDoBody;
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
