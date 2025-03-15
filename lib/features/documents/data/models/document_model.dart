import 'package:document_manager/features/documents/domain/entities/document.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class DocumentModel extends Document {
  @HiveField(0)
  final String _id;

  @HiveField(1)
  final String _title;

  @HiveField(2)
  final String _description;

  @HiveField(3)
  final String _filePath;

  @HiveField(4)
  final String _fileType;

  @HiveField(5)
  final DateTime _createdAt;

  @HiveField(6)
  final DateTime? _expiryDate;

  @HiveField(7)
  final String _categoryId;

  DocumentModel({
    required String id,
    required String title,
    required String description,
    required String filePath,
    required String fileType,
    required String categoryId,
    required DateTime createdAt,
    DateTime? expiryDate,
  })  : _id = id,
        _title = title,
        _description = description,
        _filePath = filePath,
        _fileType = fileType,
        _categoryId = categoryId,
        _createdAt = createdAt,
        _expiryDate = expiryDate;

  @override
  String get id => _id;

  @override
  String get title => _title;

  @override
  String get description => _description;

  @override
  String get filePath => _filePath;

  @override
  String get fileType => _fileType;

  @override
  String get categoryId => _categoryId;

  @override
  DateTime get createdAt => _createdAt;

  @override
  DateTime? get expiryDate => _expiryDate;

  factory DocumentModel.fromEntity(Document document) {
    return DocumentModel(
      id: document.id,
      title: document.title,
      description: document.description,
      filePath: document.filePath,
      fileType: document.fileType,
      categoryId: document.categoryId,
      createdAt: document.createdAt,
      expiryDate: document.expiryDate,
    );
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? filePath,
    String? fileType,
    String? categoryId,
    DateTime? createdAt,
    DateTime? expiryDate,
  }) {
    return DocumentModel(
      id: id ?? _id,
      title: title ?? _title,
      description: description ?? _description,
      filePath: filePath ?? _filePath,
      fileType: fileType ?? _fileType,
      categoryId: categoryId ?? _categoryId,
      createdAt: createdAt ?? _createdAt,
      expiryDate: expiryDate ?? _expiryDate,
    );
  }
}

class DocumentModelAdapter extends TypeAdapter<DocumentModel> {
  @override
  final int typeId = 0;

  @override
  DocumentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      filePath: fields[3] as String,
      fileType: fields[4] as String,
      createdAt: fields[5] as DateTime,
      expiryDate: fields[6] as DateTime?,
      categoryId: fields[7] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, DocumentModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.fileType)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.expiryDate)
      ..writeByte(7)
      ..write(obj.categoryId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
