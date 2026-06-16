import 'package:resqare_app/database/db_helper.dart';
import 'package:resqare_app/models/chat_message_model.dart';

class ChatRepository {
  final DBHelper dbHelper = DBHelper();

  // Send message
  Future<int> sendMessage(ChatMessageModel message) async {
    final db = await dbHelper.database;
    return await db.insert('chat_messages', message.toMap());
  }

  // Get messages for a reporter and volunteer
  Future<List<ChatMessageModel>> getMessages(
    int reportId,
    int volunteerId,
  ) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'chat_messages',
      where: 'reportId = ? AND volunteerId = ?',
      whereArgs: [reportId, volunteerId],
      orderBy: 'createdAt ASC',
    );
    return results.map((map) => ChatMessageModel.fromMap(map)).toList();
  }

  // Get all volunteers who have a chat history on a report
  Future<List<int>> getChatVolunteers(int reportId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT DISTINCT volunteerId FROM chat_messages WHERE reportId = ? AND volunteerId IS NOT NULL',
      [reportId],
    );
    return results.map((map) => map['volunteerId'] as int).toList();
  }

  // Mark all messages from a specific sender/room as read
  Future<void> markAsRead(
    int reportId,
    int volunteerId,
    int currentUserId,
  ) async {
    final db = await dbHelper.database;
    await db.update(
      'chat_messages',
      {'isRead': 1},
      where:
          'reportId = ? AND volunteerId = ? AND senderId != ? AND isRead = 0',
      whereArgs: [reportId, volunteerId, currentUserId],
    );
  }
}
