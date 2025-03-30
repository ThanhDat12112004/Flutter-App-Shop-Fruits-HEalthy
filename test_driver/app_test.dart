import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Shop Healthy Fruit Login Test', () {
    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver!.close();
      }
    });

    Future<void> enterCredentials(FlutterDriver d, String username, String password) async {
      final usernameField = find.byValueKey('email_field');
      final passwordField = find.byValueKey('password_field');
      final loginButton = find.byValueKey('login_button');

      await d.waitFor(usernameField);
      await d.tap(usernameField);
      await d.enterText(username);

      await d.waitFor(passwordField);
      await d.tap(passwordField);
      await d.enterText(password);

      await d.tap(loginButton);
    }

    Future<void> checkSnackBar(FlutterDriver d, String expectedMessage) async {
      final snackBarText = find.byValueKey('snackbar_text');
      try {
        await d.waitFor(snackBarText, timeout: Duration(seconds: 5));
        final actualMessage = await d.getText(snackBarText);
        expect(actualMessage, expectedMessage, reason: 'SnackBar message does not match expected');
      } catch (e) {
        fail('SnackBar không xuất hiện trong thời gian chờ: $e');
      }
    }

    // 
    // // TC1: Username rỗng, Password rỗng
    // test('TC1 - Username rỗng, Password rỗng', () async {
    //   final d = driver!;
    //   await enterCredentials(d, '', '');
    //   await checkSnackBar(d, 'Vui lòng nhập đầy đủ thông tin!');
    // });

    // // TC2: Username rỗng, Password dưới tối thiểu
    // test('TC2 - Username rỗng, Password dưới tối thiểu', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, '', 'abcde');
    //   await checkSnackBar(d, 'Vui lòng nhập tên đăng nhập!');
    // });

    // // TC3: Username rỗng, Password hợp lệ (biên dưới)
    // test('TC3 - Username rỗng, Password hợp lệ (biên dưới)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, '', 'pass12');
    //   await checkSnackBar(d, 'Vui lòng nhập tên đăng nhập!');
    // });

    // // TC4: Username rỗng, Password vượt tối đa
    // test('TC4 - Username rỗng, Password vượt tối đa', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   String longPassword = 'a' * 129;
    //   await enterCredentials(d, '', longPassword);
    //   await checkSnackBar(d, 'Vui lòng nhập tên đăng nhập!');
    // });

    // // TC5: Username hợp lệ (biên dưới), Password rỗng
    // test('TC5 - Username hợp lệ (biên dưới), Password rỗng', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, 'u', '');
    //   await checkSnackBar(d, 'Vui lòng nhập mật khẩu!');
    // });

    // // TC6: Username hợp lệ (biên dưới), Password dưới tối thiểu
    // test('TC6 - Username hợp lệ (biên dưới), Password dưới tối thiểu', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, 'u', 'abcde');
    //   await checkSnackBar(d, 'Mật khẩu phải từ 6 ký tự trở lên!');
    // });

    // // TC7: Username hợp lệ (biên dưới), Password hợp lệ (biên dưới)
    // test('TC7 - Username hợp lệ (biên dưới), Password hợp lệ (biên dưới)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, '0949927642', 'Thanhdat@123');
    //   await checkSnackBar(d, 'Đăng nhập thành công!');
    // });

    // // TC8: Username hợp lệ (biên dưới), Password vượt tối đa
    // test('TC8 - Username hợp lệ (biên dưới), Password vượt tối đa', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   String longPassword = 'a' * 129;
    //   await enterCredentials(d, 'u', longPassword);
    //   await checkSnackBar(d, 'Mật khẩu quá dài!');
    // });

    // // TC9: Username hợp lệ (biên trên), Password rỗng
    // test('TC9 - Username hợp lệ (biên trên), Password rỗng', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   String longUsername = 'u' * 50;
    //   await enterCredentials(d, longUsername, '');
    //   await checkSnackBar(d, 'Vui lòng nhập mật khẩu!');
    // });

    // // TC10: Username hợp lệ (biên trên), Password dưới tối thiểu
    // test('TC10 - Username hợp lệ (biên trên), Password dưới tối thiểu', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   String longUsername = 'u' * 50;
    //   await enterCredentials(d, longUsername, 'abcde');
    //   await checkSnackBar(d, 'Mật khẩu phải từ 6 ký tự trở lên!');
    // });

    // // TC11: Username hợp lệ (biên trên), Password hợp lệ (biên dưới)
    // test('TC11 - Username hợp lệ (biên trên), Password hợp lệ (biên dưới)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   String longUsername = 'u' * 50;
    //   await enterCredentials(d, '0949927642', 'Thanhdat@123');
    //   await checkSnackBar(d, 'Đăng nhập thành công!');
    // });

    // // TC12: Username hợp lệ (biên trên), Password vượt tối đa
    // test('TC12 - Username hợp lệ (biên trên), Password vượt tối đa', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   String longUsername = 'u' * 50;
    //   String longPassword = 'a' * 129;
    //   await enterCredentials(d, longUsername, longPassword);
    //   await checkSnackBar(d, 'Mật khẩu quá dài!');
    // });

    // // TC13: Username vượt tối đa, Password rỗng
    // test('TC13 - Username vượt tối đa, Password rỗng', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   String longUsername = 'u' * 51;
    //   await enterCredentials(d, longUsername, '');
    //   await checkSnackBar(d, 'Tên đăng nhập quá dài!');
    // });

    // // TC14: Username vượt tối đa, Password dưới tối thiểu
    // test('TC14 - Username vượt tối đa, Password dưới tối thiểu', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   String longUsername = 'u' * 51;
    //   await enterCredentials(d, longUsername, 'abcde');
    //   await checkSnackBar(d, 'Tên đăng nhập quá dài!');
    // });

    // // TC15: Username vượt tối đa, Password hợp lệ (biên dưới)
    // test('TC15 - Username vượt tối đa, Password hợp lệ (biên dưới)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   String longUsername = 'u' * 51;
    //   await enterCredentials(d, longUsername, 'pass12');
    //   await checkSnackBar(d, 'Tên đăng nhập quá dài!');
    // });

    // // TC16: Username vượt tối đa, Password vượt tối đa
    // test('TC16 - Username vượt tối đa, Password vượt tối đa', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   String longUsername = 'u' * 51;
    //   String longPassword = 'a' * 129;
    //   await enterCredentials(d, longUsername, longPassword);
    //   await checkSnackBar(d, 'Tên đăng nhập quá dài!');
    // });
    // // SC1: Username hoặc Password là null
    // test('SC1 - Username hoặc Password là null', () async {
    //   final d = driver!;
    //   await enterCredentials(d, '', 'pass123');
    //   await checkSnackBar(d, 'Vui lòng nhập đầy đủ thông tin!');
    // });

    // // SC2: Username không hợp lệ (độ dài < 1)
    // test('SC2 - Username không hợp lệ (độ dài < 1)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, '', 'pass123');
    //   await checkSnackBar(d, 'Vui lòng nhập đầy đủ thông tin!');
    // });

    // // SC3: Password không hợp lệ (độ dài < 6)
    // test('SC3 - Password không hợp lệ (độ dài < 6)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, 'user1', '123');
    //   await checkSnackBar(d, 'Tên đăng nhập hoặc mật khẩu không đúng!');
    // });

    // // SC4: API trả về lỗi (statusCode != 200)
    // test('SC4 - API trả về lỗi (statusCode != 200)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, 'user1  1213 3 @12', 'pass123213  12'); // Giả định API trả về statusCode 500
    //   await checkSnackBar(d, 'In ra lỗi');
    // });

    // // SC5: Đăng nhập thất bại (message == false)
    // test('SC5 - Đăng nhập thất bại (message == false)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, 'user1', 'wrongpass'); // Giả định API trả về statusCode 200, message = false
    //   await checkSnackBar(d, 'Tên đăng nhập hoặc mật khẩu không đúng!');
    // });

    // // SC6: Đăng nhập thành công
    // test('SC6 - Đăng nhập thành công', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, '0949927642', 'Thanhdat@123'); // Giả định API trả về statusCode 200, message = true
    //   await checkSnackBar(d, 'Đăng nhập thành công!');
    // });
    // BC1: Username hoặc Password là null
    // test('BC1 - Username hoặc Password là null', () async {
    //   final d = driver!;
    //   await enterCredentials(d, '', 'pass123');
    //   await checkSnackBar(d, 'Vui lòng điền đầy đủ thông tin!');
    // });

    // // BC2: Username và Password không null, Username không hợp lệ
    // test('BC2 - Username và Password không null, Username không hợp lệ', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, '', 'pass123');
    //   await checkSnackBar(d, 'Username không hợp lệ');
    // });

    // // BC3: Username hợp lệ, Password không hợp lệ
    // test('BC3 - Username hợp lệ, Password không hợp lệ', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, 'user1', '123');
    //   await checkSnackBar(d, 'Password không hợp lệ');
    // });

    // // BC4: API trả về lỗi (statusCode != 200)
    // test('BC4 - API trả về lỗi (statusCode != 200)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, 'user1', 'pass123'); // Giả định API trả về statusCode 500
    //   await checkSnackBar(d, 'In ra lỗi');
    // });

    // // BC5: Đăng nhập thất bại (message == false)
    // test('BC5 - Đăng nhập thất bại (message == false)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, 'user1', 'wrongpass'); // Giả định API trả về statusCode 200, message = false
    //   await checkSnackBar(d, 'Tên đăng nhập hoặc mật khẩu không đúng!');
    // });

    // // BC6: Đăng nhập thành công
    // test('BC6 - Đăng nhập thành công', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, '0949927642', 'Thanhdat@123'); // Giả định API trả về statusCode 200, message = true
    //   await checkSnackBar(d, 'Đăng nhập thành công!');
    // });
    // PC1: Path 1 - Username hoặc Password là null
    // test('PC1 - Username hoặc Password là null', () async {
    //   final d = driver!;
    //   await enterCredentials(d, '', 'pass123');
    //   await checkSnackBar(d, 'Vui lòng nhập đầy đủ thông tin!');
    // });

    // // PC2: Path 2 - Username không hợp lệ
    // test('PC2 - Username không hợp lệ', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, '', 'pass123');
    //   await checkSnackBar(d, 'Username không hợp lệ');
    // });

    // // PC3: Path 3 - Username hợp lệ, Password không hợp lệ
    // test('PC3 - Username hợp lệ, Password không hợp lệ', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, 'user1', '123');
    //   await checkSnackBar(d, 'Password không hợp lệ');
    // });

    // // PC4: Path 4 - API trả về lỗi (statusCode != 200)
    // test('PC4 - API trả về lỗi (statusCode != 200)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, 'user1', 'pass123'); // Giả định API trả về statusCode 500
    //   await checkSnackBar(d, 'In ra lỗi');
    // });

    // // PC5: Path 5 - Đăng nhập thất bại (message == false)
    // test('PC5 - Đăng nhập thất bại (message == false)', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, 'user1', 'wrongpass'); // Giả định API trả về statusCode 200, message = false
    //   await checkSnackBar(d, 'Tên đăng nhập hoặc mật khẩu không đúng!');
    // });

    // // PC6: Path 6 - Đăng nhập thành công
    // test('PC6 - Đăng nhập thành công', () async {
    //   await Future.delayed(Duration(seconds: 5));
    //   final d = driver!;
    //   await enterCredentials(d, '0949927642', 'Thanhdat@123'); // Giả định API trả về statusCode 200, message = true
    //   await checkSnackBar(d, 'Đăng nhập thành công!');
    // });
    // CC1: username == null là True, password == null là False
    test('CC1 - Username == null', () async {
      final d = driver!;
      await enterCredentials(d, '', 'pass123');
      await checkSnackBar(d, 'Vui lòng nhập đầy đủ thông tin!');
    });

    // CC2: username == null là False, password == null là True
    test('CC2 - Password == null', () async {
      await Future.delayed(Duration(seconds: 5));
      final d = driver!;
      await enterCredentials(d, 'user1', '');
      await checkSnackBar(d, 'Vui lòng nhập đầy đủ thông tin!');
    });

    // CC3: username.length < 1 là True
    test('CC3 - Username.length < 1', () async {
      await Future.delayed(Duration(seconds: 5));
      final d = driver!;
      await enterCredentials(d, '', 'pass123');
      await checkSnackBar(d, 'Username không hợp lệ!');
    });

    // CC4: username.length > 50 là True
    test('CC4 - Username.length > 50', () async {
      await Future.delayed(Duration(seconds: 5));
      final d = driver!;
      String longUsername = 'a' * 51;
      await enterCredentials(d, longUsername, 'pass123');
      await checkSnackBar(d, 'Username không hợp lệ!');
    });

    // CC5: username contains special characters là True
    test('CC5 - Username contains special characters', () async {
      await Future.delayed(Duration(seconds: 5));
      final d = driver!;
      await enterCredentials(d, 'user#123', 'pass123');
      await checkSnackBar(d, 'Username không hợp lệ!');
    });

    // CC6: password.length < 6 là True
    test('CC6 - Password.length < 6', () async {
      await Future.delayed(Duration(seconds: 5));
      final d = driver!;
      await enterCredentials(d, 'user1', '123');
      await checkSnackBar(d, 'Password không hợp lệ!');
    });

    // CC7: password.length > 128 là True
    test('CC7 - Password.length > 128', () async {
      await Future.delayed(Duration(seconds: 5));
      final d = driver!;
      String longPassword = 'a' * 129;
      await enterCredentials(d, 'user1', longPassword);
      await checkSnackBar(d, 'Password không hợp lệ');
    });

    // CC8: message == false
    test('CC8 - Message == false', () async {
      await Future.delayed(Duration(seconds: 5));
      final d = driver!;
      await enterCredentials(d, '0949927642a', 'Thanhdat@123'); // API trả về statusCode = 200, message = false
      await checkSnackBar(d, 'Tên đăng nhập hoặc mật khẩu không đúng!');
    });

    // CC9: message == true
    test('CC9 - Message == true', () async {
      await Future.delayed(Duration(seconds: 5));
      final d = driver!;
      await enterCredentials(d, '0949927642', 'Thanhdat@123'); // API trả về statusCode = 200, message = true
      await checkSnackBar(d, 'Đăng nhập thành công!');
    });
  });
  
}
