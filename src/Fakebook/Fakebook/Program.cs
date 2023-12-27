using Fakebook.Entities;
using Fakebook.Interfaces;
using Fakebook.IoCExtensions;
using Fakebook.Services;

var builder = WebApplication.CreateBuilder(args);

Console.WriteLine("Hello world");

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IFakebookCache, FakebookCache>();

builder.Configuration.AddCustomAzureAppConfiguration(); // custom method
builder.Configuration.AddCustomAzureKeyVault(); // custom method
builder.Services.AddDatabase(builder.Configuration); // custom method
builder.Services.AddRedisCache(builder.Configuration); // custom method

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();


var usersEndpoint = app.MapGroup("/Users")
    .WithName("Users")
    .WithOpenApi();

usersEndpoint
    .MapGet("/", (IUserService userService) => userService.GetAllUsers())
    .WithName(nameof(IUserService.GetAllUsers));

usersEndpoint
    .MapGet("/{id}", (IUserService userService, string id) => 
    {
        var user = userService.GetUserById(id);

        return user is null ? Results.NotFound() : Results.Ok(user);
    })
    .WithName(nameof(IUserService.GetUserById));

usersEndpoint.MapPost("/", (IUserService userService, User user) =>
{
    var createdUser = userService.CreateUser(user);
    return Results.Created($"/Users/{createdUser.Id}", createdUser);
})
    .WithName(nameof(IUserService.CreateUser));

usersEndpoint
    .MapDelete("/{id}", (IUserService userService, string id) => userService.DeleteUserById(id))
    .WithName(nameof(IUserService.DeleteUserById));

app.Run();

