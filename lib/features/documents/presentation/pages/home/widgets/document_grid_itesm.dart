// ignore_for_file: deprecated_member_use
import 'package:document_manager/core/utils/constants/colors.dart';
import 'package:document_manager/core/utils/file/file_utils.dart';
import 'package:document_manager/core/utils/formatters/formatter.dart';
import 'package:document_manager/features/documents/data/models/category_model.dart';
import 'package:document_manager/features/documents/domain/entities/document.dart';
import 'package:document_manager/features/documents/presentation/bloc/category/category_bloc.dart';
import 'package:document_manager/features/documents/presentation/widgets/document_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//Changed to grid,
class DocumentGridItem extends StatelessWidget {
  final Document document;
  final bool isExpired;
  final VoidCallback onTap;

  const DocumentGridItem({
    super.key,
    required this.document,
    required this.isExpired,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileIcon = DMFileUtils.getFileIcon(document.filePath);
    final fileColor = DMFileUtils.getFileColor(document.filePath);
    final formattedDate = DMFormatter.formatDate(document.expiryDate);
    // Check if document is expired
    final bool isExpired = document.expiryDate != null &&
        document.expiryDate!.isBefore(DateTime.now());
    final bool isExpiringSoon = document.expiryDate != null &&
        !isExpired &&
        DMFormatter.isExpiringSoon(document.expiryDate!);

    // Status colors
    final Color expiryColor = isExpired
        ? Colors.red
        : (isExpiringSoon ? Colors.orange : theme.colorScheme.primary);

    return Card(
      elevation: 0,
      color: isExpired ? Colors.red.shade100 : DMColors.lightCardColor2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: fileColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      fileIcon,
                      size: 20,
                      color: fileColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      document.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Document thumbnail
              Expanded(
                flex: 4,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: DocumentThumbnail(
                      filePath: document.filePath,
                      documentId: document.id,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Category indicator at the bottom, changed to only icon
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

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (document.expiryDate != null)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: expiryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.timer_outlined,
                                  size: 10,
                                  color: expiryColor,
                                ),
                              ),
                            const SizedBox(width: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (formattedDate.isNotEmpty)
                                  Text(
                                    formattedDate,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isExpired || isExpiringSoon
                                          ? expiryColor
                                          : null,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Icon(
                          category.icon,
                          size: 16,
                          color: category.color,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
