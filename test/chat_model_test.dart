import 'package:flutter_test/flutter_test.dart';
import 'package:gym_mobile_flutter/app/modules/chat/models/chat_model.dart';

void main() {
  test('ConversationModel maps API payload', () {
    final model = ConversationModel.fromJson({
      'id': 'conv-1',
      'subject': 'Admin Support',
      'status': 'open',
      'updated_at': '2026-07-10T10:00:00.000000Z',
      'last_message': 'Halo admin',
      'last_message_at': '2026-07-10T10:05:00.000000Z',
      'other_party_name': 'Admin Budi',
      'admin': {'id': 'admin-1', 'name': 'Admin Budi'},
    });

    expect(model.id, 'conv-1');
    expect(model.title, 'Admin Support');
    expect(model.lastMessage, 'Halo admin');
    expect(model.otherPartyName, 'Admin Budi');
    expect(model.isActive, isTrue);
  });

  test('MessageModel detects own message', () {
    final model = MessageModel.fromJson(
      {
        'id': 'msg-1',
        'conversation_id': 'conv-1',
        'sender_id': 'member-1',
        'message': 'Halo',
        'created_at': '2026-07-10T10:00:00.000000Z',
      },
      'member-1',
    );

    expect(model.isMe, isTrue);
    expect(model.message, 'Halo');
  });
}
