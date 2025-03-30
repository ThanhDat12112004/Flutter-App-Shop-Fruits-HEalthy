using API_DBFruits.Models;

namespace API_DBFruits.Repositories
{
    public interface IDonHangRepository
    {
        Task<IEnumerable<DonHang>> GetDonHangsAsync();
        Task<DonHang> GetDonHangByIdAsync(int id);
        Task<IEnumerable<DonHang>> GetDonHangsByKhachHangIdAsync(string khachHangId); // New method
        Task AddDonHangAsync(DonHang donHang);
        Task UpdateDonHangAsync(DonHang donHang);
        Task DeleteDonHangAsync(int id);
    }
}
