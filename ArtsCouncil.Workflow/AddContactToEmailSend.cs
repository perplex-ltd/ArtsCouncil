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
    public class AddContactToEmailSend : BaseWorkflowActivity
    {

        [Input("Email Send")]
        [ReferenceTarget("cdi_emailsend")]
        [ArgumentRequired(true)]
        public InArgument<EntityReference> EmailSend { get; set; }

        [Input("Contact")]
        [ReferenceTarget("contact")]
        [ArgumentRequired(true)]
        public InArgument<EntityReference> Contact { get; set; }

        /// <summary>
        /// Associates the <see cref="Contact"/> record to the <see cref="EmailSend"/> record.
        /// </summary>
        /// <param name="context"></param>
        protected override void ExecuteActivity(CodeActivityContext context)
        {

            try { 
            EntityReference emailSendReference = EmailSend.Get(context);
            EntityReference contactReference = Contact.Get(context);

            Service.Associate("cdi_emailsend", emailSendReference.Id, 
                new Relationship("cdi_emailsend_contact"), new EntityReferenceCollection(new[] { contactReference }));
            } catch (Exception e)
            {
                TracingService.Trace("Couldn't associate contact to email: {0}", e.Message);
                throw;
            }
        }
    }
}
