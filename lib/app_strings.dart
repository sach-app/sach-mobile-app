/// Bilingual string table for EN / UR.
/// Usage: S.t('key') where LocaleStore.instance.isUrdu determines the language.
/// For Urdu, directionality should be TextDirection.rtl.
library;

import 'locale_store.dart';

class S {
  S._();

  static bool get _u => LocaleStore.instance.isUrdu;

  // ── App-wide ────────────────────────────────────────────────────────────────
  static String get appName => _u ? 'ساچ پورٹل' : 'SACH Portal';
  static String get home => _u ? 'ہوم' : 'Home';
  static String get myFirs => _u ? 'میری ایف آئی آر' : 'My FIRs';
  static String get alerts => _u ? 'اطلاعات' : 'Alerts';
  static String get profile => _u ? 'پروفائل' : 'Profile';
  static String get signOut => _u ? 'لاگ آؤٹ' : 'Sign Out';
  static String get changeLanguage =>
      _u ? 'زبان تبدیل کریں' : 'Change Language';
  static String get switchLang =>
      _u ? 'Switch to English' : 'اردو میں تبدیل کریں';
  static String get pending => _u ? 'زیر التواء' : 'Pending';
  static String get resolved => _u ? 'حل شدہ' : 'Resolved';
  static String get investigating => _u ? 'تفتیش جاری' : 'Investigating';
  static String get closed => _u ? 'بند' : 'Closed';
  static String get underReview => _u ? 'جائزہ' : 'Under Review';
  static String get verified => _u ? 'تصدیق شدہ' : 'VERIFIED';
  static String get nadraVerified => _u ? 'ساچ تصدیق شدہ' : 'SACH Verified';
  static String get noResults => _u ? 'کوئی نتیجہ نہیں' : 'No results';
  static String get logout => _u ? 'لاگ آؤٹ' : 'Logout';

  // ── Menu / Nav ──────────────────────────────────────────────────────────────
  static String get goToDashboard => _u ? 'ڈیش بورڈ' : 'Go to Dashboard';
  static String get goToMyFirs => _u ? 'میری ایف آئی آر' : 'My FIRs';
  static String get goToAlerts => _u ? 'اطلاعات' : 'Alerts';
  static String get goToProfile => _u ? 'پروفائل' : 'Profile';
  static String get fileNewFir => _u ? 'نئی ایف آئی آر' : 'File New e-FIR';

  // ── Dashboard ───────────────────────────────────────────────────────────────
  static String get lodgeFir =>
      _u ? 'نئی ای-ایف آئی آر داخل کریں' : 'Lodge a New e-FIR';
  static String get fileSecurely => _u
      ? 'آن لائن محفوظ طریقے سے شکایت درج کریں'
      : 'File your complaint securely online';
  static String get startNewComplaint =>
      _u ? 'نئی شکایت شروع کریں' : 'Start New Complaint';
  static String get recentComplaints =>
      _u ? 'حالیہ شکایات' : 'Recent Complaints';
  static String get viewAll => _u ? 'سب دیکھیں' : 'View All';
  static String get totalFirs => _u ? 'کل ایف آئی آر' : 'Total FIRs';
  static String get noComplaintsYet =>
      _u ? 'ابھی تک کوئی شکایت نہیں' : 'No complaints filed yet';
  static String get noComplaintsHint => _u
      ? 'اوپر "نئی شکایت شروع کریں" دبائیں۔'
      : 'Use "Start New Complaint" above to\nfile your first e-FIR securely.';
  static String get latestAlerts => _u ? 'تازہ ترین اطلاعات' : 'Latest Alerts';
  static String get viewAllAlerts =>
      _u ? 'سب اطلاعات دیکھیں' : 'View all alerts';
  static String get noAlertsYet => _u ? 'کوئی اطلاع نہیں' : 'No alerts yet';

  // ── My FIRs ─────────────────────────────────────────────────────────────────
  static String get myComplaints => _u ? 'میری شکایات' : 'My Complaints';
  static String get allComplaints => _u ? 'تمام شکایات' : 'All Complaints';
  static String get filterByStatus =>
      _u ? 'حیثیت سے فلٹر کریں' : 'Filter by status';
  static String get noComplaintsFilter =>
      _u ? 'کوئی شکایت نہیں' : 'No complaints';
  static String get tapToFileFir => _u
      ? 'نئی ای-ایف آئی آر کے لیے + دبائیں'
      : 'Tap + to file a new e-FIR securely';

  // ── Alerts ──────────────────────────────────────────────────────────────────
  static String get alertsTitle =>
      _u ? 'اطلاعات اور اپڈیٹس' : 'Alerts & Updates';
  static String get unread => _u ? 'غیر پڑھی' : 'unread';
  static String get markAllRead => _u ? 'سب پڑھا نشان کریں' : 'Mark all read';
  static String get clearAllAlerts =>
      _u ? 'تمام اطلاعات حذف کریں' : 'Clear all alerts';
  static String get noAlertsHint => _u
      ? 'ایف آئی آر اپڈیٹس یہاں آئیں گی'
      : 'You\'ll be notified of FIR status updates here';

  // ── Profile ─────────────────────────────────────────────────────────────────
  static String get profileTitle => _u ? 'پروفائل' : 'Profile';
  static String get editProfile => _u ? 'پروفائل ترمیم کریں' : 'Edit Profile';
  static String get contactInfo => _u ? 'رابطہ معلومات' : 'Contact Information';
  static String get phoneNumber => _u ? 'فون نمبر' : 'Phone Number';
  static String get emailAddress => _u ? 'ای میل پتہ' : 'Email Address';
  static String get residentialInfo =>
      _u ? 'رہائشی معلومات' : 'Residential Information';
  static String get district => _u ? 'ضلع' : 'District';
  static String get province => _u ? 'صوبہ' : 'Province';
  static String get permanentAddress => _u ? 'مستقل پتہ' : 'Permanent Address';
  static String get accountSettings =>
      _u ? 'اکاؤنٹ سیٹنگز' : 'Account Settings';
  static String get privacySettings =>
      _u ? 'رازداری سیٹنگز' : 'Privacy Settings';
  static String get notifSettings =>
      _u ? 'اطلاع سیٹنگز' : 'Notification Settings';
  static String get verifiedCitizen =>
      _u ? 'تصدیق شدہ شہری' : 'Verified Citizen';
  static String get cnicNumber => _u ? 'شناختی کارڈ نمبر' : 'CNIC Number';
  static String get idStatus => _u ? 'شناخت کی حیثیت' : 'ID Status';

  // ── Edit Profile ─────────────────────────────────────────────────────────────
  static String get epPersonalInfo =>
      _u ? 'ذاتی معلومات' : 'Personal Information';
  static String get epFullName => _u ? 'پورا نام' : 'Full Name';
  static String get epAltPhone =>
      _u ? 'متبادل فون نمبر' : 'Alternate Phone Number';
  static String get epPhoneHint =>
      _u ? 'فون نمبر درج کریں' : 'Enter phone number';
  static String get epEmailHint =>
      _u ? 'ای میل پتہ درج کریں' : 'Enter email address';
  static String get epAddressDetails =>
      _u ? 'پتہ کی تفصیلات' : 'Address Details';
  static String get epAddressHint =>
      _u ? 'اپنا مستقل پتہ درج کریں' : 'Enter your permanent address';
  static String get epCity => _u ? 'شہر' : 'City';
  static String get epCityHint => _u ? 'شہر کا نام' : 'Enter city name';
  static String get epSaveChanges =>
      _u ? 'تبدیلیاں محفوظ کریں' : 'Save Changes';
  static String get epCancel => _u ? 'منسوخ' : 'Cancel';
  static String get epNadraNotice => _u
      ? 'تصدیق شدہ اکاؤنٹ: آپ کا نام اور شناختی کارڈ ساچ ویریفیکیشن سے مقفل ہیں اور تبدیل نہیں کیے جا سکتے۔'
      : 'Verified Account: Your Name and CNIC are locked via SACH Verification and cannot be altered.';

  // ── File FIR ────────────────────────────────────────────────────────────────
  static String get fileFir => _u ? 'ای-ایف آئی آر داخل کریں' : 'File e-FIR';
  static String get stepLocation => _u ? 'مقام' : 'Location';
  static String get stepDetails => _u ? 'تفصیلات' : 'Details';
  static String get stepEvidence => _u ? 'ثبوت' : 'Evidence';
  static String get streetAddress => _u ? 'گلی کا پتہ' : 'Street Address';
  static String get cityArea => _u ? 'شہر / علاقہ' : 'City / Area';
  static String get useCurrentLocation =>
      _u ? 'موجودہ مقام استعمال کریں' : 'Use Current Location';
  static String get usingCurrentLocation =>
      _u ? 'موجودہ مقام استعمال ہو رہا ہے' : 'Using Current Location';
  static String get tapToPin =>
      _u ? 'نقشے پر مقام نشان کریں' : 'Tap anywhere on the map to pin location';
  static String get locationPinned =>
      _u ? 'مقام نشان ہو گیا ✓' : 'Location pinned ✓  Tap to change';
  static String get incidentDateTime =>
      _u ? 'واقعہ کی تاریخ / وقت' : 'Incident Date / Time';
  static String get selectDateTime =>
      _u ? 'تاریخ اور وقت منتخب کریں' : 'Select date and time';
  static String get incidentCategory =>
      _u ? 'واقعہ کی قسم' : 'Incident Category';
  static String get selectCategory =>
      _u ? 'واقعہ کی قسم منتخب کریں' : 'Select incident type';
  static String get districtJurisdiction =>
      _u ? 'ضلعی دائرہ کار' : 'District Jurisdiction';
  static String get selectDistrict => _u ? 'ضلع منتخب کریں' : 'Select district';
  static String get incidentDescription =>
      _u ? 'واقعہ کی تفصیل' : 'Incident Description';
  static String get descHint =>
      _u ? 'واقعہ تفصیل سے بیان کریں…' : 'Describe the incident in detail…';
  static String get voiceHint => _u
      ? 'آواز سے متن کے لیے مائیکروفون دبائیں'
      : 'Tap the microphone icon to use voice-to-text';
  static String get uploadEvidence =>
      _u ? 'ثبوت اپلوڈ کریں' : 'Upload Evidence';
  static String get uploadHint => _u
      ? 'شکایت کی تائید کے لیے تصاویر یا ویڈیو شامل کریں'
      : 'Add photos or videos to support your complaint';
  static String get tapToUpload =>
      _u ? 'تصویر/ویڈیو اپلوڈ کریں' : 'Tap to upload photo/video evidence';
  static String get evidenceAdded => _u ? 'ثبوت شامل ✓' : 'Evidence Added ✓';
  static String get evidenceOptional => _u
      ? 'ثبوت اختیاری ہے۔ بعد میں بھی شامل کر سکتے ہیں۔'
      : 'Evidence is optional. You can attach it later from My FIRs.';
  static String get nextDetails =>
      _u ? 'اگلا: واقعہ کی تفصیل' : 'Next: Incident Details';
  static String get nextEvidence =>
      _u ? 'اگلا: ثبوت اپلوڈ کریں' : 'Next: Upload Evidence';
  static String get submitFir =>
      _u ? 'محفوظ ای-ایف آئی آر جمع کریں' : 'Submit Secure e-FIR';
  static String get firSubmitted =>
      _u ? 'ای-ایف آئی آر جمع ہو گئی!' : 'e-FIR Submitted!';
  static String get firConfirmMsg => _u
      ? 'آپ کی ایف آئی آر محفوظ طریقے سے جمع کر دی گئی ہے۔'
      : 'Your complaint has been securely lodged.';
  static String get viewDashboard =>
      _u ? 'ڈیش بورڈ دیکھیں' : 'View My Dashboard';
}
