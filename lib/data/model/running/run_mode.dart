/// Defines the running mode for the application
enum RunMode {
  /// Territory mode: Run within existing territories
  /// - User navigates to existing territories
  /// - Must follow territory boundaries and checkpoints
  /// - Can conquer territories based on pace
  territory,

  /// Landmark mode: Create your own custom territory
  /// - User creates their own running route
  /// - No predefined boundaries or checkpoints
  /// - Records route as personal landmark
  landmark,
}

/// Extension methods for RunMode
extension RunModeExtension on RunMode {
  /// Get display name for the mode
  String get displayName {
    switch (this) {
      case RunMode.territory:
        return 'Territory';
      case RunMode.landmark:
        return 'Landmark';
    }
  }

  /// Get description for the mode
  String get description {
    switch (this) {
      case RunMode.territory:
        return 'Run within existing territories and compete for ownership';
      case RunMode.landmark:
        return 'Create your own custom running route';
    }
  }

  /// Check if this mode uses existing territories
  bool get usesTerritories => this == RunMode.territory;

  /// Check if this mode creates custom routes
  bool get createsCustomRoute => this == RunMode.landmark;
}
