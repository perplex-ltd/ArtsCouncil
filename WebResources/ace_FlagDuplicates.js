var ace = ace || {};
ace.flagDuplicates = function() {



    var flagDuplicateRecords = function(primaryEntity, entityIds) {
       
        var globalContext = Xrm.Utility.getGlobalContext();
        clientUrl = globalContext.getClientUrl();
        let flowUrl = null;
        if (clientUrl == 'https://arts1.crm11.dynamics.com') {
            flowUrl = "https://prod-11.uksouth.logic.azure.com:443/workflows/59512b132a044d76a99db85d92148a77/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=zlgt2IdoO5PivR9v3nK5k1GGHjz92GUmqRwvKhvxYwc";
        } else if (clientUrl == 'https://artslive.crm11.dynamics.com') {
            flowUrl = "https://prod-15.uksouth.logic.azure.com:443/workflows/ba7a74e9bb3f4db2a9dacf57989da251/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=k51bfKymIs9tCPvHYPIXRcteySYqQGj4yAQFA_DROWk";
        }

        // define notification object
        let notification = {
            type: 2,
            level: 4, //info
            message: "Flagging selected records as duplicates...",
            showCloseButton: true
        }

        var notificationId = null;

        Xrm.App.addGlobalNotification(notification).then(
            function success(result) {
                notificationId = result;
                // Wait for 5 seconds and then clear the notification
                window.setTimeout(function () { 
                    Xrm.App.clearGlobalNotification(result); }, 5000);
            },
            function (error) {
                console.log(error.message);
                // handle error conditions
            }
        );

        let requestBody = {
            "user": globalContext.getUserName(),
            "entity": primaryEntity.getEntityName(),
            "records": entityIds
        };

        let req = new XMLHttpRequest();
        req.open("POST", flowUrl, true);
        req.setRequestHeader("Content-Type", "application/json");
        req.onreadystatechange = function () {
            if (this.readyState === 4) {
                req.onreadystatechange = null;
                if (this.status === 200 || this.status === 202) {
                    let resultJson = JSON.parse(this.response);
                    
                    // do nothing...
                } else {
                    if (notificationId) {
                        Xrm.App.clearGlobalNotification(notificationId);
                    }
                    Xrm.App.addGlobalNotification({
                        type: 2,
                        level: 4, //error
                        message: "Couldn't flag records as duplicates: "+ this.statusText,
                        showCloseButton: true
                    });
                    console.log(this.statusText);
                }
            }
        };
        req.send(JSON.stringify(requestBody));
    };

    

    return {
        //ace.flagDuplicates.flagDuplicateRecords(PrimaryControl, SelectedControlSelectedIds)
        flagDuplicateRecords:  flagDuplicateRecords
    };
}();
