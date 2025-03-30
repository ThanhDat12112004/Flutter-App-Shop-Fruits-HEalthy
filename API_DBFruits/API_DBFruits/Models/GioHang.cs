using System;
using System.Collections.Generic;

namespace API_DBFruits.Models;

public partial class GioHang
{
    public int GioHangId { get; set; }

    public String? KhachHangId { get; set; }

    public int? SanPhamId { get; set; }
    public int? SoLuong { get; set; }

    public DateOnly ThoiGian { get; set; }

    public virtual User? KhachHang { get; set; }

    public virtual SanPham? SanPham { get; set; }
}
