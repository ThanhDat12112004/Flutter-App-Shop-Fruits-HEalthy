class ChiTietDonHang {
  ChiTietDonHang({
    required this.chiTietDonHangId,
    required this.donHangId,
    required this.sanPhamId,
    required this.soLuong,
    required this.giaBan,
  });

  final int? chiTietDonHangId;
  final int? donHangId;
  final int? sanPhamId;
  final int? soLuong;
  final int? giaBan;

  factory ChiTietDonHang.fromJson(Map<String, dynamic> json) {
    return ChiTietDonHang(
      chiTietDonHangId: json["chiTietDonHangId"],
      donHangId: json["donHangId"],
      sanPhamId: json["sanPhamId"],
      soLuong: json["soLuong"],
      giaBan: json["giaBan"],
    );
  }
}
