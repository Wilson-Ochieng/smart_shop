import 'package:flutter/material.dart';

class LoadngManager extends StatelessWidget {
  const LoadngManager({
    super.key,
    required this.child,
    required this.isLoading,
  });
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) ...[
          Container(color: Colors.black.withOpacity(0.7)),

          Center(child: CircularProgressIndicator(color: Colors.red)),
        ],
      ],
    );
  }
}
