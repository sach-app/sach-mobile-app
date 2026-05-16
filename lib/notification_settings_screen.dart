import 'package:flutter/material.dart';
import 'theme.dart';
import 'app_nav.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // General
  bool _pushEnabled = true;
  bool _smsEnabled = true;
  bool _emailEnabled = false;

  // FIR & Alerts
  bool _firStatusUpdates = true;
  bool _firAssignmentAlerts = true;
  bool _govtAlerts = true;
  bool _reminders = false;

  // Do Not Disturb
  bool _dndEnabled = false;
  TimeOfDay _dndStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _dndEnd = const TimeOfDay(hour: 7, minute: 0);

  // Sound & Haptics
  bool _sound = true;
  bool _vibration = true;

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

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
          'Notification Settings',
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
              // ── Notification Channels ───────────────────────────────────
              _sectionHeader(
                'Notification Channels',
                Icons.notifications_rounded,
              ),
              const SizedBox(height: 10),
              _card([
                _toggleTile(
                  icon: Icons.notifications_rounded,
                  title: 'Push Notifications',
                  subtitle: 'In-app alerts on your device',
                  value: _pushEnabled,
                  onChanged: (v) => setState(() => _pushEnabled = v),
                  accent: kGreen,
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.sms_rounded,
                  title: 'SMS Notifications',
                  subtitle: 'Important updates via text message',
                  value: _smsEnabled,
                  onChanged: (v) => setState(() => _smsEnabled = v),
                  accent: kGold,
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.email_rounded,
                  title: 'Email Notifications',
                  subtitle: 'Summaries and reports via email',
                  value: _emailEnabled,
                  onChanged: (v) => setState(() => _emailEnabled = v),
                  accent: kGreen,
                ),
              ]),
              const SizedBox(height: 20),

              // ── FIR & Complaint Alerts ──────────────────────────────────
              _sectionHeader(
                'FIR & Complaint Alerts',
                Icons.folder_open_rounded,
              ),
              const SizedBox(height: 10),
              _card([
                _toggleTile(
                  icon: Icons.update_rounded,
                  title: 'FIR Status Updates',
                  subtitle: 'Get notified when your FIR status changes',
                  value: _firStatusUpdates,
                  onChanged: (v) => setState(() => _firStatusUpdates = v),
                  accent: kGreen,
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.person_pin_circle_rounded,
                  title: 'Officer Assignment Alerts',
                  subtitle: 'Know when an officer is assigned to your case',
                  value: _firAssignmentAlerts,
                  onChanged: (v) => setState(() => _firAssignmentAlerts = v),
                  accent: kGold,
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.campaign_rounded,
                  title: 'Critical Alerts',
                  subtitle: 'Emergency and public safety broadcasts',
                  value: _govtAlerts,
                  onChanged: (v) => setState(() => _govtAlerts = v),
                  accent: kGreen,
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.alarm_rounded,
                  title: 'Follow-up Reminders',
                  subtitle: 'Reminders about pending actions on your FIRs',
                  value: _reminders,
                  onChanged: (v) => setState(() => _reminders = v),
                  accent: kGold,
                ),
              ]),
              const SizedBox(height: 20),

              // ── Sound & Haptics ─────────────────────────────────────────
              _sectionHeader('Sound & Haptics', Icons.volume_up_rounded),
              const SizedBox(height: 10),
              _card([
                _toggleTile(
                  icon: Icons.volume_up_rounded,
                  title: 'Notification Sound',
                  subtitle: 'Play a sound for incoming alerts',
                  value: _sound,
                  onChanged: (v) => setState(() => _sound = v),
                  accent: kGreen,
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.vibration_rounded,
                  title: 'Vibration',
                  subtitle: 'Vibrate on notifications',
                  value: _vibration,
                  onChanged: (v) => setState(() => _vibration = v),
                  accent: kGold,
                ),
              ]),
              const SizedBox(height: 20),

              // ── Do Not Disturb ──────────────────────────────────────────
              _sectionHeader('Do Not Disturb', Icons.do_not_disturb_on_rounded),
              const SizedBox(height: 10),
              _card([
                _toggleTile(
                  icon: Icons.do_not_disturb_on_rounded,
                  title: 'Enable Quiet Hours',
                  subtitle: 'Silence alerts between set times',
                  value: _dndEnabled,
                  onChanged: (v) => setState(() => _dndEnabled = v),
                  accent: kGold,
                ),
                if (_dndEnabled) ...[
                  _divider(),
                  _timeTile(
                    label: 'Start Time',
                    time: _dndStart,
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _dndStart,
                        builder: (ctx, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: kGreen,
                              onPrimary: Colors.white,
                              surface: kBgCard,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (t != null) setState(() => _dndStart = t);
                    },
                  ),
                  _divider(),
                  _timeTile(
                    label: 'End Time',
                    time: _dndEnd,
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _dndEnd,
                        builder: (ctx, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: kGreen,
                              onPrimary: Colors.white,
                              surface: kBgCard,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (t != null) setState(() => _dndEnd = t);
                    },
                  ),
                ],
              ]),
              const SizedBox(height: 24),

              // Footer
              Center(
                child: Text(
                  'Emergency critical alerts cannot be silenced\nand will always be delivered.',
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
  Widget _sectionHeader(String title, IconData icon) {
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
        Icon(icon, color: kGold, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
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

  Widget _timeTile({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
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
                color: kInputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kDivider),
              ),
              child: Icon(Icons.access_time_rounded, color: kGold, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: kGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kGold.withOpacity(0.3)),
              ),
              child: Text(
                _fmt(time),
                style: TextStyle(
                  color: kGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: kDivider, indent: 16, endIndent: 16);
}
