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
        showHideNLPGTargetedApplicantFields(ec);
        showHidePriorities(ec);
    };

    var safeSetVisible = function(formCtx, field, visibility) {
        const attribute = formCtx.getAttribute(field);
        if (attribute) {
            attribute.controls.forEach(c => {
                c.setVisible(visibility);
            });
        }
    };

    
    var safeSetRequired = function(formCtx, field, required) {
        const attribute = formCtx.getAttribute(field);
        if (attribute) {
            attribute.setRequiredLevel(required ? "required": "none");
        }
    };

    var showHideNLPGTargetedApplicantFields = function (executionContext) {
        const formCtx = executionContext.getFormContext();
        const fundingprogramme = formCtx.getAttribute("ace_fundingprogramme")?.getValue();
        const targetedapplicant = formCtx.getAttribute("ace_targetedapplicant")?.getValue();
        var nlpgTargetedApplicant = false;
        // if funding programme is NLPG New and targeted applicant is true
        if (fundingprogramme && targetedapplicant) {
            nlpgTargetedApplicant = targetedapplicant &&
                fundingprogramme.length == 1 && 
                fundingprogramme[0].name == 'National Lottery Project Grants New'
        }
        safeSetVisible(formCtx, "ace_firsttimeapplicant", nlpgTargetedApplicant);
        safeSetRequired(formCtx, "ace_firsttimeapplicant", nlpgTargetedApplicant);
        safeSetVisible(formCtx, "ace_targetapplicantgroupmultiselect", nlpgTargetedApplicant);
        safeSetRequired(formCtx, "ace_targetapplicantgroupmultiselect", nlpgTargetedApplicant);

        safeSetVisible(formCtx, "ace_sendnlpgadvicegivingsurvey", nlpgTargetedApplicant);
        sendnlpgadvicegivingsurvey = formCtx.getAttribute("ace_sendnlpgadvicegivingsurvey");
        if (sendnlpgadvicegivingsurvey) sendnlpgadvicegivingsurvey.setValue(nlpgTargetedApplicant);
    };

    var showHidePriorities = function(executionContext) {
        const formCtx = executionContext.getFormContext();
        const value =  formCtx.getAttribute("ace_targetapplicantgroupmultiselect")?.getValue();
        const prioritiesSelected = value && value.find(el => el == 805290002) == 805290002;
        safeSetVisible(formCtx, "ace_priorities", prioritiesSelected);
        safeSetRequired(formCtx, "ace_priorities", prioritiesSelected);
    };

    return {
        //ace.adviceGivingForm.updateToField(executionContext)
        updateToField: updateToField,
        onLoad: onLoad,
        showHideNLPGTargetedApplicantFields: showHideNLPGTargetedApplicantFields,
        showHidePriorities: showHidePriorities
    };
}();