({
	init : function (component) {
	    var reportTypeId = component.get("v.pageReference").state.recordTypeId;
        console.log(component.get("v.pageReference").state.recordTypeId);

        var action = component.get("c.getAccountRecordTypeID");
        action.setParams({
                    recordTypeId: reportTypeId,
                });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // do something with response.getReturnValue(), such as firing your create event here.
                var recordTypeName = response.getReturnValue();
                console.log(recordTypeName);
                if(recordTypeName === 'Person Account') {
                    component.set("v.isPersonAccount", true);
                    // Find the component whose aura:id is "flowData"
                    var flow = component.find("flowData");
                    console.log('Start flow');
                    flow.startFlow("New_Account");

                } else {
                    component.set("v.isPersonAccount", false);
                    var event = $A.get("event.force:createRecord");
                    event.setParams({
                        entityApiName: "Account",
                        recordTypeId: reportTypeId
                    })
                    event.fire();
                }
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
    },

    statusChange : function (component, event, helper) {
        if (event.getParam('status') === "FINISHED") {
           helper.setOutputVariables(component, event);
           helper.flowFinished(component, event);
       }
    },

    cancelAction : function (component, event, helper) {
        component.set("v.error", false);

        helper.cancelHelper(component);

    },

    restartFlow : function(component, helper) {
        component.set('v.error', false);
        var a = component.get('c.init');
        $A.enqueueAction(a);

    },
})