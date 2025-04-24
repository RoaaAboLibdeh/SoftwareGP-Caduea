import 'package:flutter/material.dart';
import 'package:avatar_plus/avatar_plus.dart';
import 'package:cadeau_project/custom/theme.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'chat_message.dart';

class AvatarChatPage extends StatefulWidget {
  final String avatarCode; // Original avatar code for display
  final String avatarName; // Friendly display name
  final String userId;
  final String userName;

  const AvatarChatPage({
    super.key,
    required this.avatarCode,
    required this.avatarName,
    required this.userId,
    required this.userName,
  });

  @override
  State<AvatarChatPage> createState() => _AvatarChatPageState();
}

class _AvatarChatPageState extends State<AvatarChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isAvatarTyping = false;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(
      userId: widget.userId,
      avatarId: widget.avatarCode,
    );
    _loadChatHistory();
    _addWelcomeMessage();
  }

  Future<void> _loadChatHistory() async {
    final history = await _apiService.getChatHistory();
    setState(() => _messages.addAll(history));
  }

  void _addWelcomeMessage() {
    _addAvatarMessage(
      "Hello ${widget.userName}! I'm ${widget.avatarName}, your shopping assistant. How can I help you today?",
    );
  }

  void _addAvatarMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isAvatar: true, timestamp: DateTime.now()),
      );
      _isAvatarTyping = false;
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      text: _messageController.text,
      isAvatar: false,
      timestamp: DateTime.now(),
    );
    setState(() => _messages.add(userMessage));
    _scrollToBottom();
    _messageController.clear();

    // Show typing indicator
    setState(() => _isAvatarTyping = true);

    // Get API response
    final response = await _apiService.getAvatarResponse(
      userMessage.text,
      _messages,
    );
    _addAvatarMessage(response);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              child: AvatarPlus(
                widget.avatarCode, // Use the original code for avatar display
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.avatarName, // Display friendly name
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                  ),
                ),
                if (_isAvatarTyping)
                  Text(
                    'typing...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6F61EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF6F61EF).withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isAvatarTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _messages.length) {
                    final message = _messages[index];
                    return ChatBubble(
                      message: message.text,
                      isAvatar: message.isAvatar,
                      avatarCode: widget.avatarCode,
                      avatarName: widget.avatarName, // Use friendly name
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
                      child: TypingIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF6F61EF),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

// class ChatMessage {
//   final String text;
//   final bool isAvatar;
//   final DateTime timestamp;

//   ChatMessage({
//     required this.text,
//     required this.isAvatar,
//     required this.timestamp,
//   });
// }

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isAvatar;
  final String avatarName;
  final String avatarCode;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isAvatar,
    required this.avatarName,
    required this.avatarCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAvatar) ...[
            Container(
              width: 36,
              height: 36,
              child: AvatarPlus(avatarCode, width: 36, height: 36),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isAvatar ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isAvatar ? Colors.grey[100] : const Color(0xFF6F61EF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isAvatar ? 0 : 16),
                      topRight: const Radius.circular(16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: Radius.circular(isAvatar ? 16 : 0),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isAvatar ? Colors.black87 : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAvatar ? avatarName : "You",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          if (!isAvatar) const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [_buildDot(0), _buildDot(1), _buildDot(2)],
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300 + (index * 100)),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: const Color(0xFF6F61EF),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
