var ace = ace || {};
ace.caseForm = function() {

    // Locks the Start Date field if it contains data. Only execute on load.
    var lockStartDate = function(executionContext) {
        var formContext = executionContext.getFormContext();
        var slaStartAttribute = formContext.getAttribute("ace_slastart");
        if (slaStartAttribute && slaStartAttribute.getValue()) {
            slaStartControl = formContext.getControl("header_ace_slastart");
            if (slaStartControl) {
                slaStartControl.setDisabled(true);
            }
        }
    };

    var setupForm = function(executionContext) {
        togglePartnershipType(executionContext);
    };

    var togglePartnershipType = function(ctx) {
        var form = ctx.getFormContext();
        var supportTypeAttribute = form.getAttribute("ace_supporttyperequired");
        var typeOfPartnershipAttr = form.getAttribute("ace_typeofpartnership");
        if (supportTypeAttribute && typeOfPartnershipAttr) {
            var typeOfPartnershipCtrl = typeOfPartnershipAttr.controls.getByIndex(0);
            if (supportTypeAttribute.getValue() == 805290003) {
                typeOfPartnershipAttr.setRequiredLevel("required");
                typeOfPartnershipCtrl.setVisible(true);
            } else {
                typeOfPartnershipAttr.setRequiredLevel("none");
                typeOfPartnershipCtrl.setVisible(false);
            }

        }
    };

    return {
        //ace.caseForm.lockStartDate(executionContext)
        lockStartDate: lockStartDate,
        //ace.caseForm.setupForm(executionContext)
        setupForm: setupForm,
        //ace.caseForm.togglePartnershipType(ctx)
        togglePartnershipType: togglePartnershipType
    };
}();
