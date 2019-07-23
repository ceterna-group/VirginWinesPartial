({
	 doInit: function(component) {
        console.log('Record IDDD');
        console.log(component.get("v.recordId"));

        var action = component.get("c.isAccountDeleted");
                action.setParams({
                            recordId: component.get("v.recordId"),
                        });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var isDel = response.getReturnValue();
                        console.log(isDel);
                        component.set("v.isDeleted", isDel);
                    }
                    else if (state === "ERROR") {
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