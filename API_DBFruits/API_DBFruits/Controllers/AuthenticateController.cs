using API_DBFruits.Models;
using API_DBFruits.Repositories;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace API_DBFruits.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthenticateController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly RoleManager<IdentityRole> _roleManager;
        private readonly IConfiguration _configuration;
        private readonly IUserRepository _userRepository;

        public AuthenticateController(
            UserManager<User> userManager,
            RoleManager<IdentityRole> roleManager,
            IConfiguration configuration,
            IUserRepository userRepository)
        {
            _userManager = userManager;
            _roleManager = roleManager;
            _configuration = configuration;
            _userRepository = userRepository;
        }
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById(string id)
        {
            var user = await _userRepository.GetUserByIdAsync(id);
            if (user == null)
                return NotFound(new { Status = false, Message = "User not found" });

            return Ok(new { Status = true, Data = user });
        }
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(string id, [FromBody] User user)
        {
            if (id != user.Id)
                return BadRequest(new { Status = false, Message = "User ID mismatch" });

            var updated = await _userRepository.UpdateUserAsync(user);
            if (!updated)
                return StatusCode(StatusCodes.Status500InternalServerError, new { Status = false, Message = "Update failed" });

            return Ok(new { Status = true, Message = "User updated successfully" });
        }
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegistrationModel model)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userExists = await _userManager.Users
                  .FirstOrDefaultAsync(u => u.UserName == model.Username || u.PhoneNumber == model.PhoneNumber);

            if (userExists != null)
                return StatusCode(StatusCodes.Status400BadRequest, new { Status = false, Message = "User already exists" });

            var user = new User
            {
                TenKhachHang = model.TenKhachHang,
                PhoneNumber = model.PhoneNumber,
                DiaChi = model.DiaChi,
                UserName = model.Username,
                Email = model.Email,
                Initials = model.Initials
            };

            var result = await _userManager.CreateAsync(user, model.Password);
            if (!result.Succeeded)
                return StatusCode(StatusCodes.Status500InternalServerError, new { Status = false, Message = "User creation failed" });
    
                await _userManager.AddToRoleAsync(user, "User");

            return Ok(new { Status = true, Message = "User created successfully" });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginModel model)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            // Tìm user dựa trên Username hoặc PhoneNumber
            var user = await _userManager.Users
                .FirstOrDefaultAsync(u => u.UserName == model.Username || u.PhoneNumber == model.Username);

            if (user == null || !await _userManager.CheckPasswordAsync(user, model.Password))
                return Unauthorized(new { Status = false, Message = "Invalid username or password" });

            // Lấy các role của user
            var userRoles = await _userManager.GetRolesAsync(user);


            var authClaims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, user.UserName),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim("UserId", user.Id),
                new Claim("DiaChi", user.DiaChi),
                new Claim("SoDienThoai", user.PhoneNumber),
                new Claim("Email", user.Email),
                new Claim("TenKhachHang", user.TenKhachHang)

            };
            foreach (var userRole in userRoles)
            {
                authClaims.Add(new Claim(ClaimTypes.Role, userRole));
            }

            // Tạo JWT token
            var token = GenerateToken(authClaims);

            return Ok(new { Status = true, Message = "Logged in successfully", Token = token });
        }



        private string GenerateToken(IEnumerable<Claim> claims)
        {
            var jwtSettings = _configuration.GetSection("JWTKey");
            var authSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["Secret"]));

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddHours(Convert.ToDouble(jwtSettings["TokenExpiryTimeInHour"])),
                Issuer = jwtSettings["ValidIssuer"],
                Audience = jwtSettings["ValidAudience"],
                SigningCredentials = new SigningCredentials(authSigningKey, SecurityAlgorithms.HmacSha256)
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }

}
