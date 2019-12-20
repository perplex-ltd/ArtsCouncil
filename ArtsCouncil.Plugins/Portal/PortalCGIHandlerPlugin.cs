using Microsoft.Crm.Sdk.Messages;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Plugins.Portal
{
    public class PortalCGIHandlerPlugin : IPlugin
    {


        public void Execute(IServiceProvider serviceProvider)
        {

            //Extract the tracing service for use in debugging sandboxed plug-ins.
            var tracingService =
                (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            tracingService.Trace("DCN Portal CGI plugin.");
            try
            {
                // Obtain the execution context from the service provider.
                IPluginExecutionContext context = (IPluginExecutionContext)
                    serviceProvider.GetService(typeof(IPluginExecutionContext));
                // Obtain the organization service reference.
                IOrganizationServiceFactory serviceFactory =
                    (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                var service = serviceFactory.CreateOrganizationService(context.UserId);

                tracingService.Trace("Input Parameters {0}", context.InputParameters);
                foreach (var ip in context.InputParameters)
                {
                    tracingService.Trace("{0}/{1}", ip.Key, ip.Value);
                }
                if (!(context.InputParameters.Contains("Query")))
                {
                    throw new ApplicationException("No query expresssion.");
                }
                QueryExpression query;
                if (context.InputParameters["Query"] is QueryExpression q)
                {
                    query = q;
                }
                else if (context.InputParameters["Query"] is FetchExpression fetchQ)
                {
                    FetchXmlToQueryExpressionRequest conversionRequest = new FetchXmlToQueryExpressionRequest() { FetchXml = fetchQ.Query };
                    FetchXmlToQueryExpressionResponse conversionResponse = (service.Execute(conversionRequest) as FetchXmlToQueryExpressionResponse);
                    query = conversionResponse.Query;

                }
                else
                {
                    throw new ApplicationException("Invalid query parameter.");
                }

                if (query.EntityName != "ace_dcnportalcgi")
                    throw new ApplicationException("Portal CGI plugin is incorrectly registered.");
                var condition = query.Criteria.Conditions.First(ce => ce.AttributeName == "ace_name");
#if DEBUG
                foreach (var value in condition.Values)
                {
                    tracingService.Trace("Condition.Value: {0}", value);
                }

#endif
                var cgiParameter = condition.Values[0].ToString();
                tracingService.Trace("cgiParameter: {0}", cgiParameter);
                Dictionary<string, string> parameters;
                try
                {
                    parameters = JsonConvert.DeserializeObject<Dictionary<string, string>>(cgiParameter);
                } catch (JsonReaderException ex)
                {
                    throw new InvalidPluginExecutionException(ex.Message);
                }


                var cgiServiceName = (string)parameters["Service"];
                tracingService.Trace("Service {0}", cgiServiceName);
                var cgiService = GetCgiService(cgiServiceName);
                string jsonResult;
                try
                {
                    jsonResult = cgiService.Execute(parameters, service, tracingService);
                    tracingService.Trace("Json result: {0}", jsonResult);
                }
                catch (Exception ex)
                {
                    tracingService.Trace("Whoopsy daisy... {0}", ex);
                    jsonResult =
@"{
    ""Status"": ""Error"",
    ""Error"": """ + ex.Message + @"""
}";
                }

                if (!(context.OutputParameters.Contains("BusinessEntityCollection") &&
                    context.OutputParameters["BusinessEntityCollection"] is EntityCollection))
                {
                    throw new ApplicationException("No BusinessEntityCollection.");
                }
                var entityCollection = (EntityCollection)context.OutputParameters["BusinessEntityCollection"];
                entityCollection.Entities.Clear();

                var output = new Entity("ace_dcnportalcgi");
                output["ace_cgivalue"] = jsonResult;
                entityCollection.Entities.Add(output);

                tracingService.Trace("Done!");
            }
            catch (FaultException<OrganizationServiceFault> ex)
            {
                tracingService.Trace("Fault: {0} {1}", ex.Message, ex.StackTrace);
                throw new InvalidPluginExecutionException("An error occurred in the PortalCGIHandler plug-in", ex);
            }
            catch (Exception ex)
            {
                tracingService.Trace("PortalCGIHandler: {0}", ex.ToString());
                throw new ApplicationException(string.Format("Unexpected exception: {0}", ex.Message));
            }
        }

        #region Factory stuff

        private static CgiService GetCgiService(string service)
        {
            if (cgiServices.ContainsKey(service))
            {
                return (CgiService)Activator.CreateInstance(cgiServices[service]);
            }
            else
            {
                throw new ApplicationException(string.Format("No service {0} registered.", service));
            }
        }

        private static Dictionary<string, Type> cgiServices = new Dictionary<string, Type>();

        static PortalCGIHandlerPlugin()
        {
            cgiServices.Add("manageBookmarks", typeof(ManageBookmarks));
            cgiServices.Add("subscribeToNewsletter", typeof(SubscribeToNewsletter));
        }
        #endregion
    }

}
