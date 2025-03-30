using API_DBFruits.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace API_DBFruits.Repositories
{
    public interface IChiTietDonHangRepository
    {
        Task<IEnumerable<ChiTietDonHang>> GetChiTietDonHangsAsync();
        Task<ChiTietDonHang> GetChiTietDonHangByIdAsync(int id);
        Task<IEnumerable<ChiTietDonHang>> GetChiTietDonHangByDonHangIdAsync(int donHangId); // Thêm dòng này
        Task AddChiTietDonHangAsync(ChiTietDonHang chiTietDonHang);
        Task UpdateChiTietDonHangAsync(ChiTietDonHang chiTietDonHang);
        Task DeleteChiTietDonHangAsync(int id);
    }
}
