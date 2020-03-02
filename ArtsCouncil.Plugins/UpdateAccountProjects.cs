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
    public class UpdateAccountProjects : IPlugin
    {

        private class Project
        {
            public Guid ProjectId { get; set; }
            public Guid AccountId { get; set; }
        }

        ITracingService tracingService;
        IOrganizationService service;

        public void Execute(IServiceProvider serviceProvider)
        {
            tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            try
            {

                IPluginExecutionContext context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
                if (context.InputParameters.Contains("Target") &&
                    context.InputParameters["Target"] is Entity)
                {
                    Entity target = (Entity)context.InputParameters["Target"];
                    if (target.LogicalName != "account")
                        return;
                    tracingService.Trace(nameof(UpdateAccountProjects));
                    // Only run if parentaccountid attribute was changed...
                    if (!target.Attributes.Contains("parentaccountid"))
                    {
                        return;
                    }

                    IOrganizationServiceFactory serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                    service = serviceFactory.CreateOrganizationService(context.UserId);

                    var relationshipManager = new ProjectAccountRelationshipManager(service, tracingService);

                    foreach (var project in GetProjectIds(target.Id))
                    {
                        relationshipManager.UpdateRelationships(project.ProjectId, project.AccountId);
                    }
                    tracingService.Trace("Done!");
                }
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

        private IEnumerable<Project> GetProjectIds(Guid accountId)
        {
            var fetchXml = $@"
<fetch distinct='true'>
  <entity name='adv_project'>
    <link-entity name='ace_adv_project_account' from='adv_projectid' to='adv_projectid' intersect='true'>
      <link-entity name='account' from='accountid' to='accountid'>
        <filter>
          <condition attribute='accountid' operator='eq-or-under' value='{accountId}'/>
        </filter>
      </link-entity>
    </link-entity>
    <attribute name='adv_projectid' />
    <attribute name='adv_mainapplicant' />
  </entity>
</fetch>";
            var result = service.RetrieveMultiple(new FetchExpression(fetchXml));
            foreach (var e in result.Entities)
            {
                yield return new Project()
                {
                    ProjectId = (Guid)e["adv_projectid"],
                    AccountId = ((EntityReference)e["adv_mainapplicant"]).Id
                };
            }
        }
    }
}
