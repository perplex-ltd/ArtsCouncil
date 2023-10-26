var ace = ace || {};
ace.adviceGivingForm = function() {


    /* Updates the To field to include any person (contact) in the regarding field
     * Supposed to run on load and on change of the regarding field
     */
    var updateToField = function(executionContext) {
        const formCtx = executionContext.getFormContext();
        const regarding = formCtx.getAttribute("regardingobjectid")?.getValue();
        if (regarding) {
            // only do anything is regarding is set to a contact...
            if (regarding[0].entityType === "contact") {
                const toAttribute = formCtx.getAttribute("to");
                if (toAttribute) {
                    if ( toAttribute.getValue() == null) {
                        // if to is empty, add regarding contact into To field
                        toAttribute.setValue(regarding);
                    } else {
                        // otherwise, add regarding contact if it's not there yet    
                        let contactFound = false;
                        toAttribute.getValue().forEach(v => {contactFound ||= v.id === regarding[0].id});
                        if (!contactFound) {
                            const to = toAttribute.getValue();
                            to.push(regarding[0]);
                            toAttribute.setValue(to);
                        }
                    }
                }
            }
        }
    };
    var onLoad = function(ec) {
        if (!ec.getFormContext().data.entity.getId()) {
            ace.adviceGivingForm.updateToField(ec);
        }
    };

    return {
        //ace.adviceGivingForm.updateToField(executionContext)
        updateToField: updateToField,
        onLoad: onLoad
    };
}();