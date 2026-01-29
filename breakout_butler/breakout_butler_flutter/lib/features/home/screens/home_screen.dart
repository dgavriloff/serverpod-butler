import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/sp_breakpoints.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/widgets/sp_button.dart';
import '../widgets/animated_pad_hero.dart';
import '../widgets/create_session_card.dart';
import '../widgets/landing_illustration.dart';
import '../widgets/or_divider.dart';

/// Home screen — split-screen on desktop/tablet, stacked on mobile.
///
/// Tracks mouse position globally so the dot illustration responds to
/// cursor movement anywhere on the page. Uses an animation controller
/// to smoothly ease the offset back to zero when the cursor leaves.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  /// The live target offset (set directly by mouse hover).
  Offset _targetOffset = Offset.zero;

  /// The rendered offset (animated toward _targetOffset).
  Offset _currentOffset = Offset.zero;

  /// Controller used to animate back to zero on mouse exit.
  late final AnimationController _returnController;
  late Animation<Offset> _returnAnimation;

  @override
  void initState() {
    super.initState();
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        setState(() => _currentOffset = _returnAnimation.value);
      });
  }

  @override
  void dispose() {
    _returnController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    final size = context.size;
    if (size == null || size.isEmpty) return;

    // Stop any return animation — live tracking takes over.
    if (_returnController.isAnimating) _returnController.stop();

    setState(() {
      _targetOffset = Offset(
        (event.localPosition.dx / size.width - 0.5) * 2.0,
        (event.localPosition.dy / size.height - 0.5) * 2.0,
      );
      _currentOffset = _targetOffset;
    });
  }

  void _onExit() {
    // Animate from the current offset smoothly back to center.
    _returnAnimation = Tween<Offset>(
      begin: _currentOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _returnController,
      curve: Curves.easeOutCubic,
    ));
    _returnController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = screenSizeOf(context);

    return Scaffold(
      backgroundColor: SpColors.background,
      body: MouseRegion(
        onHover: _onHover,
        onExit: (_) => _onExit(),
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
              const AnimatedPadHero(),
              const SizedBox(height: SpSpacing.lg),
              const CreateSessionCard(),
              const SizedBox(height: SpSpacing.lg),
              const OrDivider(),
              const SizedBox(height: SpSpacing.lg),
              SpSecondaryButton(
                label: 'join a session',
                icon: Icons.login,
                onPressed: () => context.go('/join'),
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

    final screenWidth = MediaQuery.sizeOf(context).width;

    return Stack(
      children: [
        // ── Illustration: extends past the 55% mark so dots bleed
        //    behind the right pane (clipped by the pane on top).
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: screenWidth * 0.62,
          child: LandingIllustration(mouseOffset: _currentOffset),
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
                    child: AnimatedPadHero(),
                  ),
                ),
              ),

              // Right pane: cards + or + create button — with left shadow
              Expanded(
                flex: 45,
                child: Container(
                  decoration: const BoxDecoration(
                    color: SpColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 24,
                        offset: Offset(-8, 0),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    right: rightPadding,
                    left: SpSpacing.lg,
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
                            const CreateSessionCard(),
                            const SizedBox(height: SpSpacing.lg),
                            const OrDivider(),
                            const SizedBox(height: SpSpacing.lg),
                            SpSecondaryButton(
                              label: 'join a session',
                              icon: Icons.login,
                              onPressed: () => context.go('/join'),
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
