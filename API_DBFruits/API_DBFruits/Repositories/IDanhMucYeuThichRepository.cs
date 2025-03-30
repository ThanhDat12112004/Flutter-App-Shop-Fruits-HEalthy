using API_DBFruits.Models;

namespace API_DBFruits.Repositories
{
    public interface IDanhMucYeuThichRepository
    {
        Task<IEnumerable<DanhMucYeuThich>> GetDanhMucsAsync();
        Task<DanhMucYeuThich?> GetDanhMucByIdAsync(int id);
        Task<IEnumerable<DanhMucYeuThich>> GetDanhMucsByKhachHangIdAsync(string khachHangId);
        Task<IEnumerable<DanhMucYeuThich>> GetDanhMucsByKhachHangAndSanPhamAsync(string khachHangId, int sanPhamId); // Add this line

        Task AddDanhMucAsync(DanhMucYeuThich danhMuc);
        Task UpdateDanhMucAsync(DanhMucYeuThich danhMuc);
        Task DeleteDanhMucAsync(int id);
    }
}
