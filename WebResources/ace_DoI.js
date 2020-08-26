var ace = ace || { __namespace: true };

ace.doi = { 
    confirm: function(executionContext){ 
        Xrm.Utility.confirmDialog("Please confirm this declaration is correct.",
            function () {
                Xrm.Page.getAttribute("ace_updatedeclaration").setValue(true);
                Xrm.Page.data.entity.save();
            },
            function () {}
        );
    },

    shareMessageId: "ace.declarationOfInterests.shareMessage",

    share: function () {
        var formContext = Xrm.Page;
        formContext.ui.clearFormNotification(ace.doi.shareMessageId);

        var lookupOptions = {
            defaultEntityType: "account",
            entityTypes: ["systemuser"],
            allowMultiSelect: false,
            defaultViewId: "00000000-0000-0000-00AA-000010001019",
            viewIds: ["00000000-0000-0000-00AA-000010001019"]
        };

        Xrm.Utility.lookupObjects(lookupOptions)
            .then(this.runShareAction,
                function () {
                    formContext.ui.setFormNotification("Sorry, there's a problem...", "ERROR", ace.doi.shareMessageId);
                },
            );
    },

    runShareAction: function (result) {
        if (result && result.length > 0) {
            var userId = result[0].id;
            var userName = result[0].name;
            var entityId = Xrm.Page.data.entity.getId();
            // CRM REST Builder code...
            var parameters = {};
            var entity = {};
            entity.id = entityId;
            entity.entityType = "ace_declarationofinterest";
            parameters.entity = entity;
            var user = {};
            user.systemuserid = userId;
            user["@odata.type"] = "Microsoft.Dynamics.CRM.systemuser";
            parameters.User = user;

            var ace_DoIShareRegisterRequest = {
                entity: parameters.entity,
                User: parameters.User,

                getMetadata: function() {
                    return {
                        boundParameter: "entity",
                        parameterTypes: {
                            "entity": {
                                "typeName": "mscrm.ace_declarationofinterest",
                                "structuralProperty": 5
                            },
                            "User": {
                                "typeName": "mscrm.systemuser",
                                "structuralProperty": 5
                            }
                        },
                        operationType: 0,
                        operationName: "ace_DoIShareRegister"
                    };
                }
            };

            Xrm.WebApi.online.execute(ace_DoIShareRegisterRequest).then(
                function success(result) {
                    if (result.ok) {
                        Xrm.Page.ui.setFormNotification("This register can now be edited by " + userName + ".", 
                            "INFORMATION", ace.doi.shareMessageId);
                    }
                },
                function(error) {
                    Xrm.Page.ui.setFormNotification(error.message, "ERROR", ace.doi.shareMessageId);
                }
            );

        };
    }
}