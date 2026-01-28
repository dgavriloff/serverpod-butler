import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/sp_breakpoints.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../widgets/create_session_card.dart';
import '../widgets/home_hero.dart';
import '../widgets/join_session_card.dart';

/// Home screen — split-screen on desktop/tablet, stacked on mobile.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = screenSizeOf(context);

    return Scaffold(
      backgroundColor: SpColors.background,
      body: size == SpScreenSize.mobile ? _buildMobile() : _buildSplit(context),
    );
  }

  /// Mobile: vertical stack, centered, scrollable.
  Widget _buildMobile() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SpSpacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeHero(),
              SizedBox(height: SpSpacing.lg),
              JoinSessionCard(),
              SizedBox(height: SpSpacing.lg),
              CreateSessionCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// Desktop/tablet: two-pane split — hero left, cards right.
  Widget _buildSplit(BuildContext context) {
    final size = screenSizeOf(context);
    final horizontalPadding =
        size == SpScreenSize.desktop ? SpSpacing.xxl * 2 : SpSpacing.xl;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: SpSpacing.xl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left pane: hero ──────────────────────────────────────
          const Expanded(
            flex: 55,
            child: Center(
              child: HomeHero(alignment: CrossAxisAlignment.start),
            ),
          ),

          const SizedBox(width: SpSpacing.xxl),

          // ── Right pane: cards ────────────────────────────────────
          Expanded(
            flex: 45,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      JoinSessionCard(),
                      SizedBox(height: SpSpacing.lg),
                      CreateSessionCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
