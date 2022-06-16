var ace = ace || {};
ace.eventsForm = function() {

    var onload = function(executionContext) {
        var formContext = executionContext.getFormContext();
        try {
            let isDcnEvent = formContext.getAttribute("ace_isdcnevent").getValue()
            formContext.ui.tabs.get("cdi_generaltab").sections.get("ace_DCN").setVisible(isDcnEvent);
        } catch (errror) {
            //ignore...
        }
        var attendedManualField = Xrm.Page.getControl("ace_attendedmanual");
        if (attendedManualField) attendedManualField.setDisabled(false);
    };

    return {
        //ace.eventsForm.onload(executionContext)
        onload: onload
    };
}();
