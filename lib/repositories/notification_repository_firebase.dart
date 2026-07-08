import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqare_app/models/notification_model_firebase.dart';

class NotificationRepositoryFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of notifications for a recipient
  Stream<List<NotificationModelFirebase>> streamNotifications(String recipientId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: recipientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationModelFirebase.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Stream unread count for badge
  Stream<int> streamUnreadCount(String recipientId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: recipientId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create a notification
  Future<bool> createNotification(NotificationModelFirebase notification) async {
    try {
      await _firestore.collection('notifications').add(notification.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper send notification method
  Future<bool> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    required String type,
    required String referenceId,
  }) async {
    final notif = NotificationModelFirebase(
      recipientId: recipientId,
      title: title,
      body: body,
      type: type,
      referenceId: referenceId,
      createdAt: DateTime.now().toIso8601String(),
    );
    return createNotification(notif);
  }

  // Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({'isRead': true});
      return true;
    } catch (e) {
      return false;
    }
  }

  // Mark all notifications as read for a recipient
  Future<bool> markAllAsRead(String recipientId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: recipientId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }
}
