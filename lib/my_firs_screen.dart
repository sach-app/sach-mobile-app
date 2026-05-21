import 'package:flutter/material.dart';
import 'theme.dart';
import 'fir_model.dart';
import 'fir_store.dart';
import 'file_fir_screen.dart';
import 'dashboard_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';
import 'sach_route.dart';
import 'locale_store.dart';
import 'app_strings.dart';
import 'app_nav.dart';
import 'sach_header.dart';
import 'fir_detail_screen.dart';
import 'dart:convert';
import 'api_service.dart';

class MyFirsScreen extends StatefulWidget {
  const MyFirsScreen({super.key});

  @override
  State<MyFirsScreen> createState() => _MyFirsScreenState();
}

class _MyFirsScreenState extends State<MyFirsScreen> {
  String _search = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    FirStore.instance.addListener(_onStoreUpdate);
    LocaleStore.instance.addListener(_onStoreUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FirStore.instance.fetchMyFirs();
    });
  }

  @override
  void dispose() {
    FirStore.instance.removeListener(_onStoreUpdate);
    LocaleStore.instance.removeListener(_onStoreUpdate);
    super.dispose();
  }

  void _onStoreUpdate() => setState(() {});

  List<FirItem> get _filtered {
    return FirStore.instance.firs.where((f) {
      final matchSearch =
          _search.isEmpty ||
          f.id.toLowerCase().contains(_search.toLowerCase()) ||
          f.title.toLowerCase().contains(_search.toLowerCase());
      if (_filterStatus == 'All') return matchSearch;

      final fStatus = f.status.toLowerCase().replaceAll('_', ' ').trim();
      final filterStatusNormalized = _filterStatus.toLowerCase().replaceAll('_', ' ').trim();

      bool isMatch = fStatus == filterStatusNormalized;
      if (!isMatch) {
        if (filterStatusNormalized == 'investigating' && fStatus == 'under investigation') {
          isMatch = true;
        } else if (filterStatusNormalized == 'under review' && fStatus == 'reviewed') {
          isMatch = true;
        } else if (filterStatusNormalized == 'pending' && fStatus == 'filed') {
          isMatch = true;
        }
      }
      return matchSearch && isMatch;
    }).toList();
  }

  Future<void> _openFileFir() async {
    final result = await sachPush<FirItem>(context, const FileFirScreen());
    if (result != null) FirStore.instance.add(result);
  }


  @override
  Widget build(BuildContext context) {
    final firs = _filtered;

    return Directionality(
      textDirection: LocaleStore.instance.dir,
      child: Scaffold(
        backgroundColor: kBgDeep,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 4),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SachHeader(
              title: S.myComplaints,
              actions: [
                // Filter button
                PopupMenuButton<String>(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        color: _filterStatus != 'All'
                            ? kGold
                            : Colors.white.withOpacity(0.75),
                        size: 24,
                      ),
                      if (_filterStatus != 'All')
                        Positioned(
                          right: -2,
                          top: -2,
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
                  color: kBgCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tooltip: 'Filter by status',
                  onSelected: (v) => setState(() => _filterStatus = v),
                  itemBuilder: (_) {
                    const statuses = [
                      'All',
                      'Pending',
                      'Investigating',
                      'Resolved',
                      'Closed',
                      'Under Review',
                    ];
                    const labels = [
                      'All Complaints',
                      'Pending',
                      'Investigating',
                      'Resolved',
                      'Closed',
                      'Under Review',
                    ];
                    return List.generate(statuses.length, (i) {
                      final selected = _filterStatus == statuses[i];
                      return PopupMenuItem<String>(
                        value: statuses[i],
                        padding: EdgeInsets.zero,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? kGreen.withOpacity(0.12)
                                : Colors.transparent,
                            border: i < statuses.length - 1
                                ? Border(
                                    bottom: BorderSide(
                                      color: kDivider.withOpacity(0.4),
                                    ),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.check_rounded
                                    : Icons.circle_outlined,
                                color: selected ? kGold : kTextSub,
                                size: 14,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                labels[i],
                                style: TextStyle(
                                  color: selected ? kGold : Colors.white,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
                // Search
                IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: kGold,
                    size: 24,
                  ),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: _FirSearchDelegate(),
                    );
                  },
                ),
                // 3-dots menu
                buildAppMenu(context, 1),
              ],
            ),
          ),
        ),
        body: FirStore.instance.isLoading
            ? const Center(child: CircularProgressIndicator(color: kGold))
            : firs.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: firs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _MyFirCard(item: firs[i]),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openFileFir,
          backgroundColor: kGreen,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  // Helper to build a themed popup menu item
  PopupMenuItem<String> menuItem(
    IconData icon,
    String label,
    String value, {
    bool danger = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: danger ? Colors.redAccent : kGold, size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: danger ? Colors.redAccent : Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
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
            Icons.folder_open_rounded,
            color: kTextSub.withOpacity(0.4),
            size: 72,
          ),
          const SizedBox(height: 20),
          Text(
            _filterStatus != 'All'
                ? '${S.noComplaintsFilter} — $_filterStatus'
                : S.noComplaintsYet,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(S.tapToFileFir, style: TextStyle(color: kTextSub, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── FIR Card ─────────────────────────────────────────────────────────────────
class _MyFirCard extends StatelessWidget {
  final FirItem item;
  const _MyFirCard({required this.item});

  Color get _statusColor {
    final status = item.status.toLowerCase().trim();
    switch (status) {
      case 'pending':
      case 'filed':
        return const Color(0xFFF59E0B);
      case 'under_review':
      case 'under review':
      case 'reviewed':
        return const Color(0xFF8B5CF6);
      case 'under_investigation':
      case 'under investigation':
      case 'investigating':
        return const Color(0xFF3B82F6);
      case 'resolved':
        return kGreen;
      case 'closed':
        return kTextSub;
      default:
        return kTextSub;
    }
  }

  String get _statusLabel {
    final status = item.status.toLowerCase().trim();
    switch (status) {
      case 'pending':
      case 'filed':
        return 'Pending';
      case 'under_review':
      case 'under review':
      case 'reviewed':
        return 'Under Review';
      case 'under_investigation':
      case 'under investigation':
      case 'investigating':
        return 'Investigating';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return item.status.replaceAll('_', ' ').split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '').join(' ');
    }
  }

  IconData get _categoryIcon {
    final t = item.title.toLowerCase();
    if (t.contains('theft') || t.contains('robbery'))
      return Icons.add_shopping_cart_outlined;
    if (t.contains('vehicle') || t.contains('accident'))
      return Icons.directions_car_outlined;
    if (t.contains('assault') || t.contains('violence'))
      return Icons.personal_injury_outlined;
    if (t.contains('cyber') || t.contains('fraud') || t.contains('scam'))
      return Icons.computer_outlined;
    if (t.contains('property') || t.contains('land'))
      return Icons.home_work_outlined;
    if (t.contains('missing')) return Icons.person_search_outlined;
    return Icons.description_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => sachPush(context, FirDetailScreen(fir: item)),
          splashColor: kGreen.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kGreen.withOpacity(0.2)),
                  ),
                  child: Icon(_categoryIcon, color: kGreen, size: 22),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.trackingNumber != null && item.trackingNumber!.isNotEmpty
                                      ? item.trackingNumber!
                                      : 'Tracking No: Pending',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.date,
                                  style: TextStyle(
                                    color: kTextSub,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status badge
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
                              _statusLabel,
                              style: TextStyle(
                                color: _statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        style: TextStyle(
                          color: kTextSub,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.city.isNotEmpty || item.district.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: kTextSub,
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              [
                                item.district,
                                item.city,
                              ].where((s) => s.isNotEmpty).join(', '),
                              style: TextStyle(color: kTextSub, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Chevron
                Icon(Icons.chevron_right_rounded, color: kTextSub, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Search Delegate ───────────────────────────────────────────────────────────
class _FirSearchDelegate extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(backgroundColor: kBgCard, elevation: 0),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(titleLarge: TextStyle(color: Colors.white)),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear_rounded, color: kGold),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kGold, size: 18),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(query);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(query);

  Widget _buildList(String q) {
    final results = FirStore.instance.firs
        .where(
          (f) =>
              f.id.toLowerCase().contains(q.toLowerCase()) ||
              f.title.toLowerCase().contains(q.toLowerCase()),
        )
        .toList();
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No results for "$q"',
          style: const TextStyle(color: kTextSub),
        ),
      );
    }
    return Container(
      color: kBgDeep,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _MyFirCard(item: results[i]),
      ),
    );
  }
}
