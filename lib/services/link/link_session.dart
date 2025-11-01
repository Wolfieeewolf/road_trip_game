import 'package:flutter/foundation.dart';

import '../auth/auth_user.dart';

class LinkSession {
  const LinkSession({
    required this.code,
    required this.host,
    required this.participants,
    required this.updatedAt,
  });

  final String code;
  final AuthUser host;
  final List<AuthUser> participants;
  final DateTime updatedAt;

  bool get isEmpty => code.isEmpty;

  bool isHost(String userId) => host.id == userId;

  bool containsUser(String userId) =>
      participants.any((participant) => participant.id == userId);

  List<AuthUser> get sortedParticipants {
    final items = List<AuthUser>.from(participants);
    items.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
    return items;
  }

  LinkSession copyWith({
    List<AuthUser>? participants,
    DateTime? updatedAt,
  }) {
    return LinkSession(
      code: code,
      host: host,
      participants: participants ?? this.participants,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'host': host.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LinkSession.fromJson(Map<String, dynamic> json) {
    final participantsJson = json['participants'] as List<dynamic>? ?? [];
    return LinkSession(
      code: json['code'] as String,
      host: AuthUser.fromJson(json['host'] as Map<String, dynamic>),
      participants: participantsJson
          .map((item) => AuthUser.fromJson(item as Map<String, dynamic>))
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LinkSession &&
        other.code == code &&
        other.host == host &&
        listEquals(other.participants, participants);
  }

  @override
  int get hashCode => Object.hash(code, host, Object.hashAll(participants));
}
