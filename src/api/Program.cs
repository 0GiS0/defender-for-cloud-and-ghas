var builder = WebApplication.CreateBuilder(args);

var frontendOrigins = new[]
{
    "http://localhost:8080",
    "http://127.0.0.1:8080"
};

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// INSECURE: CORS allows local frontend origins without auth restrictions
builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendDev", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

// INSECURE: No HTTPS redirection
// INSECURE: No authentication/authorization middleware
app.UseCors("FrontendDev");
app.MapControllers();

app.Run();
