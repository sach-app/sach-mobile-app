import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'app_strings.dart';
import 'app_nav.dart';
import 'user_profile_store.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _altPhoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late String? _selectedDistrict;

  // 15 Pakistan districts
  static const List<String> _districts = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Peshawar',
    'Quetta',
    'Sialkot',
    'Gujranwala',
    'Hyderabad',
    'Bahawalpur',
    'Sargodha',
    'Sukkur',
    'Larkana',
  ];

  @override
  void initState() {
    super.initState();
    final p = UserProfileStore.instance.profile;
    _altPhoneCtrl = TextEditingController(text: p.altPhone);
    _emailCtrl = TextEditingController(text: p.email);
    _addressCtrl = TextEditingController(text: p.address);
    _cityCtrl = TextEditingController(text: p.city);
    _selectedDistrict = _districts.contains(p.district) ? p.district : null;
  }

  @override
  void dispose() {
    _altPhoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    UserProfileStore.instance.saveEdits(
      altPhone: _altPhoneCtrl.text,
      email: _emailCtrl.text,
      address: _addressCtrl.text,
      district: _selectedDistrict ?? '',
      city: _cityCtrl.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: kGold, size: 18),
            const SizedBox(width: 10),
            const Text(
              'Profile updated successfully',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: kBgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profile = UserProfileStore.instance.profile;
    return Scaffold(
      backgroundColor: kBgDeep,
      appBar: AppBar(
        backgroundColor: kBgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kGold,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          S.editProfile,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [buildAppMenu(context, 3)],
      ),
      body: Stack(
        children: [
          const SachBackgroundGlow(),
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                // ── Avatar & identity section ────────────────────────────────
                _buildAvatarSection(profile),
                const SizedBox(height: 28),

                // ── Personal Information ─────────────────────────────────────
                _sectionLabel(S.epPersonalInfo),
                const SizedBox(height: 12),

                SachLabel(S.epFullName),
                _lockedField(profile.fullName),
                const SizedBox(height: 16),

                SachLabel(S.epAltPhone),
                TextFormField(
                  controller: _altPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: sachInputDecoration(
                    hint: S.epPhoneHint,
                    prefixIcon: Container(
                      alignment: Alignment.center,
                      width: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '+92',
                            style: TextStyle(
                              color: kGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 16,
                            margin: const EdgeInsets.only(left: 8),
                            color: kDivider,
                          ),
                        ],
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      final digits = v.replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 12 || !digits.startsWith('923'))
                        return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                  inputFormatters: [_PhoneFormatter()],
                ),
                const SizedBox(height: 16),

                SachLabel(S.emailAddress),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: sachInputDecoration(
                    hint: S.epEmailHint,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.email_outlined, color: kGold, size: 18),
                    ),
                  ),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && !v.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // ── Address Details ──────────────────────────────────────────
                _sectionLabel(S.epAddressDetails),
                const SizedBox(height: 12),

                SachLabel(S.permanentAddress),
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: sachInputDecoration(hint: S.epAddressHint),
                ),
                const SizedBox(height: 16),

                SachLabel(S.district),
                _buildDistrictDropdown(),
                const SizedBox(height: 16),

                SachLabel(S.epCity),
                TextFormField(
                  controller: _cityCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: sachInputDecoration(hint: S.epCityHint),
                ),
                const SizedBox(height: 24),

                // ── Locked fields notice ──────────────────────────────────
                _buildLockedNotice(),
                const SizedBox(height: 28),

                // ── Save button ──────────────────────────────────────────────
                SachGradientButton(
                  label: S.epSaveChanges,
                  icon: Icons.save_rounded,
                  onPressed: _saveChanges,
                ),
                const SizedBox(height: 14),

                // ── Cancel ───────────────────────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(
                      S.epCancel,
                      style: TextStyle(
                        color: kTextSub,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar section ─────────────────────────────────────────────────────────
  Widget _buildAvatarSection(dynamic profile) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [kGreen.withOpacity(0.55), kGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: kGold.withOpacity(0.5), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: kGreen.withOpacity(0.35),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGold,
                  border: Border.all(color: kBgDeep, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: kGold.withOpacity(0.4), blurRadius: 8),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Identity-locked name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.lock_rounded, color: kTextSub, size: 13),
          ],
        ),
        const SizedBox(height: 5),
        // Identity-locked CNIC
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.cnic,
              style: TextStyle(
                color: kTextSub,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 5),
            Icon(Icons.lock_rounded, color: kTextSub, size: 11),
          ],
        ),
      ],
    );
  }

  // ── Section label with green left-accent ──────────────────────────────────
  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: kGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── Non-editable (locked) field ───────────────────────────────────────────
  Widget _lockedField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: kInputBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 14,
              ),
            ),
          ),
          Icon(Icons.lock_rounded, color: kTextSub, size: 14),
        ],
      ),
    );
  }

  // ── District dropdown ─────────────────────────────────────────────────────
  Widget _buildDistrictDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDistrict,
      dropdownColor: kBgCard,
      decoration: sachInputDecoration(hint: S.selectDistrict),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextSub),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      items: _districts
          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
          .toList(),
      onChanged: (v) => setState(() => _selectedDistrict = v),
    );
  }

  // ── Locked fields notice ──────────────────────────────────────────────────
  Widget _buildLockedNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kGold.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold.withOpacity(0.25), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(right: 10, top: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kGold.withOpacity(0.12),
              border: Border.all(color: kGold.withOpacity(0.4)),
            ),
            child: Center(
              child: Icon(Icons.verified_rounded, color: kGold, size: 12),
            ),
          ),
          Expanded(
            child: Text(
              S.epLockedNotice,
              style: TextStyle(
                color: kGold.withOpacity(0.8),
                fontSize: 11.5,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Phone Formatter ──────────────────────────────────────────────────────────
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    // Extract only digits from the raw input
    String digits = next.text.replaceAll(RegExp(r'\D'), '');
    // Remove leading '92' if user typed it (we always show +92)
    if (digits.startsWith('92')) digits = digits.substring(2);
    // Remove leading '0' (habit: 03XX → 3XX)
    if (digits.startsWith('0')) digits = digits.substring(1);
    // First digit must be 3 — discard anything else
    if (digits.isNotEmpty && digits[0] != '3') digits = '';
    // Cap at 10 digits (excluding +92)
    if (digits.length > 10) digits = digits.substring(0, 10);
    // Build formatted string: +92 followed by digits
    final text = '+92 $digits';
    return next.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
