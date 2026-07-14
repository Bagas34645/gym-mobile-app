import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/chat_controller.dart';
import 'package:intl/intl.dart';

class ChatDetailView extends GetView<ChatController> {
  ChatDetailView({super.key});

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        // Defer cleanup so AppBar doesn't rebuild mid-pop animation.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.leaveChat();
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Admin Support',
            style: AppTextStyles.headingSmall,
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller
                        .messages[controller.messages.length - 1 - index];
                    return _buildMessageBubble(message);
                  },
                );
              }),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: Get.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.createdAt),
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 9,
                color: isMe ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => IconButton(
                icon: Icon(
                  Icons.send,
                  color: controller.isSending.value
                      ? AppColors.textSecondary
                      : AppColors.accent,
                ),
                onPressed: controller.isSending.value
                    ? null
                    : () {
                        final text = _messageController.text;
                        if (text.isNotEmpty) {
                          controller.sendMessage(text);
                          _messageController.clear();
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
