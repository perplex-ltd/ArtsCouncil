var ace = ace || {};
ace.activityRibbon = function() {

    // Locks the Start Date field if it contains data. Only execute on load.
    var JSHookEnableRule = function(primaryControl) {
        debugger;
        $(document).ready(hideUnusedActivities);
        return false;
    };


    var hideUnusedActivities = function() {
        debugger;
    }

    return {
        //ace.activityRibbon.JSHookEnableRule(...)
        JSHookEnableRule: JSHookEnableRule,
        //ace.activityRibbon.hideUnusedActivities()
        hideUnusedActivities: hideUnusedActivities
    };
}();
