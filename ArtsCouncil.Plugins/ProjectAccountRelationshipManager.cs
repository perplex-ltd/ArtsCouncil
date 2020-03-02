using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Plugins
{
    internal class ProjectAccountRelationshipManager
    {
        private IOrganizationService service;
        private ITracingService tracingService;

        public ProjectAccountRelationshipManager(IOrganizationService service, ITracingService tracingService)
        {
            this.service = service;
            this.tracingService = tracingService;
        }

        internal void UpdateRelationships(Guid projectId, Guid accountId)
        {
            var newAccountIds = GetAllParentAccountsId(accountId);
            var oldAccountIds = GetCurrentLinkedAccountIds(projectId);

            var idsToRemove = oldAccountIds.Except(newAccountIds);
            var idsToAdd = newAccountIds.Except(oldAccountIds);

            var relationship = new Relationship("ace_adv_project_account");
            service.Disassociate("adv_project", projectId, relationship, GetEntityReferenceCollection(idsToRemove));
            service.Associate("adv_project", projectId, relationship, GetEntityReferenceCollection(idsToAdd));
        }

        private EntityReferenceCollection GetEntityReferenceCollection(IEnumerable<Guid> ids)
        {
            var collection = new EntityReferenceCollection();
            foreach (var id in ids)
            {
                collection.Add(new EntityReference("account", id));
            }
            return collection;
        }

        private IEnumerable<Guid> GetCurrentLinkedAccountIds(Guid projectId)
        {
            var fetchXml = $@"
<fetch>
  <entity name='ace_adv_project_account'>
    <attribute name='accountid' />
    <attribute name='adv_projectid' />
    <filter>
      <condition attribute='adv_projectid' operator='eq' value='{projectId/*{7a363865-9a54-ea11-a813-000d3a7f195f}*/}'/>
    </filter>
  </entity>
</fetch>";
            var result = service.RetrieveMultiple(new FetchExpression(fetchXml));
            foreach (var e in result.Entities)
            {
                yield return (Guid)e["accountid"];
            }
        }

        /// <summary>
        /// Returns all parent, grandparent, etc. account ids, including the <paramref name="accountId"/>.
        /// </summary>
        /// <param name="accountId"></param>
        /// <returns></returns>
        private IEnumerable<Guid> GetAllParentAccountsId(Guid accountId)
        {
            Entity parent;
            do
            {
                yield return accountId;
                parent = service.Retrieve("account", accountId, new ColumnSet(new string[] { "parentaccountid" }));
                if (parent.Attributes.Contains("parentaccountid"))
                    accountId = ((EntityReference)parent["parentaccountid"]).Id;
                else
                    accountId = Guid.Empty;
            } while (accountId != Guid.Empty);
        }
    }
}
