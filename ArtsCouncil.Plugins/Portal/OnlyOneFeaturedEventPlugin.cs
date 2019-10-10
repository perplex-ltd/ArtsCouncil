using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Plugins.Portal
{
    public class OnlyOneFeaturedEventPlugin : OnlyOneFeaturedNewsEventPlugin
    {
        protected override string EntityName => "cdi_event";

        protected override string GetQuery(Guid id)
        {
            var fetchData = new
            {
                cdi_eventid = id.ToString("D")
            };
            var fetchXml = $@"
<fetch>
  <entity name='cdi_event'>
    <attribute name='cdi_eventid' />
    <filter>
      <condition attribute='ace_featured' operator='eq' value='1'/>
      <condition attribute='cdi_eventid' operator='neq' value='{fetchData.cdi_eventid}'/>
    </filter>
  </entity>
</fetch>";
            return fetchXml;
        }
    }
}
