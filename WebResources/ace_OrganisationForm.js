var ace = ace || {};
ace.organisationForm = function() {

    var setupProjectsGrid = function(executionContext) {
        debugger;
        var NAME_SGPROJECTS = "sgProjects";
        //You need the code below because using SetParameter in formContext.getControl("Credit_Performance") will not work.
        var subGrid = window.parent.document.getElementById(NAME_SGPROJECTS);
        if (subGrid == null || subGrid.control == null) {
            setTimeout( () => { setupProjectsGrid(executionContext)}, 1000);
        }
        var subGrid = subGrid.control;

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

    return {
        //ace.organisationForm.setupProjectsGrid
        setupProjectsGrid: setupProjectsGrid
    };
}();
