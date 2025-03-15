import 'dart:io';
import 'package:document_manager/core/utils/file/file_utils.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:document_manager/features/documents/domain/entities/document.dart';
import 'package:document_manager/features/documents/domain/repositories/document_repository.dart';
import 'package:document_manager/features/documents/data/models/document_model.dart';
import 'package:path/path.dart' as path;

class DocumentRepositoryImpl implements DocumentRepository {
  final Box<DocumentModel> _documentsBox;
  final Uuid _uuid = const Uuid();

  DocumentRepositoryImpl(this._documentsBox);

  @override
  Future<List<Document>> getAllDocuments() async {
    return _documentsBox.values.toList();
  }

  @override
  Future<Document> getDocumentById(String id) async {
    final document = _documentsBox.values.firstWhere(
      (doc) => doc.id == id,
      orElse: () => throw Exception('Document not found'),
    );
    return document;
  }

  @override
  Future<Document> addDocument({
    required String title,
    required String description,
    required File file,
    required String categoryId,
    DateTime? expiryDate,
  }) async {
    final id = _uuid.v4();
    final filePath = await DMFileUtils.saveFile(file);
    final fileType =
        path.extension(filePath).toLowerCase().replaceFirst('.', '');

    final document = DocumentModel(
      id: id,
      title: title,
      description: description,
      filePath: filePath,
      fileType: fileType,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      expiryDate: expiryDate,
    );

    await _documentsBox.put(id, document);
    return document;
  }

  @override
  Future<Document> updateDocument({
    required String id,
    String? title,
    String? description,
    File? file,
    String? categoryId,
    DateTime? expiryDate,
  }) async {
    final existingDocument = await getDocumentById(id) as DocumentModel;
    String filePath = existingDocument.filePath;
    String fileType = existingDocument.fileType;

    if (file != null) {
      // Delete old file
      await DMFileUtils.deleteFile(existingDocument.filePath);
      // Save new file
      filePath = await DMFileUtils.saveFile(file);
      fileType = path.extension(filePath).toLowerCase().replaceFirst('.', '');
    }

    final updatedDocument = existingDocument.copyWith(
      title: title,
      description: description,
      filePath: file != null ? filePath : null,
      fileType: file != null ? fileType : null,
      categoryId: categoryId,
      expiryDate: expiryDate,
    );

    await _documentsBox.put(id, updatedDocument);
    return updatedDocument;
  }

  @override
  Future<void> deleteDocument(String id) async {
    final document = await getDocumentById(id);
    await DMFileUtils.deleteFile(document.filePath);
    await _documentsBox.delete(id);
  }
}
