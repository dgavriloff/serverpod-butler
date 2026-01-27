import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../widgets/create_session_card.dart';
import '../widgets/home_hero.dart';
import '../widgets/join_session_card.dart';

/// Home screen — hero, join card, create card in a centered column.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = width >= 600 ? SpSpacing.xxl : SpSpacing.md;

    return Scaffold(
      backgroundColor: SpColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
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
      ),
    );
  }
}
