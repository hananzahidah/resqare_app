import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model_firebase.g.dart';

@JsonSerializable()
class ChatMessageModelFirebase {
  final String? id;
  final String reportId;
  final String volunteerId;
  final String senderId;
  final String message;
  final String createdAt;

  @JsonKey(fromJson: _isReadFromJson, toJson: _isReadToJson)
  final int isRead;

  ChatMessageModelFirebase({
    this.id,
    required this.reportId,
    required this.volunteerId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.isRead = 0,
  });

  static int _isReadFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static dynamic _isReadToJson(int value) => value;

  factory ChatMessageModelFirebase.fromJson(Map<String, dynamic> json) => _$ChatMessageModelFirebaseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageModelFirebaseToJson(this);

  ChatMessageModelFirebase copyWith({
    String? id,
    String? reportId,
    String? volunteerId,
    String? senderId,
    String? message,
    String? createdAt,
    int? isRead,
  }) {
    return ChatMessageModelFirebase(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      volunteerId: volunteerId ?? this.volunteerId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  factory ChatMessageModelFirebase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatMessageModelFirebase.fromJson({
      ...data,
      'id': doc.id,
    });
  }
}
