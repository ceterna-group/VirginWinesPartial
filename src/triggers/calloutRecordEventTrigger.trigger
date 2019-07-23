// Trigger for listening to Cloud_News events.
trigger calloutRecordEventTrigger on callout_Record_Event__e (after insert) {    
    // List to hold all cases to be created.
    List<Case> cases = new List<Case>();
    
    // Get queue Id for case owner
    
    Callout_Record__c calloutRecord = new Callout_Record__c();   
    
    // Iterate through each notification.
    for (callout_Record_Event__e event : Trigger.New) {
        calloutRecord = [SELECT Id, Method_Name__c FROM Callout_Record__c WHERE Method_Name__c = :event.methodName__c  AND Object__c = :event.Object_Id__c ];
   }
    
    Flow.Interview flow = new Flow.Interview.Callout_Errors(new map<String,Object> 
                                                {'vAccountId' => calloutRecord.Object__c });     
    flow.start();
}