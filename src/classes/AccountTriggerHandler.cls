public with sharing class AccountTriggerHandler {
    /** @description After Update 
    * @param Account
    * @return void
    * @date 2019  **/  
    public static void AfterInsertHandle(List<Account> listNewAccount) {
		//send to mantiki creation of account (INT001)
		System.debug('AfterInsertHandle');
    	for(Account acc : listNewAccount){
    		if(acc.recordtypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId())	{
    			serializeAccount(JSON.serialize(acc),true);

    		}
    	}
    }
    /** @description Before Update 
    * @param Account (new and old)
    * @return void
    * @date 2019  **/  
    public static void AfterUpdateHandle(List<Account> listNewAccount, List<Account> listOldAccount, Map<Id, Account> mapOldAccount) {
    	boolean updAccMantiki = false;
    	Map<Id,Account> mapListAcc = new Map<Id,Account>();
    	//send to Mantiki if some error occurs on creation in SF
    	for(Account acc : listNewAccount){
    		if(acc.recordtypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId() && !acc.Created_on_Mantiki__c)	{
    			serializeAccount(JSON.serialize(acc),true);
    		}
    		if(acc.recordtypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId() && acc.Created_on_Mantiki__c)	{
    			if(acc.Salutation != mapOldAccount.get(acc.Id).Salutation ||
    			   acc.FirstName != mapOldAccount.get(acc.Id).FirstName ||
    			   acc.LastName != mapOldAccount.get(acc.Id).LastName ||
    			   acc.PersonEmail != mapOldAccount.get(acc.Id).PersonEmail ||
    			   acc.Phone != mapOldAccount.get(acc.Id).Phone ||
    			   acc.PersonHomePhone != mapOldAccount.get(acc.Id).PersonHomePhone ||
    			   acc.PersonOtherPhone != mapOldAccount.get(acc.Id).PersonOtherPhone ||
    			   acc.PersonBirthdate != mapOldAccount.get(acc.Id).PersonBirthdate ||
    			   acc.AccountNumber != mapOldAccount.get(acc.Id).AccountNumber ||
    			   acc.Risk_Level__c != mapOldAccount.get(acc.Id).Risk_Level__c)	{
    				mapListAcc.put(acc.Id,acc);
    			}
    		}
    	}

    	if(mapListAcc.size()>0)	{
    		for(Account acc : listNewAccount){
    			if(mapListAcc.containsKey(acc.Id))	{
    				serializeAccount(JSON.serialize(mapListAcc.get(acc.Id)),false);
    			}
    		}
    		
    	}
    }


    @future(callout=true)
    public static void serializeAccount(String acc, boolean creation)   {
        CalloutsClass.accountCreationUpdate(acc,creation);
    }


}