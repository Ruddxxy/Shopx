import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/services/chat_service.dart';
import '../../../theme/shopx_theme.dart';
import '../../../core/providers/theme_provider.dart';


final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(apiKey: dotenv.env['OPENAI_API_KEY'] ?? '');
});

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      messages.add({'text': userMessage, 'sender': 'user'});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // Move API call to a separate isolate
      final response = await compute(_getChatResponse, {
        'message': userMessage,
        'apiKey': dotenv.env['OPENAI_API_KEY'] ?? '',
      });
      
      if (mounted) {
        setState(() {
          messages.add({'text': response, 'sender': 'bot'});
          _isLoading = false;
        });
        _scrollToBottom();
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          messages.add({'text': 'Sorry, something went wrong. Please try again.', 'sender': 'bot'});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  // Function to be run in a separate isolate
  static Future<String> _getChatResponse(Map<String, dynamic> params) async {
    final chatService = ChatService(apiKey: params['apiKey'] as String);
    return await chatService.getChatResponse(params['message'] as String);
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

  Widget _buildMessageBubble(Map<String, String> message, bool isUser) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Hero(
                  tag: 'bot_avatar',
                  child: CircleAvatar(
                    backgroundColor: ShopXTheme.accentGold,
                    radius: 16,
                    child: const Icon(Icons.shopping_bag, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? ShopXTheme.accentGold : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message['text']!,
                    style: TextStyle(
                      color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                Hero(
                  tag: 'user_avatar',
                  child: CircleAvatar(
                    backgroundColor: ShopXTheme.accentGold,
                    radius: 16,
                    child: const Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    final theme = isDarkMode ? ShopXTheme.darkTheme : ShopXTheme.lightTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'AI Shopping Assistant',
          style: TextStyle(
            color: ShopXTheme.accentGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: isDarkMode ? ShopXTheme.textLight : ShopXTheme.textDark),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['sender'] == 'user';
                return _buildMessageBubble(message, isUser);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ShopXTheme.accentGold),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      color: isDarkMode ? ShopXTheme.textLight : ShopXTheme.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything about shopping...',
                      hintStyle: TextStyle(
                        color: isDarkMode ? ShopXTheme.textDark : ShopXTheme.textDark.withAlpha(100),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: ShopXTheme.accentGold, width: 2),
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: ShopXTheme.accentGold,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
} 