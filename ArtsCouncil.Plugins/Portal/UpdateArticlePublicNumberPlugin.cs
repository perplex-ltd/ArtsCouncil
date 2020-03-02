using Microsoft.Xrm.Sdk;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Plugins.Portal
{
    public class UpdateArticlePublicNumberPlugin : IPlugin
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
                if (target.LogicalName != "knowledgearticle")
                    return;


                try
                {
                    tracingService.Trace("UpdateArticlePublicNumberPlugin.");
                    // Only run if ace_typeofpartnership attribute was changed...
                    if (!target.Attributes.Contains("ace_seoid"))
                    {
                        return;
                    }

                    // Obtain the organization service reference.
                    IOrganizationServiceFactory serviceFactory =
                        (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                    service = serviceFactory.CreateOrganizationService(context.UserId);
                    var seoId = (string)target["ace_seoid"];
                    tracingService.Trace($"seo id is {seoId}");
                    if (!string.IsNullOrEmpty(seoId))
                    {
                        if (target.Attributes.Contains("articlepublicnumber"))
                        {
                            target["articlepublicnumber"] = seoId;
                        }
                        else
                        {
                            target.Attributes.Add("articlepublicnumber", seoId);
                        }
                    }
                    tracingService.Trace("Done!");
                }
                catch (FaultException<OrganizationServiceFault> ex)
                {
                    tracingService.Trace("Fault: {0} {1}", ex.Message, ex.StackTrace);
                    throw new InvalidPluginExecutionException("An error occurred while update the article public number plug-in", ex);
                }
                catch (Exception ex)
                {
                    tracingService.Trace("{0}: {1}", GetType().Name, ex.ToString());
                    throw;
                }
            }
        }

    }
}
