﻿using Fakebook.Entities;

namespace Fakebook.Interfaces;

public interface IUserService
{
    User CreateUser(User user);
    User GetUserById(string id);
    IReadOnlyCollection<User> GetAllUsers();

    void DeleteUserById(string user);
}

