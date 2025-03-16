import 'dart:io';
import 'package:document_manager/core/common_widgets/section_header_widget.dart';
import 'package:document_manager/core/common_widgets/textfield_widget.dart';
import 'package:document_manager/core/utils/app_methods/app_methods.dart';
import 'package:document_manager/core/utils/constants/colors.dart';
import 'package:document_manager/core/utils/constants/default_category.dart';
import 'package:document_manager/core/utils/constants/text_strings.dart';
import 'package:document_manager/core/utils/document_media/document_media.dart';
import 'package:document_manager/features/documents/presentation/bloc/document/document_bloc.dart';
import 'package:document_manager/features/documents/presentation/pages/add_document/widgets/document_file_selection.dart';
import 'package:document_manager/features/documents/presentation/pages/view_edit_document/widgets/expiry_date_picker.dart';
import 'package:document_manager/features/documents/presentation/widgets/category_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedFile;
  DateTime? _expiryDate;
  String? _selectedCategoryId;
  bool _isFormValid = false;

  // Use DocumentMediaUtils for media operations
  final DocumentMediaUtils _mediaUtils = DocumentMediaUtils();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _titleController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty &&
          _selectedFile != null;
      //optional
      // _selectedCategoryId != null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final file = await DocumentMediaUtils.pickDocument();
    if (file != null) {
      setState(() {
        _selectedFile = file;
        _validateForm();
      });
    }
  }

  Future<void> _captureImage() async {
    final image = await DocumentMediaUtils.captureImage();
    if (image != null) {
      setState(() {
        _selectedFile = image;
        _validateForm();
      });
    }
  }

  Future<void> _recordVideo() async {
    final video = await DocumentMediaUtils.recordVideo();
    if (video != null) {
      setState(() {
        _selectedFile = video;
        _validateForm();
      });
    }
  }

  Future<void> _startRecording() async {
    await _mediaUtils.startRecording((error) {
      DMAppMethods.showSnackBar(context, Text(error), DMColors.error);
    });
    setState(() {});
  }

  Future<void> _stopRecording() async {
    final audioFile = await _mediaUtils.stopRecording((error) {
      DMAppMethods.showSnackBar(context, Text(error), DMColors.error);
    });
    setState(() {
      if (audioFile != null) {
        _selectedFile = audioFile;
        _validateForm();
      }
    });
  }

  Future<void> _saveDocument() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFile == null) {
        DMAppMethods.showSnackBar(
            context, const Text('Please select a file'), DMColors.error);
        return;
      }

      //If no category is selected, default to "Uncategorized"
      final categoryId = _selectedCategoryId ?? defaultCategoryId;

      context.read<DocumentBloc>().add(
            AddDocument(
              title: _titleController.text,
              description: _descriptionController.text,
              file: _selectedFile!,
              categoryId: categoryId,
              expiryDate: _expiryDate,
            ),
          );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(DMTexts.addDocAppBar),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          final isLoading = state is DocumentOperationInProgress;

          return isLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        DMTexts.savingDoc,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'Document Information',
                              icon: Icons.article_outlined,
                            ),
                            const SizedBox(height: 20),
                            // Title text field
                            CustomTextField(
                              controller: _titleController,
                              labelText: 'Title*',
                              hintText: 'Enter document title',
                              prefixIcon: Icons.title,
                              fieldType: FieldType.title,
                              characterLimit: 20,
                            ),

                            const SizedBox(height: 16),

                            // Description text field
                            CustomTextField(
                              controller: _descriptionController,
                              labelText: 'Description*',
                              hintText: 'Enter document description',
                              prefixIcon: Icons.description,
                              maxLines: 3,
                              fieldType: FieldType.description,
                              characterLimit: 100,
                            ),

                            const SizedBox(height: 24),
                            DocumentFileSelection(
                              selectedFile: _selectedFile,
                              mediaUtils: _mediaUtils,
                              onPickFile: _pickFile,
                              onCaptureImage: _captureImage,
                              onRecordVideo: _recordVideo,
                              onStartRecording: _startRecording,
                              onStopRecording: _stopRecording,
                              onRemoveFile: () {
                                setState(() {
                                  _selectedFile = null;
                                  _validateForm();
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            SectionHeader(
                              title: 'Additional Information (optional)',
                              icon: Icons.info_outline,
                            ),
                            const SizedBox(height: 20),
                            _buildCategorySection(context),
                            const SizedBox(height: 16),
                            ExpiryDatePicker(
                              expiryDate: _expiryDate,
                              onDateChanged: (date) {
                                setState(() {
                                  _expiryDate = date;
                                });
                              },
                              labelText: 'Expiry Date',
                              useBoxDecoration: true,
                            ),
                            const SizedBox(height: 40),
                            _buildSaveButton(context, colorScheme),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          CategorySelector(
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (categoryId) {
              setState(() {
                _selectedCategoryId = categoryId;
                _validateForm();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isFormValid ? _saveDocument : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save),
            const SizedBox(width: 12),
            Text(
              'Save Document',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adding a Document'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DMTexts.point1),
              SizedBox(height: 8),
              Text(DMTexts.point2),
              SizedBox(height: 8),
              Text(DMTexts.point3),
              SizedBox(height: 8),
              Text(DMTexts.point4),
              SizedBox(height: 8),
              Text(DMTexts.point5),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(DMTexts.gotIT),
          ),
        ],
      ),
    );
  }
}
