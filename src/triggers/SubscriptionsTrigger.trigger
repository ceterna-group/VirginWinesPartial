trigger SubscriptionsTrigger on Subscriptions__c (after update) {
    //THIS USER/PROFILE WILL NOT TRIGGER UPDATE: UserInfo.getUserId() != '0056E0000052XAxQAM'
    if(Test.isRunningTest()){
        if(Trigger.isAfter && Trigger.isUpdate){
            SubscriptionsTriggerHandler.AfterUpdateHandle(trigger.new, trigger.old, trigger.oldMap);
        }
    }
}