import 'package:flutter/material.dart';
import 'app_spacing.dart';

enum TextFieldType {
  text,
  email,
  password,
  number,
  phone,
  url,
  multiline,
}

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextFieldType type;
  final int maxLines;
  final int? minLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final Widget? prefix;
  final Widget? suffix;
  final bool readOnly;
  final bool enabled;
  final TextInputAction textInputAction;
  final String? errorText;
  final bool showCounter;
  final int? maxLength;
  final bool isRequired;

  const AppTextField({
    Key? key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.type = TextFieldType.text,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.onChanged,
    this.onTap,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.errorText,
    this.showCounter = false,
    this.maxLength,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == TextFieldType.password;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.password:
        return TextInputType.visiblePassword;
      case TextFieldType.number:
        return TextInputType.number;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.url:
        return TextInputType.url;
      case TextFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPassword = widget.type == TextFieldType.password;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LABEL
        Row(
          children: [
            Text(
              widget.label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.isRequired)
              Text(
                ' *',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // TEXT FIELD
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          keyboardType: _getKeyboardType(),
          maxLines: isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          obscureText: isPassword && _obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          textInputAction: widget.textInputAction,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            filled: true,
            fillColor: widget.enabled
            ? const Color(0xFFFCFCFD)
            : const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            prefixIcon: widget.prefix != null
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: widget.prefix,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                    child: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  )
                : (widget.suffix != null
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: widget.suffix,
                      )
                    : null),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            counterText: widget.showCounter ? null : '',
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
