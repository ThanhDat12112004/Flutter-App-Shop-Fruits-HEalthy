class GioHang {
  GioHang({
    required this.gioHangId,
    required this.khachHangId,
    required this.sanPhamId,
    required this.soLuong,
    required this.thoiGian,
  });

  final int? gioHangId;
  final String? khachHangId;
  final int? sanPhamId;
  final int? soLuong;
  final DateTime? thoiGian;

  factory GioHang.fromJson(Map<String, dynamic> json) {
    return GioHang(
      gioHangId: json["gioHangId"],
      khachHangId: json["khachHangId"],
      sanPhamId: json["sanPhamId"],
      soLuong: json["soLuong"],
      thoiGian: DateTime.tryParse(json["thoiGian"] ?? ""),
    );
  }
}
