using Microsoft.AspNetCore.Mvc;
using Azure.Storage.Blobs;
using SensitiveDataApi.Models;
using System.Data.SqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace SensitiveDataApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TransactionsController : ControllerBase
{
    private readonly ILogger<TransactionsController> _logger;
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _environment;

    // INSECURE: Hardcoded API key
    private const string HardcodedApiKey = "sk-demo-fake-api-key-1234567890abcdef";

    // INSECURE: Hardcoded connection string
    private const string BackupConnectionString = "DefaultEndpointsProtocol=https;AccountName=stvulnerabledemo;AccountKey=fake+demo+key+not+real+base64==;EndpointSuffix=core.windows.net";

    public TransactionsController(ILogger<TransactionsController> logger, IConfiguration configuration, IWebHostEnvironment environment)
    {
        _logger = logger;
        _configuration = configuration;
        _environment = environment;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromHeader(Name = "X-Api-Key")] string apiKey)
    {
        // INSECURE: Hardcoded API key comparison
        if (apiKey != HardcodedApiKey)
        {
            return Unauthorized(new { error = "Invalid API key" });
        }

        try
        {
            var wrapper = await LoadTransactionsWrapperAsync();

            // INSECURE: Returns full card numbers and CVVs without masking
            return Ok(wrapper);
        }
        catch (Exception ex)
        {
            // INSECURE: Exposes internal error details
            return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace, source = ex.Source });
        }
    }

    [HttpGet("{transactionId}")]
    public async Task<IActionResult> GetById(string transactionId, [FromHeader(Name = "X-Api-Key")] string apiKey)
    {
        if (apiKey != HardcodedApiKey)
        {
            return Unauthorized(new { error = "Invalid API key" });
        }

        var transactions = await LoadTransactionsAsync();
        var transaction = transactions.FirstOrDefault(t => t.TransactionId == transactionId);

        if (transaction == null)
            return NotFound();

        // INSECURE: Returns full card number and CVV
        return Ok(transaction);
    }

    // INSECURE: SQL Injection vulnerability
    [HttpGet("search")]
    public IActionResult Search([FromQuery] string query, [FromQuery] string status)
    {
        // INSECURE: Log injection - user input logged directly
        _logger.LogInformation("Transaction search - query: " + query + ", status: " + status);

        try
        {
            var sqlConnectionString = _configuration["ConnectionStrings:SqlDatabase"];
            using var connection = new SqlConnection(sqlConnectionString);
            connection.Open();

            // INSECURE: SQL Injection - string concatenation
            var sqlQuery = "SELECT * FROM Transactions WHERE MerchantName LIKE '%" + query + "%'";
            if (!string.IsNullOrEmpty(status))
            {
                sqlQuery += " AND Status = '" + status + "'";
            }

            using var command = new SqlCommand(sqlQuery, connection);
            using var reader = command.ExecuteReader();
            var results = new List<Transaction>();

            while (reader.Read())
            {
                results.Add(new Transaction
                {
                    TransactionId = reader.GetString(0),
                    CustomerId = reader.GetInt32(1),
                    CardNumber = reader.GetString(2),
                    Amount = reader.GetDecimal(3),
                    Status = reader.GetString(4)
                });
            }

            return Ok(results);
        }
        catch (Exception ex)
        {
            // INSECURE: Full exception exposed including connection string details
            return StatusCode(500, new { error = ex.ToString() });
        }
    }

    [HttpGet("by-customer/{customerId}")]
    public async Task<IActionResult> GetByCustomer(int customerId)
    {
        // INSECURE: No authentication required for this endpoint
        var transactions = await LoadTransactionsAsync();
        var customerTransactions = transactions.Where(t => t.CustomerId == customerId).ToList();

        // INSECURE: Returns full card details without masking
        return Ok(customerTransactions);
    }

    // INSECURE: Insecure deserialization endpoint
    [HttpPost("import")]
    public IActionResult ImportTransactions([FromBody] string jsonData)
    {
        // INSECURE: Log injection
        _logger.LogInformation("Importing transactions: " + jsonData);

        // INSECURE: Deserializing with TypeNameHandling.All allows arbitrary type instantiation
        var settings = new JsonSerializerSettings
        {
            TypeNameHandling = TypeNameHandling.All
        };

        var transactions = JsonConvert.DeserializeObject<List<Transaction>>(jsonData, settings);
        return Ok(new { imported = transactions?.Count ?? 0, message = "Transactions imported successfully" });
    }

    // INSECURE: Path traversal vulnerability
    [HttpGet("report/{filename}")]
    public IActionResult GetReport(string filename)
    {
        // INSECURE: No path validation - allows directory traversal
        var filePath = Path.Combine("/app/reports", filename);

        if (!System.IO.File.Exists(filePath))
            return NotFound();

        var content = System.IO.File.ReadAllText(filePath);
        return Ok(new { filename = filename, content = content });
    }

    private async Task<List<Transaction>> LoadTransactionsAsync()
    {
        var wrapper = await LoadTransactionsWrapperAsync();
        return wrapper?.Transactions ?? new List<Transaction>();
    }

    private async Task<TransactionWrapper?> LoadTransactionsWrapperAsync()
    {
        var localFilePath = GetLocalDataFilePath("transactions.json");
        if (localFilePath != null)
        {
            var jsonContent = await System.IO.File.ReadAllTextAsync(localFilePath);

            var localSettings = new JsonSerializerSettings
            {
                TypeNameHandling = TypeNameHandling.All,
                ContractResolver = new DefaultContractResolver
                {
                    NamingStrategy = new SnakeCaseNamingStrategy()
                }
            };

            return JsonConvert.DeserializeObject<TransactionWrapper>(jsonContent, localSettings);
        }

        return await GetTransactionsFromStorageAsync();
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

    private async Task<TransactionWrapper?> GetTransactionsFromStorageAsync()
    {
        var connectionString = _configuration["ConnectionStrings:StorageAccount"] ?? BackupConnectionString;
        var blobServiceClient = new BlobServiceClient(connectionString);
        var containerClient = blobServiceClient.GetBlobContainerClient("sensitive-data");
        var blobClient = containerClient.GetBlobClient("transactions.json");

        var response = await blobClient.DownloadAsync();
        using var reader = new StreamReader(response.Value.Content);
        var jsonContent = await reader.ReadToEndAsync();

        var settings = new JsonSerializerSettings
        {
            TypeNameHandling = TypeNameHandling.All
        };
        var wrapper = JsonConvert.DeserializeObject<TransactionWrapper>(jsonContent, settings);
        return wrapper;
    }
}
