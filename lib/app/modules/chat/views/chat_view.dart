import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/chat_controller.dart';

class ChatListView extends GetView<ChatController> {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kontak Admin', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchConversations,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.surface2,
                          child: const Icon(
                            Icons.support_agent,
                            size: 28,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Support',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hubungi admin untuk bantuan seputar membership, jadwal, atau pertanyaan lainnya.',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isSending.value
                        ? null
                        : () async {
                            final existing = controller.activeConversation;
                            if (existing != null) {
                              await controller.openChat(existing);
                              return;
                            }

                            final message = await controller.promptInitialMessage();
                            if (message != null && message.isNotEmpty) {
                              await controller.startOrOpenChat(
                                initialMessage: message,
                              );
                            }
                          },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(
                      controller.activeConversation != null
                          ? 'Lanjutkan Chat'
                          : 'Chat dengan Admin',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (controller.conversations.isNotEmpty) ...[
                  Text(
                    'Percakapan sebelumnya',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.conversations.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final conv = controller.conversations[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.surface2,
                          child: const Icon(
                            Icons.person,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        title: Text(
                          conv.otherPartyName ?? conv.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          conv.lastMessage ?? conv.subject ?? 'Belum ada pesan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: conv.lastMessageAt != null
                            ? Text(
                                DateFormat('HH:mm').format(conv.lastMessageAt!),
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 10,
                                ),
                              )
                            : null,
                        onTap: () => controller.openChat(conv),
                      );
                    },
                  ),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Belum ada percakapan sebelumnya.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
