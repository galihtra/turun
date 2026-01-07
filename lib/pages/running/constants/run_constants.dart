class RunConstants {
  // Map zoom levels
  static const double defaultZoom = 17.0;
  static const double minZoom = 0.0;
  static const double maxZoom = 21.0;

  // Draggable sheet sizes
  static const double minSheetSize = 0.25;
  static const double maxSheetSize = 0.7;
  static const double sheetExpandedThreshold = 0.4;

  // UI update intervals
  static const Duration uiUpdateInterval = Duration(seconds: 1);

  // Map control positioning
  static const double mapControlsBottomOffset = 0.3;
  static const double mapControlsRightPadding = 16.0;
  static const double mapControlButtonRadius = 22.0;
  static const double mapControlButtonSpacing = 12.0;

  // Banner positioning
  static const double bannerTopOffset = 100.0;
  static const double bannerHorizontalPadding = 16.0;

  // Badge positioning
  static const double badgePadding = 16.0;

  // Route polyline width
  static const int userRoutePolylineWidth = 6;
}
