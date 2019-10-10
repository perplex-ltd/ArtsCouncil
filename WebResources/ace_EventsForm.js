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
    };

    return {
        //ace.eventsForm.onload(executionContext)
        onload: onload
    };
}();
