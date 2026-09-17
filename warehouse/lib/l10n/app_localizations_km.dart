// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get orders => 'កម្មង់';

  @override
  String get stock => 'ស្តុក';

  @override
  String get hrm => 'ធនធានមនុស្ស';

  @override
  String get profile => 'គណនី';

  @override
  String get settings => 'ការកំណត់';

  @override
  String get stageOrdered => 'បានបញ្ជាទិញ';

  @override
  String get stagePacked => 'ខ្ចប់រួច';

  @override
  String get stageAudited => 'ត្រួតពិនិត្យរួច';

  @override
  String get couldNotLoadShipments => 'មិនអាចទាញកម្មង់បាន';

  @override
  String get pullDownToTryAgain => 'ទាញចុះក្រោមដើម្បីព្យាយាមម្ដងទៀត។';

  @override
  String get nothingHere => 'មិនទាន់មានអ្វីទេ';

  @override
  String get notAccepted => 'មិនទាន់ទទួល';

  @override
  String get collectCash => 'យកលុយ';

  @override
  String get hasANote => 'មានកំណត់ចំណាំ';

  @override
  String withStaff(String name) {
    return 'ជាមួយ $name';
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
      other: '$countString មុខ',
      one: '1 មុខ',
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
      other: '$countString ឯកករ',
      one: '1 ឯកករ',
    );
    return '$_temp0';
  }

  @override
  String get deliverTo => 'បញ្ជូនទៅ';

  @override
  String get items => 'ទំនិញ';

  @override
  String packedOf(String done, String total) {
    return 'ខ្ចប់ $done / $total';
  }

  @override
  String get noRackLocation => 'មិនទាន់កំណត់ទីតាំងធ្នើរ';

  @override
  String get collectOnDelivery => 'យកលុយពេលប្រគល់';

  @override
  String get collectOnDeliveryBody =>
      'ដាក់វិក្កយបត្រក្នុងប្រអប់។ អ្នកដឹកយកលុយនៅមុខទ្វារ។';

  @override
  String get notPaidCollect => 'មិនទាន់ទូទាត់ — យកលុយពេលប្រគល់';

  @override
  String get acceptToPack => 'ទទួលយកទៅខ្ចប់';

  @override
  String get markPacked => 'កំណត់ថាខ្ចប់រួច';

  @override
  String get markAudited => 'កំណត់ថាត្រួតពិនិត្យរួច';

  @override
  String get releaseShipment => 'លែងទុក';

  @override
  String get waitingForRider => 'កំពុងរង់ចាំអ្នកដឹក';

  @override
  String get waitingForRiderBody => 'អ្នកដឹកនឹងចុចយកចេញពីកម្មវិធីរបស់ពួកគាត់។';

  @override
  String get printBoxLabels => 'បោះពុម្ពស្លាកប្រអប់';

  @override
  String get preparingLabels => 'កំពុងរៀបចំស្លាក…';

  @override
  String get labelPrinter => 'ម៉ាស៊ីនបោះពុម្ពស្លាក';

  @override
  String get chooseBluetoothPrinter => 'ជ្រើសម៉ាស៊ីនបោះពុម្ព Bluetooth';

  @override
  String get bluetoothLabelPrinter => 'ម៉ាស៊ីនបោះពុម្ពស្លាក Bluetooth';

  @override
  String get theWarehouseStickerPrinter => 'ម៉ាស៊ីនស្លាកក្នុងឃ្លាំង';

  @override
  String get otherPrinterOrPdf => 'ម៉ាស៊ីនផ្សេង ឬរក្សាទុកជា PDF';

  @override
  String get wifiUsbOrKeepCopy => 'Wi-Fi, USB ឬរក្សាចម្លង';

  @override
  String get chooseTheLabelPrinter => 'ជ្រើសម៉ាស៊ីនបោះពុម្ពស្លាក';

  @override
  String get pairedPrinters => 'ម៉ាស៊ីនដែលបានភ្ជាប់';

  @override
  String get printATestLabel => 'បោះពុម្ពស្លាកសាកល្បង';

  @override
  String get sending => 'កំពុងផ្ញើ…';

  @override
  String get forgetThisPrinter => 'ដកម៉ាស៊ីននេះចេញ';

  @override
  String get testLabelSent => 'បានផ្ញើស្លាកសាកល្បង។';

  @override
  String get bluetoothIsOff => 'Bluetooth បិទ';

  @override
  String get bluetoothIsOffBody => 'សូមបើក Bluetooth រួចចុចផ្ទុកឡើងវិញ។';

  @override
  String get noPrintersPaired => 'មិនមានម៉ាស៊ីនភ្ជាប់ទេ';

  @override
  String get noPrintersPairedBody =>
      'សូមភ្ជាប់ម៉ាស៊ីននៅក្នុង Android Settings > Bluetooth ជាមុន រួចត្រឡប់មកចុចផ្ទុកឡើងវិញ។';

  @override
  String get nothingToLabel => 'កម្មង់នេះមិនមានអ្វីដើម្បីដាក់ស្លាកទេ។';

  @override
  String labelsSent(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'បានផ្ញើស្លាក $countString។',
      one: 'បានផ្ញើស្លាក 1។',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'ផ្ទុកឡើងវិញ';

  @override
  String get unnamedPrinter => 'ម៉ាស៊ីនគ្មានឈ្មោះ';

  @override
  String get whatYouCanDo => 'អ្វីដែលអ្នកអាចធ្វើបាន';

  @override
  String get acceptAndPack => 'ទទួល និងខ្ចប់កម្មង់';

  @override
  String get markShipmentsAudited => 'កំណត់កម្មង់ថាត្រួតពិនិត្យរួច';

  @override
  String get changeStockNumbers => 'ផ្លាស់ប្ដូរចំនួនស្តុក';

  @override
  String get signOut => 'ចាកចេញ';

  @override
  String get handsetsAreShared => 'ទូរស័ព្ទជារបស់រួម។ សូមចាកចេញនៅចុងវេន។';

  @override
  String get language => 'ភាសា';

  @override
  String get languageKhmer => 'ភាសាខ្មែរ';

  @override
  String get languageEnglish => 'English';

  @override
  String get signIn => 'ចូលគណនី';

  @override
  String get username => 'ឈ្មោះគណនី';

  @override
  String get password => 'ពាក្យសម្ងាត់';

  @override
  String get showPassword => 'បង្ហាញពាក្យសម្ងាត់';

  @override
  String get hidePassword => 'លាក់ពាក្យសម្ងាត់';

  @override
  String get signInWithStaffAccount =>
      'ចូលដោយគណនីបុគ្គលិក yeaksa.com របស់អ្នក។';

  @override
  String get server => 'ម៉ាស៊ីនមេ';

  @override
  String get serverAddress => 'អាសយដ្ឋានម៉ាស៊ីនមេ';

  @override
  String get other => 'ផ្សេងទៀត';

  @override
  String get defaultChoice => 'តាមដើម';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get save => 'រក្សាទុក';

  @override
  String get couldNotReachServer => 'មិនអាចតភ្ជាប់ម៉ាស៊ីនមេបាន។';

  @override
  String get somethingWentWrong => 'មិនដំណើរការទេ។';

  @override
  String printerSaved(String name) {
    return 'រក្សាទុករួច។ ស្លាកនឹងបោះពុម្ពទៅ $name។';
  }

  @override
  String get inUse => 'កំពុងប្រើ';
}
