using System;
using System.Activities;

using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Workflow;

namespace ArtsCouncil.Workflow
{

    /// <summary>
    /// Provides commonly used base functions
    /// </summary>
    public abstract class BaseWorkflowActivity : CodeActivity
    {

        public ITracingService TracingService { get; private set; }
        public IOrganizationService Service { get; private set; }

        /// <summary>
        /// Creates a Web Enquiry record based on the <see cref="PostedForm"/>.
        /// </summary>
        /// <param name="context"></param>
        protected override void Execute(CodeActivityContext context)
        {
            // Retrieve the CrmService so that we can retrieve the loan application
            TracingService = context.GetExtension<ITracingService>();
            IWorkflowContext wfContext = context.GetExtension<IWorkflowContext>();
            IOrganizationServiceFactory serviceFactory = context.GetExtension<IOrganizationServiceFactory>();
            Service = serviceFactory.CreateOrganizationService(wfContext.InitiatingUserId);
            try
            {
                ExecuteActivity(context);   
            } catch (Exception ex) {
                TracingService.Trace("Unexpected error: {0} ({1})", ex.Message, ex);
                throw;
            }
        }

        /// <summary>
        /// Executes the custom workflow activity logic, after <see cref="Service"/> and <see cref="TracingService"/> 
        /// parameters have been initialised. Any uncaught exceptions are logged and re-thrown.
        /// </summary>
        /// <param name="context">The CodeActivity context.</param>
        protected abstract void ExecuteActivity(CodeActivityContext context);
    }
}
