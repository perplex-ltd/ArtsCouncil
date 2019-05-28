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
    public sealed class ConvertPostedFormToWebEnquiry : BaseWorkflowActivity
    {
        /// <summary>
        /// The logical name of the Web Enquiry entity.
        /// </summary>
        const string WebEnquiryName = "ace_webenquiry";

        /// <summary>
        /// A reference to the posted form. Its posted fields will be used to make up the Web Enquiry record.
        /// </summary>
        [Input("Posted Form")]
        [ReferenceTarget("cdi_postedform")]
        [ArgumentRequired(true)]
        public InArgument<EntityReference> PostedForm { get; set; }

        [Output("Web Enquiry")]
        [ReferenceTarget(WebEnquiryName)]
        public OutArgument<EntityReference> WebEnquiry { get; set; }

        /// <summary>
        /// Creates a Web Enquiry record based on the <see cref="PostedForm"/>.
        /// </summary>
        /// <param name="context"></param>
        protected override void ExecuteActivity(CodeActivityContext context)
        {
            // Get and check entity reference
            EntityReference postedForm = PostedForm.Get(context);
            if (postedForm == null)
            {
                throw new InvalidOperationException("Posted Form has not been specified", new ArgumentNullException("Posted Form"));
            }
            TracingService.Trace("Posted Form {0}", postedForm);
            var targetFields = new List<AttributeMetadata>(EnumerateWebEnquiryFields(Service));
            var postedFields = new List<KeyValuePair<string, string>>(EnumeratePostedFields(Service, postedForm.Id));
            Entity webEnquiry = new Entity(WebEnquiryName);
            foreach (var postedField in postedFields)
            {
                var targetField = targetFields.Find(a => a.LogicalName == postedField.Key);
                if (targetField != null)
                {
                    if (targetField.AttributeType.HasValue)
                    {
                        var targetValue = ConvertValue(postedField.Value, targetField.AttributeType.Value);
                        if (targetValue != null)
                        {
                            TracingService.Trace("Setting value {0}", targetValue);
                            webEnquiry[targetField.LogicalName] = targetValue;
                        }
                    }
                }
            }
            // add other things
            var postedFormEntity = Service.Retrieve(postedForm.LogicalName, postedForm.Id, new ColumnSet(new string[] { "cdi_contactid" }));
            webEnquiry["ace_senderid"] = postedFormEntity["cdi_contactid"];
            webEnquiry["senton"] = DateTime.Now;
            // go on and create it
            TracingService.Trace("Creating web enquiry...");
            Guid id = Service.Create(webEnquiry);
            TracingService.Trace("Web Enquiry created ({0})", id);
            WebEnquiry.Set(context, new EntityReference(WebEnquiryName, id));
        }

        /// <summary>
        /// Converts (parses) the supplied text value into a value compatible with <see cref="type"/>
        /// </summary>
        /// <param name="value"></param>
        /// <param name="type"></param>
        /// <returns>A value or null.</returns>
        private object ConvertValue(string value, AttributeTypeCode type)
        {
            if (value == null) return null;
            try
            {
                switch (type)
                {
                    case AttributeTypeCode.BigInt:
                        return Int64.Parse(value);
                    case AttributeTypeCode.Boolean:
                        return Boolean.Parse(value);
                    case AttributeTypeCode.DateTime:
                        return DateTime.Parse(value);
                    case AttributeTypeCode.Decimal:
                        return Decimal.Parse(value);
                    case AttributeTypeCode.Double:
                        return double.Parse(value);
                    case AttributeTypeCode.Integer:
                        return int.Parse(value);
                    case AttributeTypeCode.Memo:                        
                    case AttributeTypeCode.String:
                        return value as string;
                    case AttributeTypeCode.Money:
                        return new Money(Decimal.Parse(value));
                    case AttributeTypeCode.Picklist:
                        return new OptionSetValue(int.Parse(value));
                    default:
                        return null;
                }
            } catch (FormatException)
            {
                return null;
            }
        }

        private IEnumerable<KeyValuePair<string, string>> EnumeratePostedFields(IOrganizationService service, Guid postedFormId)
        {
            TracingService.Trace("EnumberatePostedFields");
            // Query posted fields referenced in Posted Form.
            string fetchXml = @"
<fetch>
  <entity name='cdi_postedfield' >
    <attribute name='cdi_value' />
    <filter>
      <condition attribute='cdi_postedformid' operator='eq' value='{0}' />
    </filter>
    <link-entity name='cdi_formfield' from='cdi_formfieldid' to='cdi_formfieldid' alias='field' >
      <attribute name='cdi_fieldid' />
    </link-entity>
  </entity>
</fetch>
";
            fetchXml = string.Format(fetchXml, postedFormId);
            EntityCollection resultCollection = service.RetrieveMultiple(new FetchExpression(fetchXml));
            foreach (var e in resultCollection.Entities)
            {
                if (e.Contains("cdi_value"))
                {
                    var result = new KeyValuePair<string, string>(
                        (string)e.GetAttributeValue<AliasedValue>("field.cdi_fieldid").Value,
                        (string)e["cdi_value"]);
                    TracingService.Trace("Enumerating posted field {0} ({1})", result.Key, result.Value);
                    yield return result;
                }
            }
        }

        /// <summary>
        /// Enumerates all logical names of the Web Enquiry's attributes
        /// </summary>
        /// <param name="service"></param>
        /// <returns></returns>
        private IEnumerable<AttributeMetadata> EnumerateWebEnquiryFields(IOrganizationService service)
        {
            TracingService.Trace("EnumerateWebEnquiry Fields...");
            RetrieveEntityRequest req = new RetrieveEntityRequest
            {
                EntityFilters = EntityFilters.Attributes,
                LogicalName = WebEnquiryName 
            };
            RetrieveEntityResponse res = (RetrieveEntityResponse)service.Execute(req);
            EntityMetadata currentEntity = res.EntityMetadata;
            foreach (AttributeMetadata attribute in currentEntity.Attributes)
            {
                TracingService.Trace("Web Enquiry field {0}", attribute);
                yield return attribute;
            }
        }
    }
}
