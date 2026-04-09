import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250,
        height: 6,
        decoration: BoxDecoration(
          color: const Color(0xFFD6D1DF),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.06, 1),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111217),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
