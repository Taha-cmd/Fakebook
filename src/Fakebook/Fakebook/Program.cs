using Fakebook.Interfaces;
using Fakebook.IoCExtensions;
using Fakebook.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddScoped<IUserService, UserService>();

builder.Configuration.AddCustomAzureAppConfiguration(); // custom method
builder.Configuration.AddCustomAzureKeyVault(); // custom method
builder.Services.AddDatabase(builder.Configuration); // Custom method


var app = builder.Build();


app.UseSwagger();
app.UseSwaggerUI();

app.MapGet("/Users", (IUserService userService) => userService.GetAllUsers());

app.Run();

