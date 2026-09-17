// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get orders => 'Orders';

  @override
  String get stock => 'Stock';

  @override
  String get hrm => 'HRM';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get stageOrdered => 'Ordered';

  @override
  String get stagePacked => 'Packed';

  @override
  String get stageAudited => 'Audited';

  @override
  String get couldNotLoadShipments => 'Could not load shipments';

  @override
  String get pullDownToTryAgain => 'Pull down to try again.';

  @override
  String get nothingHere => 'Nothing here yet';

  @override
  String get notAccepted => 'Not accepted';

  @override
  String get collectCash => 'Collect cash';

  @override
  String get hasANote => 'Has a note';

  @override
  String withStaff(String name) {
    return 'With $name';
  }

  @override
  String itemsCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String unitsCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString units',
      one: '1 unit',
    );
    return '$_temp0';
  }

  @override
  String get deliverTo => 'Deliver to';

  @override
  String get items => 'Items';

  @override
  String packedOf(String done, String total) {
    return '$done / $total packed';
  }

  @override
  String get noRackLocation => 'No rack location set';

  @override
  String get collectOnDelivery => 'Collect on delivery';

  @override
  String get collectOnDeliveryBody =>
      'Put the invoice in the box. The rider collects at the door.';

  @override
  String get notPaidCollect => 'Not paid — collect on delivery';

  @override
  String get acceptToPack => 'Accept to pack';

  @override
  String get markPacked => 'Mark packed';

  @override
  String get markAudited => 'Mark audited';

  @override
  String get releaseShipment => 'Release';

  @override
  String get waitingForRider => 'Waiting for the rider';

  @override
  String get waitingForRiderBody =>
      'The rider marks it picked up from the rider app.';

  @override
  String get printBoxLabels => 'Print box labels';

  @override
  String get preparingLabels => 'Preparing labels…';

  @override
  String get labelPrinter => 'Label printer';

  @override
  String get chooseBluetoothPrinter => 'Choose the Bluetooth sticker printer';

  @override
  String get bluetoothLabelPrinter => 'Bluetooth label printer';

  @override
  String get theWarehouseStickerPrinter => 'The warehouse sticker printer';

  @override
  String get otherPrinterOrPdf => 'Other printer, or save as PDF';

  @override
  String get wifiUsbOrKeepCopy => 'Wi-Fi, USB, or keep a copy';

  @override
  String get chooseTheLabelPrinter => 'Choose the label printer';

  @override
  String get pairedPrinters => 'Paired printers';

  @override
  String get printATestLabel => 'Print a test label';

  @override
  String get sending => 'Sending…';

  @override
  String get forgetThisPrinter => 'Forget this printer';

  @override
  String get testLabelSent => 'Test label sent.';

  @override
  String get bluetoothIsOff => 'Bluetooth is off';

  @override
  String get bluetoothIsOffBody => 'Switch Bluetooth on, then tap refresh.';

  @override
  String get noPrintersPaired => 'No printers paired';

  @override
  String get noPrintersPairedBody =>
      'Pair the printer in Android Settings > Bluetooth first, then come back and tap refresh.';

  @override
  String get nothingToLabel => 'This shipment has nothing to label.';

  @override
  String labelsSent(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString labels sent.',
      one: '1 label sent.',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get unnamedPrinter => 'Unnamed printer';

  @override
  String get whatYouCanDo => 'What you can do';

  @override
  String get acceptAndPack => 'Accept and pack shipments';

  @override
  String get markShipmentsAudited => 'Mark shipments audited';

  @override
  String get changeStockNumbers => 'Change stock numbers';

  @override
  String get signOut => 'Sign out';

  @override
  String get handsetsAreShared =>
      'Handsets are shared. Sign out at the end of your shift.';

  @override
  String get language => 'Language';

  @override
  String get languageKhmer => 'ភាសាខ្មែរ';

  @override
  String get languageEnglish => 'English';

  @override
  String get signIn => 'Sign in';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signInWithStaffAccount =>
      'Sign in with your yeaksa.com staff account.';

  @override
  String get server => 'Server';

  @override
  String get serverAddress => 'Server address';

  @override
  String get other => 'Other';

  @override
  String get defaultChoice => 'Default';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get couldNotReachServer => 'Could not reach the server.';

  @override
  String get somethingWentWrong => 'That did not work.';

  @override
  String printerSaved(String name) {
    return 'Saved. Labels will print to $name.';
  }

  @override
  String get inUse => 'In use';
}
