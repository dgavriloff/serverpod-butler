import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/sp_breakpoints.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/widgets/sp_button.dart';
import '../widgets/home_hero.dart';
import '../widgets/join_session_card.dart';
import '../widgets/landing_illustration.dart';
import '../widgets/or_divider.dart';

/// Home screen — split-screen on desktop/tablet, stacked on mobile.
///
/// Tracks mouse position globally so the dot illustration responds to
/// cursor movement anywhere on the page.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Offset _mouseOffset = Offset.zero;

  void _onHover(PointerEvent event) {
    final size = context.size;
    if (size == null || size.isEmpty) return;
    setState(() {
      _mouseOffset = Offset(
        (event.localPosition.dx / size.width - 0.5) * 2.0,
        (event.localPosition.dy / size.height - 0.5) * 2.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = screenSizeOf(context);

    return Scaffold(
      backgroundColor: SpColors.background,
      body: MouseRegion(
        onHover: _onHover,
        onExit: (_) => setState(() => _mouseOffset = Offset.zero),
        child: screenSize == SpScreenSize.mobile
            ? _buildMobile()
            : _buildSplit(screenSize),
      ),
    );
  }

  /// Mobile: vertical stack, centered, scrollable.
  Widget _buildMobile() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SpSpacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeHero(),
              const SizedBox(height: SpSpacing.lg),
              const JoinSessionCard(),
              const SizedBox(height: SpSpacing.lg),
              const OrDivider(),
              const SizedBox(height: SpSpacing.lg),
              SpSecondaryButton(
                label: 'create new session',
                icon: Icons.add,
                onPressed: () => context.go('/create'),
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Desktop/tablet: illustration extends to left edge, content is padded.
  Widget _buildSplit(SpScreenSize size) {
    final rightPadding =
        size == SpScreenSize.desktop ? SpSpacing.xxl * 2 : SpSpacing.xl;

    return Stack(
      children: [
        // ── Illustration: spans left half, edge-to-edge ──────────
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: MediaQuery.sizeOf(context).width * 0.55,
          child: LandingIllustration(mouseOffset: _mouseOffset),
        ),

        // ── Content layer ────────────────────────────────────────
        Positioned.fill(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left pane: hero card, padded from left edge
              Expanded(
                flex: 55,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: size == SpScreenSize.desktop
                        ? SpSpacing.xxl * 2
                        : SpSpacing.xl,
                    right: SpSpacing.lg,
                    top: SpSpacing.xl,
                    bottom: SpSpacing.xl,
                  ),
                  child: const Center(
                    child: HomeHero(),
                  ),
                ),
              ),

              // Right pane: cards + or + create button
              Expanded(
                flex: 45,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: rightPadding,
                    top: SpSpacing.xl,
                    bottom: SpSpacing.xl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const JoinSessionCard(),
                            const SizedBox(height: SpSpacing.lg),
                            const OrDivider(),
                            const SizedBox(height: SpSpacing.lg),
                            SpSecondaryButton(
                              label: 'create new session',
                              icon: Icons.add,
                              onPressed: () => context.go('/create'),
                              fullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
