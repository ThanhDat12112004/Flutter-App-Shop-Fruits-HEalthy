class User {
  User({
    required this.id,
    required this.userName,
    required this.normalizedUserName,
    required this.email,
    required this.normalizedEmail,
    required this.emailConfirmed,
    required this.passwordHash,
    required this.securityStamp,
    required this.concurrencyStamp,
    required this.phoneNumber,
    required this.phoneNumberConfirmed,
    required this.twoFactorEnabled,
    required this.lockoutEnd,
    required this.lockoutEnabled,
    required this.accessFailedCount,
    required this.initials,
    required this.tenKhachHang,
    required this.diaChi,
  });

  final String? id;
  final String? userName;
  final String? normalizedUserName;
  final String? email;
  final String? normalizedEmail;
  final bool? emailConfirmed;
  final String? passwordHash;
  final String? securityStamp;
  final String? concurrencyStamp;
  final String? phoneNumber;
  final bool? phoneNumberConfirmed;
  final bool? twoFactorEnabled;
  final DateTime? lockoutEnd;
  final bool? lockoutEnabled;
  final int? accessFailedCount;
  final String? initials;
  final String? tenKhachHang;
  final String? diaChi;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      userName: json["userName"],
      normalizedUserName: json["normalizedUserName"],
      email: json["email"],
      normalizedEmail: json["normalizedEmail"],
      emailConfirmed: json["emailConfirmed"],
      passwordHash: json["passwordHash"],
      securityStamp: json["securityStamp"],
      concurrencyStamp: json["concurrencyStamp"],
      phoneNumber: json["phoneNumber"],
      phoneNumberConfirmed: json["phoneNumberConfirmed"],
      twoFactorEnabled: json["twoFactorEnabled"],
      lockoutEnd: DateTime.tryParse(json["lockoutEnd"] ?? ""),
      lockoutEnabled: json["lockoutEnabled"],
      accessFailedCount: json["accessFailedCount"],
      initials: json["initials"],
      tenKhachHang: json["tenKhachHang"],
      diaChi: json["diaChi"],
    );
  }
}
