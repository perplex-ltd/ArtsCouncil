using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace ArtsCouncil.Plugins.Portal
{
    class SubscribeToNewsletter : CgiService
    {

        ITracingService tracer;
        IOrganizationService service;

        /// <summary>
        /// Adds or deletes a bookmark.
        /// </summary>
        /// <param name="parameters">A dictionary containing Action, UserId and ArticleId values</param>
        /// <param name="service"></param>
        /// <param name="tracingService"></param>
        /// <returns></returns>
        public override string Execute(IDictionary<string, string> parameters, IOrganizationService service, ITracingService tracingService)
        {
            tracer = tracingService;
            this.service = service;
            

            var email = parameters["Email"];
            var firstname = parameters["FirstName"];
            var lastname = parameters["LastName"];

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(firstname) || string.IsNullOrEmpty(lastname))
            {
                throw new ApplicationException("Required parameters are not present.");
            }

            // find contact record
            Entity contact = FindContactRecord(email); 
            if (contact == null)
            {
                tracer.Trace("Creating new contact");
                contact = new Entity("contact");
                contact["firstname"] = firstname;
                contact["lastname"] = lastname;
                contact["emailaddress1"] = email;
                contact["ace_dcnnewsletter"] = true;
                service.Create(contact);
            } else
            {
                if (contact.Attributes.Contains("ace_dcnnewsletter") && (bool)contact["ace_dcnnewsletter"])
                {
                    tracer.Trace("Contact {0} is already subscribed", contact.Id);
                }
                else
                {
                    tracer.Trace("Updating contact {0}", contact.Id);
                    contact["ace_dcnnewsletter"] = true;
                    service.Update(contact);
                }
            }
            return CreateReturnValue("Subscribed");
        }

        private Entity FindContactRecord(string email)
        {
            tracer.Trace("Finding contact by email {0}", email);
            var fetchXml = $@"
<fetch top='10'>
  <entity name='contact'>
    <attribute name='ace_dcnnewsletter' />
    <attribute name='emailaddress1' />
    <attribute name='emailaddress2' />
    <attribute name='emailaddress3' />
    <filter>
      <filter type='or'>
        <condition attribute='emailaddress1' operator='eq' value='{email}'/>
        <condition attribute='emailaddress2' operator='eq' value='{email}'/>
        <condition attribute='emailaddress3' operator='eq' value='{email}'/>
      </filter>
      <condition attribute='statuscode' operator='eq' value='1'/>
    </filter>
  </entity>
</fetch>";
            var result = service.RetrieveMultiple(new FetchExpression(fetchXml));
            tracer.Trace("Found {0} contact(s)", result.Entities.Count);
            if (result.Entities.Count == 0) return null;
            else if (result.Entities.Count == 1) return result.Entities[0];
            else
            {
                var contact = result.Entities.FirstOrDefault(e => string.Compare(e["emailaddress1"] as string, email, true) == 0);
                if (contact == null)
                    contact = result.Entities.FirstOrDefault(e => string.Compare(e["emailaddress2"] as string, email, true) == 0);
                if (contact == null)
                    contact = result.Entities.FirstOrDefault(e => string.Compare(e["emailaddress3"] as string, email, true) == 0);
                if (contact == null) // that shouln't really happen
                    contact = result.Entities[0];
                return contact;
            }
        }

        private string CreateReturnValue(string message)
        {
            return "{\n" +
                "\t\"Status\": \"Ok\",\n" +
                string.Format("\t\"Message\": \"{0}\",\n", message) +
                string.Format("\t\"Time\": \"{0}\"\n", DateTime.Now) +
                "}";
        }
    }
}
