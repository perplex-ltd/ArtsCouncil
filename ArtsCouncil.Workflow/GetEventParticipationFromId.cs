using System;
using System.Activities;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using Microsoft.Xrm.Sdk.Workflow;


namespace ArtsCouncil.Workflow
{
    /// <summary>
    /// Provides a workflowactivity to retrieve a ClickDimensions Event record by its ID.
    /// </summary>
    public class GetEventParticipationFromId : BaseWorkflowActivity
    {
        private const string cdEventParticipation = "cdi_eventparticipation";

        /// <summary>
        /// The Guid of the Event record, in any support form (either with or without braces).
        /// </summary>
        [Input("Event Participation Guid")]
        [ArgumentRequired(true)]
        public InArgument<string> EventParticipationId{ get; set; }

        [Output("Event Participation")]
        [ReferenceTarget(cdEventParticipation)]
        public OutArgument<EntityReference> EventParticipation { get; set; }

        /// <summary>
        /// Checks if the supplied <see cref="EventParticipationId"/> exists and is a ClickDimensions event record, 
        /// then sets <see cref="Event"/>.
        /// </summary>
        /// <param name="context"></param>
        protected override void ExecuteActivity(CodeActivityContext context)
        {
            Guid id = new Guid(EventParticipationId.Get(context));
            EntityReference participationReference = null;
            // Empty Guid should not be an error, but return a null Event reference.
            if (id != Guid.Empty) { 
                // Just to check the event actually exists...
                var result = Service.Retrieve(cdEventParticipation, id, new ColumnSet("cdi_eventparticipationid"));
                participationReference = new EntityReference(cdEventParticipation, result.Id);
            }
            EventParticipation.Set(context, participationReference);
        }
    }
}
