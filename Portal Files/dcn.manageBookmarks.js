if (typeof (dcn) == "undefined") {
    dcn = { __namespace: true };
}
dcn.manageBookmarks = {

    add: function(articleId) {
        _manageBookmark("add", articleId).then(function() {
            $("#bookmark_off" + articleId).hide();
            $("#bookmark_on" + articleId).show()
        }); 
    },
    remove: function(articleId) {
        _manageBookmark("remove", articleId).then(function() {
            $("#bookmark_on" + articleId).hide();
            $("#bookmark_off" + articleId).show()
        }); 
    },

    _manageBookmark: function(action, articleId) {
        return  $.getJSON( "/services/manageBookmarks/?action=" + action + "&articleid=" + articleId );
    }
};

dcn.actions = {
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