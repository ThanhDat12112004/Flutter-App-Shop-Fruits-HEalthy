using API_DBFruits.Models;
using Microsoft.EntityFrameworkCore;

namespace API_DBFruits.Repositories
{
    public class DanhMucYeuThichRepository : IDanhMucYeuThichRepository
    {
        private readonly DbfruitsContext _context;

        public DanhMucYeuThichRepository(DbfruitsContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<DanhMucYeuThich>> GetDanhMucsAsync()
        {
            return await _context.DanhMucYeuThiches.ToListAsync();
        }

        public async Task<DanhMucYeuThich?> GetDanhMucByIdAsync(int id)
        {
            return await _context.DanhMucYeuThiches.FindAsync(id);
        }
        public async Task<IEnumerable<DanhMucYeuThich>> GetDanhMucsByKhachHangIdAsync(string khachHangId)
        {
            return await _context.DanhMucYeuThiches
               .Where(d => d.KhachHangId == khachHangId)
               .ToListAsync();
        }
        public async Task<IEnumerable<DanhMucYeuThich>> GetDanhMucsByKhachHangAndSanPhamAsync(string khachHangId, int sanPhamId)
        {
            return await _context.DanhMucYeuThiches
              .Where(d => d.KhachHangId == khachHangId && d.SanPhamId == sanPhamId)
              .ToListAsync();
        }

        public async Task AddDanhMucAsync(DanhMucYeuThich danhMuc)
        {
            _context.DanhMucYeuThiches.Add(danhMuc);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateDanhMucAsync(DanhMucYeuThich danhMuc)
        {
            _context.Entry(danhMuc).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public async Task DeleteDanhMucAsync(int id)
        {
            var danhMuc = await _context.DanhMucYeuThiches.FindAsync(id);
            if (danhMuc != null)
            {
                _context.DanhMucYeuThiches.Remove(danhMuc);
                await _context.SaveChangesAsync();
            }
        }
    }
}
