({
	init : function(component, event, helper) {
		var flow = component.find("flowData");
        console.log('Start flow');
        var inputVariables = [
        	            {
        	                name : "recordId",
        	                type : "String",
        	                value : component.get("v.recordId")
        	                //value : component.get("v.recordId")
        	            }
        	        ];
        flow.startFlow("New_Account", inputVariables);
	},

	statusChange : function (component, event, helper) {
            window.console.log('dddd');
             window.console.log('FInish');
           var navEvt = $A.get("e.force:navigateToSObject");
           navEvt.setParams({
           "recordId": component.get("v.recordId"),
           "slideDevName": "related",
           "isredirect": true
           });
           navEvt.fire();
        },
})