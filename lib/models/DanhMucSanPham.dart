class DanhMucSanPham {
  DanhMucSanPham({
    required this.danhMucId,
    required this.tenDanhMuc,
    required this.moTa,
    required this.sanPhams,
  });

  final int? danhMucId;
  final String? tenDanhMuc;
  final String? moTa;
  final List<dynamic> sanPhams;

  factory DanhMucSanPham.fromJson(Map<String, dynamic> json) {
    return DanhMucSanPham(
      danhMucId: json["danhMucId"],
      tenDanhMuc: json["tenDanhMuc"],
      moTa: json["moTa"],
      sanPhams: json["sanPhams"] == null
          ? []
          : List<dynamic>.from(json["sanPhams"]!.map((x) => x)),
    );
  }
}
