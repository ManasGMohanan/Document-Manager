import 'dart:io';
import 'package:document_manager/core/utils/app_methods/app_methods.dart';
import 'package:document_manager/core/utils/document_media/document_media.dart';
import 'package:document_manager/features/documents/presentation/bloc/document/document_bloc.dart';
import 'package:document_manager/features/documents/presentation/pages/add_document/widgets/document_file_selection.dart';
import 'package:document_manager/features/documents/presentation/widgets/category_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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

  // Use DocumentMediaUtils for media operations
  final DocumentMediaUtils _mediaUtils = DocumentMediaUtils();

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
      });
    }
  }

  Future<void> _captureImage() async {
    final image = await DocumentMediaUtils.captureImage();
    if (image != null) {
      setState(() {
        _selectedFile = image;
      });
    }
  }

  Future<void> _recordVideo() async {
    final video = await DocumentMediaUtils.recordVideo();
    if (video != null) {
      setState(() {
        _selectedFile = video;
      });
    }
  }

  Future<void> _startRecording() async {
    await _mediaUtils.startRecording((error) {
      DMAppMethods.showSnackBar(context, Text(error), Colors.red);
    });
    setState(() {});
  }

  Future<void> _stopRecording() async {
    final audioFile = await _mediaUtils.stopRecording((error) {
      DMAppMethods.showSnackBar(context, Text(error), Colors.red);
    });
    setState(() {
      if (audioFile != null) {
        _selectedFile = audioFile;
      }
    });
  }

  Future<void> _selectExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate != null) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  Future<void> _saveDocument() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFile == null) {
        DMAppMethods.showSnackBar(context, 'Please select a file', Colors.red);
        return;
      }

      if (_selectedCategoryId == null) {
        DMAppMethods.showSnackBar(
            context, 'Please select or create a category', Colors.red);
        return;
      }

      context.read<DocumentBloc>().add(
            AddDocument(
              title: _titleController.text,
              description: _descriptionController.text,
              file: _selectedFile!,
              categoryId: _selectedCategoryId!,
              expiryDate: _expiryDate,
            ),
          );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Document'),
      ),
      body: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          final isLoading = state is DocumentOperationInProgress;

          return isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            hintText: 'Enter document title',
                            prefixIcon: Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9\s\-_\.]+$')
                                .hasMatch(value)) {
                              return 'Title can only contain letters, numbers, spaces, and basic punctuation';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter document description',
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
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
                            });
                          },
                        ),
                        Text(
                          'Additional Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        CategorySelector(
                          selectedCategoryId: _selectedCategoryId,
                          onCategorySelected: (categoryId) {
                            setState(() {
                              _selectedCategoryId = categoryId;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _selectExpiryDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Expiry Date (Optional)',
                              hintText: 'Select expiry date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _expiryDate != null
                                      ? DateFormat('MMM dd, yyyy')
                                          .format(_expiryDate!)
                                      : 'No expiry date',
                                ),
                                if (_expiryDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _expiryDate = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveDocument,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Save Document'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
