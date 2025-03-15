import 'package:document_manager/core/utils/constants/colors.dart';
import 'package:document_manager/core/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

/// A circular loader widget with customizable foreground and background colors.
class DMCircularLoader extends StatelessWidget {
  /// Default constructor for the TCircularLoader.
  ///
  /// Parameters:
  ///   - foregroundColor: The color of the circular loader.
  ///   - backgroundColor: The background color of the circular loader.
  const DMCircularLoader({
    super.key,
    this.foregroundColor = DMColors.white,
    this.backgroundColor = DMColors.primary,
  });

  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DMSizes.lg),
      decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle), // Circular background
      child: Center(
        child: CircularProgressIndicator(
            color: foregroundColor,
            backgroundColor: Colors.transparent), // Circular loader
      ),
    );
  }
}
