import 'package:document_manager/features/documents/domain/entities/document.dart';

//Used for grouping documents by aaded date
class DocumentGrouper {
  static Map<String, List<Document>> groupDocumentsByDate(
      List<Document> documents) {
    final Map<String, List<Document>> groupedDocuments = {
      'Today': [],
      'Yesterday': [],
      'This Month': [],
      'Last Month': [],
      'Older': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    for (final document in documents) {
      final documentDate = document.createdAt;
      final docDate =
          DateTime(documentDate.year, documentDate.month, documentDate.day);

      if (docDate == today) {
        groupedDocuments['Today']!.add(document);
      } else if (docDate == yesterday) {
        groupedDocuments['Yesterday']!.add(document);
      } else if (docDate.isAfter(thisMonth) || docDate == thisMonth) {
        groupedDocuments['This Month']!.add(document);
      } else if (docDate.isAfter(lastMonth) || docDate == lastMonth) {
        groupedDocuments['Last Month']!.add(document);
      } else {
        groupedDocuments['Older']!.add(document);
      }
    }

    // Remove vacant groups
    groupedDocuments.removeWhere((key, value) => value.isEmpty);

    return groupedDocuments;
  }
}
