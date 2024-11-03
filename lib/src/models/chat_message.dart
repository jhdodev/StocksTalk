class ChatMessage {
  final String id;
  final String stockCode;
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.stockCode,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      stockCode: json['stockCode'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stockCode': stockCode,
      'userId': userId,
      'userName': userName,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
