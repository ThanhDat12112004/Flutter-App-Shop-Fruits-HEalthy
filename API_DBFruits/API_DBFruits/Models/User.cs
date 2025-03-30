using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;

namespace API_DBFruits.Models;

public partial class User : IdentityUser
{
    public string? Initials { get; set; }
    public string TenKhachHang { get; set; } = null!;
    public string? DiaChi { get; set; }
    public virtual ICollection<DonHang> DonHangs { get; set; } = new List<DonHang>();
    public virtual ICollection<DanhMucYeuThich> DanhMucYeuThiches { get; set; } = new List<DanhMucYeuThich>();
    public virtual ICollection<GioHang> GioHangs { get; set; } = new List<GioHang>();
}
