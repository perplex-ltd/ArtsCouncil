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
    /// Custom workflow activity to retrieve an organisation using a certain email domain.
    /// </summary>
    public class GetOrganisationByName : BaseWorkflowActivity
    {
        /// <summary>
        /// An email address or the domain (including the @ sign)
        /// </summary>
        [Input("Organisation Name")]
        [ArgumentRequired(true)]
        public InArgument<string> OrganisationName { get; set; }

        [Output("Organisation")]
        [ReferenceTarget("account")]
        public OutArgument<EntityReference> Account { get; set; }

        protected override void ExecuteActivity(CodeActivityContext context)
        {
            // Extract email domain
            var orgName = OrganisationName.Get<string>(context);
            if (string.IsNullOrEmpty(orgName))
            {
                TracingService.Trace("No organisation name specified.");
                return;
            }
            // Get organisations using this domain
            var fetchXml = $@"
<fetch distinct='true' aggregate='true' returntotalrecordcount='true'>
  <entity name='account'>
    <attribute name='accountid' alias='accountid' groupby='true' />
    <attribute name='ace_mainorganisation' alias='ace_mainorganisation' groupby='true' />
    <attribute name='new_grantiumapplicantnumber' alias='new_grantiumapplicantnumber' groupby='true' />
    <filter>
      <condition attribute='name' operator='eq' value='{OrganisationName}'/>
      <condition attribute='statecode' operator='eq' value='0'/>
    </filter>
    <link-entity name='contact' from='parentcustomerid' to='accountid' link-type='outer' alias='c'>
      <order alias='numberOfContacts' descending='true' />
      <attribute name='parentcustomerid' alias='numberOfContacts' aggregate='count' />
    </link-entity>
  </entity>
</fetch>";
            var result = Service.RetrieveMultiple(new FetchExpression(fetchXml));
            TracingService.Trace("Got {0} organisations...", result.TotalRecordCount);
            if (result.TotalRecordCount > 0 && result.TotalRecordCount <= 10) 
            {
                var org = result.Entities[0].ToEntityReference();
                Account.Set(context, org);
            }
        }

    }
}
