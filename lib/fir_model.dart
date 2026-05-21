import 'dart:math';

class EvidenceItem {
  final String id;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final String createdAt;

  EvidenceItem({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.createdAt,
  });

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    return EvidenceItem(
      id: json['id']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? 'evidence',
      fileType: json['file_type']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

// Shared FIR data model used by dashboard and file_fir_screen
class FirItem {
  final String id;
  final String? trackingNumber;
  final String title;
  final String date;
  final String? _status;
  final String address;
  final String city;
  final String district;
  final String description;
  final String incidentDate;
  final String category;
  final String ledgerHash;
  final List<EvidenceItem> evidence;
  final double? latitude;
  final double? longitude;
  final int? assignedOfficerId;
  final String? officerName;

  String get status {
    final rawStatus = _status ?? 'Pending';
    final normalizedStatus = rawStatus.toLowerCase().trim();
    final isOfficerAssigned = assignedOfficerId != null ||
        (officerName != null && officerName!.isNotEmpty);
    if (isOfficerAssigned && (normalizedStatus == 'pending' || normalizedStatus == 'filed')) {
      return 'under review';
    }
    return rawStatus;
  }

  FirItem({
    required this.id,
    this.trackingNumber,
    required this.title,
    required this.date,
    String? status = 'Pending',
    this.address = '',
    this.city = '',
    this.district = '',
    this.description = '',
    this.incidentDate = '',
    this.category = '',
    String? ledgerHash,
    this.evidence = const [],
    this.latitude,
    this.longitude,
    this.assignedOfficerId,
    this.officerName,
  }) : _status = status ?? 'Pending',
       ledgerHash = ledgerHash ?? _genHash();

  factory FirItem.fromJson(Map<String, dynamic> json) {
    return FirItem(
      id: json['id'] != null ? json['id'].toString() : '',
      trackingNumber: json['tracking_number']?.toString(),
      title: json['title']?.toString() ?? '',
      date: json['created_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      address: json['incident_location']?.toString() ?? '',
      city: '',
      district: '',
      description: json['description']?.toString() ?? '',
      incidentDate: json['incident_date']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((e) => EvidenceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      assignedOfficerId: json['assigned_officer_id'] != null
          ? int.tryParse(json['assigned_officer_id'].toString())
          : null,
      officerName: json['officer_name']?.toString(),
    );
  }

  static String _genHash() {
    const chars = '0123456789abcdef';
    final rng = Random();
    return '0x${List.generate(64, (_) => chars[rng.nextInt(chars.length)]).join()}';
  }
}
