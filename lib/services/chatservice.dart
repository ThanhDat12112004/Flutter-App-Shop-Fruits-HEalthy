import 'dart:convert';
import 'package:diacritic/diacritic.dart';
import 'package:fruitshealthy_nhom2/config/config_url.dart';
import 'package:fruitshealthy_nhom2/screens/ProductDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

const String apiKey = 'AIzaSyCjmz9-P60N_LDvb504nHff48mCbhUtrnU';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isProductLink;
  final Map<String, dynamic>? product;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isProductLink = false,
    this.product,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotAI extends StatefulWidget {
  const ChatbotAI({super.key});

  @override
  _ChatbotAIState createState() => _ChatbotAIState();
}

class _ChatbotAIState extends State<ChatbotAI> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  List<dynamic> _productsData = [];
  bool _isLoading = false;
  bool _isTyping = false;
  late GenerativeModel _model;
  late ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _fetchProductData();
    _addInitialBotMessage();
  }

  void _initializeGemini() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );

    _chat = _model.startChat(history: [
      Content.text(
        'You are an AI assistant for an healthy fruit shop. You help customers with '
        'product information, recommendations, and shopping advice. Be friendly, '
        'professional, and always try to provide helpful, detailed responses in Vietnamese. '
        'Focus on fruits and related topics.',
      ),
    ]);
  }

  Future<void> _fetchProductData() async {
    try {
      final response =
          await http.get(Uri.parse('${Config_URL.baseUrl}api/ProductApi'));
      if (response.statusCode == 200) {
        setState(() {
          _productsData = json.decode(response.body);
          _isLoading = false;
        });
        _updateGeminiContext();
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateGeminiContext() async {
    String productContext = 'Available products:\n';
    for (var product in _productsData) {
      productContext += '''
- ${product['tenSanPham']}:
  Price: ${product['giaBan']} VND/kg
  Stock: ${product['soLuongTon']} kg
  Description: ${product['moTa']}
''';
    }

    await _chat.sendMessage(Content.text(
        'Here is the current product information. Use this to answer customer queries:\n$productContext'));
  }

  void _addInitialBotMessage() {
    _messages.add(ChatMessage(
      text:
          "Xin chào! Tôi là trợ lý AI của Fruits Healthy Shop. Tôi có thể giúp bạn tìm hiểu về các sản phẩm, tư vấn lựa chọn, và trả lời mọi thắc mắc của bạn. Bạn cần tôi giúp gì không?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Map<String, dynamic>? _findProduct(String query) {
    query = removeDiacritics(query.toLowerCase()); // Loại bỏ dấu của query

    return _productsData.firstWhere(
      (product) {
        String productName = removeDiacritics(product['tenSanPham']
            .toString()
            .toLowerCase()); // Loại bỏ dấu tên sản phẩm
        return productName.contains(removeDiacritics(query.toLowerCase())) ||
            removeDiacritics(query.toLowerCase()).contains(productName);
      },
      orElse: () => null,
    );
  }

  Widget _buildProductLink(Map<String, dynamic> product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              sanPhamId:
                  product['sanPhamId'], // Truyền ID sản phẩm tới trang chi tiết
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 0, 255, 21)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              product['anhSanPham'] ?? '',
              height: 30,
              // width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['tenSanPham'],
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${product['giaBan']} VNnnnD/kg',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      // Tìm sản phẩm liên quan
      final relatedProduct = _findProduct(text);

      // Thêm thông tin sản phẩm vào prompt
      String productInfo = '';
      if (relatedProduct != null) {
        productInfo =
            '\n\nSản phẩm bạn muốn: ${relatedProduct['tenSanPham']} - ${relatedProduct['giaBan']} VND/kg\n';
      }

      final response = await _chat.sendMessage(Content.text(
          '$text\n$productInfo\nTrả lời bằng tiếng Việt và chỉ về các sản phẩm của shop.'));

      String responseText =
          response.text ?? 'Xin lỗi, tôi không thể xử lý yêu cầu này.';

      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: responseText,
          isUser: false,
        ));

        // Nếu tìm thấy sản phẩm, hiển thị chi tiết sản phẩm
        if (relatedProduct != null) {
          _messages.add(ChatMessage(
            text: "Chi tiết sản phẩm:",
            isUser: false,
            isProductLink: true,
            product: relatedProduct,
          ));
        }
      });
    } catch (e) {
      print('Error getting Gemini response: $e');
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại sau.',
          isUser: false,
        ));
      });
    }

    _scrollToBottom();
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 0, 255, 55),
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color.fromARGB(255, 178, 255, 193)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (message.isProductLink && message.product != null)
                    _buildProductLink(message.product!),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 0, 255, 94),
              child: Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Orange Shop AI Assistant'),
      // ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _handleSubmitted,
                    decoration: const InputDecoration(
                      labelText: 'Bạn muốn hỏi gì?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _handleSubmitted(_controller.text),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
