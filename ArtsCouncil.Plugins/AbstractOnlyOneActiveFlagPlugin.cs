using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Plugins
{
    /// <summary>
    /// This plugin ensures a flag is only active/true for one record per set of records.
    /// </summary>
    /// <remarks>
    /// Register on the target entity and filter on the onchange event for the flag.
    /// When a record's flag is set to true, this will deactive the flag for all other records returned by
    /// CreateQuery().
    /// </remarks>
    public abstract class AbstractOnlyOneActiveFlagPlugin : IPlugin
    {
        protected ITracingService TracingService { get; private set; }
        protected IOrganizationService Service { get; private set; }

        /// <summary>
        /// The name of the target entity.
        /// </summary>
        protected abstract string EntityName { get; }
        /// <summary>
        /// The name of the flag field.
        /// </summary>
        protected abstract string Field { get; }
        /// <summary>
        /// Return a query the returns all records where the flag should be deactivated.
        /// </summary>
        /// <param name="id">The id of the current </param>
        /// <returns></returns>
        protected abstract QueryBase CreateQuery(Guid id);

        public void Execute(IServiceProvider serviceProvider)
        {

            //Extract the tracing service for use in debugging sandboxed plug-ins.
            TracingService =
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
                    TracingService.Trace("Plugin is not propertly registered ({0} instead of {1})", target.LogicalName, EntityName);
                    return;
                }

                try
                {
                    TracingService.Trace("Only one featured news/events plugin.");
                    // Only run if ace_featured attribute was changed...
                    if (!target.Attributes.Contains(Field))
                    {
                        return;
                    }
                    // Only run if ace_featured is true
                    if ((bool)target.Attributes[Field] == false)
                    {
                        TracingService.Trace($"{0} is false.", Field);
                        return;
                    }

                    // Obtain the organization service reference.
                    IOrganizationServiceFactory serviceFactory =
                        (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                    Service = serviceFactory.CreateOrganizationService(context.UserId);

                    // Update other records (set flag to false where needed)
                    var query = CreateQuery(target.Id);
                    if (query is null)
                    {
                        return;
                    }
                    var results = Service.RetrieveMultiple(query);
                    foreach (var entity in results.Entities)
                    {
                        entity[Field] = false;
                        TracingService.Trace("About to update record {0}", entity.Id);
                        Service.Update(entity);
                    }


                    TracingService.Trace("Done!");
                }
                catch (FaultException<OrganizationServiceFault> ex)
                {
                    TracingService.Trace("Fault: {0} {1}", ex.Message, ex.StackTrace);
                    throw new InvalidPluginExecutionException("An error occurred.", ex);
                }
                catch (Exception ex)
                {
                    TracingService.Trace("Unhandled general exception: {0}", ex.ToString());
                    throw;
                }
            }
        }        
    }
}
