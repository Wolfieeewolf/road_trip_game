import 'dart:convert';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.displayName,
    required this.createdAt,
  });

  final String id;
  final String displayName;
  final DateTime createdAt;

  String get friendCode => id.substring(0, 6).toUpperCase();

  AuthUser copyWith({
    String? displayName,
  }) {
    return AuthUser(
      id: id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static AuthUser? fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUser.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static String toStorage(AuthUser user) {
    return jsonEncode(user.toJson());
  }
}
