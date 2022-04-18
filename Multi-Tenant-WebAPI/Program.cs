using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Azure.AppConfiguration.AspNetCore;

var builder = WebApplication.CreateBuilder(args);


// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddAzureAppConfiguration();


//Retrieve the Connection String from the secrets manager
var appConfigConnectionString = builder.Configuration.GetConnectionString("AppConfig");

builder.Host.ConfigureAppConfiguration(builder =>
{
    //Connect to your App Config Store using the connection string
    builder.AddAzureAppConfiguration(options =>
    {
        options.Connect(appConfigConnectionString)
        //Configure Refresh Sentinel key to trigger reload of configurations
        .ConfigureRefresh(refresh =>
        {
            refresh.Register("AppServiceAPI:Settings:Sentinel", refreshAll: true);
            //.SetCacheExpiration(new TimeSpan(0, 5, 0));
        })
        //Configure use of Key Vault reference in Azure App Configuration Service
        .ConfigureKeyVault(kv =>
        {
            kv.SetCredential(new DefaultAzureCredential());
        });
    });
});


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAzureAppConfiguration();

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
