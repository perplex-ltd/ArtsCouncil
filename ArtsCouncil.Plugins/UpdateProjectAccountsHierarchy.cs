using Microsoft.Xrm.Sdk;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Plugins
{
    public class UpdateProjectAccountsHierarchy : IPlugin
    {
        private const string LookupField = "adv_mainapplicant";
        ITracingService tracingService;
        IOrganizationService service;

        public void Execute(IServiceProvider serviceProvider)
        {
            tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            IPluginExecutionContext context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            if (context.InputParameters.Contains("Target") &&
                context.InputParameters["Target"] is Entity)
            {
                Entity target = (Entity)context.InputParameters["Target"];
                if (target.LogicalName != "adv_project")
                    return;
                try
                {
                    tracingService.Trace("UpdateProjectAccountsHierarchy.");
                    // Only run if ace_typeofpartnership attribute was changed...
                    if (!target.Attributes.Contains(LookupField))
                    {
                        return;
                    }

                    // Obtain the organization service reference.
                    IOrganizationServiceFactory serviceFactory =
                        (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                    service = serviceFactory.CreateOrganizationService(context.UserId);

                    var applicant = target.Attributes[LookupField] as EntityReference;
                    if (applicant is null) return;
                    if (applicant.LogicalName != "account") return;

                    var relationshipManager = new ProjectAccountRelationshipManager(service, tracingService);
                    relationshipManager.UpdateRelationships(target.Id, applicant.Id);

                    // Remove all accounts from account-projects relationship

                    // add all previously retrieved accounts 

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

    }
}
