using API_DBFruits.Models;

namespace API_DBFruits.Repositories
{
    public interface IProductRepository
    {
        Task<IEnumerable<SanPham>> GetProductsAsync();
        Task<SanPham> GetProductByIdAsync(int id);
        Task AddProductAsync(SanPham sanpham);
        Task UpdateProductAsync(SanPham sanpham);
        Task DeleteProductAsync(int id);
    }

}
