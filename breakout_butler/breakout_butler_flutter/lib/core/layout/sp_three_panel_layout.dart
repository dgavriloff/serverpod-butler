import 'package:flutter/material.dart';
import '../theme/sp_colors.dart';
import '../theme/sp_durations.dart';
import '../theme/sp_spacing.dart';
import 'sp_breakpoints.dart';

/// The core three-panel layout from the breakoutpad design doc.
///
/// Desktop: nav bar + primary content + sidebar (280-320px)
/// Tablet:  nav bar + primary content + toggle-able sidebar
/// Mobile:  primary content + bottom nav + sidebar as bottom sheet
///
/// The [nav] widget is placed at the top on desktop/tablet,
/// or as bottom navigation on mobile.
///
/// The [sidebar] is always-visible on desktop, toggle-able on tablet,
/// and presented as a bottom sheet on mobile via [showSidebar].
class SpThreePanelLayout extends StatefulWidget {
  const SpThreePanelLayout({
    super.key,
    required this.nav,
    required this.body,
    this.sidebar,
    this.sidebarWidth = 300,
    this.mobileBottomNav,
    this.floatingAction,
  });

  /// Top navigation bar (breadcrumb-style).
  final Widget nav;

  /// Primary content area.
  final Widget body;

  /// Right sidebar content. Pass null if this screen has no sidebar.
  final Widget? sidebar;

  /// Width of the sidebar on desktop. Default 300px.
  final double sidebarWidth;

  /// Optional bottom nav for mobile. If null, [nav] is still shown at top.
  final Widget? mobileBottomNav;

  /// Optional FAB for mobile (e.g., toggle sidebar sheet).
  final Widget? floatingAction;

  @override
  State<SpThreePanelLayout> createState() => _SpThreePanelLayoutState();
}

class _SpThreePanelLayoutState extends State<SpThreePanelLayout> {
  bool _sidebarExpanded = true;

  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
  }

  void _showSidebarSheet(BuildContext context) {
    if (widget.sidebar == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag handle
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(top: SpSpacing.sm),
                decoration: BoxDecoration(
                  color: SpColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(child: widget.sidebar!),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = screenSizeOf(context);

    switch (screenSize) {
      case SpScreenSize.desktop:
        return _buildDesktop();
      case SpScreenSize.tablet:
        return _buildTablet();
      case SpScreenSize.mobile:
        return _buildMobile();
    }
  }

  Widget _buildDesktop() {
    return Scaffold(
      body: Column(
        children: [
          widget.nav,
          Expanded(
            child: Row(
              children: [
                Expanded(child: widget.body),
                if (widget.sidebar != null) ...[
                  const VerticalDivider(width: 1),
                  SizedBox(
                    width: widget.sidebarWidth,
                    child: widget.sidebar!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablet() {
    return Scaffold(
      body: Column(
        children: [
          // Nav with sidebar toggle
          Row(
            children: [
              Expanded(child: widget.nav),
              if (widget.sidebar != null)
                IconButton(
                  icon: Icon(
                    _sidebarExpanded ? Icons.chevron_right : Icons.chevron_left,
                    color: SpColors.textSecondary,
                  ),
                  onPressed: _toggleSidebar,
                  tooltip: _sidebarExpanded ? 'hide panel' : 'show panel',
                ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: widget.body),
                if (widget.sidebar != null)
                  AnimatedContainer(
                    duration: SpDurations.normal,
                    curve: Curves.easeOutCubic,
                    width: _sidebarExpanded ? widget.sidebarWidth : 0,
                    child: _sidebarExpanded
                        ? Row(
                            children: [
                              const VerticalDivider(width: 1),
                              Expanded(child: widget.sidebar!),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile() {
    return Scaffold(
      body: Column(
        children: [
          widget.nav,
          Expanded(child: widget.body),
        ],
      ),
      bottomNavigationBar: widget.mobileBottomNav,
      floatingActionButton: widget.sidebar != null && widget.floatingAction == null
          ? FloatingActionButton.small(
              onPressed: () => _showSidebarSheet(context),
              backgroundColor: SpColors.primaryAction,
              foregroundColor: SpColors.background,
              child: const Icon(Icons.menu_open),
            )
          : widget.floatingAction,
    );
  }
}
