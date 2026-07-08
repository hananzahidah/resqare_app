class NotificationModelFirebase {
  final String? id;
  final String recipientId;
  final String title;
  final String body;
  final String type; // 'report_created', 'report_claimed', 'rescue_status', 'volunteer_status', 'new_chat'
  final String referenceId; // reportId, applicationId, etc.
  final bool isRead;
  final String createdAt;

  NotificationModelFirebase({
    this.id,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.type,
    required this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModelFirebase.fromFirestore(Map<String, dynamic> data, String documentId) {
    return NotificationModelFirebase(
      id: documentId,
      recipientId: data['recipientId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      referenceId: data['referenceId'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'title': title,
      'body': body,
      'type': type,
      'referenceId': referenceId,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
