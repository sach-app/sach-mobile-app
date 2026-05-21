import 'package:flutter/material.dart';
import 'theme.dart';
import 'sach_route.dart';
import 'app_nav.dart';
import 'edit_profile_screen.dart';
import 'app_strings.dart';
import 'user_profile_store.dart';
import 'change_password_dialog.dart';
import 'locale_store.dart';
import 'sach_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    UserProfileStore.instance.addListener(_onProfileChanged);
    LocaleStore.instance.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    UserProfileStore.instance.removeListener(_onProfileChanged);
    LocaleStore.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final p = UserProfileStore.instance.profile;
    return Scaffold(
      backgroundColor: kBgDeep,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 4),
        child: SachHeader(
          title: S.profileTitle,
          actions: [
            buildAppMenu(
              context,
              3,
              extraItems: [
                PopupMenuItem<String>(
                  value: 'edit_profile',
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_rounded, color: kGold, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          S.editProfile,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const SachBackgroundGlow(),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // ── Identity Card ─────────────────────────────────────────────
              _buildIdentityCard(p),
              const SizedBox(height: 12),

              // ── Edit Profile button ───────────────────────────────────────
              _buildEditButton(context),
              const SizedBox(height: 24),

              // ── Contact Information ───────────────────────────────────────
              _buildSectionHeader(S.contactInfo),
              const SizedBox(height: 12),
              _buildInfoCard([
                if (p.altPhone.isNotEmpty)
                  _InfoRow(
                    icon: Icons.phone_rounded,
                    label: 'Alternate Phone',
                    value: _formatPhone(p.altPhone),
                  )
                else
                  _InfoRow(
                    icon: Icons.phone_rounded,
                    label: 'Alternate Phone',
                    value: '—',
                    empty: true,
                  ),
                _InfoRow(
                  icon: Icons.email_rounded,
                  label: 'Email Address',
                  value: p.email.isNotEmpty ? p.email : '—',
                  empty: p.email.isEmpty,
                ),
              ]),
              const SizedBox(height: 20),

              // ── Residential Information ───────────────────────────────────
              _buildSectionHeader(S.residentialInfo),
              const SizedBox(height: 12),
              _buildInfoCard([
                _InfoRow(
                  label: 'District',
                  value: p.district.isNotEmpty ? p.district : '—',
                  empty: p.district.isEmpty,
                ),
                _InfoRow(
                  label: 'City',
                  value: p.city.isNotEmpty ? p.city : '—',
                  empty: p.city.isEmpty,
                ),
                _InfoRow(
                  label: 'Permanent Address',
                  value: p.address.isNotEmpty ? p.address : '—',
                  empty: p.address.isEmpty,
                ),
              ]),
              const SizedBox(height: 20),

              // ── Settings ──────────────────────────────────────────
              _buildSectionHeader(S.accountSettings),
              const SizedBox(height: 12),
              _buildSettingsTile(
                icon: Icons.password_rounded,
                label: 'Change Password',
                onTap: () => showChangePasswordDialog(context),
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                icon: Icons.settings_rounded,
                label: S.accountSettings,
                onTap: () => sachPush(context, const EditProfileScreen()),
              ),
              const SizedBox(height: 8),
              _buildLanguageTile(context),
              const SizedBox(height: 8),
              _buildSettingsTile(
                icon: Icons.logout_rounded,
                label: S.logout,
                danger: true,
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (r) => false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPhone(String raw) {
    String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('92')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.isEmpty) return '—';
    return '+92 $digits';
  }

  // ── Identity card ─────────────────────────────────────────────────────────
  Widget _buildIdentityCard(UserProfile p) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kGreen.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [kGreen.withOpacity(0.6), kGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: kGold.withOpacity(0.4), width: 2),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, color: kGold, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          S.verifiedCitizen,
                          style: TextStyle(
                            color: kGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            height: 1,
            color: kDivider,
          ),
          Text(S.cnicNumber, style: TextStyle(color: kTextSub, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            p.cnic,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.idStatus, style: TextStyle(color: kTextSub, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGreen.withOpacity(0.4)),
                ),
                child: Text(
                  S.verified,
                  style: TextStyle(
                    color: kGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kGreen, Color(0xFF015C2E)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => sachPush(context, const EditProfileScreen()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
        label: Text(
          S.editProfile,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider, width: 1.5),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (row.icon != null) ...[
                      Icon(
                        row.icon,
                        color: row.empty ? kTextSub : kGold,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.label,
                            style: TextStyle(color: kTextSub, fontSize: 11),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            row.value,
                            style: TextStyle(
                              color: row.empty
                                  ? kTextSub.withOpacity(0.5)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: row.empty
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                              fontStyle: row.empty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                Divider(color: kDivider, height: 1, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return Material(
      color: kBgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: kGreen.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: danger ? Colors.redAccent.withOpacity(0.2) : kDivider,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: danger ? Colors.redAccent.withOpacity(0.08) : kInputBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: danger
                        ? Colors.redAccent.withOpacity(0.2)
                        : kDivider,
                  ),
                ),
                child: Icon(
                  icon,
                  color: danger ? Colors.redAccent : kGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: danger ? Colors.redAccent : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: kTextSub, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDivider, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: kInputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kDivider),
            ),
            child: const Icon(Icons.language_rounded, color: kGold, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              S.changeLanguage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<bool>(
              value: LocaleStore.instance.isUrdu,
              dropdownColor: kBgDeep,
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(Icons.arrow_drop_down_rounded, color: kGold),
              style: const TextStyle(
                color: kGold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              items: const [
                DropdownMenuItem(value: false, child: Text('English')),
                DropdownMenuItem(value: true, child: Text('اردو')),
              ],
              onChanged: (bool? isUrdu) {
                if (isUrdu != null && isUrdu != LocaleStore.instance.isUrdu) {
                  LocaleStore.instance.toggle();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row data class ────────────────────────────────────────────────────────
class _InfoRow {
  final IconData? icon;
  final String label;
  final String value;
  final bool empty;
  const _InfoRow({
    this.icon,
    required this.label,
    required this.value,
    this.empty = false,
  });
}
