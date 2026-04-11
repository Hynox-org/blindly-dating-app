import 'package:flutter/foundation.dart';

@immutable
class Message {
  final String id;
  final String matchId;
  final String senderProfileId;
  final String receiverProfileId;
  final String text; // This will hold decrypted version for UI
  final String? originalContent; // This holds the raw cipherText
  final DateTime createdAt;
  final String? replyToId;
  final String? reaction;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime? editedAt;
  final String messageType;
  final int? voiceDuration;
  final String? iv;
  final String? encryptedKeySender;
  final String? encryptedKeyReceiver;

  final bool deletedForSender;
  final bool deletedForReceiver;
  final bool deletedForEveryone;
  final bool isSending; // Added for optimistic updates

  const Message({
    required this.id,
    required this.matchId,
    required this.senderProfileId,
    required this.receiverProfileId,
    required this.text,
    this.originalContent,
    required this.createdAt,
    this.replyToId,
    this.reaction,
    this.deliveredAt,
    this.readAt,
    this.editedAt,
    this.messageType = 'text',
    this.voiceDuration,
    this.iv,
    this.encryptedKeySender,
    this.encryptedKeyReceiver,
    this.deletedForSender = false,
    this.deletedForReceiver = false,
    this.deletedForEveryone = false,
    this.isSending = false,
  });

  factory Message.fromMap(Map<String, dynamic> map, {String? decryptedText}) {
    return Message(
      id: map['id'].toString(),
      matchId: map['match_id'],
      senderProfileId: map['sender_profile_id'],
      receiverProfileId: map['receiver_profile_id'],
      text: decryptedText ?? map['content'] ?? '',
      originalContent: map['content'],
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      replyToId: map['reply_to_id'],
      reaction: map['reaction'],
      deliveredAt: map['delivered_at'] != null
          ? DateTime.parse(map['delivered_at']).toLocal()
          : null,
      readAt: map['read_at'] != null
          ? DateTime.parse(map['read_at']).toLocal()
          : null,
      editedAt: map['edited_at'] != null
          ? DateTime.parse(map['edited_at']).toLocal()
          : null,
      messageType: map['message_type'] ?? 'text',
      voiceDuration: map['voice_duration'],
      iv: map['iv'],
      encryptedKeySender: map['encrypted_key_sender'],
      encryptedKeyReceiver: map['encrypted_key_receiver'],
      deletedForSender: map['deleted_for_sender'] ?? false,
      deletedForReceiver: map['deleted_for_receiver'] ?? false,
      deletedForEveryone: map['deleted_for_everyone'] ?? false,
      isSending: false, // Messages from DB are never optimistic
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'match_id': matchId,
      'sender_profile_id': senderProfileId,
      'receiver_profile_id': receiverProfileId,
      'content': originalContent ?? text,
      'created_at': createdAt.toUtc().toIso8601String(),
      'reply_to_id': replyToId,
      'reaction': reaction,
      'delivered_at': deliveredAt?.toUtc().toIso8601String(),
      'read_at': readAt?.toUtc().toIso8601String(),
      'edited_at': editedAt?.toUtc().toIso8601String(),
      'message_type': messageType,
      'voice_duration': voiceDuration,
      'iv': iv,
      'encrypted_key_sender': encryptedKeySender,
      'encrypted_key_receiver': encryptedKeyReceiver,
      'deleted_for_sender': deletedForSender,
      'deleted_for_receiver': deletedForReceiver,
      'deleted_for_everyone': deletedForEveryone,
    };
  }

  Message copyWith({
    String? text,
    String? originalContent,
    String? reaction,
    DateTime? editedAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool? deletedForSender,
    bool? deletedForReceiver,
    bool? deletedForEveryone,
    bool? isSending,
  }) {
    return Message(
      id: id,
      matchId: matchId,
      senderProfileId: senderProfileId,
      receiverProfileId: receiverProfileId,
      text: text ?? this.text,
      originalContent: originalContent ?? this.originalContent,
      createdAt: createdAt,
      replyToId: replyToId,
      reaction: reaction ?? this.reaction,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      editedAt: editedAt ?? this.editedAt,
      messageType: messageType,
      voiceDuration: voiceDuration,
      iv: iv,
      encryptedKeySender: encryptedKeySender,
      encryptedKeyReceiver: encryptedKeyReceiver,
      deletedForSender: deletedForSender ?? this.deletedForSender,
      deletedForReceiver: deletedForReceiver ?? this.deletedForReceiver,
      deletedForEveryone: deletedForEveryone ?? this.deletedForEveryone,
      isSending: isSending ?? this.isSending,
    );
  }
}
