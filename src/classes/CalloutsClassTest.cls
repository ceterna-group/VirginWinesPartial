@isTest
public class CalloutsClassTest {
	//ACCOUNT
	public static Account configAccount(){
		Id personAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

		Account account = new Account();
		account.Store__c = 'Virgin Wines';
		account.PersonEmail = 'test@test.com';
		account.Salutation = 'Mr';
		account.FirstName = 'FirstTest';
		account.LastName = 'LastTest';
		account.Phone = '1234567890';
		account.PersonHomePhone = '1234567890';
		account.PersonOtherPhone = '1234567890';
		account.PersonBirthdate = Date.today() - 100;
		account.RecordTypeId = personAccount;

		return account;
	}
	//CONTACT
	public static Contact configContact()	{
		Contact contact = new Contact(
				FirstName = 'Test First Name',
				LastName = 'Test Last Name'
		);

		return contact;
	}
	//CUSTOM SETTING
	public static void createCustomSetting(){
		Mantiki__c man = new Mantiki__c();
		man.Begin__c = null;
		man.Client_Id__c = 'xxxx';
		man.Client_Secret__c = 'xxxxxxxxxxxxxxxxxxxxxxxxxxx';
		man.End_Point__c = 'http://teste.com';
		man.Finish__c = null;
		man.getToken__c = 'xxxx/xxxxx';
		man.Grant_Type__c = 'xxxxxxxxxxxxx';
		man.Message__c = null;
		man.Token__c = null;
		man.Account__c = 'xxxxxxxxxxxxxx';
		man.Individual__c = 'xxxxxxxxxxxxxx';
		man.Winebank__c = 'xxxxxxxxxxxxxx';
		man.Telesales__c = 'xxxxxxxxxxxxxx';
		insert man;
	}

	//TEST ACCOUNT TRIGGER HANDLER INSERT
	static testMethod void creationAccount()	{
		createCustomSetting();

		Account account = configAccount();

		Test.startTest();
		insert account;
		Test.stopTest();

		System.assertEquals(2,[SELECT Object__c FROM Callout_Record__c WHERE Object__c = :account.Id].size(),
				'CalloutsClass should insert a record of Callout Records when an Account is INSERTED.');
	}
	//TEST ACCOUNT TRIGGER HANDLER UPDATE
	static testMethod void updateAccount()	{
		createCustomSetting();

		Account account = configAccount();
		insert account;

		Test.startTest();
		update account;

		account.Created_on_Mantiki__c = true;
		account.Risk_Level__c = 'test';
		update account;
		Test.stopTest();

		System.assertEquals(4,[SELECT Object__c FROM Callout_Record__c WHERE Object__c = :account.Id].size(),
				'CalloutsClass should insert records of Callout Records when an Account is INSERTED/UPDATED.');
	}

	//TEST #1 tokenRefresh METHOD IN CalloutsClass:
	static testMethod void tokenRefreshTest1()	{
		//Insert Custom Setting:
		createCustomSetting();
		Mantiki__c mantikiSettings = Mantiki__c.getOrgDefaults();
		//Set up a Response Body with an error of 'Invalid Token':
		String responseBody = '{"error":"invalid_token","error_description":"Invalid access token: Z Z Z Z Z "}';

		Test.startTest();
		CalloutsClass.tokenRefresh(responseBody, mantikiSettings);
		Test.stopTest();

		System.assertEquals(TRUE, CalloutsClass.tokenRefreshed, 'The TOKEN should have been refreshed by the CalloutsClass.');
	}

	//TEST #2 tokenRefresh METHOD IN CalloutsClass:
	static testMethod void tokenRefreshTest2()	{
		//Insert Custom Setting:
		createCustomSetting();
		Mantiki__c mantikiSettings = Mantiki__c.getOrgDefaults();
		//Set up a Response Body with a different error of 'Invalid Token':
		String responseBody = '{"error_category":"Bad Request","error_type":"Invalid state","message":"Subscription not open"}';

		Test.startTest();
		CalloutsClass.tokenRefresh(responseBody, mantikiSettings);
		Test.stopTest();

		System.assertEquals(FALSE, CalloutsClass.tokenRefreshed, 'The TOKEN should NOT have been refreshed by the CalloutsClass.');
	}


	// TEST MOCK #1  (method calling HttpCalloutMock class):
	// OBJECT: Account
	static testmethod void updateAccountTestMock() {
		createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		Account account = configAccount();

		// Mock #1: Return a response from Mantiki saying Token is invalid:
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(401, 'Complete', '{"error":"invalid_token","error_description":"Invalid access token: zzzzzzz"}', null);
		// Mock #2: Return a response from Mantiki with a new valid Token:
		CalloutsClassMock fakeResponse2 = new CalloutsClassMock(200, 'Complete', '{"access_token" : "4d689d20-a449-4fc0-b8a9-621eecde953f","token_type" : "bearer","expires_in" : 86281}', null);
		// Mock #3: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and an Individual :
		CalloutsClassMock fakeResponse3 = new CalloutsClassMock(200, 'Complete', '{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', fakeResponse1);
		requestsMap.put('2', fakeResponse2);
		requestsMap.put('3', fakeResponse3);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		Test.startTest();
		insert account;
		Test.stopTest();

		System.assertEquals(2,[SELECT COUNT() FROM Callout_Record__c ],
				'CalloutsClass should insert a record of Callout Record when an Account is INSERTED/UPDATED.');
		System.assertEquals(1,[SELECT COUNT() FROM Individual ],
				'CalloutsClass should have inserted a record of Individual when an Account is inserted.');
	}

	// TEST MOCK #2  (method calling HttpCalloutMock class):
	// OBJECT: Individual  (TRIGGER FOR INDIVIDUAL ONLY WORKS ON UPDATE)
	static testmethod void updateIndividualTestMock() {
		createCustomSetting(); //Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		Individual individual = new Individual(LastName = 'Adams', Wine_Advisor_emails__c = 'Monthly');
		insert individual;

		// Mock #1: -->  Error (401)
		// Return a response from Mantiki saying Token is invalid:
		CalloutsClassMock fakeResponse3 = new CalloutsClassMock(401, 'Complete',
				'{"error":"invalid_token","error_description":"Invalid access token: zzzzzzz"}',
				null); // Mock #2:  REFRESH TOKEN -->  Success (200)
		// Return a response from Mantiki with a new valid Token:
		CalloutsClassMock fakeResponse2 = new CalloutsClassMock(200, 'Complete',
				'{"access_token" : "4d689d20-a449-4fc0-b8a9-621eecde953f","token_type" : "bearer","expires_in" : 86281}',
				null); // Mock #4:   -->  Success (200)
		// Return a success response from Mantiki with a JSON that could be anything since we do not use the Response in this case:
		CalloutsClassMock fakeResponse4 = new CalloutsClassMock(200, 'Complete',
				'{"Wine_Advisor_emails":"Never","Send_a_Gift_other_Post":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Phone":false,"Send_a_Gift_emails":"Never","Mail_Wine_club_other_Post":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Phone":false,"Mail_Wine_club_emails":"Never","Daily_Mail_other_Post":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Phone":false,"Daily_Mail_emails":"Never"}}',
				null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('2', fakeResponse2);
		requestsMap.put('3', fakeResponse3);
		requestsMap.put('4', fakeResponse4);

		MultiRequestMock fakeMultiResponse = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		Test.startTest();
		individual.Wine_Advisor_emails__c = 'Weekly';
		update individual;
		Test.stopTest();

		System.assertEquals(1, [SELECT COUNT() FROM Individual ], '1 records of Individual should have been inserted.');
		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :individual.Id].size(),
				'CalloutsClass should insert a record of Callout Records when an Individual is UPDATED.');
	}

	// TEST MOCK #3  (method calling HttpCalloutMock class):
	// OBJECT: Individual  (TRIGGER FOR INDIVIDUAL ONLY WORKS ON UPDATE)
	//         Insert Person Account with Store = 'vwshop'
	static testmethod void updateIndividualTestMock2() {
		createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		// Insert Person Account with Store = 'vwshop'
		Account account = configAccount();
		account.Store__c = 'vwshop';
		insert account;

		//Get Contact linked to the Account with Store != 'vwshop' that was created when the Person Account was inserted:
		Contact contact = [SELECT Name, AccountId, Account.Store__c FROM Contact WHERE AccountId = :account.Id];

		//Insert Individual and link it to the Contact linked to the Account with Store = 'vwshop'
		Individual individual = new Individual(
				LastName = 'Mendes',
				Wine_Advisor_emails__c = 'Monthly',
				Contact__c = contact.Id

		);
		insert individual;

		// Mock #1: For Account Insert   -->  Success (200)
		// Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and an Individual
		// (in this case the Mock the "contactPreferences" is empty so it won't insert an Individual ):
		CalloutsClassMock accountFakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"id":1106,"customerNumber":"84001800","fraudStatus":"Low","contactPreferences":{}}', null);
		// Mock #3: For Individual Update   -->  Error (401)
		// Return a response from Mantiki saying Token is invalid:
		CalloutsClassMock individualFakeResponse3 = new CalloutsClassMock(401, 'Complete', '{"error":"invalid_token","error_description":"Invalid access token: zzzzzzz"}', null);
		// Mock #2:   TOKEN REFRESH -->  Success (200)
		// Return a response from Mantiki with a new valid Token:
		CalloutsClassMock individualFakeResponse2 = new CalloutsClassMock(200, 'Complete', '{"access_token" : "4d689d20-a449-4fc0-b8a9-621eecde953f","token_type" : "bearer","expires_in" : 86281}', null);
		// Mock #4:   -->  Success (200)
		// Return a success response from Mantiki with a JSON that could be anything since we do not use the Response in this case:
		CalloutsClassMock individualFakeResponse4 = new CalloutsClassMock(200, 'Complete', '{"Wine_Advisor_emails":"Never","Send_a_Gift_other_Post":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Phone":false,"Send_a_Gift_emails":"Never","Mail_Wine_club_other_Post":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Phone":false,"Mail_Wine_club_emails":"Never","Daily_Mail_other_Post":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Phone":false,"Daily_Mail_emails":"Never"}}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', accountFakeResponse1);
		requestsMap.put('3', individualFakeResponse3);
		requestsMap.put('2', individualFakeResponse2);
		requestsMap.put('4', individualFakeResponse4);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		Test.startTest();
		//Update the Individual to trigger the method: individualUpdate
		individual.Wine_Advisor_emails__c = 'Weekly';
		update individual;
		Test.stopTest();

		System.assertEquals(1,[SELECT COUNT() FROM Individual ],
				'1 records of Individual should have been inserted.');
		System.assertEquals(1,[SELECT Object__c FROM Callout_Record__c WHERE Object__c = :individual.Id].size(),
				'CalloutsClass should insert a record of Callout Records when an Individual is UPDATED.');

	}

	// TEST MOCK #4  (method calling HttpCalloutMock class):
	// OBJECT: Subscription
	static testmethod void updateSubscriptionTestMock() {
		createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		// Mock #3: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert  :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}', null);
		// Mock #1: Return a response from Mantiki saying Token is invalid:
		CalloutsClassMock fakeResponse3 = new CalloutsClassMock(401, 'Complete', '{"error":"invalid_token","error_description":"Invalid access token: zzzzzzz"}', null);
		// Mock #2: Return a response from Mantiki with a new valid Token:
		CalloutsClassMock fakeResponse2 = new CalloutsClassMock(200, 'Complete', '{"access_token" : "4d689d20-a449-4fc0-b8a9-621eecde953f","token_type" : "bearer","expires_in" : 86281}', null);
		// Mock #3: Return a success response from Mantiki with a JSON that could be anything since we do not use the Response in this case:
		CalloutsClassMock fakeResponse4 = new CalloutsClassMock(200, 'Complete', '{"reasonCode":"Health Reasons - Sickness"}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', fakeResponse1);
		requestsMap.put('2', fakeResponse2);
		requestsMap.put('3', fakeResponse3);
		requestsMap.put('4', fakeResponse4);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		Account account = configAccount();
		insert account;

		Subscriptions__c subscriptions = new Subscriptions__c(
				Name = 'test',
				Customer__c = account.Id
		);
		insert subscriptions;

		Test.startTest();
		subscriptions.Skip_Reason__c = 'Need a break';
		subscriptions.Cancel_Reason__c = 'test';
		update subscriptions;
		Test.stopTest();

		System.assertEquals(2,[SELECT Object__c FROM Callout_Record__c WHERE Object__c = :subscriptions.Id].size(),
				'CalloutsClass should insert a record of Callout Records when an Subscriptions__c is INSERTED/UPDATED.');
		System.assertEquals(2,[SELECT Object__c FROM Callout_Record__c WHERE Object__c = :account.Id].size(),
				'CalloutsClass should insert a record of Callout Records when an Account is INSERTED.');
		System.assertEquals(1,[SELECT COUNT() FROM Subscriptions__c ],
				'CalloutsClass should insert records of Callout Records when a Subscriptions is INSERTED/UPDATED.');
	}

	// TEST MOCK #5  (method calling HttpCalloutMock class):
	// OBJECT: Winebank
	static testmethod void updateWinebankTestMock() {
		createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		// Mock #1: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and Individual :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}', null);
		// Mock #2: Return a response from Mantiki saying Token is invalid:
		CalloutsClassMock fakeResponse3 = new CalloutsClassMock(401, 'Complete', '{"error":"invalid_token","error_description":"Invalid access token: zzzzzzz"}', null);
		// Mock #3: Return a response from Mantiki with a new valid Token:
		CalloutsClassMock fakeResponse2 = new CalloutsClassMock(200, 'Complete', '{"access_token" : "4d689d20-a449-4fc0-b8a9-621eecde953f","token_type" : "bearer","expires_in" : 86281}', null);
		// Mock #4:  Return a success response from Mantiki with a JSON that could be anything since we do not use the Response in this case:
		CalloutsClassMock fakeResponse4 = new CalloutsClassMock(200, 'Complete', '{"refundBalance":true,"reasonCode":"Health Reasons - Sickness"}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', fakeResponse1);
		requestsMap.put('2', fakeResponse2);
		requestsMap.put('3', fakeResponse3);
		requestsMap.put('4', fakeResponse4);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		Account account = configAccount();
		insert account;

		Winebank_Membership__c winebank = new Winebank_Membership__c(
				Name = 'test',
				Customer__c = account.Id
		);
		insert winebank;

		Test.startTest();
		//Update #1: Cancel Reason
		winebank.Cancel_Reason__c = 'Customer Failure - Money/Cannot Afford';
		//Update #2: Holiday
		winebank.Holiday_Start_Date__c = Date.today();
		winebank.Holiday_End_Date__c = Date.today().addDays(1);
		update winebank;
		Test.stopTest();


		System.assertEquals(2,[SELECT Object__c FROM Callout_Record__c WHERE Object__c = :winebank.Id].size(),
				'CalloutsClass should insert a record of Callout Records when a Winebank_Membership__c is UPDATED.');
		System.assertEquals(4,[SELECT Object__c FROM Callout_Record__c WHERE Object__c = :account.Id].size(),
				'CalloutsClass should insert a record of Callout Records when an Account is INSERTED.');
		System.assertEquals(1,[SELECT COUNT() FROM Winebank_Membership__c ],
				'CalloutsClass should insert records of Callout Records when a Subscriptions is INSERTED/UPDATED.');
	}

	// TEST MOCK #6  (method calling HttpCalloutMock class):
	// OBJECT: Winebank
	static testmethod void getWinebankTestMock() {
		//String to hold the response body of the REST Callout:
		String returnString;
		//Create custom setting with REST API details:
		createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		// Mock #1: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and Individual:
		CalloutsClassMock fakeResponse3 = new CalloutsClassMock(200, 'Complete', '{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}', null);
		// Mock #2: Return a response from Mantiki saying Token is invalid:
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(401, 'Complete', '{"error":"invalid_token","error_description":"Invalid access token: zzzzzzz"}', null);
		// Mock #3: Return a response from Mantiki with a new valid Token:
		CalloutsClassMock fakeResponse2 = new CalloutsClassMock(200, 'Complete', '{"access_token" : "4d689d20-a449-4fc0-b8a9-621eecde953f","token_type" : "bearer","expires_in" : 86281}', null);
		// Mock #4: Return a success response from Mantiki with a JSON that could be anything since we do not use the Response in this case:
		CalloutsClassMock fakeResponse5 = new CalloutsClassMock(200, 'Complete', '{"Name":"test"}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', fakeResponse1);
		requestsMap.put('2', fakeResponse2);
		requestsMap.put('3', fakeResponse3);
		requestsMap.put('5', fakeResponse5);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		Account account = configAccount();
		insert account;

		Winebank_Membership__c winebank = new Winebank_Membership__c(
				Name = 'test',
				Customer__c = account.Id
		);
		insert winebank;

		Test.startTest();

		returnString = CalloutsClass.getWinebank([SELECT Name From Winebank_Membership__c].Id);
		Test.stopTest();

		// Verify mock response is not null
		System.assertNotEquals(null, returnString, 'The callout returned a null response');

		//verify body
		System.assertEquals('{"Name":"test"}', returnString, 'Expected: {"Name":"test"} & ' + 'Actual: ' + returnString);

		//verify Callout_Record__c records
		System.assertEquals(1,[SELECT Count() FROM Callout_Record__c] ,
				'CalloutsClass should insert a record of Callout Records when receives a Winebank_Membership__c from Mantiki and when a Account is created.');
	}
}