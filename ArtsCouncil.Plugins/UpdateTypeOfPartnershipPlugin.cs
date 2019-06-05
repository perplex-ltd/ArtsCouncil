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

                    // Prepare and retrieve partnership record ids
                    var allPartnershipTypes = PreparePartnershipTypeRecords();
                    // Get multi option set value and linked records
                    var targetOptions = (OptionSetValueCollection)target.Attributes["ace_typeofpartnership"];
                    // attribute returns null if it's empty, we'd rather take an empty collection 🍵
                    if (targetOptions == null)
                    {
                        targetOptions = new OptionSetValueCollection();
                    }
                    var linkedOptions = RetrieveLinkedPartnershipTypeRecords(target).ToList<OptionSetValue>();
                    // Compare 
                    IList<EntityReference> partnershipTypesToAdd = new List<EntityReference>();
                    IList<EntityReference> partnershipTypesToRemove = new List<EntityReference>();
                    // find options in target but not linked
                    foreach (var o in targetOptions)
                    {
                        if (!linkedOptions.Contains(o))
                        {
                            tracingService.Trace("Need to add an option: {0}", o.Value);
                            partnershipTypesToAdd.Add(new EntityReference("ace_partnershiptype", allPartnershipTypes[o.Value]));
                        }
                    }
                    // find linked options not in target
                    foreach (var o in linkedOptions)
                    {
                        if (!targetOptions.Contains(o))
                        {
                            tracingService.Trace("Need to remove an option: {0}", o.Value);
                            partnershipTypesToRemove.Add(new EntityReference("ace_partnershiptype", allPartnershipTypes[o.Value]));
                        }
                    }
                    var relationship = new Relationship("ace_ace_partnershiptype_incident");
                    // associate partnership types to add
                    tracingService.Trace("Associating {0} records", partnershipTypesToAdd.Count);
                    service.Associate("incident", target.Id, relationship, new EntityReferenceCollection(partnershipTypesToAdd));
                    // disassociate partnership types to remove
                    tracingService.Trace("Disassociating {0} records", partnershipTypesToRemove.Count);
                    service.Disassociate("incident", target.Id, relationship, new EntityReferenceCollection(partnershipTypesToRemove));
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

        private IDictionary<int, Guid> PreparePartnershipTypeRecords()
        {
            // Get all option set and values
            var options = GetOptionSetMetaData();
            // prepare result list
            var partnershipTypeRecords = new Dictionary<int, Guid>(options.Count);
            // Get all linked records
            var results = service.RetrieveMultiple(new QueryExpression()
            {
                EntityName = "ace_partnershiptype",
                ColumnSet = new ColumnSet("ace_name", "ace_value"),
                PageInfo = new PagingInfo()
                {
                    ReturnTotalRecordCount = true
                }
            });
            tracingService.Trace("Got {0} existing partnership type records", results.TotalRecordCount);
            // update records with wrong names
            foreach (var e in results.Entities)
            {
                var option = options.FirstOrDefault(o =>
                {
                    return e["ace_value"] != null && ((OptionSetValue)e["ace_value"]).Value == o.Value.Value;
                });
                if (option == null) // Option doesn't exist anymore, delete...
                {
                    tracingService.Trace("Deleting record {0}", e["ace_name"]);
                    service.Delete(e.LogicalName, e.Id);
                }
                else if (option.Label.UserLocalizedLabel.Label != (string)e["ace_name"]) //Record's label is out of date, update
                {
                    tracingService.Trace("Updating record {1} (was {0})", e["ace_name"], option.Label.UserLocalizedLabel.Label);
                    e["ace_name"] = option.Label.UserLocalizedLabel.Label;
                    service.Update(e);
                    partnershipTypeRecords.Add(option.Value.Value, e.Id);
                }
                else
                {
                    tracingService.Trace("Leave record {0}", e["ace_name"]);
                    partnershipTypeRecords.Add(option.Value.Value, e.Id);
                }
            }
            // create missing records
            foreach (var o in options)
            {
                var record = results.Entities.FirstOrDefault(e =>
                {
                    return e["ace_value"] != null && ((OptionSetValue)e["ace_value"]).Value == o.Value.Value;
                });
                if (record == null) // record doesn't exist, create
                {
                    tracingService.Trace("Creating record {0}", o.Label.UserLocalizedLabel.Label);
                    var newRecord = new Entity("ace_partnershiptype");
                    newRecord["ace_name"] = o.Label.UserLocalizedLabel.Label;
                    newRecord["ace_value"] = new OptionSetValue(o.Value.GetValueOrDefault());
                    Guid id = service.Create(newRecord);
                    partnershipTypeRecords.Add(o.Value.Value, id);
                }
            }
            return partnershipTypeRecords;
        }

        private OptionMetadataCollection GetOptionSetMetaData()
        {
            var retrieveRequest = new RetrieveOptionSetRequest
            {
                Name = "ace_dcnpartnership"
            };
            tracingService.Trace("Retrieving option set metadata");
            var response = (RetrieveOptionSetResponse)service.Execute(retrieveRequest);
            return ((OptionSetMetadata)response.OptionSetMetadata).Options;

        }

        private IEnumerable<OptionSetValue> RetrieveLinkedPartnershipTypeRecords(Entity target)
        {
            string query = @"
<fetch>
  <entity name='ace_partnershiptype' >
    <attribute name='ace_value' />
    <link-entity name='ace_ace_partnershiptype_incident' from='ace_partnershiptypeid' to='ace_partnershiptypeid' intersect='true' >
      <filter>
        <condition attribute='incidentid' operator='eq' value='{0}' />
      </filter>
    </link-entity>
  </entity>
</fetch>";
            query = string.Format(query, target.Id.ToString("D"));
            tracingService.Trace("Retrieving linked partnership type records\n{0}", query);
            var results = service.RetrieveMultiple(new FetchExpression(query));
            foreach (var e in results.Entities)
            {
                tracingService.Trace("  Linked record {0}", ((OptionSetValue)e["ace_value"]).Value);
                yield return (OptionSetValue)e["ace_value"];
            }
        }
    }
}
