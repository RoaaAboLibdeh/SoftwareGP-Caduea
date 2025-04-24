class ChatMessage {
  final String text;
  final bool isAvatar;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isAvatar,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isAvatar: json['isAvatar'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isAvatar': isAvatar,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
