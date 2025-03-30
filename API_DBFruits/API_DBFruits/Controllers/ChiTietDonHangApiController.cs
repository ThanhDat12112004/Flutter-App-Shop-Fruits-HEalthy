using API_DBFruits.Models;
using API_DBFruits.Repositories;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace API_DBFruits.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChiTietDonHangApiController : ControllerBase
    {
        private readonly IChiTietDonHangRepository _chiTietDonHangRepository;

        public ChiTietDonHangApiController(IChiTietDonHangRepository chiTietDonHangRepository)
        {
            _chiTietDonHangRepository = chiTietDonHangRepository;
        }

        // Lấy danh sách chi tiết đơn hàng
        [HttpGet("")]
        public async Task<ActionResult<IEnumerable<ChiTietDonHang>>> GetChiTietDonHangs()
        {
            try
            {
                var chiTietDonHangs = await _chiTietDonHangRepository.GetChiTietDonHangsAsync();
                return Ok(chiTietDonHangs);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // Lấy chi tiết đơn hàng theo ID
        [HttpGet("{id}")]
        public async Task<ActionResult<ChiTietDonHang>> GetChiTietDonHangById(int id)
        {
            try
            {
                var chiTietDonHang = await _chiTietDonHangRepository.GetChiTietDonHangByIdAsync(id);
                if (chiTietDonHang == null)
                    return NotFound();
                return Ok(chiTietDonHang);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("donhang/{donHangId}")]
        public async Task<ActionResult<IEnumerable<ChiTietDonHang>>> GetChiTietDonHangByDonHangId(int donHangId)
        {
            try
            {
                var chiTietDonHangs = await _chiTietDonHangRepository.GetChiTietDonHangByDonHangIdAsync(donHangId);
                if (chiTietDonHangs == null)
                    return NotFound();
                return Ok(chiTietDonHangs);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // Thêm mới chi tiết đơn hàng
        [HttpPost("")]
        public async Task<ActionResult<IEnumerable<ChiTietDonHang>>> AddChiTietDonHang([FromBody] ChiTietDonHang chiTietDonHang)
        {
            try
            {
                await _chiTietDonHangRepository.AddChiTietDonHangAsync(chiTietDonHang);
                return CreatedAtAction(nameof(GetChiTietDonHangById), new { id = chiTietDonHang.ChiTietDonHangId }, chiTietDonHang);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error");
            }
                
        }

        // Cập nhật chi tiết đơn hàng
        [HttpPut("{id}")]
        public async Task<ActionResult> UpdateChiTietDonHang(int id, [FromBody] ChiTietDonHang chiTietDonHang)
        {
            try
            {
                if (id != chiTietDonHang.ChiTietDonHangId)
                    return BadRequest();

                await _chiTietDonHangRepository.UpdateChiTietDonHangAsync(chiTietDonHang);
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // Xóa chi tiết đơn hàng
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteChiTietDonHang(int id)
        {
            try
            {
                await _chiTietDonHangRepository.DeleteChiTietDonHangAsync(id);
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
