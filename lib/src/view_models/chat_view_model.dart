import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';

class ChatViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  late DatabaseReference _chatRef;
  StreamSubscription<DatabaseEvent>? _messagesSubscription;

  void initChat(String stockCode) {
    debugPrint('Initializing chat for stock: $stockCode');
    _messages.clear();
    _chatRef = FirebaseDatabase.instance.ref().child('chats').child(stockCode);
    _subscribeToMessages(stockCode);
    notifyListeners();
  }

  void _subscribeToMessages(String stockCode) {
    _messagesSubscription?.cancel();
    try {
      debugPrint('Subscribing to messages for stock: $stockCode');
      _messagesSubscription = _chatRef
          .orderByChild('timestamp')
          .limitToLast(100)
          .onChildAdded
          .listen((event) {
        debugPrint('Received message event: ${event.snapshot.value}');
        if (event.snapshot.value != null) {
          try {
            final message = ChatMessage.fromJson(
              Map<String, dynamic>.from(event.snapshot.value as Map),
            );
            _messages.add(message);
            _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            notifyListeners();
          } catch (e) {
            debugPrint('Error parsing message: $e');
          }
        }
      }, onError: (error) {
        debugPrint('Error subscribing to messages: $error');
      });
    } catch (e) {
      debugPrint('Error setting up message subscription: $e');
    }
  }

  Future<void> sendMessage(String stockCode, String message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Cannot send message: User is not logged in');
      return;
    }

    try {
      debugPrint('Attempting to send message for stock: $stockCode');

      // chatRef 재확인
      if (_chatRef.path != 'chats/$stockCode') {
        debugPrint('Updating chatRef path');
        _chatRef =
            FirebaseDatabase.instance.ref().child('chats').child(stockCode);
      }

      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        stockCode: stockCode,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        message: message,
        timestamp: DateTime.now(),
      );

      debugPrint('Sending message: ${newMessage.toJson()}');

      // 메시지 전송 시도
      final newRef = _chatRef.push();
      await newRef.set(newMessage.toJson());

      debugPrint('Message sent successfully with key: ${newRef.key}');
    } catch (e, stackTrace) {
      debugPrint('Error sending message: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    debugPrint('Disposing ChatViewModel');
    _messages.clear();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
