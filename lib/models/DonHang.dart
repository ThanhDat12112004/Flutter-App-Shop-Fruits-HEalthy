class DonHang {
  DonHang({
    required this.donHangId,
    required this.khachHangId,
    required this.diaChi,
    required this.ngayDat,
    required this.tongTien,
    required this.trangThai,
  });

  final int? donHangId;
  final String? khachHangId;
  final DateTime? ngayDat;
  final String? diaChi;
  final int? tongTien;
  final String? trangThai;

  factory DonHang.fromJson(Map<String, dynamic> json) {
    return DonHang(
      donHangId: json["donHangId"],
      khachHangId: json["khachHangId"],
      diaChi: json["diaChi"],
      ngayDat: DateTime.tryParse(json["ngayDat"] ?? ""),
      tongTien: json["tongTien"],
      trangThai: json["trangThai"],
    );
  }
}
