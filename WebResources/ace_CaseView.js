var ace = ace || {};

ace.caseView = function() {

    // Locks the Start Date field if it contains data. Only execute on load.
    var assignLeads = function(selectedIds, grid) {
        var dialogParameters = { 
            pageType: "webresource",//required 
            webresourceName: "ace_assign-leads/index.html",//Html Webresource that will be shown 
            data: JSON.stringify(selectedIds)
        }; 
        var navigationOptions = { 
            target: 2,//use 1 if you want to open page inline or 2 to open it as dialog 
            width: 450, 
            height: 450, 
            position: 1//1 to locate dialog in center and 2 to locate it on the side 
        }; 
        Xrm.Navigation.navigateTo(dialogParameters, navigationOptions).then(
            function () {
                Xrm.Page.ui.setFormNotification("Assigning leads...", "INFO", "assigning-leads-msg");
                let timeout = setTimeout(() => {
                    clearTimeout(timeout);
                    grid.refresh();
                    Xrm.ui.clearFormNotification("assigning-leads-msg");
                }, 2000);
                
            }, 
            function(e) { 
                Xrm.Navigation.openAlertDialog({ text: e.message, title: "Error"});
            });
    };

    return {
        //ace.caseView.assignLeads()
        assignLeads: assignLeads
    };
}();
