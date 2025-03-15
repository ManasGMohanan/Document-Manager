import 'package:document_manager/core/utils/app_methods/app_methods.dart';
import 'package:document_manager/core/utils/file/file_utils.dart';
import 'package:document_manager/core/utils/formatters/formatter.dart';
import 'package:document_manager/features/documents/data/models/category_model.dart';
import 'package:document_manager/features/documents/domain/entities/document.dart';
import 'package:document_manager/features/documents/presentation/bloc/category/category_bloc.dart';
import 'package:document_manager/features/documents/presentation/bloc/document/document_bloc.dart';
import 'package:document_manager/features/documents/presentation/widgets/category_selector.dart';
import 'package:document_manager/features/documents/presentation/widgets/document_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DocumentDetailsScreen extends StatefulWidget {
  final String documentId;

  const DocumentDetailsScreen({
    super.key,
    required this.documentId,
  });

  @override
  State<DocumentDetailsScreen> createState() => _DocumentDetailsScreenState();
}

class _DocumentDetailsScreenState extends State<DocumentDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _documentType;
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
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (mounted) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(
        //         content: Text('Document not found'),
        //         backgroundColor: Colors.red,
        //       ),
        //     );
        //     Navigator.pop(context);
        //   }
        // });
      }
    }
    return null;
  }

  void _initializeFields(Document document) {
    _titleController.text = document.title;
    _descriptionController.text = document.description;
    _documentType = document.fileType;
    _expiryDate = document.expiryDate;
    _selectedCategoryId = document.categoryId;
  }

  Future<void> _updateDocument() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or create a category'),
          backgroundColor: Colors.red,
        ),
      );
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
        content: const Text(
            'Are you sure you want to delete this document? This action cannot be undone.'),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocumentBloc, DocumentState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          if (state is DocumentOperationSuccess) {
            DMAppMethods.showSnackBar(context, state.message, Colors.green);
          } else if (state is DocumentError) {
            DMAppMethods.showSnackBar(context, state.message, Colors.red);
          }
        }
      },
      builder: (context, state) {
        final document = _getDocument(context);

        if (document == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Document Details'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Initialize fields if not in editing mode
        if (!_isEditing) {
          _initializeFields(document);
        }

        final isLoading = state is DocumentOperationInProgress;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Document' : 'Document Details'),
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditing) ...[
                        // Edit mode
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            prefixIcon: Icon(Icons.title),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
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
                      ] else ...[
                        // View mode
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      DMFileUtils.getFileIcon(
                                          document.filePath),
                                      size: 40,
                                      color: DMFileUtils.getFileColor(
                                          document.filePath),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            document.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                          BlocBuilder<CategoryBloc,
                                              CategoryState>(
                                            builder: (context, state) {
                                              if (state is CategoriesLoaded) {
                                                final category =
                                                    state.categories.firstWhere(
                                                  (cat) =>
                                                      cat.id ==
                                                      document.categoryId,
                                                  orElse: () => CategoryModel(
                                                    id: '',
                                                    name: 'Unknown',
                                                    colorValue:
                                                        Colors.grey.value,
                                                    iconData: Icons
                                                        .help_outline.codePoint,
                                                  ),
                                                );

                                                return Row(
                                                  children: [
                                                    Icon(
                                                      category.icon,
                                                      color: category.color,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      category.name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                  ],
                                                );
                                              }
                                              return Text(
                                                'Loading category...',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 32),
                                Text(
                                  'Description',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(document.description),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Created',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          Text(
                                            DMFormatter.formatDateTime(
                                                document.createdAt),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (document.expiryDate != null)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Expires',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                            ),
                                            Text(
                                              DMFormatter.formatDate(
                                                  document.expiryDate!),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        DMFormatter.isExpired(
                                                                document
                                                                    .expiryDate)
                                                            ? Colors.red
                                                            : null,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DocumentViewer(
                                    filePath: document.filePath,
                                    title: document.title,
                                    documentId: document.id,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Document'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}
