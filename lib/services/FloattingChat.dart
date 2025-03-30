import 'package:flutter/material.dart';
import 'package:fruitshealthy_nhom2/screens/Chatbot_screen.dart';
import 'package:fruitshealthy_nhom2/theme/apptheme.dart';

class FloatingChatButton extends StatelessWidget {
  const FloatingChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatbotScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: Stack(
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 28,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
