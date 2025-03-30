using API_DBFruits.Models;

namespace API_DBFruits.Repositories
{
    public interface IGioHangRepository
    {
        Task<IEnumerable<GioHang>> GetGioHangsAsync();
        Task<GioHang?> GetGioHangByIdAsync(int id);
        Task<IEnumerable<GioHang>> GetGioHangsByKhachHangIdAsync(string khachHangId);
        Task<GioHang?> GetGioHangByKhachHangAndSanPhamAsync(string khachHangId, int sanPhamId);

        Task AddGioHangAsync(GioHang gioHang);
        Task UpdateGioHangAsync(GioHang gioHang);
        Task DeleteGioHangAsync(int id);
    }
}
