import 'package:flutter/material.dart';
import 'package:avatar_plus/avatar_plus.dart';

class AvatarNotification {
  static void showFavoriteMessage(
    BuildContext context,
    String avatarName,
    String displayName,
  ) {
    final messages = [
      "Nice choice! 💖",
      "Great taste! 👌",
      "You've got good taste! ✨",
      "This one's special! 💫",
      "Lovely pick! 🌸",
      "Favorited with love! 💘",
      "Great choice! 🎁",
      "Love it! 💖",
    ];
    _showAvatarMessage(context, avatarName, messages);
  }

  static void showCartMessage(
    BuildContext context,
    String avatarName,
    String displayName,
  ) {
    final messages = [
      "Great choice! 🎁",
      "Ready to checkout? 💰",
      "Nice Choice! 🎀",
      "Good choice! 💪",
      "This one is really special! 💫",
      "Nice selection! 👍",
      "You've got good taste! ✨",
      "Lovely pick! 🌸",
    ];
    _showAvatarMessage(context, avatarName, messages);
  }

  static void _showAvatarMessage(
    BuildContext context,
    String avatarName,
    // String displayName,
    List<String> messages,
  ) {
    final randomMessage =
        messages[DateTime.now().millisecondsSinceEpoch % messages.length];

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            top: 30,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF998BCF),
                          width: 2,
                        ),
                      ),
                      child: AvatarPlus(avatarName),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          randomMessage,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
