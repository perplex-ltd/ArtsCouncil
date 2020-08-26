var ace = ace || { __namespace: true };

ace.projectForm = {

    projectContactChanged: function (executionContext) {

        var formContext = executionContext.getFormContext();
        var overriddenAttribute = formContext.getAttribute("ace_projectcontactoverridden");
        if (!overriddenAttribute) return;
        overriddenAttribute.setValue(true);
    }

}