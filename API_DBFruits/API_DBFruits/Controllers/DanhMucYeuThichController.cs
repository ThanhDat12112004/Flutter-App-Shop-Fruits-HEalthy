using API_DBFruits.Models;
using API_DBFruits.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace API_DBFruits.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DanhMucYeuThichController : ControllerBase
    {
        private readonly IDanhMucYeuThichRepository _repository;

        public DanhMucYeuThichController(IDanhMucYeuThichRepository repository)
        {
            _repository = repository;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<DanhMucYeuThich>>> GetDanhMucs()
        {
            var danhMucs = await _repository.GetDanhMucsAsync();
            return Ok(danhMucs);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<DanhMucYeuThich>> GetDanhMucById(int id)
        {
            var danhMuc = await _repository.GetDanhMucByIdAsync(id);
            if (danhMuc == null)
                return NotFound();
            return Ok(danhMuc);
        }
        [HttpGet("ByKhachHangId/{khachHangId}")]
        public async Task<ActionResult<IEnumerable<DanhMucYeuThich>>> GetDanhMucsByKhachHangId(string khachHangId)
        {
            var danhMucs = await _repository.GetDanhMucsByKhachHangIdAsync(khachHangId);
            if (!danhMucs.Any())
                return NotFound(new { Message = "No favorite categories found for this customer ID." });
            return Ok(danhMucs);
        }
        [HttpGet("KhachHangIdAndSanPhamId/{khachHangId}/{sanPhamId}")]
        public async Task<ActionResult<IEnumerable<DanhMucYeuThich>>> GetDanhMucsByKhachHangAndSanPham(string khachHangId, int sanPhamId)
        {
            var danhMucs = await _repository.GetDanhMucsByKhachHangAndSanPhamAsync(khachHangId,sanPhamId);
            if (!danhMucs.Any())
                return NotFound(new { Message = "No favorite categories found for this customer ID." });
            return Ok(danhMucs);
        }



        [HttpPost]
        public async Task<ActionResult> AddDanhMuc(DanhMucYeuThich danhMuc)
        {
            await _repository.AddDanhMucAsync(danhMuc);
            return CreatedAtAction(nameof(GetDanhMucById), new { id = danhMuc.DanhMucYeuThichId }, danhMuc);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateDanhMuc(int id, DanhMucYeuThich danhMuc)
        {
            if (id != danhMuc.DanhMucYeuThichId)
                return BadRequest();

            await _repository.UpdateDanhMucAsync(danhMuc);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteDanhMuc(int id)
        {
            await _repository.DeleteDanhMucAsync(id);
            return NoContent();
        }
    }
}
