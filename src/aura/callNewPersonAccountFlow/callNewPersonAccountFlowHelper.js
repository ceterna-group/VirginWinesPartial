({
    personAccountFlowAction : function(component) {
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
                    var inputVariables = [
                    {
                        name : "firstName",
                        type : "String",
                        value : component.get("firstName")
                    },
                    {
                        name : "lastName",
                        type : "String",
                        value : component.get("lastName")
                    },
                    {
                        name : "salutationOutput",
                        type : "String",
                        value : component.get("salutationOutput")
                    },
                    {
                        name : "storeOutput",
                        type : "String",
                        value : component.get("storeOutput")
                    },
                    {
                        name : "tel1",
                        type : "String",
                        value : component.get("tel1")
                    },
                    {
                        name : "tel2",
                        type : "String",
                        value : component.get("tel2")
                    },
                    {
                        name : "tel3",
                        type : "String",
                        value : component.get("tel3")
                    },
                    {
                        name : "allowContact",
                        type : "Boolean",
                        value : component.get("allowContact")
                    },
                    {
                        name : "DateBirthday",
                        type : "Date",
                        value : component.get("DateBirthday")
                    }
                ];
                // In that component, start your flow. Reference the flow's Unique Name.
                flow.startFlow("New_Account", inputVariables);
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

	cancelHelper : function(component) {
		var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": "Account"
            });
            homeEvt.fire();
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
       .catch(function(error) {
            console.log(error);
       });
	},

	setOutputVariables : function(component, event) {
	    var outputVariables = event.getParam("outputVariables");

        console.log('outputVariables');
        console.log(outputVariables);
        var outputVar;
        for(var i = 0; i < outputVariables.length; i++) {
            outputVar = outputVariables[i];
            // Pass the values to the component's attributes
            if(outputVar.name === "accountId") {
                if(outputVar.value != null) {
                    component.set("v.accountId", outputVar.value);
                    console.log("testeststets");
                    console.log(component.get("v.accountId"));
                }
            }
        }
	},

	treatCalloutResponse : function(component, event) {
	    // smth after two seconds
        // check component.isValid() if you want to work with component
        var action = component.get("c.getCalloutRecord");
        action.setParams({
            methodName: component.get("v.methodName"),
            accountId: component.get("v.accountId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state');
            console.log(state);
            if (state === "SUCCESS") {
                component.set("v.loading", false);
                // do something with response.getReturnValue(), such as firing your create event here.
                var calloutRecord = response.getReturnValue();
                console.log('calloutRecord');
                console.log(calloutRecord);
                console.log(calloutRecord.length);
                console.log(calloutRecord[0].JSON_Received__c);
                console.log(calloutRecord[0].Status_Code__c);
                if((calloutRecord[0].Status_Code__c >= 400 && calloutRecord[0].Status_Code__c <= 600) || calloutRecord[0].Status_Code__c === 0 || calloutRecord[0].Status_Code__c === 208 || calloutRecord.length === 0) {

                    if(calloutRecord.length == 0) {
                        component.set("v.statusCode", 'None')
                        component.set("v.body", 'CPU Time Limit Exceeded');
                    } else {
                        component.set("v.statusCode", calloutRecord[0].Status_Code__c)
                        component.set("v.body", calloutRecord[0].JSON_Received__c);
                    }

                    component.set("v.error", true);
                } else {
                    var homeEvt = $A.get("e.force:navigateToSObject");
                    homeEvt.setParams({
                        "recordId": component.get("v.accountId"),
                        "slideDevName": "Detail",
                        "isredirect": true
                    });
                    homeEvt.fire();
                }

            } else if (state === "ERROR") {
                component.set("v.loading", false);
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
        component.set("v.loading", true);
        window.setTimeout(
            $A.getCallback(function() {
                $A.enqueueAction(action);
            }), 2000
        );
	},

	restartFlow : function (component, event) {
        var flow = cmp.find("flowData");
            var inputVariables = [
                {
                    name : 'firstName',
                    type : 'String',
                    value : component.get('firstName')
                },
                {
                    name : 'lastName',
                    type : 'String',
                    value : component.get('lastName')
                },
                {
                    name : 'salutationOutput',
                    type : 'String',
                    value : component.get('salutationOutput')
                },
                {
                    name : 'storeOutput',
                    type : 'String',
                    value : component.get('storeOutput')
                },
                {
                    name : 'tel1',
                    type : 'String',
                    value : component.get('tel1')
                },
                {
                    name : 'tel2',
                    type : 'String',
                    value : component.get('tel2')
                },
                {
                    name : 'tel3',
                    type : 'String',
                    value : component.get('tel3')
                },
                {
                    name : 'allowContact',
                    type : 'Boolean',
                    value : component.get('allowContact')
                },
                {
                    name : 'DateBirthday',
                    type : 'Date',
                    value : component.get('DateBirthday')
                }
            ];
            flow.startFlow("New_Account", inputVariables);
	},

	flowFinished: function (component, event) {
	    component.set('v.isPersonAccount', false);
        console.log('Finish');

        console.log(component.get("v.accountId"));
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
        "recordId": component.get("v.accountId"),
        "slideDevName": "related",
        "isredirect": true
        });
        navEvt.fire();
	},
})