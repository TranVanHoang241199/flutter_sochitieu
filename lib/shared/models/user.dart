import 'package:hive/hive.dart';


@HiveType(typeId: 3)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userName;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? fullName;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final String? avatar;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final bool isOnline;

  @HiveField(9)
  final String? accessToken;

  @HiveField(10)
  final String? refreshToken;

  User({
    required this.id,
    required this.userName,
    this.email,
    this.fullName,
    this.phone,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.isOnline = false,
    this.accessToken,
    this.refreshToken,
  });

  User copyWith({
    String? id,
    String? userName,
    String? email,
    String? fullName,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOnline,
    String? accessToken,
    String? refreshToken,
  }) {
    return User(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnline: isOnline ?? this.isOnline,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isOnline': isOnline,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
      fullName: json['fullName'],
      phone: json['phone'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isOnline: json['isOnline'] ?? false,
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  @override
  String toString() {
    return 'User(id: $id, userName: $userName, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Hive Adapter
class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 3;

  @override
  User read(BinaryReader reader) {
    return User(
      id: reader.readString(),
      userName: reader.readString(),
      email: reader.readString(),
      fullName: reader.readString(),
      phone: reader.readString(),
      avatar: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      updatedAt: DateTime.parse(reader.readString()),
      isOnline: reader.readBool(),
      accessToken: reader.readString(),
      refreshToken: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.userName);
    writer.writeString(obj.email ?? '');
    writer.writeString(obj.fullName ?? '');
    writer.writeString(obj.phone ?? '');
    writer.writeString(obj.avatar ?? '');
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeString(obj.updatedAt.toIso8601String());
    writer.writeBool(obj.isOnline);
    writer.writeString(obj.accessToken ?? '');
    writer.writeString(obj.refreshToken ?? '');
  }
}
