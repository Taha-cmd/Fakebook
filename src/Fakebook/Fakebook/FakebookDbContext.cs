using Fakebook.Entities;
using Microsoft.EntityFrameworkCore;

namespace Fakebook;

public class FakebookDbContext : DbContext
{
    public FakebookDbContext(DbContextOptions<FakebookDbContext> options) : base(options)
    {
        Database.EnsureCreated();
    }

    public DbSet<User> Users { get; set; }
}

