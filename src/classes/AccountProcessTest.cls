@isTest
private class AccountProcessTest {

    //TEST createAccount METHOD IN THE AccountProcess with store == 'vwshop' :
    static testMethod void createAccountTest1() {
        
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        // Set up a mock request performed by external service Mantiki to be captured by a Salesforce Class
        // Class: AccountProcess is on the lookout for incoming REST calls on the Account object (urlMapping='/api/Account/*'):
        req.requestURI = '/services/apexrest/Account';  //Request URL must be the same as the urlMapping in the AccountProcess class
        req.httpMethod = 'POST';
        
        //Pass a JSON to the body of the request with parameters to match the CreateAccountWrapper in the AccountProcess class:
        //(fields from the wrapper will be mapped to the fields of a new Account)
        req.requestBody = Blob.valueof('{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":1234,"Telephone_3":54321,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}');
        RestContext.request = req;
 

        Test.startTest();
        	AccountProcess.createAccount();
        Test.stopTest();
	
	    //Check if a new Account was created as expected:
        System.assertEquals(1,[SELECT COUNT() FROM Account]);
        
   }
    
    //TEST createAccount METHOD IN THE AccountProcess with store != 'vwshop' :
    static testMethod void createAccountTest2() {
        
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        // Set up a mock request performed by external service Mantiki to be captured by a Salesforce Class
        // Class: AccountProcess is on the lookout for incoming REST calls on the Account object (urlMapping='/api/Account/*'):
        req.requestURI = '/services/apexrest/Account';  //Request URL must be the same as the urlMapping in the AccountProcess class
        req.httpMethod = 'POST';
        
        //Pass a JSON to the body of the request with parameters to match the CreateAccountWrapper in the AccountProcess class:
        //(fields from the wrapper will be mapped to the fields of a new Account)
        req.requestBody = Blob.valueof('{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"test","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}');
        RestContext.request = req;

        Test.startTest();
        	AccountProcess.createAccount();
        Test.stopTest();
        
        //Check if a new Account was created as expected:
        System.assertEquals(1,[SELECT COUNT() FROM Account]);
        
   }
    
    //TEST createAccount METHOD IN THE AccountProcess with empty Customer_Number and Customer_ID:
    static testMethod void createAccountTest3() {
        
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        // Set up a mock request performed by external service Mantiki to be captured by a Salesforce Class
        // Class: AccountProcess is on the lookout for incoming REST calls on the Account object (urlMapping='/api/Account/*'):
        req.requestURI = '/services/apexrest/Account';  //Request URL must be the same as the urlMapping in the AccountProcess class
        req.httpMethod = 'POST';
        
        //Pass a JSON to the body of the request with parameters to match the CreateAccountWrapper in the AccountProcess class:
        //(fields from the wrapper will be mapped to the fields of a new Account)
        req.requestBody = Blob.valueof('{"Customer_Number":"","Customer_ID": null,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"test","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}');
        RestContext.request = req;
 

        Test.startTest();
        	AccountProcess.createAccount();
        Test.stopTest();
        
        //Check if a new Callout_Record__c was created as expected due to Customer_Number and Customer_ID in the response being empty :
        System.assertEquals(1,[SELECT COUNT() FROM Callout_Record__c]);
        
   }

}