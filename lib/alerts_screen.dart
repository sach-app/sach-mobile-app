import 'package:flutter/material.dart';
import 'theme.dart';
import 'locale_store.dart';
import 'app_strings.dart';
import 'app_nav.dart';
import 'sach_header.dart';
import 'alert_store.dart';
import 'sach_route.dart';
import 'dashboard_screen.dart';
import 'my_firs_screen.dart';
import 'profile_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    AlertStore.instance.addListener(_rebuild);
    LocaleStore.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    AlertStore.instance.removeListener(_rebuild);
    LocaleStore.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final store = AlertStore.instance;
    final isUrdu = LocaleStore.instance.isUrdu;
    final dir = LocaleStore.instance.dir;

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        backgroundColor: kBgDeep,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 4),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SachHeader(
              title: S.alertsTitle,
              subtitle: store.unreadCount > 0
                  ? '${store.unreadCount} ${S.unread}'
                  : null,
              actions: [
                if (store.unreadCount > 0)
                  TextButton(
                    onPressed: () => store.markAllRead(),
                    child: Text(
                      S.markAllRead,
                      style: const TextStyle(
                        color: kGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                buildAppMenu(
                  context,
                  2,
                  extraItems: [
                    if (store.alerts.isNotEmpty)
                      _popItem(
                        Icons.done_all_rounded,
                        S.markAllRead,
                        'mark_read',
                      ),
                    if (store.alerts.isNotEmpty)
                      _popItem(
                        Icons.delete_outline_rounded,
                        S.clearAllAlerts,
                        'clear',
                        danger: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: store.alerts.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: store.alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _AlertCard(
                  item: store.alerts[i],
                  isUrdu: isUrdu,
                  onTap: () {
                    store.markRead(store.alerts[i]);
                    _showAlertDetail(context, store.alerts[i], isUrdu);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            color: kTextSub.withOpacity(0.4),
            size: 72,
          ),
          const SizedBox(height: 20),
          Text(
            S.noAlertsYet,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(S.noAlertsHint, style: TextStyle(color: kTextSub, fontSize: 13)),
        ],
      ),
    );
  }

  void _showAlertDetail(BuildContext context, AlertItem alert, bool isUrdu) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: kDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Alert icon
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGreen.withOpacity(0.1),
                  border: Border.all(
                    color: kGreen.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(alert.icon, color: kGreen, size: 32),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Center(
              child: Text(
                alert.title(isUrdu),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Case reference badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGold.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.folder_outlined, color: kGold, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      alert.subtitle(isUrdu),
                      style: const TextStyle(
                        color: kGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Details box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kInputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kDivider, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(Icons.access_time_rounded, 'Time', alert.time),
                  const SizedBox(height: 10),
                  _detailRow(Icons.info_outline_rounded, 'Status', 'Read'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Dismiss button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: kGreen.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: kGreen.withOpacity(0.3)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Dismiss',
                  style: TextStyle(
                    color: kGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: kTextSub, size: 14),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: kTextSub,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _popItem(
    IconData icon,
    String label,
    String value, {
    bool danger = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: danger ? Colors.redAccent : kGold, size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: danger ? Colors.redAccent : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Alert Card ───────────────────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final AlertItem item;
  final bool isUrdu;
  final VoidCallback onTap;
  const _AlertCard({
    required this.item,
    required this.isUrdu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: kGreen.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.isUnread ? kGreen.withOpacity(0.25) : kDivider,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.isUnread ? kGreen.withOpacity(0.12) : kInputBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isUnread ? kGreen.withOpacity(0.3) : kDivider,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color: item.isUnread ? kGreen : kTextSub,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title(isUrdu),
                      style: TextStyle(
                        color: item.isUnread
                            ? Colors.white
                            : Colors.white.withOpacity(0.75),
                        fontSize: 14,
                        fontWeight: item.isUnread
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle(isUrdu),
                      style: TextStyle(color: kTextSub, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.time,
                      style: TextStyle(
                        color: kTextSub.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.isUnread)
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kGold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
