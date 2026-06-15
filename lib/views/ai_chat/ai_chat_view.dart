import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers.dart';

class AIChatView extends ConsumerStatefulWidget {
  final String? initialMessage;
  const AIChatView({super.key, this.initialMessage});

  @override
  ConsumerState<AIChatView> createState() => _AIChatViewState();
}

class _AIChatViewState extends ConsumerState<AIChatView> {
  final List<ChatMessage> _messages = [];
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Hello! I am your FitByte AI assistant. I have analyzed your profile and I am ready to help you reach your goals. How can I assist you with your nutrition today?', 
      isUser: false
    ));
    
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendAutomatedMessage(widget.initialMessage!);
      });
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

  void _sendAutomatedMessage(String text) async {
    if (_isLoading) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();
    _getAIResponse(text);
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();
    _getAIResponse(text);
  }

  void _getAIResponse(String text) async {
    try {
      final user = ref.read(userProvider);
      final contextPrompt = user != null 
          ? "User Profile: ${user.age}y/o ${user.gender}, ${user.weight}kg, Goal: ${user.goalWeight}kg, Activity: ${user.activityLevel}, Diet: ${user.dietaryPreference}. "
          : "";
      
      final fullPrompt = "$contextPrompt User says: $text";
      
      final response = await ref.read(aiServiceProvider).getDietRecommendation(fullPrompt);
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: response, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: 'Sorry, I encountered an error: $e', isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: const Icon(Icons.auto_awesome, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('FitByte AI Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text('AI is thinking...', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            _buildQuickActions(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildActionChip('Suggest Breakfast', Icons.breakfast_dining),
          _buildActionChip('Fat Loss Tips', Icons.trending_down),
          _buildActionChip('High Protein Snacks', Icons.egg),
          _buildActionChip('Hydration Advice', Icons.water_drop),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey[300]!),
        avatar: Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        onPressed: () => _sendAutomatedMessage(label),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: msg.isUser ? Theme.of(context).colorScheme.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
                bottomRight: Radius.circular(msg.isUser ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              msg.isUser ? 'You' : 'FitByte AI',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
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

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}
