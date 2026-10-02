import 'package:flutter/material.dart';

class SquareCloseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const SquareCloseButton({
    super.key,
    this.onPressed,
    this.size = 32.0,
    this.backgroundColor = Colors.red,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4.0),
          child: Icon(Icons.close, color: iconColor, size: size * 0.7),
        ),
      ),
    );
  }
}
