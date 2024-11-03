import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message.dart';
import '../../models/stock.dart';
import '../../view_models/chat_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StockChatRoomPage extends StatefulWidget {
  final Stock stock;

  const StockChatRoomPage({super.key, required this.stock});

  @override
  State<StockChatRoomPage> createState() => _StockChatRoomPageState();
}

class _StockChatRoomPageState extends State<StockChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().initChat(widget.stock.srtnCd);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.stock.name),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Consumer<ChatViewModel>(
          builder: (context, viewModel, child) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _scrollToBottom());

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = viewModel.messages[index];
                      final isMyMessage = message.userId ==
                          FirebaseAuth.instance.currentUser?.uid;

                      final previousMessage =
                          index > 0 ? viewModel.messages[index - 1] : null;
                      final isConsecutive = previousMessage != null &&
                          previousMessage.userId == message.userId &&
                          message.timestamp
                                  .difference(previousMessage.timestamp)
                                  .inMinutes <
                              5;

                      final nextMessage = index < viewModel.messages.length - 1
                          ? viewModel.messages[index + 1]
                          : null;
                      final isLastInSequence = nextMessage == null ||
                          nextMessage.userId != message.userId ||
                          nextMessage.timestamp
                                  .difference(message.timestamp)
                                  .inMinutes >=
                              5;

                      return ChatMessageWidget(
                        message: message,
                        isMyMessage: isMyMessage,
                        showHeader: !isConsecutive,
                        showFooter: isLastInSequence,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 100,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller: _messageController,
                              maxLines: null,
                              textAlignVertical: TextAlignVertical.center,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                hintText: '메시지',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                if (_messageController.text.isNotEmpty) {
                                  viewModel.sendMessage(
                                    widget.stock.srtnCd,
                                    _messageController.text,
                                  );
                                  _messageController.clear();
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    _scrollToBottom,
                                  );
                                }
                              },
                              child: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _messageController,
                                builder: (context, value, child) {
                                  return Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.arrow_upward,
                                      color: value.text.isEmpty
                                          ? Colors.grey
                                          : const Color(0xFF007AFF),
                                      size: 24,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isMyMessage;
  final bool showHeader;
  final bool showFooter;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isMyMessage,
    required this.showHeader,
    required this.showFooter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: showHeader ? 8 : 2,
        bottom: showFooter ? 8 : 2,
        left: 12,
        right: 12,
      ),
      child: Column(
        crossAxisAlignment:
            isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showHeader && !isMyMessage) ...[
            Text(
              message.userName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
          ],
          Row(
            mainAxisAlignment:
                isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMyMessage && showHeader)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    message.userName.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              if (!isMyMessage && showHeader) const SizedBox(width: 8),
              if (!isMyMessage && !showHeader) const SizedBox(width: 40),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMyMessage
                        ? const Color(0xFF007AFF)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(showHeader ? 20 : 5),
                      topRight: Radius.circular(showHeader ? 20 : 5),
                      bottomLeft:
                          Radius.circular(showFooter && !isMyMessage ? 5 : 20),
                      bottomRight:
                          Radius.circular(showFooter && isMyMessage ? 5 : 20),
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: isMyMessage ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showFooter) ...[
            const SizedBox(height: 2),
            Padding(
              padding: EdgeInsets.only(
                left: !isMyMessage ? 40 : 0,
                right: isMyMessage ? 0 : 0,
              ),
              child: Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';

    if (messageDate == today) {
      return '오늘 $time';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '어제 $time';
    } else {
      return '${timestamp.month}/${timestamp.day} $time';
    }
  }
}
