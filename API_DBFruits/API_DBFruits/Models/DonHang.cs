using System;
using System.Collections.Generic;

namespace API_DBFruits.Models;

public partial class DonHang
{
    public int DonHangId { get; set; }

    public string? KhachHangId { get; set; }

    public string? DiaChi { get; set; }

    public DateOnly NgayDat { get; set; }

    public int? TongTien { get; set; }

    public string? TrangThai { get; set; }

    public virtual ICollection<ChiTietDonHang> ChiTietDonHangs { get; set; } = new List<ChiTietDonHang>();

    public virtual User? KhachHang { get; set; }
}
