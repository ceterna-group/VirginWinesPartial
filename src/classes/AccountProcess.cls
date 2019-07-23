@RestResource(urlMapping='/api/Account/*')
global with sharing class AccountProcess {
    @HttpPost
    global static String createAccount() {
        Map<String,String> mapResponse = new Map<String,String>();
        RestRequest request = RestContext.request;
        String jsonObj = request.requestBody.toString();
        CreateAccountWrapper tempResponse = (CreateAccountWrapper) JSON.deserialize(jsonObj, CreateAccountWrapper.class);
        //BUILD ACCOUNT
        Account newAccount = new Account();
        newAccount.FirstName = tempResponse.First_Name;
        newAccount.LastName = tempResponse.Last_Name;
        newAccount.AccountNumber = tempResponse.Customer_Number;
        newAccount.Customer_ID__c  = String.valueOf(tempResponse.Customer_ID);
        if(!String.isBlank( tempResponse.Title)) {
            newAccount.Salutation = tempResponse.Title;
        }
        newAccount.Phone = tempResponse.Telephone_1;
        newAccount.PersonHomePhone = tempResponse.Telephone_2;
        newAccount.PersonOtherPhone = tempResponse.Telephone_3;
        if(!String.isBlank(tempResponse.Date_Of_Birth)){
            newAccount.PersonBirthdate = date.parse(tempResponse.Date_Of_Birth);
        }
        newAccount.Risk_Level__c = tempResponse.Risk_level;
        newAccount.Store__c = tempResponse.Store_ID;
        newAccount.VAA_Number__c = tempResponse.VA_A_Number;
        newAccount.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        newAccount.Created_on_Mantiki__c = true;
        newAccount.PersonEmail = tempResponse.Email;

        if(tempResponse.Customer_Number == '' || tempResponse.Customer_ID == null)    {
            mapResponse.put('errorCode','Customer Code');
            mapResponse.put('message','Customer Number and Customer ID must be fill');
            CalloutRecord.insertCallinRecordError('AccountProcess', 'createAccount', request.requestBody.toString(),JSON.serialize(mapResponse),'',null,'POST');
        }else{
            insert newAccount;

            List<Contact> tempCont = [SELECT ID FROM Contact WHERE AccountId = :newAccount.Id];
            
            List<Individual> listIndividual = new List<Individual>();
            listIndividual = createIndividual(tempResponse.preferences,tempResponse.First_Name,tempResponse.Last_Name,tempCont[0].Id,tempResponse.Store_ID, String.valueOf(tempResponse.Customer_ID));
            insert listIndividual;

            Set<Id> setIndividual = new Set<Id>();
            //BUILD JSON TO RESPONDE
            mapResponse.put('AccountID',newAccount.Id);
            Integer x = 0;
            for(Individual i : listIndividual)	{
            	mapResponse.put('PreferencesID'+x,i.Id);
            }
            CalloutRecord.insertCallinRecordSucess('AccountProcess', 'createAccount', request.requestBody.toString(),JSON.serialize(mapResponse),'',newAccount.Id,'POST');
        }
        
        return JSON.serialize(mapResponse);
    }   

    public static List<Individual> createIndividual(List<CreateIndividualWrapper> listciw,String firstName, String lastName, Id contactID,String store, String customerID)   {
        List<Individual> listIndividual = new List<Individual>();
        Individual newIndividual = new Individual();
        for(CreateIndividualWrapper ciw : listciw) {
            newIndividual = new Individual();
            newIndividual.FirstName = firstName;
            newIndividual.LastName = lastName;
            if(store == 'vwshop')   {
                newIndividual.Virgin_Wines_emails__c = ciw.Virgin_Wines_emails;
                newIndividual.Virgin_Wines_other_Phone__c = ciw.Virgin_Wines_other_Phone;
                newIndividual.Virgin_Wines_other_SMS__c = ciw.Virgin_Wines_other_SMS;
                newIndividual.Virgin_Wines_other_Post__c = ciw.Virgin_Wines_other_Post;
                newIndividual.Other_Third_Parties_Email__c = ciw.Other_Third_Parties_Email;
                newIndividual.Other_Virgin_Companies_Email__c = ciw.Other_Virgin_Companies_Email;
                
            }else{
                newIndividual.Daily_Mail_emails__c = ciw.Daily_Mail_emails;
                newIndividual.Daily_Mail_other_Phone__c = ciw.Daily_Mail_other_Phone;
                newIndividual.Daily_Mail_other_SMS__c = ciw.Daily_Mail_other_SMS;
                newIndividual.Daily_Mail_other_Post__c = ciw.Daily_Mail_other_Post;
                newIndividual.Mail_Wine_club_emails__c = ciw.Mail_Wine_club_emails;
                newIndividual.Mail_Wine_club_other_Phone__c = ciw.Mail_Wine_club_other_Phone;
                newIndividual.Mail_Wine_club_other_SMS__c = ciw.Mail_Wine_club_other_SMS;
                newIndividual.Mail_Wine_club_other_Post__c = ciw.Mail_Wine_club_other_Post;
            }   
            newIndividual.Send_a_Gift_emails__c = ciw.Send_a_Gift_emails;  
            newIndividual.Send_a_Gift_other_Phone__c = ciw.Send_a_Gift_other_Phone; 
            newIndividual.Send_a_Gift_other_SMS__c = ciw.Send_a_Gift_other_SMS; 
            newIndividual.Send_a_Gift_other_Post__c = ciw.Send_a_Gift_other_Post;  
            newIndividual.Wine_Advisor_emails__c = ciw.Wine_Advisor_emails;   
            newIndividual.Contact__c = contactID;
            newIndividual.Customer_ID__c = customerID;
            listIndividual.add(newIndividual);
        }
        return listIndividual;
    }

    public class CreateAccountWrapper{
        public String Customer_Number {get;set;}
        public Integer Customer_ID {get;set;}
        public String Title {get;set;}
        public String First_Name {get;set;}
        public String Last_Name {get;set;}
        public String Telephone_1 {get;set;}
        public String Telephone_2 {get;set;}
        public String Telephone_3 {get;set;}
        public String Date_Of_Birth {get;set;}
        public String Risk_level {get;set;}
        public String Store_ID {get;set;}
        public String VA_A_Number {get;set;}
        public String Email {get;set;} //Account field: Email__c

        public List<CreateIndividualWrapper> preferences {get;set;}
    }

    public class CreateIndividualWrapper{
        public String Virgin_Wines_emails {get;set;}
        public Boolean Virgin_Wines_other_Phone {get;set;}
        public Boolean Virgin_Wines_other_SMS {get;set;}
        public Boolean Virgin_Wines_other_Post {get;set;}
        public String Send_a_Gift_emails {get;set;}
        public Boolean Send_a_Gift_other_Phone {get;set;}
        public Boolean Send_a_Gift_other_SMS {get;set;}
        public Boolean Send_a_Gift_other_Post {get;set;}
        public Boolean Other_Third_Parties_Email {get;set;}
        public Boolean Other_Virgin_Companies_Email {get;set;}
        public String Wine_Advisor_emails {get;set;}
        public String Daily_Mail_emails {get;set;}
        public Boolean Daily_Mail_other_Phone {get;set;}
        public Boolean Daily_Mail_other_SMS {get;set;}
        public Boolean Daily_Mail_other_Post {get;set;}
        public String Mail_Wine_club_emails {get;set;}
        public Boolean Mail_Wine_club_other_Phone {get;set;}
        public Boolean Mail_Wine_club_other_SMS {get;set;}
        public Boolean Mail_Wine_club_other_Post {get;set;}
    }
}