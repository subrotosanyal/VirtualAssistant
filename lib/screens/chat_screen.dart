import 'package:virtual_assistant/util/chat_util.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String apiKey;

  ChatScreen({required this.apiKey});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<MessagePair> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isGeneratingResponse = false;

  void _handleSendMessage() async {
    setState(() {
      _isGeneratingResponse = true;
    });
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _messageController.clear();

      setState(() {
        _chatMessages.add(MessagePair('You', message));
      });

      try {
        final choices = await ChatUtility.sendMessage(message, widget.apiKey);
        setState(() {
          _chatMessages.addAll(choices
              .map((choice) => MessagePair('Chatbot', choice.toString()))
              .toList());
        });
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (e) {
        setState(() {
          _chatMessages.add(MessagePair('Error', e.toString()));
        });
      }
      setState(() {
        _isGeneratingResponse = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Converse'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: _buildChatBubble(_chatMessages[index].user, _chatMessages[index].message),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                IconButton(
                  onPressed: _isGeneratingResponse ? null : _handleSendMessage,
                  icon: _isGeneratingResponse
                      ? const SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String user, String message) {
    final isUserMessage = user == 'You';
    final isChatbotMessage = user == 'Chatbot';
    final content = message;
    Alignment alignment = Alignment.bottomCenter;
    Color color = Colors.red;
    if (isUserMessage) {
      alignment = Alignment.centerRight;
      color = Colors.lightBlueAccent;
    }
    if (isChatbotMessage) {
      alignment = Alignment.centerLeft;
      color = Colors.grey.shade300;
    }
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUserMessage ? Colors.white : Colors.black,
          ),
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

class MessagePair {
  final String user;
  final String message;

  MessagePair(this.user, this.message);
}
