using System;
using System.Collections.Generic;

namespace API_DBFruits.Models;

public partial class DanhMucSanPham
{
    public int DanhMucId { get; set; }

    public string TenDanhMuc { get; set; } = null!;

    public string? MoTa { get; set; }

    public virtual ICollection<SanPham> SanPhams { get; set; } = new List<SanPham>();
}
