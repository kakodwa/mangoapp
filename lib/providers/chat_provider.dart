import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import 'api_provider.dart';

/// Fetches the user's active chat conversations
final userChatRoomsProvider = FutureProvider.autoDispose<List<ChatRoomModel>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.getList(
    'chat/rooms/',
    fromJson: (json) => ChatRoomModel.fromJson(json),
  );
});

final chatRoomActionsProvider = Provider((ref) => ChatRoomActions(ref));

class ChatRoomActions {
  final Ref ref;

  ChatRoomActions(this.ref);

  /// Initializes or retrieves an existing chat room for a product
  Future<ChatRoomModel> getOrCreateRoom(int productId) async {
    final api = ref.read(apiClientProvider);
    final response = await api.post(
      'chat/rooms/get_or_create_room/', // 👈 Must retain explicit trailing slash for DRF @action
      data: {'product_id': productId},
      fromJson: (json) => ChatRoomModel.fromJson(json),
    );
    return response;
  }

  /// Fetches historical messages for a given room ID
  Future<List<ChatMessageModel>> fetchMessages(int roomId) async {
    final api = ref.read(apiClientProvider);
    return api.getList(
      'chat/rooms/$roomId/messages/',
      fromJson: (json) => ChatMessageModel.fromJson(json),
    );
  }

  /// Sends a new text message to a given room ID
  Future<ChatMessageModel> sendMessage(int roomId, String text) async {
    final api = ref.read(apiClientProvider);
    return await api.post<ChatMessageModel>(
      'chat/rooms/$roomId/send_message/',
      data: {
        'text': text,
        'message': text,
      },
      fromJson: (json) => ChatMessageModel.fromJson(json),
    );
  }
}