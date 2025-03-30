using API_DBFruits.Models;
using Microsoft.EntityFrameworkCore;

namespace API_DBFruits.Repositories
{
    public class GioHangRepository : IGioHangRepository
    {
        private readonly DbfruitsContext _context;

        public GioHangRepository(DbfruitsContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<GioHang>> GetGioHangsAsync()
        {
            return await _context.GioHangs.ToListAsync();
        }

        public async Task<GioHang?> GetGioHangByIdAsync(int id)
        {
            return await _context.GioHangs.FindAsync(id);
        }

        public async Task<IEnumerable<GioHang>> GetGioHangsByKhachHangIdAsync(string khachHangId)
        {
            return await _context.GioHangs
                .Where(g => g.KhachHangId == khachHangId)
                .ToListAsync();

        }
        public async Task<GioHang?> GetGioHangByKhachHangAndSanPhamAsync(string khachHangId, int sanPhamId)
        {
            return await _context.GioHangs
                .FirstOrDefaultAsync(g => g.KhachHangId == khachHangId && g.SanPhamId == sanPhamId);
        }

        public async Task AddGioHangAsync(GioHang gioHang)
        {
            _context.GioHangs.Add(gioHang);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateGioHangAsync(GioHang gioHang)
        {
            _context.Entry(gioHang).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public async Task DeleteGioHangAsync(int id)
        {
            var gioHang = await _context.GioHangs.FindAsync(id);
            if (gioHang != null)
            {
                _context.GioHangs.Remove(gioHang);
                await _context.SaveChangesAsync();
            }
        }
    }
}
