import 'package:flutter/material.dart';

class SubtitleTextWidget extends StatelessWidget {
  const SubtitleTextWidget({
    super.key,
    required this.label,
    this.fontSize = 18,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.textDecoration = TextDecoration.none,
    this.fontStyle = FontStyle.normal,
  });

  final String label;
  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final Color? color;
  final TextDecoration textDecoration;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,

        decoration: textDecoration,
        color: Colors.red,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
