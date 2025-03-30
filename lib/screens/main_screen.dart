import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fruitshealthy_nhom2/screens/Chatbot_screen.dart';
import 'package:fruitshealthy_nhom2/screens/GioiHang_Screen.dart';
import 'package:fruitshealthy_nhom2/screens/OrderHistoryPage.dart';
import 'package:fruitshealthy_nhom2/screens/danhmucyeuthich_trang.dart';
import 'package:fruitshealthy_nhom2/screens/login_screen.dart';
import 'package:fruitshealthy_nhom2/theme/CustomBottomNavBar.dart';
import 'package:fruitshealthy_nhom2/screens/market_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _role = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _role = prefs.getString('jwt_role') ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading role: $e');
    }
  }

  Widget _getCurrentScreen() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _buildScreen(),
    );
  }

  Widget _buildScreen() {
    switch (_currentIndex) {
      case 0:
        return const MarketScreen(key: ValueKey('market'));
      case 1:
        return FavoritePage(key: const ValueKey('favorite'));
      case 2:
        return const CartPage(key: ValueKey('cart'));
      case 3:
        return const OrderHistoryPage(key: ValueKey('history'));
      case 4:
        return const ChatbotScreen(key: ValueKey('chatbot'));
      case 5:
        _logout();
        return const MarketScreen(key: ValueKey('market_logout'));
      default:
        return const MarketScreen(key: ValueKey('market_default'));
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng xuất thành công'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng xuất: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                _getCurrentScreen(),
              ],
            ),
          ),
          bottomNavigationBar:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? CustomBottomNavBar(
                      currentIndex: _currentIndex,
                      onTap: (index) {
                        if (index == 5) {
                          _logout();
                        } else {
                          setState(() {
                            _currentIndex = index;
                          });
                        }
                      },
                      userRole: _role,
                    )
                  : null,
        );
      },
    );
  }
}
