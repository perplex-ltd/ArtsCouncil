var dcn = dcn || {};
dcn.manageBookmarks = function() {

    var add = function(articleId) {
        manageBookmark("add", articleId).then(function() {
            $("#bookmark_off" + articleId).hide();
            $("#bookmark_on" + articleId).show()
        }); 
    };
    var remove = function(articleId) {
        manageBookmark("remove", articleId).then(function() {
            $("#bookmark_on" + articleId).hide();
            $("#bookmark_off" + articleId).show()
        }); 
    };

    var manageBookmark = function(action, articleId) {
        return  $.getJSON( "/services/manageBookmarks/?action=" + action + "&articleid=" + articleId );
    };

    return {
        add: add, //dcn.manageBookmarks.add(articleId)
        remove: remove //dcn.manageBookmarks.remove(articleId)
    };
}();
