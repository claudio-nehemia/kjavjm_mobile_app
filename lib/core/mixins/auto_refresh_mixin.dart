import 'package:flutter/material.dart';
import '../services/auto_refresh_service.dart';

mixin AutoRefreshMixin<T extends StatefulWidget> on State<T> {
  late AutoRefreshService _autoRefreshService;
  late VoidCallback _refreshCallback;

  @override
  void initState() {
    super.initState();
    _autoRefreshService = AutoRefreshService();
    _refreshCallback = _onAutoRefresh;
    _autoRefreshService.addListener(_refreshCallback);
  }

  @override
  void dispose() {
    _autoRefreshService.removeListener(_refreshCallback);
    super.dispose();
  }

  // Override this method in your widget to handle auto refresh
  void _onAutoRefresh() {
    if (mounted) {
      onAutoRefresh();
    }
  }

  // Implement this method in your widget
  void onAutoRefresh();

  // Helper methods
  void startAutoRefresh() {
    _autoRefreshService.startAutoRefresh();
  }

  void stopAutoRefresh() {
    _autoRefreshService.stopAutoRefresh();
  }

  bool get isAutoRefreshActive => _autoRefreshService.isActive;
}