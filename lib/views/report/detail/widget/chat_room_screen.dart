import 'dart:async';
import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/models/chat_message_model.dart';
import 'package:resqare_app/models/report_model.dart';
import 'package:resqare_app/repositories/chat_repository.dart';
import 'package:resqare_app/utils/date_formater.dart';

class ChatRoomScreen extends StatefulWidget {
  final ReportModel report;
  final int volunteerId;
  final String otherUserName;

  const ChatRoomScreen({
    super.key,
    required this.report,
    required this.volunteerId,
    required this.otherUserName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessageModel> _messages = [];
  Timer? _pollingTimer;
  bool _isLoading = true;
  bool _isReadOnly = false;
  late int _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = PreferenceHandler.userId;
    
    // Sesi chat menjadi Read-Only jika:
    // 1. Status laporan adalah "completed" (atau "rescued")
    // 2. ATAU volunteerId obrolan ini tidak sama dengan rescuedBy laporan saat ini (karena volunteer tersebut sudah membatalkan tugas)
    final reportStatus = widget.report.status.toLowerCase();
    final isReportFinished = reportStatus == 'completed' || reportStatus == 'rescued';
    final isNotActiveVolunteer = widget.report.rescuedBy != widget.volunteerId;

    _isReadOnly = isReportFinished || isNotActiveVolunteer;

    _loadMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadMessages(isSilent: true);
    });
  }

  Future<void> _loadMessages({bool isSilent = false}) async {
    if (!isSilent) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final messages = await _chatRepository.getMessages(
        widget.report.id ?? 0,
        widget.volunteerId,
      );

      // Tandai pesan belum dibaca sebagai dibaca
      await _chatRepository.markAsRead(
        widget.report.id ?? 0,
        widget.volunteerId,
        _currentUserId,
      );

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });

        // Scroll ke bawah jika ada pesan baru
        if (!isSilent) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Error loading messages: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final newMessage = ChatMessageModel(
      reportId: widget.report.id ?? 0,
      volunteerId: widget.volunteerId,
      senderId: _currentUserId,
      message: text,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await _chatRepository.sendMessage(newMessage);
      _loadMessages(isSilent: true);
      _scrollToBottom();
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menentukan sub-role label (Pelapor vs Relawan)
    final isReporter = widget.report.createdBy == widget.volunteerId;
    final otherRoleLabel = isReporter ? "Pelapor Laporan" : "Relawan Penyelamat";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryBlue,
              child: Text(
                widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    otherRoleLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.softBlue.withValues(alpha: 0.4),
            child: Text(
              "Kasus: ${widget.report.title}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: Alignment.center.x == 0 ? TextAlign.center : TextAlign.start,
            ),
          ),
          
          // Chat Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              "Belum ada obrolan",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg.senderId == _currentUserId;
                          return _buildChatBubble(msg, isMe);
                        },
                      ),
          ),

          // Message Input / Read Only Banner
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
                border: isMe ? null : Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.015),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.message,
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormatter.toTimeOnly(msg.createdAt),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 13,
                    color: msg.isRead == 1 ? AppColors.primaryBlue : AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    if (_isReadOnly) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border: Border.all(color: Colors.amber.shade100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: Colors.amber.shade800, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Sesi obrolan telah berakhir dan hanya dapat dibaca.",
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _messageController,
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: "Tulis pesan...",
                    hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryBlue,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
