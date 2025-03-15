import 'package:equatable/equatable.dart';

abstract class Document extends Equatable {
  String get id;
  String get title;
  String get description;
  String get filePath;
  String get fileType;
  String get categoryId;
  DateTime get createdAt;
  DateTime? get expiryDate;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        filePath,
        fileType,
        categoryId,
        createdAt,
        expiryDate,
      ];
}
