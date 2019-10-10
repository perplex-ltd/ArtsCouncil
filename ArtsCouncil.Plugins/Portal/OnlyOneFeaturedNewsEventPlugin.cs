using Microsoft.Crm.Sdk.Messages;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Plugins.Portal
{
    public abstract class OnlyOneFeaturedNewsEventPlugin : IPlugin
    {
        ITracingService tracingService;
        IOrganizationService service;

        protected abstract string EntityName { get; }

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
                if (target.LogicalName != EntityName)
                {
                    tracingService.Trace("Plugin is not propertly registered ({0} instead of {1})", target.LogicalName, EntityName);
                    return;
                }


                try
                {
                    tracingService.Trace("Only one featured news/events plugin.");
                    // Only run if ace_featured attribute was changed...
                    if (!target.Attributes.Contains("ace_featured"))
                    {
                        return;
                    }
                    // Only run if ace_featured is true
                    if ((bool)target.Attributes["ace_featured"] == false)
                    {
                        tracingService.Trace("ace_featured is false.");
                        return;
                    }

                    // Obtain the organization service reference.
                    IOrganizationServiceFactory serviceFactory =
                        (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                    service = serviceFactory.CreateOrganizationService(context.UserId);

                    UnFeatureOtherRecords(target);
                    
                    tracingService.Trace("Done!");
                }
                catch (FaultException<OrganizationServiceFault> ex)
                {
                    tracingService.Trace("Fault: {0} {1}", ex.Message, ex.StackTrace);
                    throw new InvalidPluginExecutionException("An error occurred.", ex);
                }
                catch (Exception ex)
                {
                    tracingService.Trace("Unhandled general exception: {0}", ex.ToString());
                    throw;
                }
            }
        }

        private void UnFeatureOtherRecords(Entity target)
        {
            var query = new FetchExpression(GetQuery(target.Id));
            var results = service.RetrieveMultiple(query);
            foreach (var entity in results.Entities)
            {
                entity["ace_featured"] = false;
                tracingService.Trace("About to update record {0}", entity.Id);
                service.Update(entity);
            }
        }

        protected abstract string GetQuery(Guid id);
    }
}
