namespace SensitiveDataApi.Models;

public class Customer
{
    public int Id { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Email { get; set; }
    public string Phone { get; set; }
    public string Dni { get; set; }
    public string Ssn { get; set; }
    public string Address { get; set; }
    public string City { get; set; }
    public string Country { get; set; }
    public string DateOfBirth { get; set; }
    public int CreditScore { get; set; }
}
