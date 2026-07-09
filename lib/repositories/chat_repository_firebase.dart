import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqare_app/models/chat_message_model_firebase.dart';

class ChatRepositoryFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send message
  Future<String> sendMessage(ChatMessageModelFirebase message) async {
    final docRef = _firestore.collection('chat_messages').doc();
    final msgToSave = message.copyWith(id: docRef.id);
    await docRef.set(msgToSave.toMap());
    return docRef.id;
  }

  // Get messages for a reporter and volunteer
  Future<List<ChatMessageModelFirebase>> getMessages(
    String reportId,
    String volunteerId,
  ) async {
    final snapshot = await _firestore
        .collection('chat_messages')
        .where('reportId', isEqualTo: reportId)
        .where('volunteerId', isEqualTo: volunteerId)
        .get();

    final messages = snapshot.docs
        .map((doc) => ChatMessageModelFirebase.fromFirestore(doc))
        .toList();

    // Sort client-side to avoid composite index requirement
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  // Get real-time stream of messages for a reporter and volunteer
  Stream<List<ChatMessageModelFirebase>> getMessagesStream(
    String reportId,
    String volunteerId,
  ) {
    return _firestore
        .collection('chat_messages')
        .where('reportId', isEqualTo: reportId)
        .where('volunteerId', isEqualTo: volunteerId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ChatMessageModelFirebase.fromFirestore(doc))
              .toList();
          // Sort client-side to avoid composite index requirement
          list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return list;
        });
  }

  // Get all volunteers who have a chat history on a report
  Future<List<String>> getChatVolunteers(String reportId) async {
    final snapshot = await _firestore
        .collection('chat_messages')
        .where('reportId', isEqualTo: reportId)
        .get();

    final vols = snapshot.docs
        .map((doc) => doc.data()['volunteerId'] as String?)
        .where((id) => id != null)
        .toSet()
        .toList();

    return vols.cast<String>();
  }

  // Mark all messages from a specific sender/room as read
  Future<void> markAsRead(
    String reportId,
    String volunteerId,
    String currentUserId,
  ) async {
    final snapshot = await _firestore
        .collection('chat_messages')
        .where('reportId', isEqualTo: reportId)
        .where('volunteerId', isEqualTo: volunteerId)
        .where('isRead', isEqualTo: 0)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['senderId'] != currentUserId) {
        batch.update(doc.reference, {'isRead': 1});
      }
    }
    await batch.commit();
  }
}
