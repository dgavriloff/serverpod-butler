import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/sp_colors.dart';
import '../theme/sp_spacing.dart';
import '../theme/sp_typography.dart';

/// scratchpad text field — 48px height, 6px radius, label above.
///
/// Focus: blue border. Error: red border + message below.
class SpTextField extends StatelessWidget {
  const SpTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.autofocus = false,
    this.enabled = true,
    this.suffix,
    this.prefix,
    this.textInputAction,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool autofocus;
  final bool enabled;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: SpTypography.caption.copyWith(
            color: SpColors.textSecondary,
            fontWeight: FontWeight.w500,
          )),
          const SizedBox(height: SpSpacing.xs),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          maxLines: expands ? null : maxLines,
          minLines: minLines,
          expands: expands,
          autofocus: autofocus,
          enabled: enabled,
          textInputAction: textInputAction,
          style: SpTypography.body,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            suffixIcon: suffix,
            prefixIcon: prefix,
            isDense: true,
          ),
        ),
      ],
    );
  }
}
