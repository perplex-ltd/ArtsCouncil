using Microsoft.Xrm.Sdk.Query;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Plugins
{
    public class OnlyOneMainOrganisation : AbstractOnlyOneActiveFlagPlugin
    {
        protected override string EntityName => "account";

        protected override string Field => "ace_mainorganisation";

        protected override QueryBase CreateQuery(Guid id)
        {
            var org = Service.Retrieve(EntityName, id, new Microsoft.Xrm.Sdk.Query.ColumnSet(new string[] { "emailaddress1" }));
            string primaryEmail = org["emailaddress1"] as string;
            if (string.IsNullOrEmpty(primaryEmail)) return null;
            var idxAt = primaryEmail.IndexOf('@');
            if (idxAt == -1 || idxAt == primaryEmail.Length - 1) return null;
            var emailDomain = primaryEmail.Substring(idxAt);
            
            var fetchXml = $@"
<fetch version='1.0' output-format='xml-platform' mapping='logical' distinct='true'>
  <entity name='account'>
    <attribute name='accountid' />
    <filter>
      <condition attribute='emailaddress1' operator='ends-with' value='{emailDomain/*@artscouncil.org.uk*/}'/>
      <condition attribute='accountid' operator='neq' value='{id/*5a5eaa68-dff2-e311-a313-005056915655*/}'/>
      <condition attribute='statecode' operator='eq' value='0'/>
    </filter>
  </entity>
</fetch>";
            return new FetchExpression(fetchXml);

        }
    }
}
