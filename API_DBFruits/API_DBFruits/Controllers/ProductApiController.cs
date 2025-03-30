using API_DBFruits.Models;
using API_DBFruits.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API_DBFruits.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductApiController : ControllerBase
    {
        private readonly IProductRepository _productRepository;
        public ProductApiController(IProductRepository productRepository)
        {
            _productRepository = productRepository;
        }
        [HttpGet("")]
        public async Task<ActionResult<IEnumerable<SanPham>>> GetProducts()
        {
            try
            {
                var products = await _productRepository.GetProductsAsync();
                return Ok(products);
            }
            catch (Exception ex)
            {
                // Handle exception
                return StatusCode(500, "Internal server error");
            }
        }
        [
        HttpGet("{id}")]
        public async Task<ActionResult<IEnumerable<SanPham>>> GetProductById(int id)
        {
            try
            {
                var product = await _productRepository.GetProductByIdAsync(id);
                if (product == null)
                    return NotFound();
                return Ok(product);
            }
            catch (Exception ex)
            {
                // Handle exception
                return StatusCode(500, "Internal server error");
            }
        }
        [HttpPost("")]
        public async Task<ActionResult<IEnumerable<SanPham>>> AddProduct([FromBody] SanPham product)
        {
            try
            {
                await _productRepository.AddProductAsync(product);
                return CreatedAtAction(nameof(GetProductById), new
                {
                    id = product.SanPhamId
                }, product);
            }
            catch (Exception ex)
            {
                // Handle exception
                return StatusCode(500, "Internal server error");
            }
        }
        [HttpPut("{id}")]
        public async Task<ActionResult<IEnumerable<SanPham>>> UpdateProduct(int id, [FromBody] SanPham product)
        {
            try
            {
                if (id != product.SanPhamId)
                    return BadRequest();
                await _productRepository.UpdateProductAsync(product);
                return NoContent();
            }
            catch (Exception ex)
            {
                // Handle exception
                return StatusCode(500, "Internal server error");
            }
        }
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            try
            {
                await _productRepository.DeleteProductAsync(id);
                return NoContent();
            }
            catch (Exception ex)
            {
                // Handle exception
                return StatusCode(500, "Internal server error");
            }
        }
    }

}
