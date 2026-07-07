// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model_firebase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModelFirebase _$ChatMessageModelFirebaseFromJson(
  Map<String, dynamic> json,
) => ChatMessageModelFirebase(
  id: json['id'] as String?,
  reportId: json['reportId'] as String,
  volunteerId: json['volunteerId'] as String,
  senderId: json['senderId'] as String,
  message: json['message'] as String,
  createdAt: json['createdAt'] as String,
  isRead: json['isRead'] == null
      ? 0
      : ChatMessageModelFirebase._isReadFromJson(json['isRead']),
);

Map<String, dynamic> _$ChatMessageModelFirebaseToJson(
  ChatMessageModelFirebase instance,
) => <String, dynamic>{
  'id': instance.id,
  'reportId': instance.reportId,
  'volunteerId': instance.volunteerId,
  'senderId': instance.senderId,
  'message': instance.message,
  'createdAt': instance.createdAt,
  'isRead': ChatMessageModelFirebase._isReadToJson(instance.isRead),
};
