import 'package:flutter/material.dart';

class TitleTextWidget extends StatelessWidget {
  const TitleTextWidget({
    super.key,
    required this.label,
    this.fontSize = 18,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.textDecoration = TextDecoration.none,
    this.fontStyle = FontStyle.normal,
    this.maxLines,
  });

  final String label;
  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final Color? color;
  final int? maxLines;
  final TextDecoration textDecoration;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,

        decoration: textDecoration,
        color: color,
        fontStyle: FontStyle.italic,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
