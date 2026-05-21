import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'fir_store.dart';
import 'theme.dart';
import 'fir_model.dart';
import 'app_nav.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FirDetailScreen extends StatefulWidget {
  final FirItem fir;
  const FirDetailScreen({super.key, required this.fir});

  @override
  State<FirDetailScreen> createState() => _FirDetailScreenState();
}

class _FirDetailScreenState extends State<FirDetailScreen> {
  late FirItem _currentFir;
  bool _isUploadingEvidence = false;

  @override
  void initState() {
    super.initState();
    _currentFir = widget.fir;
    // Fetch detailed FIR data (which includes evidence) as soon as the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFir();
    });
  }

  Future<void> _refreshFir() async {
    try {
      final response = await ApiService.get('/user/fir/${_currentFir.id}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final freshFir = FirItem.fromJson(data);
        if (mounted) {
          setState(() {
            _currentFir = freshFir;
          });
          FirStore.instance.updateSingleFir(freshFir);
        }
      } else {
        debugPrint('Failed to refresh FIR. Status: ${response.statusCode}, Body: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to refresh complaint data.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Exception in _refreshFir: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEvidencePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: kGold),
                title: const Text('Take Photo with Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadEvidence(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: kGold),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadEvidence(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadEvidence(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    if (mounted) {
      setState(() => _isUploadingEvidence = true);
    }

    try {
      final success = await ApiService.uploadEvidence(_currentFir.id, pickedFile.path);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evidence submitted successfully'),
              backgroundColor: kGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _refreshFir();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload evidence'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload evidence'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingEvidence = false);
      }
    }
  }

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
    final statusMap = {
      'pending': 0,
      'filed': 0,
      'under_review': 1,
      'under review': 1,
      'reviewed': 1,
      'under_investigation': 2,
      'under investigation': 2,
      'investigating': 2,
      'resolved': 3,
      'closed': 4,
    };
    final idx = statusMap[_currentFir.status.toLowerCase().trim()];
    return idx ?? 0;
  }

  Color get _statusColor {
    final status = _currentFir.status.toLowerCase().trim();
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'investigating':
      case 'under_investigation':
        return const Color(0xFF3B82F6);
      case 'resolved':
        return kGreen;
      case 'closed':
        return kTextSub;
      case 'under review':
      case 'under_review':
        return const Color(0xFF8B5CF6);
      default:
        return kTextSub;
    }
  }

  // Return real officer name if available, otherwise derive a mock officer name from the district
  String get _officerName {
    if (_currentFir.officerName != null && _currentFir.officerName!.isNotEmpty) {
      return _currentFir.officerName!;
    }
    const officers = [
      'Inspector Muhammad Asif',
      'Sub-Inspector Tariq Mahmood',
      'Inspector Farrukh Ali',
      'DSP Khalid Mehmood',
      'Inspector Nadia Hussain',
    ];
    final hash = _currentFir.id.hashCode.abs() % officers.length;
    return officers[hash];
  }

  String get _officerRank {
    final name = _officerName;
    if (name.startsWith('DSP') || name.startsWith('Deputy')) return 'Deputy Superintendent of Police';
    if (name.startsWith('Sub-Inspector') || name.startsWith('SI')) return 'Sub-Investigating Officer';
    if (name.startsWith('ASI') || name.startsWith('Assistant')) return 'Assistant Sub-Investigating Officer';
    if (name.startsWith('Inspector')) return 'Investigating Officer';
    if (name.contains('Constable')) return 'Constable / Security Officer';
    return 'Investigating Officer';
  }

  LatLng? _parseCoordinates(String address) {
    try {
      // Matches coordinates with optional square brackets [33.6844, 73.0479] or raw 33.6844, 73.0479
      final regExp = RegExp(r'(?:\[\s*)?(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)(?:\s*\])?');
      final match = regExp.firstMatch(address);
      if (match != null && match.groupCount == 2) {
        final lat = double.parse(match.group(1)!);
        final lng = double.parse(match.group(2)!);
        // Sanity check to avoid matching random number pairs in generic addresses
        if (lat >= -90.0 && lat <= 90.0 && lng >= -180.0 && lng <= 180.0) {
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      debugPrint('Error parsing coordinates: $e');
    }
    return null;
  }

  Widget _buildMapCard(LatLng latLng) {
    return _SectionCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.map_rounded, color: kGold, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Incident Location Map',
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: latLng,
                      initialZoom: 14.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.sach.portal',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: latLng,
                            width: 30,
                            height: 44,
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: kGold,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                Container(width: 2, height: 14, color: kGold),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final parsedLatLng = _currentFir.latitude != null && _currentFir.longitude != null
        ? LatLng(_currentFir.latitude!, _currentFir.longitude!)
        : _parseCoordinates(_currentFir.address);
    return Scaffold(
      backgroundColor: kBgDeep,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        color: kGold,
        onRefresh: _refreshFir,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: [
            _buildStatusTimeline(),
            const SizedBox(height: 20),
            _buildInfoCard(context),
            const SizedBox(height: 16),
            if (parsedLatLng != null) ...[
              _buildMapCard(parsedLatLng),
              const SizedBox(height: 16),
            ],
            if (_currentFir.description.isNotEmpty) ...[
              _buildDescriptionCard(),
              const SizedBox(height: 16),
            ],
            _buildOfficerCard(context),
            const SizedBox(height: 16),
            _buildEvidenceCard(context),
            const SizedBox(height: 16),
            _buildMetaCard(),
          ],
        ),
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
          const Text(
            'Case Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          Text(
            _currentFir.trackingNumber != null && _currentFir.trackingNumber!.isNotEmpty
                ? 'Tracking No: ${_currentFir.trackingNumber!}'
                : 'Tracking No: Pending',
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
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              return SizedBox(
                width: 55,
                height: 30,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? kGreen
                          : active
                          ? _statusColor
                          : kDivider.withOpacity(0.3),
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
                                color: (done ? kGreen : _statusColor).withOpacity(
                                  0.3,
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
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_pipeline.length * 2 - 1, (i) {
              if (i.isOdd) {
                return const Expanded(child: SizedBox());
              }
              final idx = i ~/ 2;
              final done = step > idx;
              final active = step == idx;
              return SizedBox(
                width: 55,
                child: Text(
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
              );
            }),
          ),
        ],
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
      _currentFir.address,
      _currentFir.city,
      _currentFir.district,
    ].where((s) => s.isNotEmpty).join(', ');

    return _SectionCard(
      children: [
        if (_currentFir.category.isNotEmpty) ...[
          _DetailRow(
            icon: Icons.category_rounded,
            label: 'Incident Type',
            value: _currentFir.category,
            highlight: true,
          ),
          const _Divider(),
        ],
        _DetailRow(
          icon: Icons.calendar_today_rounded,
          label: 'Date Filed',
          value: _currentFir.date,
        ),
        if (_currentFir.incidentDate.isNotEmpty) ...[
          const _Divider(),
          _DetailRow(
            icon: Icons.event_rounded,
            label: 'Incident Date',
            value: _currentFir.incidentDate,
          ),
        ],
        if (location.isNotEmpty) ...[
          const _Divider(),
          _DetailRow(
            icon: Icons.location_on_rounded,
            label: 'Location',
            value: location,
          ),
        ],
        const _Divider(),
        _StatusRow(status: _currentFir.status, color: _statusColor),
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
              const Row(
                children: [
                  Icon(Icons.description_rounded, color: kGold, size: 16),
                  SizedBox(width: 8),
                  Text(
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
                _currentFir.description,
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
    final isAssigned = _currentFir.assignedOfficerId != null ||
        (_currentFir.officerName != null && _currentFir.officerName!.isNotEmpty) ||
        _currentFir.status.toLowerCase() != 'pending';
    return _SectionCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_pin_rounded, color: kGold, size: 16),
                  SizedBox(width: 8),
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
                  child: const Row(
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        color: kTextSub,
                        size: 16,
                      ),
                      SizedBox(width: 8),
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
                          color: kGold.withOpacity(0.3),
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
                            style: const TextStyle(color: kTextSub, fontSize: 12),
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

  // ── Evidence Card ──────────────────────────────────────────────────────────
  Widget _buildEvidenceCard(BuildContext context) {
    return _SectionCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.attachment_rounded, color: kGold, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Supporting Evidence',
                    style: TextStyle(
                      color: kTextSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (_currentFir.evidence.isNotEmpty) ...[
                const SizedBox(height: 14),
                ..._currentFir.evidence.map((e) => _buildEvidenceItem(e)),
                const SizedBox(height: 14),
              ] else ...[
                const SizedBox(height: 14),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploadingEvidence ? null : _showEvidencePicker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isUploadingEvidence
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: kBgDeep, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Submit Evidence',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceItem(EvidenceItem evidence) {
    final lowerUrl = evidence.fileUrl.toLowerCase();
    final isImage = lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        evidence.fileType.toLowerCase().contains('image');

    if (isImage) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kInputBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kDivider),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => _FullScreenImagePage(imageUrl: evidence.fileUrl),
                  ),
                );
              },
              child: Image.network(
                evidence.fileUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: kGold),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image_rounded, color: kTextSub, size: 30),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kDivider),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_rounded, color: kGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evidence.fileName,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  evidence.fileType,
                  style: const TextStyle(color: kTextSub, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: kGreen, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              final url = Uri.parse(evidence.fileUrl);
              launchUrl(url, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }

  // ── Meta Card ──────────────────────────────────────────────────────────────
  Widget _buildMetaCard() {
    return const _SectionCard(
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
            color: Colors.black.withOpacity(0.25),
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
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(color: kDivider, height: 1, indent: 16, endIndent: 16);
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
                  style: const TextStyle(
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
                        : Colors.white.withOpacity(0.9),
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
          const Icon(Icons.flag_rounded, color: kGold, size: 16),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
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
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
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

class _FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: kGold),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image_rounded, color: Colors.white54, size: 48),
                    SizedBox(height: 16),
                    Text('Failed to load image', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
