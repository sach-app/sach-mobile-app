import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'fir_model.dart';
import 'api_service.dart';

/// Global in-memory store for FIRs, shared across Dashboard and My FIRs screen.
class FirStore extends ChangeNotifier {
  FirStore._();
  static final FirStore instance = FirStore._();

  List<FirItem> _firs = [];
  List<FirItem> get firs => List.unmodifiable(_firs);
  
  bool isLoading = false;

  Future<void> fetchMyFirs() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/user/firs');
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> items = body['items'] ?? [];
        _firs = items.map((json) => FirItem.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle error gracefully
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void add(FirItem item) {
    _firs.insert(0, item);
    notifyListeners();
  }

  void updateSingleFir(FirItem item) {
    final idx = _firs.indexWhere((f) => f.id == item.id);
    if (idx != -1) {
      _firs[idx] = item;
      notifyListeners();
    }
  }

  int get total => _firs.length;
  int get pending => _firs.where((f) {
        final s = f.status.toLowerCase();
        return s == 'pending' || s == 'under_review' || s == 'under review';
      }).length;
  int get resolved => _firs.where((f) => f.status.toLowerCase() == 'resolved').length;
}
