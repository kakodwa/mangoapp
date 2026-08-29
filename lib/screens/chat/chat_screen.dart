// lib/screens/chat/chat_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_toast.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int roomId;
  final String peerName;

  const ChatScreen({
    Key? key,
    required this.roomId,
    required this.peerName,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<ChatMessageModel> _messages = [];
  Timer? _pollingTimer;

  late int _activeRoomId;
  late String _activePeerName;

  bool _isLoading = false;
  bool _isConnected = false;
  bool _showEmojiPicker = false;
  String _searchQuery = "";

  ChatMessageModel? _replyingToMessage;

  @override
  void initState() {
    super.initState();
    _activeRoomId = widget.roomId;
    _activePeerName = widget.peerName;

    if (_activeRoomId > 0) {
      _loadHistoricalMessages();
      _startPolling();
    }
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomId != widget.roomId && widget.roomId > 0) {
      _switchRoom(widget.roomId, widget.peerName);
    }
  }

  void _switchRoom(int newRoomId, String newPeerName) {
    _stopPolling();
    setState(() {
      _activeRoomId = newRoomId;
      _activePeerName = newPeerName;
      _isLoading = true;
      _isConnected = false;
      _replyingToMessage = null;
      _showEmojiPicker = false;
      _messages.clear();
    });
    _loadHistoricalMessages();
    _startPolling();
  }

  Future<void> _loadHistoricalMessages() async {
    if (_activeRoomId == 0) return;
    try {
      final history = await ref.read(chatRoomActionsProvider).fetchMessages(_activeRoomId);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(history);
          _isLoading = false;
          _isConnected = true;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("❌ Failed to fetch message history: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isConnected = false;
        });
      }
    }
  }

  void _startPolling() {
    _stopPolling();
    // Poll every 3 seconds over standard HTTP GET
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_activeRoomId == 0) return;
      try {
        final latestMessages = await ref
            .read(chatRoomActionsProvider)
            .fetchMessages(_activeRoomId);

        if (!mounted) return;

        final currentUserId = ref.read(authProvider).user?.id ?? 0;
        bool hasNewIncoming = false;

        for (final newMsg in latestMessages) {
          if (!_messages.any((m) => m.id == newMsg.id && m.id != 0)) {
            _messages.add(newMsg);
            if (newMsg.senderId != currentUserId) {
              hasNewIncoming = true;
            }
          }
        }

        if (hasNewIncoming) {
          _playMessageNotificationSound();
        }

        setState(() {
          _isConnected = true;
        });

        _scrollToBottom();
      } catch (e) {
        debugPrint("⚠️ Polling failed: $e");
        if (mounted) {
          setState(() => _isConnected = false);
        }
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _playMessageNotificationSound() async {
    try {
      await _audioPlayer.play(UrlSource('https://www.malatrade.com/media/sound/alert.wav'));
    } catch (e) {
      debugPrint("⚠️ Could not play audio notification: $e");
    }
  }

  Future<void> _sendMessage(int currentUserId, {String? overrideText}) async {
    final text = overrideText ?? _textController.text.trim();

    if (text.isEmpty) return;

    final originalText = text;
    _textController.clear();

    setState(() {
      _replyingToMessage = null;
      _showEmojiPicker = false;
    });

    try {
      // Send standard HTTP POST request to Django via Riverpod action provider
      await ref.read(chatRoomActionsProvider).sendMessage(_activeRoomId, originalText);
      // Refresh the chat messages list immediately
      _loadHistoricalMessages();
    } catch (e) {
      debugPrint("❌ Failed to send message: $e");
      if (mounted) {
        AppToast.info(context, "Failed to send message. Please try again.");
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

  void _showReactionDialog(ChatMessageModel msg, int currentUserId) {
    final quickEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: quickEmojis.map((emoji) {
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.pop(context);
                  _sendMessage(currentUserId, overrideText: emoji);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _stopPolling();
    _audioPlayer.dispose();
    _textController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildLeftSidebarList(int currentUserId, List<ChatRoomModel> rooms) {
    final filteredRooms = rooms.where((room) {
      final isBuyer = room.buyer == currentUserId;
      final peerName = isBuyer ? room.sellerName : room.buyerName;
      final productName = room.productName ?? '';

      final matchesPeer = peerName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesProduct = productName.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesPeer || matchesProduct;
    }).toList();

    return Column(
      children: [
        Container(
          color: AppColors.mangoOrange,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: const Row(
            children: [
              Icon(Icons.forum_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                "Active Chats",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: "Search chats...",
              prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: filteredRooms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final room = filteredRooms[index];
              final isBuyer = room.buyer == currentUserId;
              final peerName = isBuyer ? room.sellerName : room.buyerName;
              final isSelected = room.id == _activeRoomId;

              return Container(
                color: isSelected ? AppColors.mangoOrange.withOpacity(0.12) : null,
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.mangoOrange.withOpacity(0.2),
                    child: Text(
                      peerName.isNotEmpty ? peerName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: AppColors.mangoOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text(
                    peerName.isNotEmpty ? peerName : "User #$currentUserId",
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: room.productName != null
                      ? Text(
                          "📦 ${room.productName}",
                          style: TextStyle(fontSize: 10, color: AppColors.mangoOrange),
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  onTap: () {
                    _switchRoom(room.id, peerName);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainChatWindow(int currentUserId, bool isMobile) {
    if (_activeRoomId == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              "Select a conversation to start chatting",
              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Live Chat Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              if (isMobile)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    setState(() {
                      _activeRoomId = 0;
                    });
                  },
                ),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.mangoOrange,
                child: Text(
                  _activePeerName.isNotEmpty ? _activePeerName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _activePeerName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    _isConnected ? "Online" : "Connecting...",
                    style: TextStyle(
                      color: _isConnected ? Colors.green : Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Messages List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg.senderId == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () => _showReactionDialog(msg, currentUserId),
                        onDoubleTap: () => setState(() => _replyingToMessage = msg),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.70),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFFE7FFDB) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMe
                                  ? const Radius.circular(12)
                                  : const Radius.circular(0),
                              bottomRight: isMe
                                  ? const Radius.circular(0)
                                  : const Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg.text,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Reply Banner Preview Box
        if (_replyingToMessage != null)
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 36,
                  color: AppColors.mangoOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Replying to Message",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mangoOrange,
                        ),
                      ),
                      Text(
                        _replyingToMessage!.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _replyingToMessage = null),
                ),
              ],
            ),
          ),

        // Text Input Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _showEmojiPicker ? Icons.keyboard : Icons.sentiment_satisfied_alt_outlined,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    textCapitalization: TextCapitalization.sentences,
                    onTap: () {
                      if (_showEmojiPicker) {
                        setState(() => _showEmojiPicker = false);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor: AppColors.mangoOrange,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(currentUserId),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Emoji Sheet
        if (_showEmojiPicker)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              textEditingController: _textController,
              config: Config(
                emojiViewConfig: const EmojiViewConfig(
                  emojiSizeMax: 28,
                  backgroundColor: Color(0xFFF2F2F2),
                ),
                categoryViewConfig: CategoryViewConfig(
                  indicatorColor: AppColors.mangoOrange,
                  iconColorSelected: AppColors.mangoOrange,
                  backspaceColor: AppColors.mangoOrange,
                ),
                skinToneConfig: const SkinToneConfig(
                  enabled: true,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final currentUserId = auth.user?.id ?? 0;
    final chatRoomsAsync = ref.watch(userChatRoomsProvider);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth >= 750;

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      body: chatRoomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildMainChatWindow(currentUserId, !isWideScreen),
        data: (rooms) {
          if (isWideScreen) {
            return Row(
              children: [
                SizedBox(
                  width: 280,
                  child: Container(
                    color: Colors.white,
                    child: _buildLeftSidebarList(currentUserId, rooms),
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: _buildMainChatWindow(currentUserId, false),
                ),
              ],
            );
          }

          // Single View Window for Mobile
          if (_activeRoomId == 0) {
            return Container(
              color: Colors.white,
              child: _buildLeftSidebarList(currentUserId, rooms),
            );
          }

          return _buildMainChatWindow(currentUserId, true);
        },
      ),
    );
  }
}