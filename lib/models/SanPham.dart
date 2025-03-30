class SanPham {
  SanPham({
    required this.sanPhamId,
    required this.tenSanPham,
    required this.anhSanPham,
    required this.giaBan,
    required this.soLuongTon,
    required this.danhMucId,
    required this.moTa,
  });

  final int? sanPhamId;
  final String? tenSanPham;
  final String? anhSanPham;
  final int? giaBan;
  final int? soLuongTon;
  final int? danhMucId;
  final String? moTa;

  factory SanPham.fromJson(Map<String, dynamic> json) {
    return SanPham(
      sanPhamId: json["sanPhamId"],
      tenSanPham: json["tenSanPham"],
      anhSanPham: json["anhSanPham"],
      giaBan: json["giaBan"],
      soLuongTon: json["soLuongTon"],
      danhMucId: json["danhMucId"],
      moTa: json["moTa"],
    );
  }
}
