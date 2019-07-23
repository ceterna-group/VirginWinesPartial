public with sharing class WinebankTriggerHandler {
    /** @description Before Update 
    * @param Winebank_Membership__c (new and old)
    * @return void
    * @date 2019  **/  
    public static void AfterUpdateHandle(List<Winebank_Membership__c> listNewWinebank, List<Winebank_Membership__c> listOldWinebank, Map<Id, Winebank_Membership__c> mapOldWinebank) {
    	Map<Id,Winebank_Membership__c> mapListWineHoliday = new Map<Id,Winebank_Membership__c>();
    	Map<Id,Winebank_Membership__c> mapListWineCancel = new Map<Id,Winebank_Membership__c>();
    	for(Winebank_Membership__c wine : listNewWinebank)	{
    		if(wine.Holiday_Start_Date__c != mapOldWinebank.get(wine.Id).Holiday_Start_Date__c ||
    			wine.Holiday_End_Date__c != mapOldWinebank.get(wine.Id).Holiday_End_Date__c)	{
    			mapListWineHoliday.put(wine.Id, wine);
    		}
    		if(wine.Cancel_Reason__c != mapOldWinebank.get(wine.Id).Cancel_Reason__c)	{
    			mapListWineCancel.put(wine.Id, wine);
    		}    		
    	}
    	if(mapListWineHoliday.size()>0 || mapListWineCancel.size()>0)	{
    		for(Winebank_Membership__c wine : listNewWinebank){
    			if(mapListWineHoliday.containsKey(wine.Id))	{
    				serializeWinebank(JSON.serialize(mapListWineHoliday.get(wine.Id)),CalloutsClass.HOLIDAY);
    			}
    			if(mapListWineCancel.containsKey(wine.Id))	{
    				serializeWinebank(JSON.serialize(mapListWineCancel.get(wine.Id)),CalloutsClass.CANCEL);
    			}    			
    		}    		
    	}    	
    }

    @future(callout=true)
    public static void serializeWinebank(String winebank, String action)   {
	    Winebank_Membership__c temWinebank = (Winebank_Membership__c) JSON.deserialize(winebank, Winebank_Membership__c.class);
	    List<Winebank_Membership__c> winebankMembershipList = [SELECT Customer_Account_ID__c, Customer__r.Customer_ID__c FROM Winebank_Membership__c WHERE id = :temWinebank.Id LIMIT 1];
        CalloutsClass.winebankUpdate(winebank, winebankMembershipList[0].Customer__r.Customer_ID__c, action);
    }  
}