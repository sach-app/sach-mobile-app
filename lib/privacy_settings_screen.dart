import 'package:flutter/material.dart';
import 'theme.dart';
import 'app_nav.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});
  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  // Toggle states
  bool _twoFactor = true;
  bool _locationAccess = true;
  bool _dataSharing = false;
  bool _activityVisible = true;
  bool _loginAlerts = true;

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Privacy Settings',
          style: TextStyle(
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
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 60),
            children: [
              // ── Authentication & Access ─────────────────────────────────
              _sectionHeader('Authentication & Access', Icons.security_rounded),
              const SizedBox(height: 10),
              _card([
                _toggleTile(
                  icon: Icons.verified_user_rounded,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Require OTP on every login',
                  value: _twoFactor,
                  onChanged: (v) => setState(() => _twoFactor = v),
                  accent: kGreen,
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Login Activity Alerts',
                  subtitle: 'Get notified on new sign-ins',
                  value: _loginAlerts,
                  onChanged: (v) => setState(() => _loginAlerts = v),
                  accent: kGreen,
                ),
              ]),
              const SizedBox(height: 20),

              // ── Data & Location ─────────────────────────────────────────
              _sectionHeader('Data & Location', Icons.location_on_rounded),
              const SizedBox(height: 10),
              _card([
                _toggleTile(
                  icon: Icons.location_on_rounded,
                  title: 'Location Access',
                  subtitle: 'Allow app to use your GPS for FIR filing',
                  value: _locationAccess,
                  onChanged: (v) => setState(() => _locationAccess = v),
                  accent: kGold,
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.share_rounded,
                  title: 'Anonymous Data Sharing',
                  subtitle: 'Help improve SACH by sharing usage statistics',
                  value: _dataSharing,
                  onChanged: (v) => setState(() => _dataSharing = v),
                  accent: kGreen,
                ),
              ]),
              const SizedBox(height: 20),

              // ── Account Visibility ──────────────────────────────────────
              _sectionHeader('Account Visibility', Icons.visibility_rounded),
              const SizedBox(height: 10),
              _card([
                _toggleTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile Visible to Officers',
                  subtitle: 'Allow assigned officers to view your profile',
                  value: _activityVisible,
                  onChanged: (v) => setState(() => _activityVisible = v),
                  accent: kGreen,
                ),
                _divider(),
                _navTile(
                  icon: Icons.history_rounded,
                  title: 'Login History',
                  subtitle: 'View recent sign-in sessions',
                  onTap: () => _showLoginHistory(context),
                ),
                _divider(),
                _navTile(
                  icon: Icons.download_rounded,
                  title: 'Download My Data',
                  subtitle: 'Request a copy of your SACH data',
                  onTap: () => _showSnack('Data export request submitted.'),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Danger Zone ─────────────────────────────────────────────
              _sectionHeader(
                'Danger Zone',
                Icons.warning_rounded,
                danger: true,
              ),
              const SizedBox(height: 10),
              _card([
                _navTile(
                  icon: Icons.block_rounded,
                  title: 'Deactivate Account',
                  subtitle: 'Temporarily disable your SACH account',
                  onTap: () => _confirmAction(
                    context,
                    'Deactivate Account',
                    'Your account will be temporarily disabled. You can reactivate by contacting support.',
                  ),
                  danger: true,
                ),
                _divider(),
                _navTile(
                  icon: Icons.delete_forever_rounded,
                  title: 'Delete Account',
                  subtitle: 'Permanently remove all your data',
                  onTap: () => _confirmAction(
                    context,
                    'Delete Account',
                    'This will permanently erase all your FIRs, profile data, and documents. This action cannot be undone.',
                  ),
                  danger: true,
                ),
              ]),
              const SizedBox(height: 24),

              // Footer
              Center(
                child: Text(
                  'Your data is protected under Pakistan\'s\nPersonal Data Protection Act 2023.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextSub, fontSize: 11, height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon, {bool danger = false}) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: danger ? Colors.redAccent : kGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Icon(icon, color: danger ? Colors.redAccent : kGold, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: danger ? Colors.redAccent : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: kTextSub, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: kGold,
            activeTrackColor: kGreen.withOpacity(0.5),
            inactiveTrackColor: kDivider,
            inactiveThumbColor: kTextSub,
          ),
        ],
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: danger ? Colors.redAccent.withOpacity(0.08) : kInputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: danger ? Colors.redAccent.withOpacity(0.2) : kDivider,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: danger ? Colors.redAccent : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: kTextSub, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: kTextSub, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: kDivider, indent: 16, endIndent: 16);

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: kBgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showLoginHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Login Sessions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            for (final session in [
              ('Lahore, Punjab', 'Today 14:32', Icons.smartphone_rounded),
              ('Lahore, Punjab', 'Yesterday 09:15', Icons.laptop_mac_rounded),
              ('Islamabad', '2 days ago 19:44', Icons.smartphone_rounded),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Icon(session.$3, color: kGold, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.$1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            session.$2,
                            style: TextStyle(color: kTextSub, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kGreen.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          color: kGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmAction(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kBgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: kTextSub, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: kTextSub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
