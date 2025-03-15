part of 'document_bloc.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

class LoadDocuments extends DocumentEvent {}

class AddDocument extends DocumentEvent {
  final String title;
  final String description;
  final File file;
  final String categoryId;
  final DateTime? expiryDate;

  const AddDocument({
    required this.title,
    required this.description,
    required this.file,
    required this.categoryId,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [title, description, file, categoryId, expiryDate];
}

class UpdateDocument extends DocumentEvent {
  final String id;
  final String? title;
  final String? description;
  final File? file;
  final String? categoryId;
  final DateTime? expiryDate;

  const UpdateDocument({
    required this.id,
    this.title,
    this.description,
    this.file,
    this.categoryId,
    this.expiryDate,
  });

  @override
  List<Object?> get props =>
      [id, title, description, file, categoryId, expiryDate];
}

class DeleteDocument extends DocumentEvent {
  final String id;

  const DeleteDocument(this.id);

  @override
  List<Object> get props => [id];
}
