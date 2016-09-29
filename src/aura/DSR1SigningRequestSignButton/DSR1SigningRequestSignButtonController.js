({
    "doInit": function(cmp, evt) {
        var loadRecordAction = cmp.get("c.loadRecord");
        $A.enqueueAction(loadRecordAction);
        var getCurrentUserIdAction = cmp.get("c.getCurrentUserId");
    	getCurrentUserIdAction.setCallback(this, function(response) {
        	var state = response.getState();
        	if (state === "SUCCESS") {
            	cmp.set("v.currentUserId", response.getReturnValue());
         	}
        });
        $A.enqueueAction(getCurrentUserIdAction);
    },
    "loadRecord" : function(cmp, evt) {
        var action = cmp.get("c.getSigningRequestById");
        action.setParams({
            "signingRequestId": cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	cmp.set("v.signingRequest", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    "onSignClick" : function(cmp, evt) {
        
        var action = cmp.get("c.signEnvelope");
        action.setParams({
            "signingRequestId": cmp.get("v.recordId"),
            "successRedirect": cmp.get("v.successRedirect"),
            "failRedirect": cmp.get("v.failRedirect"),
            "communityUrl": cmp.get("v.communityUrl"),
            "namedCredentialAPIName": cmp.get("v.namedCredentialAPIName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if (response.getReturnValue()) {
                    window.location.assign(response.getReturnValue());
                } else {
                    $A.get("e.force:refreshView").fire();
                }
            }
        });
        $A.enqueueAction(action);
        
    }
})