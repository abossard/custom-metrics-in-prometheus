using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Prometheus;

namespace hello_func
{
    public static class Metrics
    {
        [FunctionName("metrics")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            var memoryStream = new MemoryStream();
            await Prometheus.Metrics.DefaultRegistry.CollectAndExportAsTextAsync(memoryStream, req.HttpContext.RequestAborted);
            memoryStream.Position = 0;
            var reader = new StreamReader(memoryStream, Encoding.UTF8, false);
            var body = await reader.ReadToEndAsync();
            return new OkObjectResult(body);
        }
    }
}
