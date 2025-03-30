using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using API_DBFruits.Models;  // Thay đổi tùy vào namespace của bạn

public class DanhMucSanPhamRepository : IDanhMucSanPhamRepository
{
    private readonly DbfruitsContext _context;  // DbContext của bạn

    public DanhMucSanPhamRepository(DbfruitsContext context)
    {
        _context = context;
    }

    // Lấy tất cả danh mục sản phẩm
    public async Task<List<DanhMucSanPham>> GetAllDanhMucSanPhamsAsync()
    {
        return await _context.DanhMucSanPhams.ToListAsync();
    }

    // Lấy danh mục sản phẩm theo ID
    public async Task<DanhMucSanPham> GetDanhMucSanPhamByIdAsync(int id)
    {
        return await _context.DanhMucSanPhams.FindAsync(id);
    }

    // Thêm mới danh mục sản phẩm
    public async Task CreateDanhMucSanPhamAsync(DanhMucSanPham danhMucSanPham)
    {
        _context.DanhMucSanPhams.Add(danhMucSanPham);
        await _context.SaveChangesAsync();
    }

    // Cập nhật danh mục sản phẩm
    public async Task UpdateDanhMucSanPhamAsync(DanhMucSanPham danhMucSanPham)
    {
        _context.Entry(danhMucSanPham).State = EntityState.Modified;
        await _context.SaveChangesAsync();
    }

    // Xóa danh mục sản phẩm
    public async Task DeleteDanhMucSanPhamAsync(int id)
    {
        var danhMucSanPham = await _context.DanhMucSanPhams.FindAsync(id);
        if (danhMucSanPham != null)
        {
            _context.DanhMucSanPhams.Remove(danhMucSanPham);
            await _context.SaveChangesAsync();
        }
    }
}
