import 'dart:async';
import 'package:flutter/material.dart';

class AutoRefreshService {
  static final AutoRefreshService _instance = AutoRefreshService._internal();
  factory AutoRefreshService() => _instance;
  AutoRefreshService._internal();

  Timer? _timer;
  final List<VoidCallback> _listeners = [];
  bool _isActive = false;

  // Refresh interval - can be customized
  static const Duration refreshInterval = Duration(minutes: 1);

  void startAutoRefresh() {
    if (_isActive) return;
    
    _isActive = true;
    _timer = Timer.periodic(refreshInterval, (timer) {
      _notifyListeners();
    });
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void dispose() {
    stopAutoRefresh();
    _listeners.clear();
  }

  bool get isActive => _isActive;
}