import 'package:flutter/foundation.dart';
import 'package:turun/data/model/broadcast/broadcast_model.dart';
import 'package:turun/data/services/broadcast_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Provider for managing broadcast state and interactions
class BroadcastProvider extends ChangeNotifier {
  final BroadcastService _service = BroadcastService();

  List<BroadcastModel> _broadcasts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BroadcastModel> get broadcasts => _broadcasts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasBroadcasts => _broadcasts.isNotEmpty;
  
  /// Get the highest priority broadcast to show
  BroadcastModel? get topBroadcast => _broadcasts.isNotEmpty ? _broadcasts.first : null;

  /// Fetch active broadcasts from the server
  Future<void> fetchBroadcasts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _broadcasts = await _service.fetchActiveBroadcasts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Record that a broadcast was viewed and mark it locally
  Future<void> viewBroadcast(String broadcastId) async {
    await _service.recordView(broadcastId);
    
    // Update local state
    final index = _broadcasts.indexWhere((b) => b.id == broadcastId);
    if (index != -1) {
      _broadcasts[index] = _broadcasts[index].copyWith(isViewed: true);
      notifyListeners();
    }
  }

  /// Handle broadcast action click
  Future<void> onBroadcastAction(BroadcastModel broadcast) async {
    await _service.recordClick(broadcast.id);

    switch (broadcast.actionType) {
      case BroadcastActionType.link:
      case BroadcastActionType.survey:
        if (broadcast.actionUrl != null) {
          final uri = Uri.tryParse(broadcast.actionUrl!);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
        break;
      case BroadcastActionType.inApp:
        // Handle in-app navigation - this would need to be handled by the UI
        // Return the action URL for navigation
        break;
      case BroadcastActionType.none:
        break;
    }
  }

  /// Dismiss a broadcast and remove it from local list
  Future<void> dismissBroadcast(String broadcastId) async {
    await _service.recordDismiss(broadcastId);
    
    // Remove from local list
    _broadcasts.removeWhere((b) => b.id == broadcastId);
    notifyListeners();
  }

  /// Clear all broadcasts (e.g., on logout)
  void clearBroadcasts() {
    _broadcasts = [];
    _error = null;
    notifyListeners();
  }

  /// Refresh broadcasts
  Future<void> refresh() async {
    await fetchBroadcasts();
  }
}
