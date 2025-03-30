using Microsoft.AspNetCore.Mvc;
using API_DBFruits.Models;  // Thay đổi tùy vào namespace của bạn
using Microsoft.EntityFrameworkCore;

namespace API_DBFruits.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DanhMucSanPhamApiController : ControllerBase
    {
        private readonly DbfruitsContext _context; // Sử dụng DbContext của bạn

        public DanhMucSanPhamApiController(DbfruitsContext context)
        {
            _context = context;
        }

        // GET: api/DanhMucSanPhamApi
        [HttpGet]
        public async Task<ActionResult<IEnumerable<DanhMucSanPham>>> GetDanhMucSanPhams()
        {
            return await _context.DanhMucSanPhams.ToListAsync();
        }

        // GET: api/DanhMucSanPhamApi/5
        [HttpGet("{id}")]
        public async Task<ActionResult<DanhMucSanPham>> GetDanhMucSanPham(int id)
        {
            var danhMucSanPham = await _context.DanhMucSanPhams.FindAsync(id);

            if (danhMucSanPham == null)
            {
                return NotFound();
            }

            return danhMucSanPham;
        }

        // POST: api/DanhMucSanPhamApi
        [HttpPost]
        public async Task<ActionResult<DanhMucSanPham>> PostDanhMucSanPham(DanhMucSanPham danhMucSanPham)
        {
            _context.DanhMucSanPhams.Add(danhMucSanPham);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetDanhMucSanPham", new { id = danhMucSanPham.DanhMucId }, danhMucSanPham);
        }

        // PUT: api/DanhMucSanPhamApi/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutDanhMucSanPham(int id, DanhMucSanPham danhMucSanPham)
        {
            if (id != danhMucSanPham.DanhMucId)
            {
                return BadRequest();
            }

            _context.Entry(danhMucSanPham).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/DanhMucSanPhamApi/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteDanhMucSanPham(int id)
        {
            var danhMucSanPham = await _context.DanhMucSanPhams.FindAsync(id);
            if (danhMucSanPham == null)
            {
                return NotFound();
            }

            _context.DanhMucSanPhams.Remove(danhMucSanPham);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
