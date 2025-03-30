using API_DBFruits.Models;
using API_DBFruits.Repositories;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace API_DBFruits.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DonHangApiController : ControllerBase
    {
        private readonly IDonHangRepository _donHangRepository;

        public DonHangApiController(IDonHangRepository donHangRepository)
        {
            _donHangRepository = donHangRepository;
        }

        // Lấy danh sách đơn hàng
        [HttpGet("")]
        public async Task<ActionResult<IEnumerable<DonHang>>> GetDonHangs()
        {
            try
            {
                var donHangs = await _donHangRepository.GetDonHangsAsync();
                return Ok(donHangs);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // Lấy đơn hàng theo ID
        [HttpGet("{id}")]
        public async Task<ActionResult<DonHang>> GetDonHangById(int id)
        {
            try
            {
                var donHang = await _donHangRepository.GetDonHangByIdAsync(id);
                if (donHang == null)
                    return NotFound();
                return Ok(donHang);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("khachhang/{khachHangId}")]
        public async Task<ActionResult<IEnumerable<DonHang>>> GetDonHangsByKhachHangId(string khachHangId)
        {
            var donHangs = await _donHangRepository.GetDonHangsByKhachHangIdAsync(khachHangId);
            if (donHangs == null || !donHangs.Any())
            {
                return NotFound();
            }
            return Ok(donHangs);
        }

        // Thêm mới đơn hàng
        [HttpPost("")]
        public async Task<ActionResult<IEnumerable<DonHang>>> AddDonHang([FromBody] DonHang donHang)
        {
            try
            {
                await _donHangRepository.AddDonHangAsync(donHang);
                return CreatedAtAction(nameof(GetDonHangById), new { id = donHang.DonHangId }, donHang);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // Cập nhật đơn hàng
        [HttpPut("{id}")]
        public async Task<ActionResult> UpdateDonHang(int id, [FromBody] DonHang donHang)
        {
            try
            {
                if (id != donHang.DonHangId)
                    return BadRequest();

                await _donHangRepository.UpdateDonHangAsync(donHang);
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // Xóa đơn hàng
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteDonHang(int id)
        {
            try
            {
                await _donHangRepository.DeleteDonHangAsync(id);
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
