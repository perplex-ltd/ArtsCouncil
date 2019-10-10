using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ArtsCouncil.Plugins.Portal
{
    public class OnlyOneFeaturedNewsArticlePlugin : OnlyOneFeaturedNewsEventPlugin
    {
        protected override string EntityName => "adx_blogpost";

        protected override string GetQuery(Guid id)
        {
            var fetchData = new
            {
                adx_blogpostid = id.ToString("D")
            };
            var fetchXml = $@"
<fetch>
  <entity name='adx_blogpost'>
    <attribute name='adx_blogpostid' />
    <filter>
      <condition attribute='ace_featured' operator='eq' value='1'/>
      <condition attribute='adx_blogpostid' operator='neq' value='{fetchData.adx_blogpostid/*7e241450-abb1-4bd0-9e24-d28b766c822a*/}'/>
    </filter>
  </entity>
</fetch>";
            return fetchXml;
        }
    }
}
