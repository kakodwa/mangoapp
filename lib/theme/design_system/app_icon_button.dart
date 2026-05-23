import 'package:flutter/material.dart';

enum IconButtonStyle {
  filled,
  outlined,
  ghost,
}

class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final IconButtonStyle style;
  final bool isSelected;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.iconSize = 20,
    this.color,
    this.backgroundColor,
    this.style = IconButtonStyle.filled,
    this.isSelected = false,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final bgColor = widget.backgroundColor ?? baseColor;

    Color? iconColor;
    Color? containerBg;
    Color? containerBorder;

    switch (widget.style) {
      case IconButtonStyle.filled:
        iconColor = Colors.white;
        containerBg = widget.isSelected ? bgColor : bgColor.withOpacity(0.15);
        break;
      case IconButtonStyle.outlined:
        iconColor = baseColor;
        containerBg = Colors.transparent;
        containerBorder = baseColor;
        break;
      case IconButtonStyle.ghost:
        iconColor = baseColor;
        containerBg = Colors.transparent;
        break;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: containerBg,
            border: containerBorder != null
                ? Border.all(color: containerBorder, width: 1.5)
                : null,
            boxShadow: widget.style == IconButtonStyle.filled
                ? [
                    BoxShadow(
                      color: bgColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
