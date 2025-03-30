using API_DBFruits.Models;
using Microsoft.EntityFrameworkCore;

namespace API_DBFruits.Repositories
{
    public class ProductRepository : IProductRepository
    {
        private readonly DbfruitsContext _context;

        public ProductRepository(DbfruitsContext context)
        {
            _context = context;
        }
        public async Task<IEnumerable<SanPham>> GetProductsAsync()
        {
            return await _context.SanPhams.ToListAsync();
        }
        public async Task<SanPham> GetProductByIdAsync(int id)
        {
            return await _context.SanPhams.FindAsync(id);
        }
        public async Task AddProductAsync(SanPham sanpham)
        {
            _context.SanPhams.Add(sanpham);
            await _context.SaveChangesAsync();
        }
        public async Task UpdateProductAsync(SanPham sanpham)
        {
            _context.Entry(sanpham).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }
        public async Task DeleteProductAsync(int id)
        {
            var sanpham = await _context.SanPhams.FindAsync(id);
            if (sanpham != null)
            {
                _context.SanPhams.Remove(sanpham);
                await _context.SaveChangesAsync();
            }
        }
    }

}
