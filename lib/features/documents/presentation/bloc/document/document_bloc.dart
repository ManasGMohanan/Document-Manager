import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:document_manager/features/documents/domain/entities/document.dart';
import 'package:document_manager/features/documents/domain/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';

part 'document_event.dart';
part 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentRepository repository;

  DocumentBloc({required this.repository}) : super(DocumentInitial()) {
    on<LoadDocuments>(_onLoadDocuments);
    on<AddDocument>(_onAddDocument);
    on<UpdateDocument>(_onUpdateDocument);
    on<DeleteDocument>(_onDeleteDocument);
  }

  Future<void> _onLoadDocuments(
    LoadDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      final documents = await repository.getAllDocuments();
      // Sort documents by creation date (newest first)
      documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(DocumentsLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load documents: ${e.toString()}'));
    }
  }

  Future<void> _onAddDocument(
    AddDocument event,
    Emitter<DocumentState> emit,
  ) async {
    final currentState = state;
    if (currentState is DocumentsLoaded) {
      emit(DocumentOperationInProgress(currentState.documents));
      try {
        final document = await repository.addDocument(
          title: event.title,
          description: event.description,
          file: event.file,
          categoryId: event.categoryId,
          expiryDate: event.expiryDate,
        );

        final updatedDocuments = [document, ...currentState.documents];
        emit(DocumentOperationSuccess(
            updatedDocuments, 'Document added successfully'));
      } catch (e) {
        emit(DocumentError('Failed to add document: ${e.toString()}',
            previousDocuments: currentState.documents));
      }
    }
  }

  Future<void> _onUpdateDocument(
    UpdateDocument event,
    Emitter<DocumentState> emit,
  ) async {
    final currentState = state;
    if (currentState is DocumentsLoaded) {
      emit(DocumentOperationInProgress(currentState.documents));
      try {
        final document = await repository.updateDocument(
          id: event.id,
          title: event.title,
          description: event.description,
          file: event.file,
          categoryId: event.categoryId,
          expiryDate: event.expiryDate,
        );

        final updatedDocuments = currentState.documents.map((doc) {
          return doc.id == event.id ? document : doc;
        }).toList();

        emit(DocumentOperationSuccess(
            updatedDocuments, 'Document updated successfully'));
      } catch (e) {
        emit(DocumentError('Failed to update document: ${e.toString()}',
            previousDocuments: currentState.documents));
      }
    }
  }

  Future<void> _onDeleteDocument(
    DeleteDocument event,
    Emitter<DocumentState> emit,
  ) async {
    final currentState = state;
    if (currentState is DocumentsLoaded) {
      emit(DocumentOperationInProgress(currentState.documents));
      try {
        await repository.deleteDocument(event.id);

        final updatedDocuments =
            currentState.documents.where((doc) => doc.id != event.id).toList();
        emit(DocumentOperationSuccess(
            updatedDocuments, 'Document deleted successfully'));
      } catch (e) {
        emit(DocumentError('Failed to delete document: ${e.toString()}',
            previousDocuments: currentState.documents));
      }
    }
  }
}
