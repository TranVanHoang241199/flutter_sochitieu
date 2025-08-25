import 'package:hive/hive.dart';


@HiveType(typeId: 0)
enum IncomeExpenseType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}

@HiveType(typeId: 1)
class IncomeExpense {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String? currency;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final IncomeExpenseType type;

  @HiveField(6)
  final String? categoryId;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final bool isSynced;

  @HiveField(10)
  final String? userId;

  IncomeExpense({
    required this.id,
    required this.amount,
    this.currency = 'VND',
    required this.date,
    this.description,
    required this.type,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.userId,
  });

  IncomeExpense copyWith({
    String? id,
    double? amount,
    String? currency,
    DateTime? date,
    String? description,
    IncomeExpenseType? type,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? userId,
  }) {
    return IncomeExpense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      description: description ?? this.description,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'description': description,
      'type': type.index,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'userId': userId,
    };
  }

  factory IncomeExpense.fromJson(Map<String, dynamic> json) {
    return IncomeExpense(
      id: json['id'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      type: IncomeExpenseType.values[json['type']],
      categoryId: json['categoryId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: json['isSynced'] ?? false,
      userId: json['userId'],
    );
  }

  @override
  String toString() {
    return 'IncomeExpense(id: $id, amount: $amount, type: $type, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IncomeExpense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Hive Adapters
class IncomeExpenseTypeAdapter extends TypeAdapter<IncomeExpenseType> {
  @override
  final int typeId = 0;

  @override
  IncomeExpenseType read(BinaryReader reader) {
    return IncomeExpenseType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, IncomeExpenseType obj) {
    writer.writeByte(obj.index);
  }
}

class IncomeExpenseAdapter extends TypeAdapter<IncomeExpense> {
  @override
  final int typeId = 1;

  @override
  IncomeExpense read(BinaryReader reader) {
    return IncomeExpense(
      id: reader.readString(),
      amount: reader.readDouble(),
      currency: reader.readString(),
      date: DateTime.parse(reader.readString()),
      description: reader.readString(),
      type: IncomeExpenseType.values[reader.readByte()],
      categoryId: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      updatedAt: DateTime.parse(reader.readString()),
      isSynced: reader.readBool(),
      userId: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, IncomeExpense obj) {
    writer.writeString(obj.id);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.currency ?? '');
    writer.writeString(obj.date.toIso8601String());
    writer.writeString(obj.description ?? '');
    writer.writeByte(obj.type.index);
    writer.writeString(obj.categoryId ?? '');
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeString(obj.updatedAt.toIso8601String());
    writer.writeBool(obj.isSynced);
    writer.writeString(obj.userId ?? '');
  }
}
