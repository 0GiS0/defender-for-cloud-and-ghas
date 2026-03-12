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

    // INSECURE: Hardcoded connection string
    private const string BackupConnectionString = "DefaultEndpointsProtocol=https;AccountName=stvulnerabledemo;AccountKey=fake+demo+key+not+real+base64==;EndpointSuffix=core.windows.net";

    public CustomersController(ILogger<CustomersController> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        try
        {
            var connectionString = _configuration["ConnectionStrings:StorageAccount"] ?? BackupConnectionString;
            var blobServiceClient = new BlobServiceClient(connectionString);
            var containerClient = blobServiceClient.GetBlobContainerClient("sensitive-data");
            var blobClient = containerClient.GetBlobClient("customers.csv");

            var response = await blobClient.DownloadContentAsync();
            var csvContent = response.Value.Content.ToString();

            var customers = ParseCsv(csvContent);

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
        var customers = await GetCustomersFromStorage();
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
                customers.Add(new Customer
                {
                    Id = int.TryParse(fields[0], out var id) ? id : 0,
                    FirstName = fields[1],
                    LastName = fields[2],
                    Email = fields[3],
                    Phone = fields[4],
                    Dni = fields[5],
                    Ssn = fields[6],
                    Address = fields[7],
                    City = fields[8],
                    Country = fields[9],
                    DateOfBirth = fields[10],
                    CreditScore = int.TryParse(fields[11].Trim(), out var score) ? score : 0
                });
            }
        }

        return customers;
    }

    private async Task<List<Customer>> GetCustomersFromStorage()
    {
        var connectionString = _configuration["ConnectionStrings:StorageAccount"] ?? BackupConnectionString;
        var blobServiceClient = new BlobServiceClient(connectionString);
        var containerClient = blobServiceClient.GetBlobContainerClient("sensitive-data");
        var blobClient = containerClient.GetBlobClient("customers.csv");

        var response = await blobClient.DownloadContentAsync();
        return ParseCsv(response.Value.Content.ToString());
    }
}
