using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Messages;
using Microsoft.Xrm.Sdk.Metadata;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Plugins
{
    public class UpdateActivitySortDatePlugin : IPlugin
    {

        ITracingService tracingService;
        IOrganizationService service;

        const int OPEN = 0;
        const int SCHEDULED = 3;

        public void Execute(IServiceProvider serviceProvider)
        {
            tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            try
            {

                IPluginExecutionContext context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
                if (context.InputParameters.Contains("Target") &&
                    context.InputParameters["Target"] is Entity)
                {
                    IOrganizationServiceFactory serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                    service = serviceFactory.CreateOrganizationService(context.UserId);

                    Entity target = (Entity)context.InputParameters["Target"];
                    var metadata = GetEntityMetadata(target);
                    if (!metadata.IsActivity.GetValueOrDefault(false))
                    {
                        tracingService.Trace("Entity is not an activity.");
                        return;
                    }
                    tracingService.Trace("This is a {0}", target.LogicalName);
                    // use Actual End, Due Date or Modified On
                    DateTime? due = null, actualEnd = null, modifiedOn = null;
                    if (context.PreEntityImages.ContainsKey("Image"))
                    {
                        var preImage = (Entity)context.PreEntityImages["Image"];
                        due = preImage.Contains("scheduledend") ? preImage["scheduledend"] as DateTime? : null;
                        actualEnd = preImage.Contains("actualend") ? preImage["actualend"] as DateTime? : null;
                        modifiedOn = preImage["modifiedon"] as DateTime?;
                    }
                    if (target.Contains("scheduledend")) due = target["scheduledend"] as DateTime?;
                    if (target.Contains("actualend")) actualEnd = target["actualend"] as DateTime?;
                    if (target.Contains("modifiedon")) modifiedOn = target["modifiedon"] as DateTime?;
                    tracingService.Trace("Due Date: {0}, Actual End: {1}, Modified On: {2}.", due, actualEnd, modifiedOn);
                    if (target.LogicalName == "phonecall" || target.LogicalName == "task")
                    {
                        // if activity is being closed or cancelled
                        if (target.Attributes.ContainsKey("statecode") && target["statecode"] is OptionSetValue statecode && statecode.Value != OPEN && statecode.Value != SCHEDULED)
                        {
                            // use modifiedon (current date)
                            tracingService.Trace("Activity is closing...");
                            target["sortdate"] = modifiedOn;
                        }
                        else
                        {
                            // use ActualEnd, Due or ModifiedOn 
                            if (actualEnd != null)
                            {
                                target["sortdate"] = actualEnd.Value;
                            }
                            else if (due != null)
                            {
                                target["sortdate"] = due.Value;
                            }
                            else
                            {
                                target["sortdate"] = modifiedOn.Value;
                            }
                        }
                        
                    }


                    tracingService.Trace("Done!");
                }
            }
            catch (FaultException<OrganizationServiceFault> ex)
            {
                tracingService.Trace("Fault: {0} {1}", ex.Message, ex.StackTrace);
                throw new InvalidPluginExecutionException($"An error occurred: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                tracingService.Trace("{1}: {0}", ex.ToString(), nameof(UpdateActivitySortDatePlugin));
                throw;
            }
        }

        private EntityMetadata GetEntityMetadata(Entity entity)
        {
            var request = new RetrieveEntityRequest()
            {
                LogicalName = entity.LogicalName,
                EntityFilters = Microsoft.Xrm.Sdk.Metadata.EntityFilters.Entity,
                RetrieveAsIfPublished = false
            };
            var response = (RetrieveEntityResponse)service.Execute(request);
            return response.EntityMetadata;
        }
    }
}
