// ignore_for_file: use_build_context_synchronously

import 'package:document_manager/core/utils/app_methods/app_methods.dart';
import 'package:document_manager/core/utils/constants/colors.dart';
import 'package:document_manager/core/utils/constants/text_strings.dart';
import 'package:document_manager/features/documents/domain/entities/document.dart';
import 'package:document_manager/features/documents/presentation/bloc/document/document_bloc.dart';
import 'package:document_manager/features/documents/presentation/pages/view_edit_document/widgets/document_edit_form.dart';
import 'package:document_manager/features/documents/presentation/pages/view_edit_document/widgets/document_view_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentDetailsScreen extends StatefulWidget {
  final String documentId;

  const DocumentDetailsScreen({super.key, required this.documentId});

  @override
  State<DocumentDetailsScreen> createState() => _DocumentDetailsScreenState();
}

class _DocumentDetailsScreenState extends State<DocumentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _expiryDate;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Document? _getDocument(BuildContext context) {
    final state = context.read<DocumentBloc>().state;
    if (state is DocumentsLoaded) {
      try {
        return state.documents.firstWhere(
          (doc) => doc.id == widget.documentId,
        );
      } catch (e) {
        // Document not found
        //snackbar issue
      }
    }
    return null;
  }

  void _initializeFields(Document document) {
    _titleController.text = document.title;
    _descriptionController.text = document.description;
    _expiryDate = document.expiryDate;
    _selectedCategoryId = document.categoryId;
  }

  Future<void> _updateDocument() async {
    // Validate all form fields // solved
    if (!_formKey.currentState!.validate()) {
      DMAppMethods.showSnackBar(context,
          'Please fill in all required fields correctly.', DMColors.error);
      return;
    }

    if (_selectedCategoryId == null) {
      DMAppMethods.showSnackBar(
          context, 'Please select or create a category', DMColors.error);
      return;
    }

    context.read<DocumentBloc>().add(
          UpdateDocument(
            id: widget.documentId,
            title: _titleController.text,
            description: _descriptionController.text,
            categoryId: _selectedCategoryId,
            expiryDate: _expiryDate,
          ),
        );

    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _deleteDocument() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text(DMTexts.docDeletionWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    context.read<DocumentBloc>().add(DeleteDocument(widget.documentId));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocumentBloc, DocumentState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          if (state is DocumentOperationSuccess) {
            DMAppMethods.showSnackBar(context, state.message, DMColors.success);
          } else if (state is DocumentError) {
            DMAppMethods.showSnackBar(context, state.message, DMColors.error);
          }
        }
      },
      builder: (context, state) {
        final document = _getDocument(context);
        if (document == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!_isEditing) {
          _initializeFields(document);
        }

        final isLoading = state is DocumentOperationInProgress;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Document' : 'Details'),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteDocument,
                ),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _updateDocument,
                ),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      _initializeFields(document);
                      _isEditing = false;
                    });
                  },
                ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isEditing
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: DocumentEditForm(
                        formKey:
                            _formKey, // Passing the form key here for missed
                        titleController: _titleController,
                        descriptionController: _descriptionController,
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: (catId) {
                          setState(() {
                            _selectedCategoryId = catId;
                          });
                        },
                        expiryDate: _expiryDate,
                        onExpiryDateChanged: (newDate) {
                          setState(() {
                            _expiryDate = newDate;
                          });
                        },
                      ),
                    )
                  : DocumentViewModeSection(document: document),
        );
      },
    );
  }
}
