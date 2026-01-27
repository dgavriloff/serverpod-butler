import 'package:flutter/widgets.dart';
import 'sp_breakpoints.dart';

/// Convenience builder that provides different layouts per breakpoint.
///
/// Uses [LayoutBuilder] internally so it responds to the widget's
/// available width, not the full screen width.
class SpResponsiveBuilder extends StatelessWidget {
  const SpResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints) desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < SpBreakpoints.mobile) {
          return mobile(context, constraints);
        }
        if (width < SpBreakpoints.tablet) {
          return (tablet ?? desktop)(context, constraints);
        }
        return desktop(context, constraints);
      },
    );
  }
}
