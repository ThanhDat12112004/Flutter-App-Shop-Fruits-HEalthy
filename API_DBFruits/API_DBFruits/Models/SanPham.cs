using System;
using System.Collections.Generic;

namespace API_DBFruits.Models;

public partial class SanPham
{
    public int SanPhamId { get; set; }

    public string TenSanPham { get; set; } = null!;

    public string AnhSanPham { get; set; } = null!;

    public int GiaBan { get; set; }

    public int SoLuongTon { get; set; }

    public int? DanhMucId { get; set; }

    public string? MoTa { get; set; }

    public virtual ICollection<ChiTietDonHang> ChiTietDonHangs { get; set; } = new List<ChiTietDonHang>();

    public virtual ICollection<DanhMucYeuThich> DanhMucYeuThiches { get; set; } = new List<DanhMucYeuThich>();
    public virtual ICollection<GioHang> GioHangs { get; set; } = new List<GioHang>();

    public virtual DanhMucSanPham? DanhMuc { get; set; }
}
