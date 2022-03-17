var ace = ace || {};
ace.strategicSupportForm = function() {


    var dateFields = {
        ace_11inductionmeetingheld: "ace_one2oneinductionmeetingheldon",
        ace_betaphaseend: "ace_betaphaseendon",
        ace_betaphasestart: "ace_betaphasestartedon",
        ace_boardpresentationdeckcomplete: "ace_boardpresentationdeckcompletedon",
        ace_boardpresentationdecksignedoffbyace: "ace_boardpresentationdecksignedoffbyaceon",
        ace_budgetcomplete: "ace_budgetcompletedon",
        ace_budgetsignedoffbyace: "ace_budgetsignedoffbyaceon",
        ace_changemanagementprocessinaction: "ace_changemanagementprocessinactionon",
        ace_datacapturemechanismforkpisinplace: "ace_datacapturemechanismforkpisinplaceon",
        ace_digitalarchitecturemappingcomplete: "ace_digitalinfrastructuremappingcompletedon",
        ace_digitalarchitecturemappingsignedoffbyace: "ace_digitalarchitecturemappingsignedoffbyaceo",
        ace_digitalcapacityassessment1complete: "ace_digitalassessment1completedon",
        ace_digitalcapacityassessment1issued: "ace_digitalassessment1issuedon",
        ace_digitalcapacityassessment2complete: "ace_digitalcapacityassessment2completedon",
        ace_digitalcapacityassessment2issued: "ace_digitalcapacityassessment2issuedon",
        ace_finalrelease: "ace_finalreleaseon",
        ace_followupcallcompleted: "ace_followupcallcompletedon",
        ace_highleveluserstoriescomplete: "ace_highleveluserstoriescompletedon",
        ace_highleveluserstoriessignedoffbyace: "ace_highleveluserstoriessignedoffbyaceon",
        ace_implementationstarted: "ace_implementationstartedon",
        ace_implementationtimelinecomplete: "ace_implementationtimelinecompletedon",
        ace_implementationtimelinesignedoffbyace: "ace_implementationtimelinesignedoffbyaceon",
        ace_internalandexternalcommsplancomplete: "ace_internalandexternalcommsplancompletedon",
        ace_internalandexternalcommsplansignedoffbyac: "ace_internalandexternalcommsplansignedoffon",
        ace_issueslogupdated: "ace_issueslogupdatedon",
        ace_kpisagreed: "ace_kpisagreedon",
        ace_kpisnowbeingmonitored: "ace_kpisnowbeingmonitoredon",
        ace_kpisupdate: "ace_kpisupdatedon",
        ace_mentorconfirmssolutionbeingseenwithinways: "ace_mentorconfirmssolutionbeingseenon",
        ace_programmesatisfactionsurvey: "ace_programmesatisfactionsurveycompletedon",
        ace_projectaimconfirmed: "ace_projectaimconfirmedon",
        ace_projectapprovedbyorganisationsboard: "ace_projectapprovedbyorganisationsboardon",
        ace_projectchartercomplete: "ace_projectchartercompletedon",
        ace_projectchartersignedoffbyace: "ace_projectchartersignedoffbyaceon",
        ace_projectscopeagreedbybp: "ace_projectscopeagreedbybpon",
        ace_riskregistercomplete: "ace_riskregistercompletedon",
        ace_riskregistersignedoffbyace: "ace_riskregistersignedoffbyaceon",
        ace_solutionidentified: "ace_solutionidentifiedon",
        ace_solutionimplemented: "ace_solutionimplementedon",
        ace_solutionprocured: "ace_solutionprocuredon",
        ace_stafftraining: "ace_stafftrainingcompletedon",
        ace_vendorassessmentcomplete: "ace_vendorassessmentcompletedon",
        ace_vendorassessmentsignedoffbyace: "ace_vendorassessmentsignedoffbyaceon"       
    };


    // Locks the Start Date field if it contains data. Only execute on load.
    var progressCompletedOnChange = function(executionContext) {
        var formContext = executionContext.getFormContext();
        var sourceAttribute = executionContext.getEventSource();
        var targetValue = (sourceAttribute.getValue() == 805290000) ? new Date() : null;
        var sourceFieldName = sourceAttribute.getName();
        var targetFieldName = dateFields[sourceFieldName];
        if (!targetFieldName) return;
        var targetAttribute = formContext.getAttribute(targetFieldName);
        if (!targetAttribute) return;
        targetAttribute.setValue(targetValue);
    };

    var progressPercentOnChange = function(executionContext) {
        var formContext = executionContext.getFormContext();
        var sourceAttribute = executionContext.getEventSource();
        var targetValue = (sourceAttribute.getValue() == 805290005) ? new Date() : null;
        var sourceFieldName = sourceAttribute.getName();
        var targetFieldName = sourceFieldName + "completedon";
        if (!targetFieldName) return;
        var targetAttribute = formContext.getAttribute(targetFieldName);
        if (!targetAttribute) return;
        targetAttribute.setValue(targetValue);
    }
    

    return {
        //ace.strategicSupportForm.progressCompletedOnChange(executionContext)
        progressCompletedOnChange: progressCompletedOnChange,
        //ace.strategicSupportForm.progressPercentOnChange(executionContext)
        progressPercentOnChange: progressPercentOnChange
    };
}();
