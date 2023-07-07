using Microsoft.Crm.Sdk.Messages;
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
    /// <summary>
    /// Use this plugin on the Contact entity. It will automatically convert the first, 
    /// middle and last names to beign with a capital letter, if necessary.
    /// </summary>
    public class CapitaliseNamesPlugin : IPlugin
    {

        ITracingService tracingService;
        IOrganizationService service;

        readonly string[] fields = { "firstname", "middlename", "lastname" };        

        public void Execute(IServiceProvider serviceProvider)
        {
            tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            //tracingService.Trace("Hi, I'm {0}.", this.GetType());
            try
            {
                IPluginExecutionContext context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
                if (context.InputParameters.Contains("Target") &&
                    context.InputParameters["Target"] is Entity)
                {
                    IOrganizationServiceFactory serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                    service = serviceFactory.CreateOrganizationService(context.UserId);

                    Entity target = (Entity)context.InputParameters["Target"];
                    // Verify that the target entity represents a contat.
                    // If not, this plug-in was not registered correctly.
                    if (target.LogicalName != "contact")
                        return;

                    // Get existing first and last name.
                    // (If either is not updated, we still need them to update the full name)
                    var names = new Dictionary<string, string>();
                    names["firstname"] = null;
                    names["lastname"] = null;

                    foreach (var f in fields)
                    {
                        // Only run if attribute was changed...
                        if (target.Attributes.Contains(f))
                        {
                            var value = target[f] as string;
                            if (!string.IsNullOrEmpty(value) && value.Length >= 1 && char.IsLower(value[0]))
                            {
                                tracingService.Trace("Updating attribute {0} ({1})", f, value);
                                target[f] = value[0].ToString().ToUpper() + (value.Length > 1 ? value.Substring(1) : "");
                            }
                            names[f] = target[f] as string;
                        }
                    }
                    // Get default values to create the full name from the pre image
                    if (context.PreEntityImages.ContainsKey("Image"))
                    {
                        var preImage = (Entity)context.PreEntityImages["Image"];
                        if (string.IsNullOrEmpty(names["firstname"]))
                        {
                            names["firstname"] = preImage.Contains("firstname") ? preImage["firstname"] as string : null;
                        }
                        if (string.IsNullOrEmpty(names["lastname"]))
                        {
                            names["lastname"] = preImage.Contains("lastname") ? preImage["lastname"] as string : null;
                        }
                    }
                    var fullname = $"{names["firstname"]} {names["lastname"]}".Trim();
                    tracingService.Trace("Updating names to {0}", fullname);
                    target["fullname"] = fullname;
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

    }
}
