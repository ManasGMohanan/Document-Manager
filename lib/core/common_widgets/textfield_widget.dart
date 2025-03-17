import 'package:flutter/material.dart';

enum FieldType { title, description }

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final int maxLines;
  final FieldType fieldType;
  final int? characterLimit;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.fieldType,
    this.maxLines = 1,
    this.characterLimit,
  });

  String? _validate(String? value) {
    // Basic empty check for both field types.
    if (value == null || value.isEmpty) {
      return fieldType == FieldType.title
          ? 'Please enter a title'
          : 'Please enter a description';
    }

    // Additional title-specific validations.
    if (fieldType == FieldType.title) {
      // Check for allowed characters.
      if (!RegExp(r'^[a-zA-Z0-9\s\-_\.]+$').hasMatch(value)) {
        return 'Invalid title';
      }
    }

    // Check for character limit if provided.
    if (characterLimit != null && value.length > characterLimit!) {
      return fieldType == FieldType.title
          ? 'Title cannot exceed $characterLimit characters'
          : 'Description cannot exceed $characterLimit characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLength: characterLimit,
      validator: _validate,
      decoration: InputDecoration(
        //Rich text being used for making label text to have a red asterisk
        label: RichText(
          text: TextSpan(
            text: labelText.replaceAll('*', ''),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
