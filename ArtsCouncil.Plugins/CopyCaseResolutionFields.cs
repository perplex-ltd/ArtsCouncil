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

namespace ArtsCouncil.Plugins
{

    /// <summary>
    /// This plugin copies the case resolution fields to the case.
    /// See https://community.dynamics.com/crm/b/misscrm360exploration/posts/capturing-and-storing-case-resolution-fields-in-the-case-form.
    /// </summary>
    public class CopyCaseResolutionFields : IPlugin
    {

        ITracingService tracingService;
        IOrganizationService service;

        public void Execute(IServiceProvider serviceProvider)
        {
            // Initalise
            IPluginExecutionContext context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            IOrganizationServiceFactory serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            service = serviceFactory.CreateOrganizationService(context.UserId);
            tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

            // actual work...
            if (context.InputParameters.Contains("Target") && context.InputParameters["Target"] is Entity)
            {

                //create entity context
                Entity entity = (Entity)context.InputParameters["Target"];
                if (entity.LogicalName != "incidentresolution")
                    return;

                try
                {
                    if (entity.Contains("incidentid"))
                    {
                        //get the related Case
                        var caseReference = (EntityReference)entity["incidentid"];
                        var targetCase = new Entity(caseReference.LogicalName, caseReference.Id);

                        //capture the Case Resolution Fields                      
                        string resolution = entity.Contains("subject") ? entity["subject"].ToString() : string.Empty;
                        int totalBillableTime = entity.Contains("timespent") ? (Int32)entity["timespent"] : 0;
                        string remarks = entity.Contains("description") ?
                            (entity["description"] != null ? entity["description"].ToString() : string.Empty) :
                            string.Empty;

                        //update Case with the fields
                        targetCase["ace_resolution"] = resolution;
                        targetCase["ace_timespent"] = totalBillableTime;
                        targetCase["ace_resolutionremarks"] = remarks;
                        service.Update(targetCase);
                    }
                }
                catch (Exception ex)
                {
                    throw new InvalidPluginExecutionException(ex.Message);
                }

            }
            else
            {
                tracingService.Trace("Invalid Target.");
            }
        }

    }
}
