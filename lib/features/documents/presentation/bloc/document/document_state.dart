part of 'document_bloc.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentsLoaded extends DocumentState {
  final List<Document> documents;

  const DocumentsLoaded(this.documents);

  @override
  List<Object> get props => [documents];
}

class DocumentOperationInProgress extends DocumentsLoaded {
  const DocumentOperationInProgress(super.documents);
}

class DocumentOperationSuccess extends DocumentsLoaded {
  final String message;

  const DocumentOperationSuccess(super.documents, this.message);

  @override
  List<Object> get props => [documents, message];
}

class DocumentError extends DocumentState {
  final String message;
  final List<Document>? previousDocuments;

  const DocumentError(this.message, {this.previousDocuments});

  @override
  List<Object?> get props => [message, previousDocuments];
}
