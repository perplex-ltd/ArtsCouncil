using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Messages;
using Microsoft.Xrm.Sdk.Metadata;
using Microsoft.Xrm.Sdk.Query;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Workflow
{

    /// <summary>
    /// This plugin is inteneded to run on the case entity and 
    /// updates the partnership records linked to a case based 
    /// on the type of partnership multi select option set.
    /// </summary>
    public class UpdateTypeOfPartnershipPlugin : IPlugin
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

            // The InputParameters collection contains all the data passed in the message request.
            if (context.InputParameters.Contains("Target") &&
                context.InputParameters["Target"] is Entity)
            {
                // Obtain the target entity from the input parameters.
                Entity target = (Entity)context.InputParameters["Target"];

                // Verify that the target entity represents an account.
                // If not, this plug-in was not registered correctly.
                if (target.LogicalName != "incident")
                    return;
                

                try
                {
                    tracingService.Trace("UpdateTypeOfPartnershipPlugin.");
                    // Only run if ace_typeofpartnership attribute was changed...
                    if (!target.Attributes.Contains("ace_typeofpartnership"))
                    {
                        return;
                    }

                    // Obtain the organization service reference.
                    IOrganizationServiceFactory serviceFactory =
                        (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                    service = serviceFactory.CreateOrganizationService(context.UserId);

                    var optionSetLabels = GetOptionSetLabels();
                    // Get multi option set value and linked records
                    var targetOptions = (OptionSetValueCollection)target.Attributes["ace_typeofpartnership"];
                    // attribute returns null if it's empty, we'd rather take an empty collection 🍵
                    if (targetOptions == null)
                    {
                        targetOptions = new OptionSetValueCollection();
                    }
                    var linkedOptions = RetrieveLinkedPartnershipTypeRecords(target).ToList<Entity>();
                    // Compare 
                    // find options in target but not linked
                    foreach (var o in targetOptions)
                    {
                        var existingValues = from e in linkedOptions
                                            select (OptionSetValue)e["ace_value"];
                        if (!existingValues.Contains(o))
                        {
                            tracingService.Trace("Adding option: {0}", o.Value);
                            var newRecord = new Entity("ace_partnershiptype");
                            newRecord["ace_name"] = optionSetLabels[o.Value];
                            newRecord["ace_value"] = o;
                            newRecord["ace_caseid"] = target.ToEntityReference();
                            Guid id = service.Create(newRecord);
                        }
                    }
                    // find linked options not in target
                    foreach (var e in linkedOptions)
                    {
                        var option = ((OptionSetValue)e["ace_value"]);
                        if (!targetOptions.Contains(option))
                        {
                            tracingService.Trace("Removing option: {0}", option.Value);
                            service.Delete(e.LogicalName, e.Id);
                        }
                    }
                    tracingService.Trace("Done!");
                }
                catch (FaultException<OrganizationServiceFault> ex)
                {
                    tracingService.Trace("Fault: {0} {1}", ex.Message, ex.StackTrace);
                    throw new InvalidPluginExecutionException("An error occurred in the UpdateTypeOfPartnership plug-in", ex);
                }
                catch (Exception ex)
                {
                    tracingService.Trace("UpdateTypeOfPartnershipPlugin: {0}", ex.ToString());
                    throw;
                }
            }
        }

        /// <summary>
        /// Retrievs a dictionary with the option set values and labels.
        /// </summary>
        /// <returns></returns>
        private IDictionary<int, string> GetOptionSetLabels()
        {
            var retrieveRequest = new RetrieveOptionSetRequest
            {
                Name = "ace_dcnpartnership"
            };
            tracingService.Trace("Retrieving option set metadata");
            var response = (RetrieveOptionSetResponse)service.Execute(retrieveRequest);
            var labels = new Dictionary<int, string>();
            foreach (var o in ((OptionSetMetadata)response.OptionSetMetadata).Options)
            {
                if (o.Value != null)
                {
                    labels.Add(o.Value.GetValueOrDefault(), o.Label.UserLocalizedLabel.Label);
                }
            }
            return labels;
        }

        private IEnumerable<Entity> RetrieveLinkedPartnershipTypeRecords(Entity target)
        {
            string query = @"
<fetch>
  <entity name='ace_partnershiptype' >
    <attribute name='ace_value' />
    <filter>
      <condition attribute='ace_caseid' operator='eq' value='{0}' />
    </filter>
  </entity>
</fetch>";
            query = string.Format(query, target.Id.ToString("D"));
            tracingService.Trace("Retrieving linked partnership type records\n{0}", query);
            var results = service.RetrieveMultiple(new FetchExpression(query));
            foreach (var e in results.Entities)
            {
                tracingService.Trace("  Linked record {0}", ((OptionSetValue)e["ace_value"]).Value);
                yield return e;
            }
        }
    }
}
