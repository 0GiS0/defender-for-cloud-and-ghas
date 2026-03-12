namespace SensitiveDataApi.Models;

public class Transaction
{
    public string TransactionId { get; set; }
    public int CustomerId { get; set; }
    public string CardNumber { get; set; }
    public string CardHolderName { get; set; }
    public string Cvv { get; set; }
    public string ExpiryDate { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; }
    public string MerchantName { get; set; }
    public string Timestamp { get; set; }
    public string Status { get; set; }
    public string BillingAddress { get; set; }
    public string IpAddress { get; set; }
}

public class TransactionWrapper
{
    public string Warning { get; set; }
    public List<Transaction> Transactions { get; set; }
}
