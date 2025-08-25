import 'package:hive/hive.dart';
import 'income_expense.dart';


@HiveType(typeId: 2)
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? text;

  @HiveField(3)
  final String? icon;

  @HiveField(4)
  final String? color;

  @HiveField(5)
  final int order;

  @HiveField(6)
  final IncomeExpenseType type;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final bool isSynced;

  @HiveField(10)
  final String? userId;

  Category({
    required this.id,
    this.name,
    this.text,
    this.icon,
    this.color,
    this.order = 0,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.userId,
  });

  Category copyWith({
    String? id,
    String? name,
    String? text,
    String? icon,
    String? color,
    int? order,
    IncomeExpenseType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? userId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      text: text ?? this.text,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'text': text,
      'icon': icon,
      'color': color,
      'order': order,
      'type': type.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'userId': userId,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      text: json['text'],
      icon: json['icon'],
      color: json['color'],
      order: json['order'] ?? 0,
      type: IncomeExpenseType.values[json['type']],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: json['isSynced'] ?? false,
      userId: json['userId'],
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, text: $text, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Hive Adapter
class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 2;

  @override
  Category read(BinaryReader reader) {
    return Category(
      id: reader.readString(),
      name: reader.readString(),
      text: reader.readString(),
      icon: reader.readString(),
      color: reader.readString(),
      order: reader.readInt(),
      type: IncomeExpenseType.values[reader.readByte()],
      createdAt: DateTime.parse(reader.readString()),
      updatedAt: DateTime.parse(reader.readString()),
      isSynced: reader.readBool(),
      userId: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name ?? '');
    writer.writeString(obj.text ?? '');
    writer.writeString(obj.icon ?? '');
    writer.writeString(obj.color ?? '');
    writer.writeInt(obj.order);
    writer.writeByte(obj.type.index);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeString(obj.updatedAt.toIso8601String());
    writer.writeBool(obj.isSynced);
    writer.writeString(obj.userId ?? '');
  }
}
