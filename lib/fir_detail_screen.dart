import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'fir_model.dart';
import 'app_nav.dart';

class FirDetailScreen extends StatelessWidget {
  final FirItem fir;
  const FirDetailScreen({super.key, required this.fir});

  // ── Status pipeline ────────────────────────────────────────────────────────
  static const _pipeline = [
    'Pending',
    'Under Review',
    'Investigating',
    'Resolved',
    'Closed',
  ];

  static const _pipelineLabels = [
    'Submitted',
    'Under Review',
    'Investigating',
    'Resolved',
    'Closed',
  ];

  int get _currentStep {
    final idx = _pipeline.indexOf(fir.status);
    return idx < 0 ? 0 : idx;
  }

  Color get _statusColor {
    switch (fir.status) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Investigating':
        return const Color(0xFF3B82F6);
      case 'Resolved':
        return kGreen;
      case 'Closed':
        return kTextSub;
      case 'Under Review':
        return const Color(0xFF8B5CF6);
      default:
        return kTextSub;
    }
  }

  // Derive a mock officer name from the district
  String get _officerName {
    const officers = [
      'Inspector Muhammad Asif',
      'Sub-Inspector Tariq Mahmood',
      'Inspector Farrukh Ali',
      'DSP Khalid Mehmood',
      'Inspector Nadia Hussain',
    ];
    final hash = fir.id.hashCode.abs() % officers.length;
    return officers[hash];
  }

  String get _officerRank {
    final name = _officerName;
    if (name.startsWith('DSP')) return 'Deputy Superintendent of Police';
    if (name.startsWith('Sub-Inspector')) return 'Sub-Investigating Officer';
    return 'Investigating Officer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          _buildStatusTimeline(),
          const SizedBox(height: 20),
          _buildInfoCard(context),
          const SizedBox(height: 16),
          if (fir.description.isNotEmpty) ...[
            _buildDescriptionCard(),
            const SizedBox(height: 16),
          ],
          _buildOfficerCard(context),
          const SizedBox(height: 16),
          _buildMetaCard(),
          const SizedBox(height: 20),
          _buildBlockchainCard(context),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Case Details',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          Text(
            fir.id,
            style: const TextStyle(
              color: kGold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [buildAppMenu(context, -1)],
    );
  }

  // ── Status Timeline ────────────────────────────────────────────────────────
  Widget _buildStatusTimeline() {
    final step = _currentStep;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kDivider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_pipeline.length * 2 - 1, (i) {
          if (i.isOdd) {
            final lineIdx = i ~/ 2;
            final done = step > lineIdx;
            return Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: done
                      ? const LinearGradient(colors: [kGreen, kGreen])
                      : null,
                  color: done ? null : kDivider,
                ),
              ),
            );
          }
          final idx = i ~/ 2;
          final done = step > idx;
          final active = step == idx;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? kGreen
                      : active
                      ? _statusColor
                      : kDivider.withValues(alpha: 0.3),
                  border: Border.all(
                    color: done
                        ? kGreen
                        : active
                        ? _statusColor
                        : kDivider,
                    width: 2,
                  ),
                  boxShadow: (done || active)
                      ? [
                          BoxShadow(
                            color: (done ? kGreen : _statusColor).withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  done ? Icons.check_rounded : _stepIcon(idx),
                  color: (done || active) ? Colors.white : kTextSub,
                  size: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _pipelineLabels[idx],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: done
                      ? kGreen
                      : active
                      ? _statusColor
                      : kTextSub,
                  fontSize: 9,
                  fontWeight: (done || active)
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  IconData _stepIcon(int idx) {
    switch (idx) {
      case 0:
        return Icons.upload_file_rounded;
      case 1:
        return Icons.remove_red_eye_rounded;
      case 2:
        return Icons.manage_search_rounded;
      case 3:
        return Icons.check_circle_rounded;
      case 4:
        return Icons.lock_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  // ── Info Card ──────────────────────────────────────────────────────────────
  Widget _buildInfoCard(BuildContext context) {
    final location = [
      fir.address,
      fir.city,
      fir.district,
    ].where((s) => s.isNotEmpty).join(', ');

    return _SectionCard(
      children: [
        if (fir.category.isNotEmpty) ...[
          _DetailRow(
            icon: Icons.category_rounded,
            label: 'Incident Type',
            value: fir.category,
            highlight: true,
          ),
          _Divider(),
        ],
        _DetailRow(icon: Icons.tag_rounded, label: 'Case ID', value: fir.id),
        _Divider(),
        _DetailRow(
          icon: Icons.calendar_today_rounded,
          label: 'Date Filed',
          value: fir.date,
        ),
        if (fir.incidentDate.isNotEmpty) ...[
          _Divider(),
          _DetailRow(
            icon: Icons.event_rounded,
            label: 'Incident Date',
            value: fir.incidentDate,
          ),
        ],
        if (location.isNotEmpty) ...[
          _Divider(),
          _DetailRow(
            icon: Icons.location_on_rounded,
            label: 'Location',
            value: location,
          ),
        ],
        _Divider(),
        _StatusRow(status: fir.status, color: _statusColor),
      ],
    );
  }

  // ── Description Card ───────────────────────────────────────────────────────
  Widget _buildDescriptionCard() {
    return _SectionCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description_rounded, color: kGold, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: kTextSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                fir.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Officer Card ───────────────────────────────────────────────────────────
  Widget _buildOfficerCard(BuildContext context) {
    final isAssigned = fir.status != 'Pending';
    return _SectionCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_pin_rounded, color: kGold, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Assigned Officer',
                    style: TextStyle(
                      color: kTextSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (!isAssigned)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kDivider),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        color: kTextSub,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Awaiting assignment…',
                        style: TextStyle(color: kTextSub, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else ...[
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A3A28), kGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: kGold.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _officerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _officerRank,
                            style: TextStyle(color: kTextSub, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Connecting to district police station…',
                          ),
                          backgroundColor: kBgCard,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: const Text(
                      'Contact Station',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Meta Card ──────────────────────────────────────────────────────────────
  Widget _buildMetaCard() {
    return _SectionCard(
      children: [
        _DetailRow(
          icon: Icons.security_rounded,
          label: 'Filing Method',
          value: 'e-FIR (Online Portal)',
        ),
        _Divider(),
        _DetailRow(
          icon: Icons.language_rounded,
          label: 'Portal',
          value: 'SACH Citizens Portal',
        ),
        _Divider(),
        _DetailRow(
          icon: Icons.verified_rounded,
          label: 'SACH Verified',
          value: 'Yes — Biometric confirmed',
          highlight: true,
        ),
      ],
    );
  }

  // ── Blockchain Card ────────────────────────────────────────────────────────
  Widget _buildBlockchainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGreen.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub_rounded, color: kGreen, size: 15),
              const SizedBox(width: 7),
              const Text(
                'Blockchain Hash Verification ID',
                style: TextStyle(
                  color: kGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: fir.blockchainHash));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Hash copied to clipboard'),
                      backgroundColor: kBgCard,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Icon(Icons.copy_rounded, color: kGreen, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            fir.blockchainHash,
            style: const TextStyle(
              color: Color(0xFF7FFFB8),
              fontSize: 11,
              fontFamily: 'monospace',
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: kGreen, size: 12),
              const SizedBox(width: 5),
              const Text(
                'Immutable record on SACH distributed ledger',
                style: TextStyle(color: kTextSub, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(color: kDivider, height: 1, indent: 16, endIndent: 16);
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kGold, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: kTextSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: highlight
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusRow({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.flag_rounded, color: kGold, size: 16),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Status',
                style: TextStyle(
                  color: kTextSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
