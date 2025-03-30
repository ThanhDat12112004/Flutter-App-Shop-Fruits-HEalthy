using API_DBFruits.Models;
using API_DBFruits.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace API_DBFruits.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class GioHangController : ControllerBase
    {
        private readonly IGioHangRepository _repository;

        public GioHangController(IGioHangRepository repository)
        {
            _repository = repository;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<GioHang>>> GetGioHangs()
        {
            var gioHangs = await _repository.GetGioHangsAsync();
            return Ok(gioHangs);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<GioHang>> GetGioHangById(int id)
        {
            var gioHang = await _repository.GetGioHangByIdAsync(id);
            if (gioHang == null)
                return NotFound();
            return Ok(gioHang);
        }

        [HttpGet("ByKhachHangId/{khachHangId}")]
        public async Task<ActionResult<IEnumerable<GioHang>>> GetGioHangsByKhachHangId(string khachHangId)
        {
            var gioHangs = await _repository.GetGioHangsByKhachHangIdAsync(khachHangId);
            if (!gioHangs.Any())
                return NotFound(new { Message = "No carts found for this customer ID." });
            return Ok(gioHangs);
        }
        [HttpGet("KhachHangIdAndSanPhamId/{khachHangId}/{sanPhamId}")]
        public async Task<ActionResult<GioHang>> GetGioHangByKhachHangAndSanPham(string khachHangId, int sanPhamId)
        {
            var gioHang = await _repository.GetGioHangByKhachHangAndSanPhamAsync(khachHangId, sanPhamId);
            if (gioHang == null)
                return NotFound();
            return Ok(gioHang);
        }


        [HttpPost]
        public async Task<ActionResult> AddGioHang(GioHang gioHang)
        {
            await _repository.AddGioHangAsync(gioHang);
            return CreatedAtAction(nameof(GetGioHangById), new { id = gioHang.GioHangId }, gioHang);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateGioHang(int id, GioHang gioHang)
        {
            if (id != gioHang.GioHangId)
                return BadRequest();

            await _repository.UpdateGioHangAsync(gioHang);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteGioHang(int id)
        {
            await _repository.DeleteGioHangAsync(id);
            return NoContent();
        }
    }
}
