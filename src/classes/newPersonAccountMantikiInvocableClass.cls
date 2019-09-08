/**
 * Created by lferreira036 on 30-05-2019.
 */
global without sharing class newPersonAccountMantikiInvocableClass {

	public static Mantiki__c mantikiSettings = new Mantiki__c();

	public class FlowInputs{
		@InvocableVariable
		public String accountId;

		@InvocableVariable
		public String firstName;

		@InvocableVariable
		public String lastName;

		@InvocableVariable
		public String salutation;

		@InvocableVariable
		public String emailAddress;

		@InvocableVariable
		public Date DateOfBirth;

		@InvocableVariable
		public String store;

		@InvocableVariable
		public String tel1;

		@InvocableVariable
		public String tel2;

		@InvocableVariable
		public String tel3;

		@InvocableVariable
		public Boolean AllowMarketingCommunications;
	}

	// "FlowOutputs" wrapper class
	// @InvocableVariables to store outputs from Apex to Flow
	public class FlowOutputs{
		@InvocableVariable
		public Integer responseStatusCode;

		@InvocableVariable
		public String responseBody;

		@InvocableVariable
		public String accountId;

		@InvocableVariable
		public String methodName;

		@InvocableVariable
		public String firstName;

		@InvocableVariable
		public String lastName;

		@InvocableVariable
		public String salutation;

		@InvocableVariable
		public String emailAddress;

		@InvocableVariable
		public Date DateOfBirth;

		@InvocableVariable
		public String store;

		@InvocableVariable
		public String tel1;

		@InvocableVariable
		public String tel2;

		@InvocableVariable
		public String tel3;

		@InvocableVariable
		public Boolean AllowMarketingCommunications;
	}

	@InvocableMethod(label='Invoke Apex method: New Person Account' description='Create a Person Account in Mantiki, if succeds create in Salesforce')
	public static List<FlowOutputs> newPersonAccount(List<FlowInputs>  flowInputs) {
		List<FlowOutputs> flowOutputsList = new List<FlowOutputs>();
		FlowOutputs flowOutputs = new FlowOutputs();

		System.debug('Flow Inputs:::');
		System.debug(flowInputs);

		Account newAccount = new Account();
		try {
			System.debug('Account ID');
			System.debug(flowInputs[0].accountId);

			if(String.isBlank(flowInputs[0].accountId)) {
				//Get Record type Id
				Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
				System.debug('**** Report type: **** ' + recTypeId); //TO DO DELETE

				newAccount.FirstName = flowInputs[0].firstName;
				newAccount.PersonBirthdate = flowInputs[0].DateOfBirth;
				newAccount.LastName = flowInputs[0].lastName;
				newAccount.PersonEmail = flowInputs[0].emailAddress;
				newAccount.Store__c = flowInputs[0].store;
				newAccount.Salutation = flowInputs[0].salutation;
				newAccount.Corporate__c = false;
				newAccount.Phone = flowInputs[0].tel1;
				newAccount.Telephone_2__c = flowInputs[0].tel2;
				newAccount.Telephone_3__c = flowInputs[0].tel3;
				//newAccount.PersonHomePhone = flowInputs[0].tel2;
				//newAccount.PersonOtherPhone = flowInputs[0].tel3;
				newAccount.Sync_Status__c = 'Processing';
				newAccount.Allow_Contact__c =  flowInputs[0].AllowMarketingCommunications;
				newAccount.RecordTypeId =  recTypeId;

				insert newAccount;
			} else {
				newAccount = [SELECT FirstName, PersonBirthdate, LastName, PersonEmail, Store__c, Salutation, Phone, PersonHomePhone, PersonOtherPhone, Sync_Status__c, Allow_Contact__c, RecordTypeId FROM Account WHERE Id = :flowInputs[0].accountId];
				newAccount.Sync_Status__c = 'Processing';
				update newAccount;
			}
		} catch(DmlException e) {
			System.debug('Error:: ' + e.getMessage());
			/*flowOutputs.responseStatusCode = Integer.valueOf(1111);
			flowOutputs.responseBody = e.getMessage();
			flowOutputs.firstName = flowInputs[0].firstName;
			flowOutputs.lastName = flowInputs[0].lastName;
			flowOutputs.salutation = flowInputs[0].salutation;
			flowOutputs.emailAddress = flowInputs[0].emailAddress;
			flowOutputs.store = flowInputs[0].store;
			flowOutputs.tel1 = flowInputs[0].tel1;
			flowOutputs.tel2 = flowInputs[0].tel2;
			flowOutputs.tel3 = flowInputs[0].tel3;
			flowOutputs.AllowMarketingCommunications = flowInputs[0].AllowMarketingCommunications;
			flowOutputs.DateOfBirth = flowInputs[0].DateOfBirth;
			flowOutputsList.add(flowOutputs);

			return flowOutputsList;*/

		}

		serializeAccount(JSON.serialize(newAccount),true, newAccount.Allow_Contact__c);

		flowOutputs.accountId = newAccount.Id;
		flowOutputs.methodName = 'personAccountCreation true';
		flowOutputs.firstName = flowInputs[0].firstName;
		flowOutputs.lastName = flowInputs[0].lastName;
		flowOutputs.salutation = flowInputs[0].salutation;
		flowOutputs.emailAddress = flowInputs[0].emailAddress;
		flowOutputs.store = flowInputs[0].store;
		flowOutputs.tel1 = flowInputs[0].tel1;
		flowOutputs.tel2 = flowInputs[0].tel2;
		flowOutputs.tel3 = flowInputs[0].tel3;
		flowOutputs.AllowMarketingCommunications = flowInputs[0].AllowMarketingCommunications;
		flowOutputs.DateOfBirth = flowInputs[0].DateOfBirth;
		flowOutputsList.add(flowOutputs);

		return flowOutputsList;
	}

	@future(callout=true)
	public static void serializeAccount(String acc, boolean creation, boolean allowContact)   {
		CalloutsClass.personAccountCreation(acc,creation, allowContact);
	}

	@AuraEnabled
	public static String getAccountRecordTypeID(String recordTypeId) {
		return [SELECT Name FROM RecordType WHERE Id=:recordTypeId].Name;
	}

	@AuraEnabled
	public static Boolean isAccountDeleted(Id recordId) {

		System.debug('recordId');
		System.debug(recordId);
		System.debug([SELECT COUNT() FROM Account WHERE Id=:recordId AND isDeleted = true ALL ROWS]);
		if([SELECT COUNT() FROM Account WHERE Id=:recordId AND isDeleted = true ALL ROWS] > 0) {
			return true;
		}
		return false;
	}

	/*@AuraEnabled
	public static List<Callout_Record__c> getCalloutRecord(String methodName, String accountId) {

		List<Callout_Record__c> callouts = new List<Callout_Record__c>();
		Integer cpuLimit = 0;

		while(callouts.size() == 0 && cpuLimit < 9000) {
			callouts = [SELECT JSON_Received__c, Status_Code__c, Method_Name__c, Object__c FROM Callout_Record__c WHERE Object__c = :accountId AND Method_Name__c = :methodName LIMIT 1];
			wait(1500);
			cpuLimit += 1500;
		}
		return callouts;
	}

	public static void wait(Integer millisec) {
		if(millisec == null || millisec < 0) {
			millisec = 0;
		}


		Long finishTime = DateTime.now().getTime() + millisec;
		Long actualTime = DateTime.now().getTime();
		while (finishTime > actualTime) {
			//sleep for parameter x millisecs
			actualTime = DateTime.now().getTime();
		}
		// System.debug('>>> Done from ' + startTime + ' to ' + finishTime);
	}*/
}