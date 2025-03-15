import 'dart:io';
import 'package:document_manager/features/documents/domain/entities/document.dart';

abstract class DocumentRepository {
  Future<List<Document>> getAllDocuments();
  Future<Document> getDocumentById(String id);
  Future<Document> addDocument({
    required String title,
    required String description,
    required File file,
    required String categoryId,
    DateTime? expiryDate,
  });
  Future<Document> updateDocument({
    required String id,
    String? title,
    String? description,
    File? file,
    String? categoryId,
    DateTime? expiryDate,
  });
  Future<void> deleteDocument(String id);
}
