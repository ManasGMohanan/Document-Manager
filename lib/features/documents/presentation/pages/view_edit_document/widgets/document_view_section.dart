// ignore_for_file: deprecated_member_use
import 'package:document_manager/core/utils/constants/colors.dart';
import 'package:document_manager/core/utils/file/file_utils.dart';
import 'package:document_manager/core/utils/formatters/formatter.dart';
import 'package:document_manager/features/documents/data/models/category_model.dart';
import 'package:document_manager/features/documents/domain/entities/document.dart';
import 'package:document_manager/features/documents/presentation/bloc/category/category_bloc.dart';
import 'package:document_manager/features/documents/presentation/widgets/document_thumbnail.dart';
import 'package:document_manager/features/documents/presentation/widgets/document_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DocumentViewModeSection extends StatelessWidget {
  final Document document;

  const DocumentViewModeSection({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileIcon = DMFileUtils.getFileIcon(document.filePath);
    final fileColor = DMFileUtils.getFileColor(document.filePath);
    final fileSize = DMFileUtils.getFileSize(document.filePath);
    final fileType = DMFileUtils.getFileType(document.filePath);
    final formattedDate = DMFormatter.formatDate(document.expiryDate);
    final createdDate = DMFormatter.formatDate(document.createdAt);

    // document is expired check, issue solve
    final bool isExpired = document.expiryDate != null &&
        document.expiryDate!.isBefore(DateTime.now());
    final bool isExpiringSoon = document.expiryDate != null &&
        !isExpired &&
        DMFormatter.isExpiringSoon(document.expiryDate!);

    // Status colors
    final Color expiryColor = isExpired
        ? Colors.red
        : (isExpiringSoon ? Colors.orange : theme.colorScheme.primary);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail and title section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: DocumentThumbnail(
                      filePath: document.filePath,
                      documentId: document.id,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title and file info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        document.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // File info in row
                      Row(
                        children: [
                          // File icon
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: fileColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              fileIcon,
                              size: 16,
                              color: fileColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // File size
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: DMColors.buttonPrimary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              fileSize,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: DMColors.textWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Category and expiry info row
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoriesLoaded) {
                  final category = state.categories.firstWhere(
                    (cat) => cat.id == document.categoryId,
                    orElse: () => CategoryModel(
                      id: '',
                      name: 'Uncategorized',
                      colorValue: Colors.grey.value,
                      iconData: Icons.folder_outlined.codePoint,
                    ),
                  );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: category.color.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              size: 14,
                              color: category.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: category.color,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expiry date badge (only if expiry date exists)
                      if (document.expiryDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: expiryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: expiryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isExpired
                                    ? Icons.error_outline
                                    : Icons.access_time,
                                size: 14,
                                color: expiryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isExpired
                                    ? 'Expired'
                                    : (isExpiringSoon
                                        ? 'Expires soon'
                                        : 'Expires ${DateFormat('MM/dd/yy').format(document.expiryDate!)}'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: expiryColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(),
                    ],
                  );
                }
                return const SizedBox(
                  height: 24,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 16,
            ),
            // Description section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Description',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    document.description.isEmpty
                        ? 'No description provided.'
                        : document.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: document.description.isEmpty
                          ? theme.colorScheme.onSurface.withOpacity(0.5)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date section
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Created',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                          if (createdDate.isNotEmpty)
                            Text(
                              createdDate,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Expires date
                if (document.expiryDate != null)
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: expiryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: expiryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expires',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                            if (formattedDate.isNotEmpty)
                              Text(
                                formattedDate,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
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
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // View document button
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: Text(
                  'Open $fileType',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
