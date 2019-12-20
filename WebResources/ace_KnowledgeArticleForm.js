var ace = ace || {};
ace.knowledgeArticle= (function() {

    class KnowledgeArticleForm {
        
        titleChanged(executionContext) {
			var formContext = executionContext.getFormContext(); // get formContext
            var attribute = formContext.getAttribute("title");
			if (attribute) {
				var title = attribute.getValue();
				if (title) {
					title = title.replace(/([a-z])([A-Z])/g, "$1-$2"); // camelCase => camel Case
					title = title.replace(/\W/g, "-"); // replace any special characters with space
					title = title.replace(" ", "-").toLowerCase();
					var partialUrlAttribute = formContext.getAttribute("ace_seoid");
					if (partialUrlAttribute != null) {
						if (!partialUrlAttribute.getValue()) {
							partialUrlAttribute.setValue(title);
						}
					}
				}
			}
        }

    }

    return new KnowledgeArticleForm();
})();

