var ace = ace || {};
ace.organisationForm = function() {

    var setupProjectsGrid = function(executionContext) {
        var NAME_SGPROJECTS = "sgProjects";
        //You need the code below because using SetParameter in formContext.getControl("controlname") will not work.
        var subGrid = window.parent.document.getElementById(NAME_SGPROJECTS);
        if (subGrid == null || subGrid.control == null) {
            setTimeout( () => { setupProjectsGrid(executionContext)}, 683);
            return;
        }

        var formContext = executionContext.getFormContext();
        var accountId = formContext.data.entity.getId();
        var fetchXml = 
        '<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false" >' +
            '<entity name="adv_project" >' +
            '<attribute name="adv_stage" />' +
            '<attribute name="adv_mainapplicant" />' +
            '<attribute name="adv_projectstatus" />' +
            '<attribute name="adv_projectname" />' +
            '<attribute name="adv_name" />' +
            '<attribute name="adv_grantiumapplicantnumber" />' +
            '<attribute name="adv_projectid" />' +
            '<order attribute="adv_mainapplicant" descending="false" />' +
            '<filter type="and" >' +
            '    <condition attribute="statecode" operator="eq" value="0" />' +
            '</filter>' +
            '<link-entity name="account" from="accountid" to="adv_mainapplicant" >' +
            '    <filter type="or" >' +
            '    <condition attribute="accountid" operator="eq" value="' + accountId + '" />' +
            '    <condition attribute="accountid" operator="under" value="' + accountId + '" />' +
            '    </filter>' +
            '</link-entity>' +
            '</entity>' +
        '</fetch>';
        subGrid.control.SetParameter("fetchXml", fetchXml);
        subGrid.control.refresh();

    };

    var setupContactsGrid = function(executionContext) {
        //You need the code below because using SetParameter in formContext.getControl("controlname") will not work.
        var subGrid = window.parent.document.getElementById("subgridContacts");
        if (subGrid == null || subGrid.control == null) {
            setTimeout( () => { setupContactsGrid(executionContext)}, 647);
            return;
        }

        var formContext = executionContext.getFormContext();
        var accountId = formContext.data.entity.getId();
        var fetchXml = 
        '<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">' +
        '  <entity name="contact">' +
        '    <attribute name="fullname" />' +
        '    <attribute name="parentcustomerid" />' +
        '    <attribute name="emailaddress1" />' +
        '    <attribute name="jobtitle" />' +
        '    <attribute name="contactid" />' +
        '    <order attribute="fullname" descending="false" />' +
        '    <filter type="and">' +
        '      <condition attribute="statecode" operator="eq" value="0" />' +
        '    </filter>' +
        '  </entity>' +
        '</fetch>';
        subGrid.control.SetParameter("fetchXml", fetchXml);
        subGrid.control.refresh();

    };


    var setArenaLink = function(executionContext) {
        var formContext = executionContext.getFormContext();
        var urnAttribute = formContext.getAttribute("new_urn");
        if (!urnAttribute) return;
        var urn = urnAttribute.getValue();
        var arenaLinkAttribute = formContext.getAttribute("ace_arenaurl");
        if (!arenaLinkAttribute) return;
        var link = "";
        if (urn) {
            link = "http://arena:8004/parties-extension/organisation?party_id=" + urn + "&mode=view";
        }
        arenaLinkAttribute.setValue(link);
    };

    return {
        //ace.organisationForm.setupProjectsGrid(executionContext)
        setupProjectsGrid: setupProjectsGrid,
        //ace.organisationForm.setArenaLink(executionContext)
        setArenaLink: setArenaLink,
        //ace.organisationForm.setupContactsGrid(executionContext)
        setupContactsGrid: setupContactsGrid
    };
}();
