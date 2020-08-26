using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using System.Xml.XPath;

namespace ArtsCouncil.Plugins
{
    public class IncludeHierarchyPlugin : IPlugin
    {

        ITracingService tracingService;
        IOrganizationService service;

        public void Execute(IServiceProvider serviceProvider)
        {

            //Extract the tracing service for use in debugging sandboxed plug-ins.
            tracingService =
                (ITracingService)serviceProvider.GetService(typeof(ITracingService));

            // Obtain the execution context from the service provider.
            IPluginExecutionContext context = (IPluginExecutionContext)
                serviceProvider.GetService(typeof(IPluginExecutionContext));

            tracingService.Trace($"PrimaryEntityName is {context.PrimaryEntityName}");
            if (context.MessageName != "RetrieveMultiple")
            {
                tracingService.Trace("Wrong message '{context.MessageName}'");
                return;
            }
            if (context.Stage != 20)
            {
                tracingService.Trace("Wrong stage '{context.Stage}'");
                return;
            }
            // The InputParameters collection contains all the data passed in the message request.
            if (context.InputParameters.Contains("Query") &&
                context.InputParameters["Query"] is FetchExpression query)
            {

                tracingService.Trace("Found FetchExpression...");

                try
                {

                    XDocument doc = XDocument.Parse(query.Query);
                    var includeHierarchyElement = doc.XPathSelectElement("/fetch/entity/filter/condition[@attribute='ace_includehierarchy']");
                    if (includeHierarchyElement == null) return;
                    // always remove ace_includehierarchy filter
                    if (includeHierarchyElement.Parent.Elements().Count() > 1)
                    {
                        includeHierarchyElement.Remove();
                    }
                    else
                    {
                        includeHierarchyElement.Parent.Remove();
                    }
                    if ((from v in includeHierarchyElement.Attributes("value")
                         select v.Value).FirstOrDefault() == "1")
                    {
                        var targetConditionElement = doc.XPathSelectElement($"/fetch/entity/link-entity[@name='account']/filter/condition[@attribute='accountid'][@operator='eq']");
                        if (targetConditionElement != null)
                        {
                            var hierarchyConditionElement = new XElement(targetConditionElement);
                            hierarchyConditionElement.Attribute("operator").Value = "under";

                            var newFilter = new XElement("filter");
                            newFilter.Add(new XAttribute("type", "or"));
                            targetConditionElement.Parent.Add(newFilter);
                            targetConditionElement.Remove();
                            newFilter.Add(targetConditionElement);
                            newFilter.Add(hierarchyConditionElement);
                        }
                    }
                    query.Query = doc.ToString();

                    tracingService.Trace("Done!");
                }
                catch (FaultException<OrganizationServiceFault> ex)
                {
                    tracingService.Trace("Fault: {0} {1}", ex.Message, ex.StackTrace);
                    throw new InvalidPluginExecutionException($"An error occurred in the {nameof(IncludeHierarchyPlugin)} plug-in", ex);
                }
                catch (Exception ex)
                {
                    tracingService.Trace($"{nameof(IncludeHierarchyPlugin)}: {ex}");
                    throw;
                }
            }
        }

    }
}
