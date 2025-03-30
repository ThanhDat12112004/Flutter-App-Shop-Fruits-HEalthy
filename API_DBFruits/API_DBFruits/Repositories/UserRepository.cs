using API_DBFruits.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace API_DBFruits.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly UserManager<User> _userManager;

        public UserRepository(UserManager<User> userManager)
        {
            _userManager = userManager;
        }

        public async Task<User> GetUserByIdAsync(string id)
        {
            return await _userManager.Users.FirstOrDefaultAsync(u => u.Id == id);
        }

        public async Task<bool> UpdateUserAsync(User user)
        {
            var existingUser = await _userManager.FindByIdAsync(user.Id);
            if (existingUser == null) return false;

            existingUser.TenKhachHang = user.TenKhachHang;
            existingUser.PhoneNumber = user.PhoneNumber;
            existingUser.DiaChi = user.DiaChi;
            existingUser.Email = user.Email;
            existingUser.Initials = user.Initials;

            var result = await _userManager.UpdateAsync(existingUser);
            return result.Succeeded;
        }
    }

}
