import 'package:flutter/material.dart';
import 'theme.dart';
import 'fir_model.dart';
import 'fir_store.dart';
import 'file_fir_screen.dart';
import 'my_firs_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';
import 'sach_route.dart';
import 'locale_store.dart';
import 'alert_store.dart';
import 'app_strings.dart';
import 'app_nav.dart';
import 'sach_header.dart';
import 'fir_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
    FirStore.instance.addListener(_onStoreUpdate);
    LocaleStore.instance.addListener(_onLocaleUpdate);
  }

  @override
  void dispose() {
    FirStore.instance.removeListener(_onStoreUpdate);
    LocaleStore.instance.removeListener(_onLocaleUpdate);
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onStoreUpdate() => setState(() {});
  void _onLocaleUpdate() => setState(() {});

  // Navigate to FileFirScreen and add the returned FIR to the store
  Future<void> _openFileFir() async {
    final result = await sachPush<FirItem>(context, const FileFirScreen());
    if (result != null && mounted) FirStore.instance.add(result);
  }

  // Stats via FirStore
  int get _pending => FirStore.instance.pending;
  int get _resolved => FirStore.instance.resolved;
  List<FirItem> get _firs => FirStore.instance.firs.toList();

  // ── Bell popup ────────────────────────────────────────────────────────────
  void _showAlertPopup(BuildContext context) {
    final isUrdu = LocaleStore.instance.isUrdu;
    final top3 = AlertStore.instance.alerts.take(3).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: kBgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    S.latestAlerts,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      appTabNotifier.value = 2; // Switch to Alerts tab
                    },
                    child: Text(
                      S.viewAllAlerts,
                      style: const TextStyle(
                        color: kGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (top3.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(S.noAlertsYet, style: TextStyle(color: kTextSub)),
                )
              else
                ...top3.map(
                  (a) => Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        AlertStore.instance.markRead(a);
                        setLocal(() {});
                        setState(() {});
                        _showAlertDetail(context, a, isUrdu);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: a.isUnread
                                    ? kGreen.withOpacity(0.12)
                                    : kInputBg,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: a.isUnread
                                      ? kGreen.withOpacity(0.3)
                                      : kDivider,
                                ),
                              ),
                              child: Icon(
                                a.icon,
                                color: a.isUnread ? kGreen : kTextSub,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title(isUrdu),
                                    style: TextStyle(
                                      color: a.isUnread
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 13,
                                      fontWeight: a.isUnread
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    a.subtitle(isUrdu),
                                    style: TextStyle(
                                      color: kTextSub,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (a.isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kGold,
                                ),
                              )
                            else
                              Icon(
                                Icons.chevron_right_rounded,
                                color: kTextSub,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Alert Detail Sheet ────────────────────────────────────────────────────
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
            // Handle
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
            // Icon + badge
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGreen.withOpacity(0.1),
                  border: Border.all(
                    color: kGreen.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(alert.icon, color: kGreen, size: 30),
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
            const SizedBox(height: 8),
            // Subtitle / case ref
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
                    Icon(Icons.folder_outlined, color: kGold, size: 13),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    final isUrdu = LocaleStore.instance.isUrdu;
    return SachHeader(
      title: S.appName,
      actions: [
        // Language toggle button
        GestureDetector(
          onTap: () => LocaleStore.instance.toggle(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kInputBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kDivider, width: 1),
            ),
            child: Row(
              children: [
                Text(
                  'EN',
                  style: TextStyle(
                    color: isUrdu ? kTextSub : kGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '  |  ',
                  style: TextStyle(color: kDivider, fontSize: 12),
                ),
                Text(
                  'اردو',
                  style: TextStyle(
                    color: isUrdu ? kGold : kTextSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        buildAppMenu(context, 0),
      ],
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserCard(),
            const SizedBox(height: 20),
            _buildFirCta(),
            const SizedBox(height: 24),
            if (_firs.isNotEmpty) _buildStatsRow(),
            if (_firs.isNotEmpty) const SizedBox(height: 24),
            _buildComplaintsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── User Card ────────────────────────────────────────────────────────────
  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGreen.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
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
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muhammad Ahmed Khan',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
          // Bell icon — shows latest 3 alerts popup
          Stack(
            children: [
              IconButton(
                onPressed: () => _showAlertPopup(context),
                icon: Icon(
                  Icons.notifications_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 22,
                ),
              ),
              if (AlertStore.instance.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: kGold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Lodge FIR CTA ────────────────────────────────────────────────────────
  Widget _buildFirCta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2B15), Color(0xFF071A0E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kGold.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kGreen.withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kGreen.withOpacity(0.12),
              border: Border.all(color: kGreen.withOpacity(0.3), width: 1.5),
            ),
            child: const Icon(Icons.campaign_rounded, color: kGreen, size: 34),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFF8CFFC2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              S.lodgeFir,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(S.fileSecurely, style: TextStyle(color: kTextSub, fontSize: 13)),
          const SizedBox(height: 20),
          SachGradientButton(
            label: S.startNewComplaint,
            icon: Icons.add_rounded,
            onPressed: _openFileFir,
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatChip(
          label: S.totalFirs,
          value: '${_firs.length}',
          icon: Icons.folder_rounded,
        ),
        const SizedBox(width: 12),
        _StatChip(
          label: S.pending,
          value: '$_pending',
          icon: Icons.hourglass_top_rounded,
        ),
        const SizedBox(width: 12),
        _StatChip(
          label: S.resolved,
          value: '$_resolved',
          icon: Icons.check_circle_rounded,
        ),
      ],
    );
  }

  // ─── Complaints Section ───────────────────────────────────────────────────
  Widget _buildComplaintsSection() {
    if (_firs.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              S.recentComplaints,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => appTabNotifier.value = 1, // Switch to My FIRs tab
              child: Text(
                S.viewAll,
                style: TextStyle(
                  color: kGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._firs
            .take(5)
            .map(
              (fir) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FirCard(item: fir),
              ),
            ),
      ],
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kDivider, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_rounded,
            color: kTextSub.withOpacity(0.5),
            size: 52,
          ),
          const SizedBox(height: 16),
          Text(
            S.noComplaintsYet,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            S.noComplaintsHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextSub, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

}

// ─── Stat Chip ────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: kBgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kDivider, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: kGold, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: kTextSub,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FIR Card ──────────────────────────────────────────────────────────────────
class _FirCard extends StatelessWidget {
  final FirItem item;
  const _FirCard({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Investigating':
        return const Color(0xFF3B82F6);
      case 'Resolved':
        return kGreen;
      default:
        return kTextSub;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBgCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => sachPush(context, FirDetailScreen(fir: item)),
        borderRadius: BorderRadius.circular(16),
        splashColor: kGreen.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kDivider, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kGreen.withOpacity(0.2)),
                ),
                child: Icon(Icons.description_rounded, color: kGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.id,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _statusColor.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: TextStyle(color: kTextSub, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (item.city.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: kTextSub,
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.city,
                            style: TextStyle(color: kTextSub, fontSize: 11),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: kTextSub,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.date,
                          style: TextStyle(color: kTextSub, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: kTextSub, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
