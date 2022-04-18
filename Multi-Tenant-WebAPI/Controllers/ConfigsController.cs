using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using AppServiceAPI.Models;

namespace AppServiceAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ConfigsController : ControllerBase
    {
        private readonly ILogger<ConfigsController> _logger;
        private readonly IConfiguration Configuration;

        public ConfigsController(ILogger<ConfigsController> logger, IConfiguration configuration)
        {
            _logger = logger;
            Configuration = configuration;
        }

        [HttpGet]
        [Route("Ping")]
        public string Ping()
        {
            return "Pong";
        }

        [HttpPost]
        [Route("Customer/Order")]
        public OrderStatus SubmitOrder( Order myOrder)
        {
            return new OrderStatus
            {
                Status = "Submitted for customer id : " + Configuration[myOrder.TenantId + ":Settings:CustomerId"],
                OrderDetail = myOrder.OrderDetail,
                CustomerName = Configuration[myOrder.TenantId + ":Settings:CustomerName"],
                ConnectionString = Configuration[myOrder.TenantId + ":ConnectionStrings:DBConnection"]
            };
        }
    }
}
