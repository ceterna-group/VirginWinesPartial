/**
 * Created by lferreira036 on 30-05-2019.
 */
public without sharing class AccountRecordTypeID {


	@AuraEnabled
	public static String getAccountRecordTypeID(String recordTypeId) {
		System.debug('IN retirve report');
		return [SELECT Name FROM RecordType WHERE Id=:recordTypeId].Name;
	}

	@AuraEnabled
	public static Callout_Record__c getCalloutRecord(String methodName, String accountId) {
		System.debug('IN retirve report');
		System.debug(methodName);
		System.debug(accountId);

		System.debug([SELECT JSON_Received__c, Status_Code__c, Method_Name__c, Object__c FROM Callout_Record__c WHERE Object__c = :accountId AND Method_Name__c = :methodName]);
		return [SELECT JSON_Received__c, Status_Code__c, Method_Name__c, Object__c FROM Callout_Record__c WHERE Object__c = :accountId AND Method_Name__c = :methodName];
	}
}