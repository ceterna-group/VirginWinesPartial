public with sharing class SubscriptionsTriggerHandler {
    /** @description Before Update 
    * @param Subscriptions__c (new and old)
    * @return void
    * @date 2019  **/  
   public static void AfterUpdateHandle(List<Subscriptions__c> listNewSubscriptions, List<Subscriptions__c> listOldSubscriptions, Map<Id, Subscriptions__c> mapOldSubscriptions) {
    	Map<Id,Subscriptions__c> mapListSubSkip = new Map<Id,Subscriptions__c>();
    	Map<Id,Subscriptions__c> mapListSubCancel = new Map<Id,Subscriptions__c>();
    	for(Subscriptions__c sub : listNewSubscriptions)	{
    		if(sub.Skip_Reason__c != mapOldSubscriptions.get(sub.Id).Skip_Reason__c)	{
    			mapListSubSkip.put(sub.Id, sub);
    		}
    		if(sub.Cancel_Reason__c != mapOldSubscriptions.get(sub.Id).Cancel_Reason__c)	{
    			mapListSubCancel.put(sub.Id, sub);
    		}    		
    	}
    	if(mapListSubSkip.size()>0 || mapListSubCancel.size()>0)	{
    		for(Subscriptions__c sub : listNewSubscriptions){
    			if(mapListSubSkip.containsKey(sub.Id))	{
    				serializeSubscriptions(JSON.serialize(mapListSubSkip.get(sub.Id)),CalloutsClass.SKIP);
    			}
    			if(mapListSubCancel.containsKey(sub.Id))	{
    				serializeSubscriptions(JSON.serialize(mapListSubCancel.get(sub.Id)),CalloutsClass.CANCEL);
    			}    			
    		}    		
    	}    	
    }

    @future(callout=true)
    public static void serializeSubscriptions(String subscription,String action)   {
        //Mantiki__c mantikiSettings = new Mantiki__c();
	    Subscriptions__c tempSubscription = (Subscriptions__c) JSON.deserialize(subscription, Subscriptions__c.class);
	    List<Subscriptions__c> subscriptionList = [SELECT Customer_Subscription_ID__c, Customer__r.AccountNumber FROM Subscriptions__c WHERE id = :tempSubscription.Id LIMIT 1];
        CalloutsClass.subscriptionUpdate(subscription, subscriptionList[0].Customer_Subscription_ID__c, action);
    }
}