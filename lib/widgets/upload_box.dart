
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class UploadBox extends StatelessWidget {
  final VoidCallback onTap;
  final double boxHeight;

  const UploadBox({super.key, required this.onTap, required this.boxHeight});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: const RoundedRectDottedBorderOptions(
          radius: Radius.circular(12),
          dashPattern: [6, 4],
          color: Colors.black38,
          strokeWidth: 1.5,
        ),
        child: Container(
          width: double.infinity,
          height: boxHeight,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_rounded, size: isTablet ? 34 : 30),
              const SizedBox(height: 6),
              Text(
                "Upload your logo",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 17 : 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  color: Colors.black54,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
