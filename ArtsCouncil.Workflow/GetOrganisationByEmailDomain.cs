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
    public class GetOrganisationByEmailDomain : BaseWorkflowActivity
    {
        /// <summary>
        /// An email address or the domain (including the @ sign)
        /// </summary>
        [Input("Email Address or Domain")]
        [ArgumentRequired(true)]
        public InArgument<string> Email { get; set; }

        [Output("Organisation")]
        [ReferenceTarget("account")]
        public OutArgument<EntityReference> Account { get; set; }

        protected override void ExecuteActivity(CodeActivityContext context)
        {
            // Extract email domain
            var emailDomain = Email.Get<string>(context);
            if (string.IsNullOrEmpty(emailDomain))
            {
                TracingService.Trace("No email specified.");
                return;
            }
            var idxAt = emailDomain.IndexOf('@');
            if (idxAt == -1 || idxAt == emailDomain.Length - 1)
            {
                TracingService.Trace("{0} is not a valid email address.", emailDomain);
                return;
            }
            emailDomain = emailDomain.Substring(idxAt + 1); // email domain without @
            TracingService.Trace("Email domain is {0}.", emailDomain);
            // Check if it is a free email address
            if (freeDomains.Contains(emailDomain))
            {
                TracingService.Trace("{0} is a free domain.", emailDomain);
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
      <condition attribute='emailaddress1' operator='ends-with' value='@{emailDomain/*ironbridge.org.uk*/}'/>
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




        private readonly IList<string> freeDomains = new List<string>(new string[]{
  /* Default domains included */
  "aol.com", "att.net", "comcast.net", "facebook.com", "gmail.com", "gmx.com", "googlemail.com",
  "google.com", "hotmail.com", "hotmail.co.uk", "mac.com", "me.com", "mail.com", "msn.com",
  "live.com", "sbcglobal.net", "verizon.net", "yahoo.com", "yahoo.co.uk",

  /* Other global domains */
  "email.com", "fastmail.fm", "games.com" /* AOL */, "gmx.net", "hush.com", "hushmail.com", "icloud.com",
  "iname.com", "inbox.com", "lavabit.com", "love.com" /* AOL */, "outlook.com", "pobox.com", "protonmail.ch", "protonmail.com", "tutanota.de", "tutanota.com", "tutamail.com", "tuta.io",
 "keemail.me", "rocketmail.com" /* Yahoo */, "safe-mail.net", "wow.com" /* AOL */, "ygm.com" /* AOL */,
  "ymail.com" /* Yahoo */, "zoho.com", "yandex.com",

  /* United States ISP domains */
  "bellsouth.net", "charter.net", "cox.net", "earthlink.net", "juno.com",

  /* British ISP domains */
  "btinternet.com", "virginmedia.com", "blueyonder.co.uk", "freeserve.co.uk", "live.co.uk",
  "ntlworld.com", "o2.co.uk", "orange.net", "sky.com", "talktalk.co.uk", "tiscali.co.uk",
  "virgin.net", "wanadoo.co.uk", "bt.com",

  /* Domains used in Asia */
  "sina.com", "sina.cn", "qq.com", "naver.com", "hanmail.net", "daum.net", "nate.com", "yahoo.co.jp", "yahoo.co.kr", "yahoo.co.id", "yahoo.co.in", "yahoo.com.sg", "yahoo.com.ph", "163.com", "yeah.net", "126.com", "21cn.com", "aliyun.com", "foxmail.com",

  /* French ISP domains */
  "hotmail.fr", "live.fr", "laposte.net", "yahoo.fr", "wanadoo.fr", "orange.fr", "gmx.fr", "sfr.fr", "neuf.fr", "free.fr",

  /* German ISP domains */
  "gmx.de", "hotmail.de", "live.de", "online.de", "t-online.de" /* T-Mobile */, "web.de", "yahoo.de",

  /* Italian ISP domains */
  "libero.it", "virgilio.it", "hotmail.it", "aol.it", "tiscali.it", "alice.it", "live.it", "yahoo.it", "email.it", "tin.it", "poste.it", "teletu.it",

  /* Russian ISP domains */
  "mail.ru", "rambler.ru", "yandex.ru", "ya.ru", "list.ru",

  /* Belgian ISP domains */
  "hotmail.be", "live.be", "skynet.be", "voo.be", "tvcablenet.be", "telenet.be",

  /* Argentinian ISP domains */
  "hotmail.com.ar", "live.com.ar", "yahoo.com.ar", "fibertel.com.ar", "speedy.com.ar", "arnet.com.ar",

  /* Domains used in Mexico */
  "yahoo.com.mx", "live.com.mx", "hotmail.es", "hotmail.com.mx", "prodigy.net.mx",

  /* Domains used in Canada */
  "yahoo.ca", "hotmail.ca", "bell.net", "shaw.ca", "sympatico.ca", "rogers.com",

  /* Domains used in Brazil */
  "yahoo.com.br", "hotmail.com.br", "outlook.com.br", "uol.com.br", "bol.com.br", "terra.com.br", "ig.com.br", "itelefonica.com.br", "r7.com", "zipmail.com.br", "globo.com", "globomail.com", "oi.com.br"
        }).AsReadOnly();

    }
}
