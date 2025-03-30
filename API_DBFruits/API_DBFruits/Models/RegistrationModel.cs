using System.ComponentModel.DataAnnotations;

namespace API_DBFruits.Models
{
    public class RegistrationModel
    {
        [Required]
        public string Username { get; set; } = string.Empty;
        [Required, EmailAddress]
        public string Email { get; set; } = string.Empty;
        [Required, Phone]
        public string PhoneNumber { get; set; } = string.Empty;
        [Required]
        public string TenKhachHang { get; set; } = null!;
        [Required]
        public string? DiaChi { get; set; }
        [Required, MinLength(6)]
        public string Password { get; set; } = string.Empty;
        [Required]
        public string? Initials { get; set; }
        //[Required]
        //public string? Role { get; set; }

    }
}
