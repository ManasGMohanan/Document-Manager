import 'dart:io';

import 'package:document_manager/core/utils/file/file_utils.dart';
import 'package:document_manager/core/utils/formatters/formatter.dart';
import 'package:document_manager/features/documents/data/models/category_model.dart';
import 'package:document_manager/features/documents/domain/entities/document.dart';
import 'package:document_manager/features/documents/presentation/bloc/category/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentListItem extends StatelessWidget {
  final Document document;
  final bool isExpired;
  final VoidCallback onTap;

  const DocumentListItem({
    super.key,
    required this.document,
    required this.isExpired,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(context),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            document.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isExpired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Expired',
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        BlocBuilder<CategoryBloc, CategoryState>(
                          builder: (context, state) {
                            if (state is CategoriesLoaded) {
                              final category = state.categories.firstWhere(
                                (cat) => cat.id == document.categoryId,
                                orElse: () => CategoryModel(
                                  id: '',
                                  name: 'Unknown',
                                  colorValue: Colors.grey.value,
                                  iconData: Icons.help_outline.codePoint,
                                ),
                              );

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: category.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      category.icon,
                                      size: 16,
                                      color: category.color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: category.color.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Loading...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        if (document.expiryDate != null && !isExpired)
                          Text(
                            'Expires: ${DMFormatter.formatDate(document.expiryDate!)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    return FutureBuilder<File?>(
      future: DMFileUtils.getThumbnail(document.filePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Hero(
            tag: 'thumbnail-${document.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                snapshot.data!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackThumbnail();
                },
              ),
            ),
          );
        }

        return _buildFallbackThumbnail();
      },
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: DMFileUtils.getFileColor(document.filePath).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          DMFileUtils.getFileIcon(document.filePath),
          size: 40,
          color: DMFileUtils.getFileColor(document.filePath),
        ),
      ),
    );
  }
}
