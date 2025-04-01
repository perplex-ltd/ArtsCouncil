var ace = ace || { __namespace: true };

ace.ACENCaseForm = {

    showResolveCaseDialog: function(pageContext) {
        Xrm.Navigation.navigateTo({ 
            pageType: "custom", 
            name: "ace_resolveacencase_edac4", 
            entityName: "ace_acencase", 
            recordId: Xrm.Page.data.entity.getId()
         }, {
            target:2, 
            width: 700, 
            height: 470
         })
         .then(function() {
            pageContext.data.refresh()
         })
         .catch(console.error);
    },

    showCancelCaseDialog: function() {
        Xrm.Navigation.navigateTo({ 
            pageType: "custom", 
            name: "ace_cancelacencase_e7b03", 
            entityName: "ace_acencase", 
            recordId: Xrm.Page.data.entity.getId()
         }, {
            target:2, 
            width: 700, 
            height: 400
         })
         .then(function() {
            pageContext.data.refresh()
         })
         .catch(console.error)
    }


}
