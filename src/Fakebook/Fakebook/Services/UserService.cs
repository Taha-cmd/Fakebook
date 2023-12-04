using Fakebook.Entities;
using Fakebook.Interfaces;

namespace Fakebook.Services;

public class UserService : IUserService
{
    private readonly FakebookDbContext _fakebookDbContext;
    private readonly ILogger<UserService> _logger;

    public UserService(ILogger<UserService> logger, FakebookDbContext fakebookDbContext)
    {
        _logger = logger;
        _fakebookDbContext = fakebookDbContext;
    }

    public User CreateUser(User user)
    {
        throw new NotImplementedException();
    }

    public User GetUserById(string id)
    {
        _logger.LogInformation("Get User with Id: {Id}", id);
        return _fakebookDbContext.Users.First(u => u.Id == id);
    }

    public IReadOnlyCollection<User> GetAllUsers()
    {
        _logger.LogInformation("Get All users");
        return _fakebookDbContext.Users.ToList();
    }

    public void DeleteUser(User user)
    {
        throw new NotImplementedException();
    }

    public void DeleteUserById(string user)
    {
        throw new NotImplementedException();
    }
}

