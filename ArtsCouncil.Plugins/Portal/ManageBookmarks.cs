using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace ArtsCouncil.Plugins.Portal
{
    class ManageBookmarks : CgiService
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
            var action = parameters["Action"];
            var userId = new Guid(parameters["UserId"]);
            var articleId = new Guid(parameters["ArticleId"]);

            if (action == "add")
            {
                return CreateBookmark(service, userId, articleId);
            }
            else if (action == "remove")
            {
                return DeleteBookmark(service, userId, articleId);
            }
            else
            {
                throw new ApplicationException("Invalid action specified.");
            }
        }

        private string DeleteBookmark(IOrganizationService service, Guid userId, Guid articleId)
        {
            tracer.Trace("Deleting bookmark...");
            var q = (@"
            <fetch version='1.0' output-format='xml-platform' mapping='logical' distinct='true' >
              <entity name='ace_bookmark' >
                <attribute name='ace_bookmarkid' />
                <filter type='and' >
                  <condition attribute='ace_article' operator='eq' value='{0:D}' />
                  <condition attribute='ace_portaluser' operator='eq' value='{1:D}' />
                </filter>
              </entity>
            </fetch>
");
            q = string.Format(q, articleId, userId);
            tracer.Trace("Q {0}", q);
            var query = new FetchExpression(q);
            var results = service.RetrieveMultiple(query);
            foreach (var e in results.Entities)
            {
                tracer.Trace("About to delete that bookmark...");
                service.Delete(e.LogicalName, e.Id);
            }
            return CreateReturnValue("Deleted bookmark");
        }

        private string CreateBookmark(IOrganizationService service, Guid userId, Guid articleId)
        {
            tracer.Trace("Adding bookmark...");
            Entity bookmark = new Entity("ace_bookmark");
            bookmark["ace_article"] = new EntityReference("knowledgearticle", articleId);
            bookmark["ace_portaluser"] = new EntityReference("systemuser", userId);
            service.Create(bookmark);
            return CreateReturnValue("Created bookmark");
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
