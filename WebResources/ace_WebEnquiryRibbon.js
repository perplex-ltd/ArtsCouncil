var ace = ace || {};
ace.webEnquiryRibbon = function() {

    var convertToCase = function(activityId) {

        var parameters = {};
        var entity = {};
        entity.id = activityId.replace("{", "").replace("}", "");
        entity.entityType = "ace_webenquiry";
        parameters.entity = entity;

        var ace_DCNConvertWebEnquirytoCaseRequest = {
            entity: parameters.entity,
        
            getMetadata: function() {
                return {
                    boundParameter: "entity",
                    parameterTypes: {
                        "entity": {
                            "typeName": "mscrm.ace_webenquiry",
                            "structuralProperty": 5
                        }
                    },
                    operationType: 0,
                    operationName: "ace_DCNConvertWebEnquirytoCase"
                };
            }
        };

        Xrm.WebApi.online.execute(ace_DCNConvertWebEnquirytoCaseRequest).then(
            function success(result) {
                if (result.ok) {
                    debugger;
                    result.json().then(r => {
                        debugger;
                        
                        var caseId = r.incidentid;
                        var entityFormOptions = {};
                        entityFormOptions["entityName"] = "incident";
                        entityFormOptions["entityId"] = caseId;

                        // Open the form.
                        Xrm.Navigation.openForm(entityFormOptions);
                    });
                }
            },
            function(error) {
                Xrm.Utility.alertDialog(error.message);
            }
        );

    };

    return {
        convertToCase: convertToCase
    };
}();
