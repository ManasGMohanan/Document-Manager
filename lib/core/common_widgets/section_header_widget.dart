import 'package:document_manager/core/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

//Reusable widget that can be used for sections
//add document and its widgets
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData? trailingIcon;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: DMSizes.iconMd,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: DMSizes.fontSizeSm,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        if (trailingIcon != null)
          Icon(
            trailingIcon,
            color: Theme.of(context).primaryColor,
            size: DMSizes.iconMd,
          ),
      ],
    );
  }
}
