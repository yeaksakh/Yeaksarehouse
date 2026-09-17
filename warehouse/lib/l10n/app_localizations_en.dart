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

  @override
  String get yours => 'Yours';

  @override
  String get nothingHereTitle => 'Nothing here';

  @override
  String get nothingToPack => 'Nothing to pack';

  @override
  String get nothingWaitingForAudit => 'Nothing waiting for audit';

  @override
  String get nothingWaitingForRider => 'Nothing waiting for a rider';

  @override
  String get noShipmentsAtStatus => 'No shipments at this status.';

  @override
  String get newOrdersLandHere =>
      'New orders land here. Accept one to start packing it.';

  @override
  String get packedWaitForSupervisor =>
      'Packed shipments wait here until a supervisor checks them.';

  @override
  String get auditedWaitForRider =>
      'Audited shipments sit here until the rider picks them up.';

  @override
  String get photo => 'Photo';

  @override
  String get photos => 'Photos';

  @override
  String get handBack => 'Hand back';

  @override
  String get notAcceptedYet => 'Not accepted yet';

  @override
  String get waitingForAudit => 'Waiting for audit';

  @override
  String get acceptItToStartPacking =>
      'Accept it to start packing. The website shows you as the packer.';

  @override
  String get supervisorChecksFirst =>
      'A supervisor checks the packed shipment before the rider takes it.';

  @override
  String get onlyAccepterTicks =>
      'Only the person who accepted a shipment ticks its items.';

  @override
  String get tapAnItemToTick => 'Tap an item to tick it, or scan its SKU.';

  @override
  String get scanOrTypeSku => 'Scan or type a SKU';

  @override
  String get shipmentNoLongerHere => 'That shipment is no longer here.';

  @override
  String get shipmentHasLeft => 'This shipment has left the warehouse.';

  @override
  String packedByName(String name) {
    return 'Packed by $name';
  }

  @override
  String auditedByName(String name) {
    return 'Audited by $name';
  }

  @override
  String get products => 'Products';

  @override
  String get stockCount => 'Stock count';

  @override
  String get noStockYet => 'No stock yet';

  @override
  String get productsAppearHere =>
      'Products appear here once the catalogue loads.';

  @override
  String get nothingMatches => 'Nothing matches';

  @override
  String get tryDifferentSearch => 'Try a different name, SKU or bin.';

  @override
  String get searchNameSkuBin => 'Search name, SKU or bin';

  @override
  String get scanAProduct => 'Scan a product';

  @override
  String get scan => 'Scan';

  @override
  String get closeScanner => 'Close scanner';

  @override
  String get onHand => 'On hand';

  @override
  String get reserved => 'Reserved';

  @override
  String get freeToSell => 'Free to sell';

  @override
  String get adjust => 'Adjust';

  @override
  String get saveAdjustment => 'Save adjustment';

  @override
  String get noChange => 'No change';

  @override
  String get recordWhatChanged =>
      'Record what changed, not what the total became.';

  @override
  String get neverCounted => 'Never counted';

  @override
  String get noBinAssigned => 'No bin assigned';

  @override
  String get noBarcodeOnFile => 'No barcode on file';

  @override
  String get productNoLongerListed => 'That product is no longer listed.';

  @override
  String get roleCannotChangeStock =>
      'Your role can view stock but not change it.';

  @override
  String get countLines => 'Lines counted';

  @override
  String get startCount => 'Start a count';

  @override
  String get finishCount => 'Finish count';

  @override
  String get discardCount => 'Discard count';

  @override
  String get counted => 'Counted';

  @override
  String get expected => 'Expected';

  @override
  String get difference => 'Difference';

  @override
  String get attendance => 'Attendance';

  @override
  String get leave => 'Leave';

  @override
  String get holidays => 'Holidays';

  @override
  String get leaveApprovals => 'Leave approvals';

  @override
  String get payroll => 'Payroll';

  @override
  String get yourClockInsAndHours => 'Your clock-ins and hours';

  @override
  String get yourRequestsAndAsk => 'Your requests, and ask for leave';

  @override
  String get shopDaysOff => 'The shop\'s days off this year';

  @override
  String get approveOrReject => 'Approve or reject staff requests';

  @override
  String get yourPayslips => 'Your payslips';

  @override
  String get clockedIn => 'Clocked in';

  @override
  String get notClockedIn => 'Not clocked in';

  @override
  String get tapWhenYouStart => 'Tap the button when you start.';

  @override
  String get clockIn => 'Clock in';

  @override
  String get clockOut => 'Clock out';

  @override
  String get startShiftNow => 'Start your shift now?';

  @override
  String get endShiftNow => 'End your shift now?';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get addAPhoto => 'Add a photo';

  @override
  String get retakePhoto => 'Retake photo';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get daysWorked => 'Days worked';

  @override
  String get hours => 'Hours';

  @override
  String get openShift => 'Open';

  @override
  String get noShiftsHere => 'No shifts here';

  @override
  String get clockInFromHrm =>
      'Clock in from the HRM tab and it will show here.';

  @override
  String get positionRecorded => 'Position recorded';

  @override
  String get requestLeave => 'Request leave';

  @override
  String get sendRequest => 'Send request';

  @override
  String get kindOfLeave => 'Kind of leave';

  @override
  String get chooseKindOfLeave => 'Choose the kind of leave.';

  @override
  String get fromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String get halfDay => 'Half day';

  @override
  String get halfADay => 'Half a day';

  @override
  String get reason => 'Reason';

  @override
  String get leaveRequested => 'Leave requested — waiting for approval.';

  @override
  String get noLeaveRequests => 'No leave requests';

  @override
  String get askForLeaveBelow =>
      'Ask for leave with the button below. A manager approves it.';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get request => 'Request';

  @override
  String get backToPending => 'Back to pending';

  @override
  String get noRequestsMatch => 'No leave requests match this filter.';

  @override
  String get couldNotBeChanged => 'That could not be changed.';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get comingUp => 'Coming up';

  @override
  String get alreadyPassed => 'Already passed';

  @override
  String get noHolidays => 'No holidays';

  @override
  String get noHolidaysSet => 'None are set for this year on the website.';

  @override
  String get noCountOpen => 'No count open';

  @override
  String get startOneWalkShelves =>
      'Start one, walk the shelves, and submit when you are done.';

  @override
  String get countedLabel => 'Counted';

  @override
  String get notCountedYet => 'Not counted yet';

  @override
  String get onlyUncounted => 'Only uncounted';

  @override
  String get everyLineCounted => 'Every line counted';

  @override
  String get leftToCount => 'Left';

  @override
  String get variance => 'Variance';

  @override
  String get matches => 'Matches';

  @override
  String get nothingLowOrOut => 'Nothing low or out';

  @override
  String get scanAShelfItem => 'Scan a shelf item';

  @override
  String get submit => 'Submit';

  @override
  String get submitWhenReady => 'Submit when you are ready.';

  @override
  String get countSomethingFirst => 'Count something to submit';

  @override
  String get submitThisCount => 'Submit this count?';

  @override
  String get countedLinesOverwrite => 'Counted lines overwrite the shelf.';

  @override
  String get discardCountQ => 'Discard this count?';

  @override
  String get everythingThrownAway =>
      'Everything counted so far is thrown away. The shelf is untouched.';

  @override
  String get keepCounting => 'Keep counting';

  @override
  String get keepIt => 'Keep it';

  @override
  String get discard => 'Discard';

  @override
  String get clear => 'Clear';

  @override
  String get countKeptOnDevice =>
      'A count in progress is kept on this device, so it survives a restart.';

  @override
  String get serverUnreadable =>
      'The server sent something the app could not read.';
}
