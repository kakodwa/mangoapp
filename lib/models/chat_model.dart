class ChatRoomModel {
  final int id;
  final int buyer;
  final String buyerName;
  final int seller;
  final String sellerName;
  final int? productId;
  final String? productName;
  final ChatMessageModel? lastMessage;

  ChatRoomModel({
    required this.id,
    required this.buyer,
    required this.buyerName,
    required this.seller,
    required this.sellerName,
    this.productId,
    this.productName,
    this.lastMessage,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'],
      buyer: json['buyer'],
      buyerName: json['buyer_name'] ?? '',
      seller: json['seller'],
      sellerName: json['seller_name'] ?? '',
      productId: json['product'],
      productName: json['product_name'],
      lastMessage: json['last_message'] != null 
          ? ChatMessageModel.fromJson(json['last_message']) 
          : null,
    );
  }
}

class ChatMessageModel {
  final int id;
  final int roomId;
  final int senderId;
  final String? senderName;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.senderName,
    required this.text,
    this.imageUrl,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? 0,
      roomId: json['room'] ?? json['room_id'] ?? 0,
      senderId: json['sender'] ?? json['sender_id'] ?? 0,
      senderName: json['sender_name'],
      text: json['text'] ?? json['message'] ?? '',
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}