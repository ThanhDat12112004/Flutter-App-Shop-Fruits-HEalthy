using System;
using System.Collections.Generic;

namespace API_DBFruits.Models;

public partial class DanhMucYeuThich
{
    public int DanhMucYeuThichId { get; set; }

    public string? KhachHangId { get; set; }

    public int? SanPhamId { get; set; }

    public DateOnly ThoiGian { get; set; }

    public virtual User? KhachHang { get; set; }

    public virtual SanPham? SanPham { get; set; }
}
