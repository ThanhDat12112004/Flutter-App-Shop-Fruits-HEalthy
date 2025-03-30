using API_DBFruits.Models;

namespace API_DBFruits.Repositories
{
    public interface IUserRepository
    {
        Task<User> GetUserByIdAsync(string id);
        Task<bool> UpdateUserAsync(User user);
    }

}
