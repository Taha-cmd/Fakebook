using Fakebook.Entities;
using Fakebook.Interfaces;
using Microsoft.Extensions.Caching.Distributed;
using System.Text.Json;

namespace Fakebook.Services;

public class UserService : IUserService
{
    private readonly FakebookDbContext _fakebookDbContext;
    private readonly ILogger<UserService> _logger;
    private readonly IFakebookCache _cache;

    public UserService(ILogger<UserService> logger, FakebookDbContext fakebookDbContext, IFakebookCache cache)
    {
        _logger = logger;
        _fakebookDbContext = fakebookDbContext;
        _cache = cache;
    }

    public User CreateUser(User user)
    {
        _logger.LogInformation("Create user {user}", user.Id);

        // Add user to db
        _fakebookDbContext.Users.Add(user);
        _fakebookDbContext.SaveChanges();

        return GetUserById(user.Id)!;
    }

    public User? GetUserById(string id)
    {
        _logger.LogInformation("Get User with Id: {Id}", id);

        // See if user is in cache, else get from db and cache it

        if (_cache.Exists(id))
        {
            return _cache.Get<User>(id);
        }

        var user = _fakebookDbContext.Users.FirstOrDefault(u => u.Id == id);

        if(user is not null) 
        {
            return _cache.Set<User>(id, user);
        }

        return null;
    }

    public IReadOnlyCollection<User> GetAllUsers()
    {
        _logger.LogInformation("Get All users");
        return _fakebookDbContext.Users.ToList();
    }

    public void DeleteUserById(string id)
    {
        _logger.LogInformation("Delete user with id {id}", id);

        var user = GetUserById(id);
        _fakebookDbContext.Users.Remove(user);
        _fakebookDbContext.SaveChanges();
        _cache.Remove(id);
    }
}

