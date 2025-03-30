using API_DBFruits.Models;
using Microsoft.EntityFrameworkCore;

namespace API_DBFruits.Repositories
{
    public class DonHangRepository : IDonHangRepository
    {
        private readonly DbfruitsContext _context;

        public DonHangRepository(DbfruitsContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<DonHang>> GetDonHangsAsync()
        {
            return await _context.DonHangs.ToListAsync();
        }

        public async Task<DonHang> GetDonHangByIdAsync(int id)
        {
            return await _context.DonHangs.FindAsync(id);
        }
        public async Task<IEnumerable<DonHang>> GetDonHangsByKhachHangIdAsync(string khachHangId)
        {
            return await _context.DonHangs
                .Where(d => d.KhachHangId == khachHangId)
                .ToListAsync();
        }
        public async Task AddDonHangAsync(DonHang donHang)
        {
            _context.DonHangs.Add(donHang);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateDonHangAsync(DonHang donHang)
        {
            _context.Entry(donHang).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public async Task DeleteDonHangAsync(int id)
        {
            var donHang = await _context.DonHangs.FindAsync(id);
            if (donHang != null)
            {
                _context.DonHangs.Remove(donHang);
                await _context.SaveChangesAsync();
            }
        }
    }
}
