import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../theme/sp_colors.dart';
import '../theme/sp_typography.dart';

/// Renders markdown text with app styling.
/// Use for AI-generated content that may contain formatting.
class SpMarkdown extends StatelessWidget {
  const SpMarkdown({
    super.key,
    required this.data,
    this.shrinkWrap = true,
  });

  final String data;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      shrinkWrap: shrinkWrap,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: SpTypography.body,
        h1: SpTypography.pageTitle,
        h2: SpTypography.section,
        h3: SpTypography.section.copyWith(fontSize: 16),
        h4: SpTypography.body.copyWith(fontWeight: FontWeight.w600),
        h5: SpTypography.body.copyWith(fontWeight: FontWeight.w600),
        h6: SpTypography.body.copyWith(fontWeight: FontWeight.w600),
        em: SpTypography.body.copyWith(fontStyle: FontStyle.italic),
        strong: SpTypography.body.copyWith(fontWeight: FontWeight.w700),
        code: SpTypography.body.copyWith(
          fontFamily: 'monospace',
          backgroundColor: SpColors.surfaceTertiary,
          fontSize: 13,
        ),
        codeblockDecoration: BoxDecoration(
          color: SpColors.surfaceTertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockquote: SpTypography.body.copyWith(
          color: SpColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: SpColors.border,
              width: 3,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12),
        listBullet: SpTypography.body,
        tableHead: SpTypography.body.copyWith(fontWeight: FontWeight.w600),
        tableBody: SpTypography.body,
        tableBorder: TableBorder.all(color: SpColors.border, width: 1),
        tableCellsPadding: const EdgeInsets.all(8),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: SpColors.border, width: 1),
          ),
        ),
      ),
    );
  }
}
