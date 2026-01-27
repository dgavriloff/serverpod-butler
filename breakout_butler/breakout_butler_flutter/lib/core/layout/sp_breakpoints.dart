import 'package:flutter/widgets.dart';

/// breakoutpad breakpoint system.
///
/// <600px  → mobile (single column, bottom nav, sidebar as modal)
/// 600-1024 → tablet (content + collapsible sidebar)
/// >1024   → desktop (full three-panel)
abstract final class SpBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
}

enum SpScreenSize { mobile, tablet, desktop }

/// Determine screen size category from [BuildContext].
SpScreenSize screenSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < SpBreakpoints.mobile) return SpScreenSize.mobile;
  if (width < SpBreakpoints.tablet) return SpScreenSize.tablet;
  return SpScreenSize.desktop;
}
