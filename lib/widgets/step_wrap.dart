import 'package:flutter/material.dart';

class StepWrap extends StatelessWidget {
  const StepWrap({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121218),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.35,
                color: Color(0xFF4E4D56),
              ),
            ),
          ],
          const SizedBox(height: 28),
          ...children,
        ],
      ),
    );
  }
}
