var ace = ace || { __namespace: true };

ace.contactForm = {

    updateArenaLink: function (executionContext) {

        var formContext = executionContext.getFormContext();
        var urnAttribute = formContext.getAttribute("new_arenacontacturn");
        if (!urnAttribute) return;
        var urn = urnAttribute.getValue();
        var arenaLinkAttribute = formContext.getAttribute("ace_arenaurl");
        if (!arenaLinkAttribute) return;
        var link = "";
        if (urn) {
            link = "http://arena:8004/parties-extension/contact?party_id=" + urn + "&mode=view";
        }
        arenaLinkAttribute.setValue(link);

    },

    hideOrShowMPTab : function (executionContext) {
        var formContext = executionContext.getFormContext();
        var memberIdAttribute = formContext.getAttribute("ace_mpmemberid");
        if (!memberIdAttribute) return;
        var isMember = (memberIdAttribute.getValue() ? true : false);
        formContext.ui.tabs.get("tab_MPDetails").setVisible(isMember);
    }


}