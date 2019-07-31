trigger AccountTrigger on Account (after update, after insert) {
    //THIS USER/PROFILE WILL NOT TRIGGER UPDATE: UserInfo.getUserId() != '0056E0000052XAxQAM'
    if(Test.isRunningTest()){
        if(Trigger.isAfter && Trigger.isUpdate){
            AccountTriggerHandler.AfterUpdateHandle(trigger.new, trigger.old, trigger.oldMap);
        }
        if(Trigger.isAfter && Trigger.isInsert){
            AccountTriggerHandler.AfterInsertHandle(trigger.new);
        }
    }
}