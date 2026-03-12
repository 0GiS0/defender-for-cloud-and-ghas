using Microsoft.AspNetCore.Mvc;
using Azure.Storage.Blobs;
using SensitiveDataApi.Models;
using System.Data.SqlClient;
using Newtonsoft.Json;

namespace SensitiveDataApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CustomersController : ControllerBase
{
    private readonly ILogger<CustomersController> _logger;
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _environment;

    // INSECURE: Hardcoded connection string
    private const string BackupConnectionString = "DefaultEndpointsProtocol=https;AccountName=stvulnerabledemo;AccountKey=fake+demo+key+not+real+base64==;EndpointSuffix=core.windows.net";

    public CustomersController(ILogger<CustomersController> logger, IConfiguration configuration, IWebHostEnvironment environment)
    {
        _logger = logger;
        _configuration = configuration;
        _environment = environment;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        try
        {
            var customers = await LoadCustomersAsync();

            // INSECURE: Returns ALL sensitive data including SSN, DNI
            return Ok(customers);
        }
        catch (Exception ex)
        {
            // INSECURE: Exposes internal error details
            return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var customers = await LoadCustomersAsync();
        var customer = customers.FirstOrDefault(c => c.Id == id);

        if (customer == null)
            return NotFound();

        return Ok(customer);
    }

    // INSECURE: SQL Injection vulnerability
    [HttpGet("search")]
    public IActionResult Search([FromQuery] string query)
    {
        // INSECURE: Log injection - user input logged directly
        _logger.LogInformation("User searched for: " + query);

        try
        {
            // INSECURE: SQL Injection - string concatenation in query
            var sqlConnectionString = _configuration["ConnectionStrings:SqlDatabase"];
            using var connection = new SqlConnection(sqlConnectionString);
            connection.Open();

            var sqlQuery = "SELECT * FROM Customers WHERE FirstName LIKE '%" + query + "%' OR LastName LIKE '%" + query + "%' OR Email LIKE '%" + query + "%'";
            using var command = new SqlCommand(sqlQuery, connection);

            // Execute and return results
            using var reader = command.ExecuteReader();
            var results = new List<Customer>();
            while (reader.Read())
            {
                results.Add(new Customer
                {
                    Id = reader.GetInt32(0),
                    FirstName = reader.GetString(1),
                    LastName = reader.GetString(2),
                    Email = reader.GetString(3)
                });
            }

            return Ok(results);
        }
        catch (Exception ex)
        {
            // INSECURE: Full exception exposed
            return StatusCode(500, new { error = ex.ToString() });
        }
    }

    // INSECURE: Path traversal vulnerability
    [HttpGet("export/{filename}")]
    public IActionResult ExportData(string filename)
    {
        // INSECURE: No path validation - allows directory traversal
        var filePath = Path.Combine("/app/data", filename);

        if (!System.IO.File.Exists(filePath))
            return NotFound();

        return PhysicalFile(filePath, "application/octet-stream");
    }

    // INSECURE: Insecure deserialization
    [HttpPost("import")]
    public IActionResult ImportCustomers([FromBody] string jsonData)
    {
        // INSECURE: Deserializing with TypeNameHandling.All allows arbitrary type instantiation
        var settings = new JsonSerializerSettings
        {
            TypeNameHandling = TypeNameHandling.All
        };

        var customers = JsonConvert.DeserializeObject<List<Customer>>(jsonData, settings);
        return Ok(new { imported = customers?.Count ?? 0 });
    }

    private List<Customer> ParseCsv(string csvContent)
    {
        var customers = new List<Customer>();
        var lines = csvContent.Split('\n').Skip(1); // Skip header

        foreach (var line in lines)
        {
            if (string.IsNullOrWhiteSpace(line) || line.StartsWith("#")) continue;

            var fields = line.Split(',');
            if (fields.Length >= 12)
            {
                var cityIndex = fields.Length - 4;
                var address = string.Join(",", fields.Skip(7).Take(cityIndex - 7)).Trim();

                customers.Add(new Customer
                {
                    Id = int.TryParse(fields[0], out var id) ? id : 0,
                    FirstName = fields[1].Trim(),
                    LastName = fields[2].Trim(),
                    Email = fields[3].Trim(),
                    Phone = fields[4].Trim(),
                    Dni = fields[5].Trim(),
                    Ssn = fields[6].Trim(),
                    Address = address,
                    City = fields[cityIndex].Trim(),
                    Country = fields[cityIndex + 1].Trim(),
                    DateOfBirth = fields[cityIndex + 2].Trim(),
                    CreditScore = int.TryParse(fields[cityIndex + 3].Trim(), out var score) ? score : 0
                });
            }
        }

        return customers;
    }

    private async Task<List<Customer>> LoadCustomersAsync()
    {
        var localFilePath = GetLocalDataFilePath("customers.csv");
        if (localFilePath != null)
        {
            var csvContent = await System.IO.File.ReadAllTextAsync(localFilePath);
            return ParseCsv(csvContent);
        }

        return await GetCustomersFromStorageAsync();
    }

    private string? GetLocalDataFilePath(string fileName)
    {
        if (!_environment.IsDevelopment())
        {
            return null;
        }

        var configuredDataPath = _configuration["LocalDataPath"];
        var dataDirectory = string.IsNullOrWhiteSpace(configuredDataPath)
            ? Path.GetFullPath(Path.Combine(_environment.ContentRootPath, "..", "..", "data"))
            : Path.GetFullPath(Path.IsPathRooted(configuredDataPath)
                ? configuredDataPath
                : Path.Combine(_environment.ContentRootPath, configuredDataPath));

        var filePath = Path.Combine(dataDirectory, fileName);
        return System.IO.File.Exists(filePath) ? filePath : null;
    }

    private async Task<List<Customer>> GetCustomersFromStorageAsync()
    {
        var connectionString = _configuration["ConnectionStrings:StorageAccount"] ?? BackupConnectionString;
        var blobServiceClient = new BlobServiceClient(connectionString);
        var containerClient = blobServiceClient.GetBlobContainerClient("sensitive-data");
        var blobClient = containerClient.GetBlobClient("customers.csv");

        var response = await blobClient.DownloadAsync();
        using var reader = new StreamReader(response.Value.Content);
        var csvContent = await reader.ReadToEndAsync();
        return ParseCsv(csvContent);
    }
}
