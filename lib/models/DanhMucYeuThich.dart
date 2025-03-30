class DanhMucYeuThich {
  DanhMucYeuThich({
    required this.danhMucYeuThichId,
    required this.khachHangId,
    required this.sanPhamId,
    required this.thoiGian,
  });

  final int? danhMucYeuThichId;
  final String? khachHangId;
  final int? sanPhamId;
  final DateTime? thoiGian;

  factory DanhMucYeuThich.fromJson(Map<String, dynamic> json) {
    return DanhMucYeuThich(
      danhMucYeuThichId: json["danhMucYeuThichId"],
      khachHangId: json["khachHangId"],
      sanPhamId: json["sanPhamId"],
      thoiGian: DateTime.tryParse(json["thoiGian"] ?? ""),
    );
  }
}
