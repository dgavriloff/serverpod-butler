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
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = screenSizeOf(context);

    return Scaffold(
      backgroundColor: SpColors.background,
      body: size == SpScreenSize.mobile ? _buildMobile(context) : _buildSplit(context),
    );
  }

  /// Mobile: vertical stack, centered, scrollable.
  Widget _buildMobile(BuildContext context) {
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
          // ── Left pane: illustration + hero card ───────────────
          Expanded(
            flex: 55,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  LandingIllustration(),
                  HomeHero(alignment: CrossAxisAlignment.start),
                ],
              ),
            ),
          ),

          const SizedBox(width: SpSpacing.xxl),

          // ── Right pane: join card + or + create button ───────
          Expanded(
            flex: 45,
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
        ],
      ),
    );
  }
}
