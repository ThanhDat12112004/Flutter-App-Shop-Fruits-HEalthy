import 'package:fruitshealthy_nhom2/services/chatservice.dart';
import 'package:flutter/material.dart';
import 'package:fruitshealthy_nhom2/theme/apptheme.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://raw.githubusercontent.com/ThanhDat12112004/images_fruits/refs/heads/main/logo.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'Tư vấn',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.accentColor,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: const ChatbotAI(),
    );
  }
}
