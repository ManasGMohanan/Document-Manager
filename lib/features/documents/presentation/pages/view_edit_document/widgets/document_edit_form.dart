import 'package:document_manager/core/common_widgets/textfield_widget.dart';
import 'package:document_manager/features/documents/presentation/pages/view_edit_document/widgets/expiry_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:document_manager/features/documents/presentation/widgets/category_selector.dart';

class DocumentEditForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final DateTime? expiryDate;
  final ValueChanged<DateTime?> onExpiryDateChanged;

  const DocumentEditForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.expiryDate,
    required this.onExpiryDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: titleController,
            labelText: 'Title*',
            hintText: 'Enter document title',
            prefixIcon: Icons.title,
            fieldType: FieldType.title,
            characterLimit: 20,
          ),

          const SizedBox(height: 16),

          CustomTextField(
            controller: descriptionController,
            labelText: 'Description*',
            hintText: 'Enter document description',
            prefixIcon: Icons.description,
            maxLines: 3,
            fieldType: FieldType.description,
            characterLimit: 100,
          ),
          const SizedBox(height: 16),

          CategorySelector(
            selectedCategoryId: selectedCategoryId,
            onCategorySelected: onCategorySelected,
          ),
          const SizedBox(height: 16),
          // Expiry Date Picker (using the separate widget)
          ExpiryDatePicker(
            expiryDate: expiryDate,
            onDateChanged: onExpiryDateChanged,
            labelText: 'Expiry Date',
            useBoxDecoration: false,
          ),
        ],
      ),
    );
  }
}
