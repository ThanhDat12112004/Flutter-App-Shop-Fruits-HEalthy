using API_DBFruits.Models;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace API_DBFruits.Repositories
{
    public class ChiTietDonHangRepository : IChiTietDonHangRepository
    {
        private readonly DbfruitsContext _context;

        public ChiTietDonHangRepository(DbfruitsContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<ChiTietDonHang>> GetChiTietDonHangsAsync()
        {
            return await _context.ChiTietDonHangs.ToListAsync();
        }

        public async Task<ChiTietDonHang> GetChiTietDonHangByIdAsync(int id)
        {
            return await _context.ChiTietDonHangs.FindAsync(id);
        }
        public async Task<IEnumerable<ChiTietDonHang>> GetChiTietDonHangByDonHangIdAsync(int donHangId)
        {
            return await _context.ChiTietDonHangs
                                 .Where(ct => ct.DonHangId == donHangId)
                                 .ToListAsync();
        }

        public async Task AddChiTietDonHangAsync(ChiTietDonHang chiTietDonHang)
        {
            _context.ChiTietDonHangs.Add(chiTietDonHang);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateChiTietDonHangAsync(ChiTietDonHang chiTietDonHang)
        {
            _context.Entry(chiTietDonHang).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public async Task DeleteChiTietDonHangAsync(int id)
        {
            var chiTietDonHang = await _context.ChiTietDonHangs.FindAsync(id);
            if (chiTietDonHang != null)
            {
                _context.ChiTietDonHangs.Remove(chiTietDonHang);
                await _context.SaveChangesAsync();
            }
        }
    }
}
