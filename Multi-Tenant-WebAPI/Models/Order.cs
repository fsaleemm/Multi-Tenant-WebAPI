namespace AppServiceAPI.Models
{
    public class Order
    {
        public DateTime Date { get; set; }

        public int OrderId { get; set; }

        public string? TenantId { get; set; }

        public string? OrderDetail { get; set; }
    }
}
