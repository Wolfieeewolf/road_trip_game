import 'dart:convert';

class FriendContact {
  const FriendContact({
    required this.id,
    required this.displayName,
    this.friendCode,
    this.phoneNumber,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String displayName;
  final String? friendCode;
  final String? phoneNumber;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  FriendContact copyWith({
    String? displayName,
    String? friendCode,
    String? phoneNumber,
    String? userId,
    DateTime? updatedAt,
  }) {
    return FriendContact(
      id: id,
      displayName: displayName ?? this.displayName,
      friendCode: friendCode ?? this.friendCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userId: userId ?? this.userId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'friendCode': friendCode,
      'phoneNumber': phoneNumber,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FriendContact.fromJson(Map<String, dynamic> json) {
    return FriendContact(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      friendCode: json['friendCode'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      userId: json['userId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static List<FriendContact> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => FriendContact.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static String encodeList(List<FriendContact> friends) {
    return jsonEncode(friends.map((friend) => friend.toJson()).toList());
  }
}
