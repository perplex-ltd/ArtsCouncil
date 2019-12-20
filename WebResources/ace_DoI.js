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
    }
}