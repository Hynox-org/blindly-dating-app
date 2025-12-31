import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../data/repositories/face_liveness_repository.dart';

// --- THIS WAS MISSING ---
// This defines the variable "faceLivenessProvider" so your other files can find it.
final faceLivenessProvider = ChangeNotifierProvider<FaceLivenessProvider>((ref) {
  return FaceLivenessProvider();
});

class FaceLivenessProvider with ChangeNotifier {
  final FaceLivenessRepository _repository = FaceLivenessRepository();

  bool _isLoading = false;
  String? _sessionId;
  String _verificationStatus = "IDLE"; // Options: IDLE, LOADING, SUCCESS, FAILED
  double _confidence = 0.0;

  bool get isLoading => _isLoading;
  String get verificationStatus => _verificationStatus;
  String? get sessionId => _sessionId;
  double get confidence => _confidence;

  /// 1. Initialize the Session (Call this when screen opens)
  Future<bool> initLivenessSession() async {
    _setLoading(true);
    _sessionId = await _repository.startLivenessSession();
    _setLoading(false);

    if (_sessionId != null) {
      print("Face Liveness Session Created: $_sessionId");
      return true; 
    } else {
      _verificationStatus = "FAILED";
      notifyListeners();
      return false;
    }
  }

  /// 2. Check the Result (Call this after video recording is done)
  Future<void> verifyLiveness() async {
    if (_sessionId == null) return;

    _setLoading(true);
    final result = await _repository.getLivenessResult(_sessionId!);
    _setLoading(false);

    // Lambda returns: { "status": "SUCCEEDED", "is_live": true, "confidence": 99 }
    if (result['status'] == 'SUCCEEDED' && result['is_live'] == true) {
      _verificationStatus = "SUCCESS";
      _confidence = (result['confidence'] ?? 0).toDouble();
    } else {
      _verificationStatus = "FAILED";
    }
    
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  // Reset state if user retries
  void reset() {
    _sessionId = null;
    _verificationStatus = "IDLE";
    _confidence = 0.0;
    notifyListeners();
  }
}