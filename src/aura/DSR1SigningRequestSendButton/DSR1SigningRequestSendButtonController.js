({
    "doInit": function(cmp, evt) {
        var loadRecordAction = cmp.get("c.loadRecord");
        cmp.set("v.initialStatus", null);
        $A.enqueueAction(loadRecordAction);
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
                if (!cmp.get("v.initialStatus")) {
                    cmp.set("v.initialStatus", response.getReturnValue().Status__c);
                }
                if (response.getReturnValue().Status__c === 'Pending') {
                    window.setInterval(
                        $A.getCallback(function() {
                            if (cmp.isValid()) {
                                var loadRecordAction = cmp.get("c.loadRecord");
								$A.enqueueAction(loadRecordAction);
                            }
                        }), 10000
                    );
                } else {
                    if (cmp.get("v.initialStatus") === "Pending") {
                    	$A.get("e.force:refreshView").fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    "onSendClick" : function(cmp, evt) {
        var action = cmp.get("c.sendEnvelope");
        action.setParams({
            "signingRequestId" : cmp.get("v.recordId"),
            "successRedirect": cmp.get("v.successRedirect"),
            "failRedirect": cmp.get("v.failRedirect"),
            "namedCredentialAPIName": cmp.get("v.namedCredentialAPIName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if (response.getReturnValue()) {
                    window.location.assign(response.getReturnValue());
                } else {
                    $A.get('e.force:refreshView').fire();
                }
            }
            else if (cmp.isValid() && state === "INCOMPLETE") {
				// TBD
            }
            else if (cmp.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);

    }
})