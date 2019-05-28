var ace = ace || {};
ace.emailRibbon = function() {

    var convertToCase = function(emailId) {

        var parameters = {};
        var entity = {};
        entity.id = emailId.replace("{", "").replace("}", "");
        entity.entityType = "email";
        parameters.entity = entity;

        var ace_CreateCaseFromEmailRequest = {
            entity: parameters.entity,

            getMetadata: function() {
                return {
                    boundParameter: "entity",
                    parameterTypes: {
                        "entity": {
                            "typeName": "mscrm.email",
                            "structuralProperty": 5
                        }
                    },
                    operationType: 0,
                    operationName: "ace_CreateCaseFromEmail"
                };
            }
        };

        Xrm.WebApi.online.execute(ace_CreateCaseFromEmailRequest).then(
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
