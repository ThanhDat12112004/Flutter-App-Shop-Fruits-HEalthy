using System.Collections.Generic;
using System.Threading.Tasks;
using API_DBFruits.Models;  // Thay đổi tùy vào namespace của bạn

public interface IDanhMucSanPhamRepository
{
    Task<List<DanhMucSanPham>> GetAllDanhMucSanPhamsAsync();  // Lấy tất cả danh mục sản phẩm

    Task<DanhMucSanPham> GetDanhMucSanPhamByIdAsync(int id);  // Lấy danh mục sản phẩm theo ID

    Task CreateDanhMucSanPhamAsync(DanhMucSanPham danhMucSanPham);  // Thêm mới danh mục sản phẩm

    Task UpdateDanhMucSanPhamAsync(DanhMucSanPham danhMucSanPham);  // Cập nhật danh mục sản phẩm

    Task DeleteDanhMucSanPhamAsync(int id);  // Xóa danh mục sản phẩm
}
