import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'theme.dart';
import 'fir_model.dart';
import 'app_nav.dart';

// ─── Pakistani location data ──────────────────────────────────────────────────
/// City → list of police-jurisdiction districts
const Map<String, List<String>> _cityDistricts = {
  'Karachi': [
    'Karachi Central',
    'Karachi East',
    'Karachi West',
    'Karachi South',
    'Karachi Korangi',
    'Malir',
    'Kemari',
  ],
  'Lahore': [
    'Lahore City',
    'Lahore Cantt',
    'Model Town',
    'Gulberg',
    'Iqbal Town',
    'Raiwind',
  ],
  'Islamabad': [
    'Islamabad Capital Territory',
    'Margalla Hills',
    'Sihala',
    'Noon',
  ],
  'Rawalpindi': [
    'Rawalpindi City',
    'Rawalpindi Cantt',
    'Taxila',
    'Gujar Khan',
    'Murree',
  ],
  'Peshawar': ['Peshawar City', 'Peshawar Cantt', 'Matani', 'Badaber'],
  'Quetta': ['Quetta City', 'Quetta Cantt', 'Mastung', 'Chaman Road'],
  'Multan': ['Multan City', 'Multan Cantt', 'Shujabad', 'Jalalpur Pirwala'],
  'Faisalabad': [
    'Faisalabad City',
    'Faisalabad Cantt',
    'Jaranwala',
    'Sammundri',
    'Tandlianwala',
  ],
  'Hyderabad': ['Hyderabad City', 'Hyderabad Rural', 'Latifabad', 'Qasimabad'],
  'Sialkot': ['Sialkot City', 'Sialkot Cantt', 'Sambrial', 'Daska'],
  'Gujranwala': [
    'Gujranwala City',
    'Gujranwala Cantt',
    'Kamoke',
    'Hafizabad Road',
  ],
  'Bahawalpur': [
    'Bahawalpur City',
    'Bahawalpur Cantt',
    'Ahmadpur East',
    'Uch Sharif',
  ],
  'Sargodha': ['Sargodha City', 'Sargodha Cantt', 'Bhalwal', 'Kot Momin'],
  'Sukkur': ['Sukkur City', 'Rohri', 'Pano Aqil'],
  'Larkana': ['Larkana City', 'Ratodero', 'Kamber'],
};

/// Approximate bounding boxes [minLat, maxLat, minLng, maxLng] for each city
/// Used to snap the map tap to the nearest city.
const Map<String, List<double>> _cityBounds = {
  'Karachi': [24.74, 25.20, 66.80, 67.45],
  'Lahore': [31.35, 31.70, 74.10, 74.55],
  'Islamabad': [33.55, 33.80, 72.80, 73.20],
  'Rawalpindi': [33.48, 33.70, 72.95, 73.20],
  'Peshawar': [33.90, 34.10, 71.40, 71.70],
  'Quetta': [30.10, 30.30, 66.90, 67.10],
  'Multan': [30.12, 30.30, 71.38, 71.60],
  'Faisalabad': [31.28, 31.55, 73.00, 73.25],
  'Hyderabad': [25.30, 25.50, 68.25, 68.50],
  'Sialkot': [32.42, 32.60, 74.45, 74.65],
  'Gujranwala': [32.08, 32.25, 74.12, 74.35],
  'Bahawalpur': [29.30, 29.50, 71.55, 71.80],
  'Sargodha': [32.00, 32.20, 72.55, 72.80],
  'Sukkur': [27.65, 27.80, 68.80, 68.95],
  'Larkana': [27.52, 27.68, 68.15, 68.30],
};

List<String> get _cities => _cityDistricts.keys.toList();

/// Returns the city whose bounding box contains [lat, lng],
/// or null if no city matches.
String? _cityFromLatLng(double lat, double lng) {
  for (final entry in _cityBounds.entries) {
    final b = entry.value; // [minLat, maxLat, minLng, maxLng]
    if (lat >= b[0] && lat <= b[1] && lng >= b[2] && lng <= b[3]) {
      return entry.key;
    }
  }
  return null;
}

const _categories = [
  'Theft / Robbery',
  'Vehicle Accident',
  'Property Dispute',
  'Cybercrime',
  'Fraud / Scam',
  'Assault / Violence',
  'Missing Person',
  'Land Encroachment',
  'Other',
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class FileFirScreen extends StatefulWidget {
  const FileFirScreen({super.key});

  @override
  State<FileFirScreen> createState() => _FileFirScreenState();
}

class _FileFirScreenState extends State<FileFirScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late final AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  // ── Step 0: Location ──────────────────────────────────────────────────────
  bool _locationPinned = false;
  bool _usingGps = false;
  final _addressCtrl = TextEditingController();
  String? _city;
  LatLng? _pinnedLocation;
  final _mapCtrl = MapController();

  // ── Step 1: Details ───────────────────────────────────────────────────────
  DateTime? _incidentDate;
  TimeOfDay? _incidentTime;
  String? _district;
  String? _category;
  final _descCtrl = TextEditingController();

  // ── Step 2: Evidence ──────────────────────────────────────────────────────
  bool _evidenceAdded = false;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnim = _slideCtrl
        .drive(CurveTween(curve: Curves.easeOutCubic))
        .drive(Tween(begin: const Offset(0.06, 0), end: Offset.zero));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _mapCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _goNext() {
    if (_step == 0) {
      if (_addressCtrl.text.trim().isEmpty) {
        _showSnack('Please enter the street address.');
        return;
      }
      if (_city == null) {
        _showSnack('Please select a district / city.');
        return;
      }
    }
    if (_step == 1) {
      if (_incidentDate == null) {
        _showSnack('Please select the incident date.');
        return;
      }
      if (_category == null) {
        _showSnack('Please select an incident category.');
        return;
      }
      if (_descCtrl.text.trim().length < 10) {
        _showSnack('Please describe the incident (min 10 characters).');
        return;
      }
    }
    if (_step < 2) {
      _slideCtrl.reverse().then((_) {
        setState(() => _step++);
        _slideCtrl.forward();
      });
    } else {
      _submitFir();
    }
  }

  void _goPrev() {
    if (_step > 0) {
      _slideCtrl.reverse().then((_) {
        setState(() => _step--);
        _slideCtrl.forward();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: kBgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _submitFir() {
    final now = DateTime.now();
    final rng = Random();
    final firId = 'FIR-${now.year}-${(rng.nextInt(89999) + 10000)}';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final filedDate =
        'Filed on ${months[now.month - 1]} ${now.day.toString().padLeft(2, '0')}, ${now.year}';

    // Build a short title from category or description
    String title = _category ?? _descCtrl.text;
    if (title.length > 45) title = '${title.substring(0, 42)}…';

    final fir = FirItem(
      id: firId,
      title: title,
      date: filedDate,
      status: 'Pending',
      address: _addressCtrl.text.trim(),
      city: _city ?? '',
      district: _district ?? '',
      description: _descCtrl.text.trim(),
      incidentDate: _incidentDate != null
          ? '${_incidentDate!.day}/${_incidentDate!.month}/${_incidentDate!.year}'
          : '',
      category: _category ?? '',
    );

    // Show success then pop with result
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SubmitSuccessDialog(
        firId: firId,
        onDone: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(fir); // return to dashboard with new FIR
        },
      ),
    );
  }

  // ── Date/Time helpers ─────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kGreen,
            onPrimary: Colors.white,
            surface: kBgCard,
          ),
          dialogBackgroundColor: kBgDeep,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _incidentDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kGreen,
            onPrimary: Colors.white,
            surface: kBgCard,
          ),
          dialogBackgroundColor: kBgDeep,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _incidentTime = picked);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          const SachBackgroundGlow(),
          Column(
            children: [
              _buildStepper(),
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: _buildStepContent(),
                  ),
                ),
              ),
              _buildBottomButton(),
            ],
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kBgCard,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: kGold,
          size: 20,
        ),
        onPressed: _goPrev,
      ),
      title: const Text(
        'File e-FIR',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      actions: [buildAppMenu(context, -1)],
    );
  }

  // ── Horizontal Stepper ────────────────────────────────────────────────────
  Widget _buildStepper() {
    const labels = ['Location', 'Details', 'Evidence'];
    return Container(
      color: kBgCard,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final done = _step > i ~/ 2;
            return Expanded(
              child: Container(height: 2, color: done ? kGreen : kDivider),
            );
          }
          final idx = i ~/ 2;
          final active = _step == idx;
          final done = _step > idx;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? kGreen
                      : active
                      ? kGold
                      : kDivider,
                  border: Border.all(
                    color: done
                        ? kGreen
                        : active
                        ? kGold
                        : kDivider,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: done
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: active
                                ? Colors.black
                                : Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[idx],
                style: TextStyle(
                  color: active
                      ? kGold
                      : done
                      ? kGreen
                      : kTextSub,
                  fontSize: 10,
                  fontWeight: active || done
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

  // ── Step Dispatch ─────────────────────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildLocationStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildEvidenceStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 0: Location ──────────────────────────────────────────────────────
  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Real interactive OpenStreetMap
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: const LatLng(30.3753, 69.3451),
                initialZoom: 5.5,
                onTap: (_, latLng) {
                  final detectedCity = _cityFromLatLng(
                    latLng.latitude,
                    latLng.longitude,
                  );
                  setState(() {
                    _pinnedLocation = latLng;
                    _locationPinned = true;
                    if (_addressCtrl.text.isEmpty ||
                        _addressCtrl.text == 'Current GPS Location') {
                      _addressCtrl.text =
                          '${latLng.latitude.toStringAsFixed(5)}, '
                          '${latLng.longitude.toStringAsFixed(5)}';
                    }
                    if (detectedCity != null && detectedCity != _city) {
                      _city = detectedCity;
                      _district = null; // reset district when city changes
                    }
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sach.portal',
                ),
                if (_pinnedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pinnedLocation!,
                        width: 50,
                        height: 58,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
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
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 18,
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
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded, color: kTextSub, size: 13),
              const SizedBox(width: 4),
              Text(
                _locationPinned
                    ? 'Location pinned ✓  Tap to change'
                    : 'Tap anywhere on the map to pin location',
                style: TextStyle(
                  color: _locationPinned ? kGold : kTextSub,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Use Current Location
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _usingGps = true;
                _locationPinned = true;
                if (_addressCtrl.text.isEmpty) {
                  _addressCtrl.text = 'Current GPS Location';
                }
              });
            },
            icon: Icon(
              _usingGps ? Icons.gps_fixed_rounded : Icons.my_location_rounded,
              color: _usingGps ? kGold : Colors.white,
              size: 18,
            ),
            label: Text(
              _usingGps ? 'Using Current Location' : 'Use Current Location',
              style: TextStyle(
                color: _usingGps ? kGold : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: _usingGps ? kGold : kDivider, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: _usingGps ? kGold.withOpacity(0.06) : kInputBg,
            ),
          ),
        ),
        const SizedBox(height: 20),

        const SachLabel('Street Address'),
        TextFormField(
          controller: _addressCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: sachInputDecoration(
            hint: 'Enter complete address',
            prefixIcon: Icon(Icons.home_outlined, color: kGold, size: 20),
          ),
        ),
        const SizedBox(height: 18),

        const SachLabel('District'),
        DropdownButtonFormField<String>(
          value: _city,
          dropdownColor: kBgCard,
          decoration: sachInputDecoration(hint: 'Select district'),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextSub),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: _cities
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() {
            _city = v;
            _district = null; // reset city/area whenever district changes
          }),
        ),
        const SizedBox(height: 18),

        // City / Area — filtered by district
        const SachLabel('City / Area'),
        DropdownButtonFormField<String>(
          key: ValueKey(_city), // forces rebuild when district changes
          value: _district,
          dropdownColor: kBgCard,
          decoration: sachInputDecoration(
            hint: _city == null
                ? 'Select a district first'
                : 'Select city / area in $_city',
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextSub),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: (_city == null ? <String>[] : (_cityDistricts[_city!] ?? []))
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: _city == null
              ? null
              : (v) => setState(() => _district = v),
        ),
      ],
    );
  }

  // ── Step 1: Details ───────────────────────────────────────────────────────
  Widget _buildDetailsStep() {
    final dateStr = _incidentDate == null
        ? null
        : '${_incidentDate!.day.toString().padLeft(2, '0')}/'
              '${_incidentDate!.month.toString().padLeft(2, '0')}/'
              '${_incidentDate!.year}'
              '${_incidentTime != null ? '  ${_incidentTime!.format(context)}' : ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date & Time
        const SachLabel('Incident Date / Time'),
        GestureDetector(
          onTap: () async {
            await _pickDate();
            if (_incidentDate != null) await _pickTime();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: kInputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kDivider, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: kGold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dateStr ?? 'Select date and time',
                    style: TextStyle(
                      color: dateStr != null ? Colors.white : kTextSub,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.calendar_month_rounded, color: kTextSub, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Incident category
        const SachLabel('Incident Category'),
        DropdownButtonFormField<String>(
          value: _category,
          dropdownColor: kBgCard,
          decoration: sachInputDecoration(hint: 'Select incident type'),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextSub),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _category = v),
        ),
        const SizedBox(height: 18),

        // Description
        const SachLabel('Incident Description'),
        Stack(
          children: [
            TextFormField(
              controller: _descCtrl,
              maxLines: 6,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: sachInputDecoration(
                hint: 'Describe the incident in detail…',
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () =>
                    _showSnack('Voice-to-text: speak your complaint clearly.'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: kGreen.withOpacity(0.4), blurRadius: 10),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Tap the microphone icon to use voice-to-text',
          style: TextStyle(color: kTextSub, fontSize: 11),
        ),
      ],
    );
  }

  // ── Step 2: Evidence ──────────────────────────────────────────────────────
  Widget _buildEvidenceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Evidence',
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add photos or videos to support your complaint',
          style: TextStyle(color: kTextSub, fontSize: 13),
        ),
        const SizedBox(height: 24),

        // Upload area
        GestureDetector(
          onTap: () => setState(() => _evidenceAdded = !_evidenceAdded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: _evidenceAdded ? kGreen.withOpacity(0.07) : kInputBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: _DashedBorderPainter(
                color: _evidenceAdded ? kGreen : kDivider,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _evidenceAdded
                          ? Icons.check_circle_rounded
                          : Icons.add_photo_alternate_rounded,
                      color: _evidenceAdded ? kGold : kTextSub,
                      size: 52,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _evidenceAdded
                          ? 'Evidence Added ✓'
                          : 'Tap to upload photo/video evidence',
                      style: TextStyle(
                        color: _evidenceAdded ? kGold : kTextSub,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!_evidenceAdded) ...[
                      const SizedBox(height: 4),
                      Text(
                        '(Max 25MB)',
                        style: TextStyle(color: kTextSub, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Optional note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kBgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kDivider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: kGold, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Evidence is optional. You can attach it later from My FIRs.',
                  style: TextStyle(color: kTextSub, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Bottom CTA ────────────────────────────────────────────────────────────
  Widget _buildBottomButton() {
    final labels = [
      'Next: Incident Details',
      'Next: Upload Evidence',
      'Submit Secure e-FIR',
    ];
    final isLast = _step == 2;
    return Container(
      color: kBgDeep,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kGreen, Color(0xFF015C2E)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: kGreen.withOpacity(0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                isLast ? Icons.shield_rounded : Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                labels[_step],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isLast) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded, color: kTextSub, size: 12),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Encrypted via SHA-256 & anchored to SACH Ledger.',
                    style: TextStyle(color: kTextSub, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Dashed Border Painter ───────────────────────────────────────────────────
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const radius = 16.0;
    const dashLen = 8.0;
    const gapLen = 6.0;
    final rect = ui.RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(radius),
    );
    final path = ui.Path()..addRRect(rect);
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double dist = 0;
      while (dist < m.length) {
        canvas.drawPath(m.extractPath(dist, dist + dashLen), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

// ─── Success Dialog ───────────────────────────────────────────────────────────
class _SubmitSuccessDialog extends StatelessWidget {
  final String firId;
  final VoidCallback onDone;
  const _SubmitSuccessDialog({required this.firId, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kBgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success animation circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGreen.withOpacity(0.12),
                border: Border.all(color: kGreen.withOpacity(0.5), width: 2),
              ),
              child: const Icon(Icons.check_rounded, color: kGreen, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'e-FIR Submitted!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your complaint has been securely filed and anchored to the SACH Ledger.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextSub, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            // FIR ID chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: kGold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGold.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tag_rounded, color: kGold, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    firId,
                    style: const TextStyle(
                      color: kGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SachGradientButton(label: 'View My Dashboard', onPressed: onDone),
          ],
        ),
      ),
    );
  }
}
