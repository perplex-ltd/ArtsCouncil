using System;
using System.Activities;
using System.Collections.Generic;
using System.Collections.ObjectModel;

using Microsoft.Crm.Sdk.Messages;

using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Messages;
using Microsoft.Xrm.Sdk.Metadata;
using Microsoft.Xrm.Sdk.Query;
using Microsoft.Xrm.Sdk.Workflow;

namespace ArtsCouncil.Workflow
{

    /// <summary>
    /// Provides functionality to associate a contact record with a ClickDimensions Email Send record.
    /// </summary>
    public class FindContactByEmail : BaseWorkflowActivity
    {

        [Input("Email address")]
        [ArgumentRequired(true)]
        public InArgument<string> EmailAddress { get; set; }

        [Output("Contact")]
        [ReferenceTarget("contact")]
        public OutArgument<EntityReference> Contact { get; set; }

        /// <summary>
        /// Associates the <see cref="Contact"/> record to the <see cref="EmailSend"/> record.
        /// </summary>
        /// <param name="context"></param>
        protected override void ExecuteActivity(CodeActivityContext context)
        {

            try { 
                string emailAddress = EmailAddress.Get(context);
                var fetchXml = $@"
<fetch top='1'>
  <entity name='contact'>
    <attribute name='contactid' />
    <filter type='or'>
      <condition attribute='emailaddress1' operator='eq' value='{emailAddress}'/>
      <condition attribute='emailaddress2' operator='eq' value='{emailAddress}'/>
      <condition attribute='emailaddress3' operator='eq' value='{emailAddress}'/>
    </filter>
  </entity>
</fetch>";
                var results = Service.RetrieveMultiple(new FetchExpression(fetchXml));
                if (results.Entities.Count> 0)
                {
                    var contact = results.Entities[0].ToEntityReference();
                    Contact.Set(context, contact);
                }
            } catch (Exception e)
            {
                TracingService.Trace("Couldn't search for contact: {0}", e.Message);
                throw;
            }
        }
    }
}
