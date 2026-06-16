class ChatMessageModel {
  final int? id;
  final int reportId;
  final int volunteerId;
  final int senderId;
  final String message;
  final String createdAt;
  final int isRead;

  ChatMessageModel({
    this.id,
    required this.reportId,
    required this.volunteerId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.isRead = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportId': reportId,
      'volunteerId': volunteerId,
      'senderId': senderId,
      'message': message,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] != null ? map['id'] as int : null,
      reportId: map['reportId'] as int,
      volunteerId: map['volunteerId'] as int,
      senderId: map['senderId'] as int,
      message: map['message'] as String,
      createdAt: map['createdAt'] as String,
      isRead: map['isRead'] as int? ?? 0,
    );
  }
}
