using Microsoft.Xrm.Sdk;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Plugins.Portal
{
    /// <summary>
    /// Represents a CGI service.
    /// </summary>
    abstract class CgiService
    {
        /// <summary>
        /// Executes the service. Services should return a valid JSON string containing exactly 
        /// one object with a property "Status" with the value "Ok" or throw an ApplicationException 
        /// in case of an error.
        /// </summary>
        /// <param name="parameters">A dictionary of all parameters passed to the service.</param>
        /// <param name="service">A CRM org service from the plugin execution context.</param>
        /// <param name="tracingService">A tracing service instance.</param>
        /// <returns>A JSON string representing the result.</returns>
        /// <exception cref="ApplicationException">In case of an expected error.</exception>
        public abstract string Execute(IDictionary<string, string> parameters, IOrganizationService service, ITracingService tracingService);

    }
}
