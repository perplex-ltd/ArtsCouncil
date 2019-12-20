var ace = ace || { __namespace: true };

ace.utility = {

    suggestUrlFromName: function (executionContext, sourceAttribute, targetAttribute) {
        var formContext = executionContext.getFormContext(); // get formContext
        var attribute = formContext.getAttribute(sourceAttribute);
        var targetAttribute = formContext.getAttribute(targetAttribute);
        if (attribute && targetAttribute) {
            var title = attribute.getValue();
            if (title) {
                if (!targetAttribute.getValue()) {
                    title = title.replace(/([a-z])([A-Z])/g, "$1-$2"); // camelCase => camel Case
                    title = title.replace(/\W/g, "-"); // replace any special characters with space
                    title = title.replace(" ", "-").toLowerCase();
                    title = title.replace(/\-+/g, "-");
                    targetAttribute.setValue(title);
                }
            }
        }
    }
}