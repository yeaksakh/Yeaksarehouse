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
    return 'អ្នកខ្ចប់៖ $name';
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

  @override
  String get yours => 'របស់អ្នក';

  @override
  String get nothingHereTitle => 'មិនមានអ្វីទេ';

  @override
  String get nothingToPack => 'គ្មានអ្វីត្រូវខ្ចប់';

  @override
  String get nothingWaitingForAudit => 'គ្មានអ្វីរង់ចាំត្រួតពិនិត្យ';

  @override
  String get nothingWaitingForRider => 'គ្មានអ្វីរង់ចាំអ្នកដឹក';

  @override
  String get noShipmentsAtStatus => 'គ្មានកម្មង់នៅស្ថានភាពនេះទេ។';

  @override
  String get newOrdersLandHere =>
      'កម្មង់ថ្មីមកដល់ទីនេះ។ ទទួលយកមួយដើម្បីចាប់ផ្ដើមខ្ចប់។';

  @override
  String get packedWaitForSupervisor =>
      'កម្មង់ដែលខ្ចប់រួចរង់ចាំនៅទីនេះ រហូតដល់អ្នកគ្រប់គ្រងត្រួតពិនិត្យ។';

  @override
  String get auditedWaitForRider =>
      'កម្មង់ដែលត្រួតពិនិត្យរួចនៅទីនេះ រហូតដល់អ្នកដឹកមកយក។';

  @override
  String get photo => 'រូបភាព';

  @override
  String get photos => 'រូបភាព';

  @override
  String get handBack => 'ប្រគល់ត្រឡប់';

  @override
  String get notAcceptedYet => 'មិនទាន់ទទួលយក';

  @override
  String get waitingForAudit => 'រង់ចាំត្រួតពិនិត្យ';

  @override
  String get acceptItToStartPacking =>
      'ទទួលយកដើម្បីចាប់ផ្ដើមខ្ចប់។ គេហទំព័របង្ហាញអ្នកជាអ្នកខ្ចប់។';

  @override
  String get supervisorChecksFirst =>
      'អ្នកគ្រប់គ្រងត្រួតពិនិត្យកម្មង់ដែលខ្ចប់រួច មុនអ្នកដឹកយកទៅ។';

  @override
  String get onlyAccepterTicks =>
      'មានតែអ្នកដែលបានទទួលយកកម្មង់ទេ ដែលអាចធីកទំនិញរបស់វា។';

  @override
  String get tapAnItemToTick => 'ចុចលើទំនិញដើម្បីធីក ឬស្កេន SKU របស់វា។';

  @override
  String get scanOrTypeSku => 'ស្កេន ឬវាយ SKU';

  @override
  String get shipmentNoLongerHere => 'កម្មង់នោះលែងមាននៅទីនេះទៀតហើយ។';

  @override
  String get shipmentHasLeft => 'កម្មង់នេះបានចេញពីឃ្លាំងហើយ។';

  @override
  String packedByName(String name) {
    return 'ខ្ចប់ដោយ $name';
  }

  @override
  String riderName(String name) {
    return 'អ្នកដឹកជញ្ជូន៖ $name';
  }

  @override
  String auditedByName(String name) {
    return 'ត្រួតពិនិត្យដោយ $name';
  }

  @override
  String get products => 'ផលិតផល';

  @override
  String get stockCount => 'រាប់ស្តុក';

  @override
  String get noStockYet => 'មិនទាន់មានស្តុក';

  @override
  String get productsAppearHere =>
      'ផលិតផលនឹងបង្ហាញនៅទីនេះ ពេលបញ្ជីទំនិញផ្ទុករួច។';

  @override
  String get nothingMatches => 'រកមិនឃើញ';

  @override
  String get tryDifferentSearch => 'សូមសាកល្បងឈ្មោះ SKU ឬធ្នើរផ្សេង។';

  @override
  String get searchNameSkuBin => 'ស្វែងរកឈ្មោះ SKU ឬធ្នើរ';

  @override
  String get scanAProduct => 'ស្កេនផលិតផល';

  @override
  String get scan => 'ស្កេន';

  @override
  String get closeScanner => 'បិទម៉ាស៊ីនស្កេន';

  @override
  String get onHand => 'មានក្នុងស្តុក';

  @override
  String get reserved => 'បានកក់';

  @override
  String get freeToSell => 'អាចលក់បាន';

  @override
  String get adjust => 'កែតម្រូវ';

  @override
  String get saveAdjustment => 'រក្សាទុកការកែតម្រូវ';

  @override
  String get noChange => 'គ្មានការផ្លាស់ប្ដូរ';

  @override
  String get recordWhatChanged =>
      'កត់ត្រាអ្វីដែលបានប្ដូរ មិនមែនចំនួនសរុបចុងក្រោយទេ។';

  @override
  String get neverCounted => 'មិនដែលរាប់';

  @override
  String get noBinAssigned => 'មិនទាន់កំណត់ធ្នើរ';

  @override
  String get noBarcodeOnFile => 'គ្មានបាកូដ';

  @override
  String get productNoLongerListed => 'ផលិតផលនោះលែងមានក្នុងបញ្ជីទៀតហើយ។';

  @override
  String get roleCannotChangeStock =>
      'តួនាទីរបស់អ្នកអាចមើលស្តុក តែមិនអាចកែបានទេ។';

  @override
  String get countLines => 'ជួរបានរាប់';

  @override
  String get startCount => 'ចាប់ផ្ដើមរាប់';

  @override
  String get finishCount => 'បញ្ចប់ការរាប់';

  @override
  String get discardCount => 'បោះបង់ការរាប់';

  @override
  String get counted => 'រាប់រួច';

  @override
  String get expected => 'គួរមាន';

  @override
  String get difference => 'ភាពខុសគ្នា';

  @override
  String get attendance => 'វត្តមាន';

  @override
  String get leave => 'ការឈប់សម្រាក';

  @override
  String get holidays => 'ថ្ងៃឈប់សម្រាក';

  @override
  String get leaveApprovals => 'អនុម័តការឈប់សម្រាក';

  @override
  String get payroll => 'បៀវត្សរ៍';

  @override
  String get yourClockInsAndHours => 'ការចុះវត្តមាន និងម៉ោងធ្វើការរបស់អ្នក';

  @override
  String get yourRequestsAndAsk => 'សំណើរបស់អ្នក និងស្នើសុំឈប់សម្រាក';

  @override
  String get shopDaysOff => 'ថ្ងៃឈប់សម្រាករបស់ហាងក្នុងឆ្នាំនេះ';

  @override
  String get approveOrReject => 'អនុម័ត ឬបដិសេធសំណើបុគ្គលិក';

  @override
  String get yourPayslips => 'បង្កាន់ដៃប្រាក់ខែរបស់អ្នក';

  @override
  String get clockedIn => 'បានចុះវត្តមាន';

  @override
  String get notClockedIn => 'មិនទាន់ចុះវត្តមាន';

  @override
  String get tapWhenYouStart => 'ចុចប៊ូតុងពេលអ្នកចាប់ផ្ដើម។';

  @override
  String get clockIn => 'ចុះវត្តមានចូល';

  @override
  String get clockOut => 'ចុះវត្តមានចេញ';

  @override
  String get startShiftNow => 'ចាប់ផ្ដើមវេនឥឡូវនេះ?';

  @override
  String get endShiftNow => 'បញ្ចប់វេនឥឡូវនេះ?';

  @override
  String get noteOptional => 'កំណត់ចំណាំ (មិនបង្ខំ)';

  @override
  String get addAPhoto => 'បន្ថែមរូបភាព';

  @override
  String get retakePhoto => 'ថតរូបម្ដងទៀត';

  @override
  String get today => 'ថ្ងៃនេះ';

  @override
  String get thisWeek => 'សប្ដាហ៍នេះ';

  @override
  String get thisMonth => 'ខែនេះ';

  @override
  String get daysWorked => 'ថ្ងៃធ្វើការ';

  @override
  String get hours => 'ម៉ោង';

  @override
  String get openShift => 'កំពុងបើក';

  @override
  String get noShiftsHere => 'គ្មានវេននៅទីនេះ';

  @override
  String get clockInFromHrm =>
      'ចុះវត្តមានពីផ្ទាំងធនធានមនុស្ស នោះវានឹងបង្ហាញនៅទីនេះ។';

  @override
  String get positionRecorded => 'បានកត់ត្រាទីតាំង';

  @override
  String get requestLeave => 'ស្នើសុំឈប់សម្រាក';

  @override
  String get sendRequest => 'ផ្ញើសំណើ';

  @override
  String get kindOfLeave => 'ប្រភេទការឈប់សម្រាក';

  @override
  String get chooseKindOfLeave => 'សូមជ្រើសប្រភេទការឈប់សម្រាក។';

  @override
  String get fromDate => 'ចាប់ពី';

  @override
  String get toDate => 'ដល់';

  @override
  String get halfDay => 'កន្លះថ្ងៃ';

  @override
  String get halfADay => 'កន្លះថ្ងៃ';

  @override
  String get reason => 'មូលហេតុ';

  @override
  String get leaveRequested => 'បានស្នើសុំឈប់សម្រាក — កំពុងរង់ចាំការអនុម័ត។';

  @override
  String get noLeaveRequests => 'គ្មានសំណើឈប់សម្រាក';

  @override
  String get askForLeaveBelow =>
      'ស្នើសុំឈប់សម្រាកដោយប៊ូតុងខាងក្រោម។ អ្នកគ្រប់គ្រងនឹងអនុម័ត។';

  @override
  String get approve => 'អនុម័ត';

  @override
  String get reject => 'បដិសេធ';

  @override
  String get request => 'សំណើ';

  @override
  String get backToPending => 'ត្រឡប់ទៅរង់ចាំ';

  @override
  String get noRequestsMatch => 'គ្មានសំណើឈប់សម្រាកត្រូវនឹងតម្រងនេះទេ។';

  @override
  String get couldNotBeChanged => 'មិនអាចផ្លាស់ប្ដូរបានទេ។';

  @override
  String get statusPending => 'កំពុងរង់ចាំ';

  @override
  String get statusApproved => 'បានអនុម័ត';

  @override
  String get statusRejected => 'បានបដិសេធ';

  @override
  String get statusCancelled => 'បានលុបចោល';

  @override
  String get comingUp => 'នឹងមកដល់';

  @override
  String get alreadyPassed => 'កន្លងផុតហើយ';

  @override
  String get noHolidays => 'គ្មានថ្ងៃឈប់សម្រាក';

  @override
  String get noHolidaysSet => 'មិនទាន់កំណត់សម្រាប់ឆ្នាំនេះនៅលើគេហទំព័រទេ។';

  @override
  String get noCountOpen => 'គ្មានការរាប់កំពុងបើក';

  @override
  String get startOneWalkShelves =>
      'ចាប់ផ្ដើមមួយ ដើរតាមធ្នើរ រួចដាក់ស្នើពេលរួចរាល់។';

  @override
  String get countedLabel => 'រាប់រួច';

  @override
  String get notCountedYet => 'មិនទាន់រាប់';

  @override
  String get onlyUncounted => 'តែអ្វីមិនទាន់រាប់';

  @override
  String get everyLineCounted => 'រាប់គ្រប់ជួរហើយ';

  @override
  String get leftToCount => 'នៅសល់';

  @override
  String get variance => 'ភាពខុសគ្នា';

  @override
  String get matches => 'ត្រូវគ្នា';

  @override
  String get nothingLowOrOut => 'គ្មានអ្វីខ្វះ ឬអស់';

  @override
  String get scanAShelfItem => 'ស្កេនទំនិញលើធ្នើរ';

  @override
  String get submit => 'ដាក់ស្នើ';

  @override
  String get submitWhenReady => 'ដាក់ស្នើពេលអ្នករួចរាល់។';

  @override
  String get countSomethingFirst => 'រាប់អ្វីមួយសិនដើម្បីដាក់ស្នើ';

  @override
  String get submitThisCount => 'ដាក់ស្នើការរាប់នេះ?';

  @override
  String get countedLinesOverwrite => 'ជួរដែលរាប់រួចនឹងជំនួសចំនួនលើធ្នើរ។';

  @override
  String get discardCountQ => 'បោះបង់ការរាប់នេះ?';

  @override
  String get everythingThrownAway =>
      'អ្វីដែលរាប់រួចទាំងអស់នឹងត្រូវបោះបង់។ ចំនួនលើធ្នើរមិនប៉ះពាល់ទេ។';

  @override
  String get keepCounting => 'បន្តរាប់';

  @override
  String get keepIt => 'រក្សាទុក';

  @override
  String get discard => 'បោះបង់';

  @override
  String get clear => 'សម្អាត';

  @override
  String get countKeptOnDevice =>
      'ការរាប់ដែលកំពុងដំណើរការត្រូវរក្សាក្នុងឧបករណ៍នេះ ដូច្នេះវានៅដដែលបើបើកឡើងវិញ។';

  @override
  String get serverUnreadable => 'ម៉ាស៊ីនមេបានផ្ញើអ្វីមួយដែលកម្មវិធីអានមិនបាន។';

  @override
  String get printerLanguage => 'ភាសាម៉ាស៊ីនបោះពុម្ព';

  @override
  String get printerLanguageBody =>
      'ម៉ាស៊ីនបោះពុម្ពស្លាក និងម៉ាស៊ីនបោះពុម្ពវិក្កយបត្រ ប្រើភាសាខុសគ្នា។ បើគ្មានអ្វីចេញពីម៉ាស៊ីនបោះពុម្ពស្លាកទេ ភាគច្រើនគឺមកពីមូលហេតុនេះ។';

  @override
  String get labelPrinterTspl => 'ម៉ាស៊ីនបោះពុម្ពស្លាក (TSPL)';

  @override
  String get labelPrinterTsplBody =>
      'Vigo, TSC, Xprinter និងម៉ាស៊ីនប្រើក្រដាសស្លាកភាគច្រើន';

  @override
  String get receiptPrinterEscPos => 'ម៉ាស៊ីនបោះពុម្ពវិក្កយបត្រ (ESC/POS)';

  @override
  String get receiptPrinterEscPosBody =>
      'ម៉ាស៊ីនបោះពុម្ពវិក្កយបត្រប្រើក្រដាសវែង';

  @override
  String get checkTheLanguage => 'ពិនិត្យភាសា';

  @override
  String get languageTestSent =>
      'បានផ្ញើ។ បើមាន \"TSPL OK\" ក្នុងស៊ុមចេញមក នោះម៉ាស៊ីននេះប្រើ TSPL។';

  @override
  String get ridersTab => 'អ្នកដឹក';

  @override
  String get riderStageAccepted => 'បានទទួល';

  @override
  String get riderStagePickedUp => 'បានយកទំនិញ';

  @override
  String get riderStageOnTheWay => 'កំពុងដឹក';

  @override
  String get riderStageDelivered => 'បានដល់';

  @override
  String get noRidersTitle => 'មិនទាន់មានអ្នកដឹកកាន់កម្មង់';

  @override
  String get noRidersBody =>
      'កម្មង់ដែលអ្នកដឹកបានទទួល នឹងបង្ហាញនៅទីនេះ ជាមួយស្ថានភាពចុងក្រោយ។';

  @override
  String get workTab => 'ការងារ';

  @override
  String get historyTab => 'ប្រវត្តិ';

  @override
  String seeAllCount(int count) {
    return 'មើលទាំងអស់ ($count)';
  }

  @override
  String get nextAccept => 'ទទួលយកទៅខ្ចប់';

  @override
  String get nextPack => 'បញ្ជាក់ខ្ចប់រួច';

  @override
  String get nextAudit => 'ត្រួតពិនិត្យ';

  @override
  String get nothingToDoTitle => 'មិនមានការងារទេ';

  @override
  String get nothingToDoBody =>
      'កម្មង់ថ្មី ការខ្ចប់ និងការត្រួតពិនិត្យ នឹងបង្ហាញនៅទីនេះ។';
}
