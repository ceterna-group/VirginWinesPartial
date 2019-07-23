({
    init : function(component, event, helper) {
        /*$A.get( "e.force:navigateToSObject" ).setParams( {
            "recordId": component.get( "v.recId" ),
            "slideDevName": "related"
        } ).fire();*/
         $A.get('e.force:refreshView').fire();
    }
})