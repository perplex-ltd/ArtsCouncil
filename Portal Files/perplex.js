if (typeof (Plx) == "undefined") {
    Plx = { __namespace: true };
}

Plx.Actions = {

    delete: function(id, entityName, websiteId) {
        var entityReference = {
            LogicalName: entityName,
            Id: id.replace("{", "").replace("}", "")
        };
        
        var myrequest = {
            type: "POST", 
            contentType: "application/json",
            url: "/_services/entity-grid-delete/" + websiteId,
            data: JSON.stringify(entityReference)
        }
        var promise = shell.ajaxSafePost(myrequest);
        return promise;
    }

};

