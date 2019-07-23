public class CalloutsClass{
    public CalloutsClass() {
        
    }

    public static final String CANCEL = 'cancel';
    public static final String SKIP = 'skip';
    public static final String HOLIDAY = 'holiday';
    public static final String HISTORY = 'history';
    public static Boolean tokenRefreshed = FALSE;
    public static Mantiki__c mantikiSettings = new Mantiki__c();

    public static void accountCreationUpdate(String account, boolean creation)    {
        Account tempAccount = (Account) JSON.deserialize(account, Account.class);
	    System.debug('tempAccount');
        System.debug(tempAccount);
        try {
	        if(tokenRefreshed == FALSE){
		        mantikiSettings = SettingsClass.getSettings();
	        }

            if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE))  {
                //PREPARE JSON TO BE SEND
                Map<String,Object> mapToSerialize = new Map<String,Object>();
                String jsonVar = '';
                if(creation){
                    mapToSerialize.put('salesforceId',tempAccount.Id);
                    mapToSerialize.put('store',tempAccount.Store__c);
                    mapToSerialize.put('dateOfBirth',tempAccount.PersonBirthdate);
                    mapToSerialize.put('allowContact',true);
                }else{
                    mapToSerialize.put('riskLevel',tempAccount.Risk_Level__c);
                }
                mapToSerialize.put('emailAddress',tempAccount.PersonEmail);
                mapToSerialize.put('title',tempAccount.Salutation);
                mapToSerialize.put('firstName',tempAccount.FirstName);
                mapToSerialize.put('lastName',tempAccount.LastName);
                mapToSerialize.put('telephone1',tempAccount.Phone);
                mapToSerialize.put('telephone2',tempAccount.PersonHomePhone);
                mapToSerialize.put('telephone3',tempAccount.PersonOtherPhone);

                jsonVar = JSON.serialize(mapToSerialize);

                //CALLOUT
                Map<String,String> connectionDetails = new Map<String,String>();
                connectionDetails.put('Token','Bearer '+mantikiSettings.Token__c);
                HTTPResponse response = new HTTPResponse();
                System.debug(' >>>>> Creation ' + creation);
                if(creation)    {
                    connectionDetails.put('EndPoint',mantikiSettings.End_Point__c+mantikiSettings.Prefix__c+mantikiSettings.Account__c);
                    response = InterfaceClass.post(jsonVar,connectionDetails);
                    System.debug(response);

                }else{
                    connectionDetails.put('EndPoint',mantikiSettings.End_Point__c+mantikiSettings.Prefix__c+mantikiSettings.Account__c+'/'+tempAccount.Customer_ID__c);
                    response = InterfaceClass.put(jsonVar,connectionDetails);
                }
                //UPDATE
                if(mantikiSettings.Message__c == SettingsClass.TOKEN_REFRESH)   {
                    mantikiSettings.Message__c = '';
                    update mantikiSettings;
                }
                //TREATMENT OF RESPONSE
                if(response.getStatusCode() >= 400 && response.getStatusCode()<=500)    {
	                // REST CALLOUT: IF TOKEN IS INVALID GET A NEW ONE FROM MANTIKI
	                mantikiSettings = tokenRefresh(response.getBody(), mantikiSettings);
	                if(tokenRefreshed == TRUE){
		                //CALL METHOD WITHIN ITSELF TO RESTART THE PROCESS OF SENDING A REQUEST TO MANTIKI :
		                accountCreationUpdate(account, creation);
	                }else{
                        if(creation) {

                            Account findAccount = [SELECT Id, Name FROM Account WHERE id = :tempAccount.Id];
                            System.debug('findAccountDel');
                            System.debug(findAccount);
                            if(findAccount != null) {
                                delete findAccount;
                            }
                        }
                        CalloutRecord.insertCalloutRecordError('CalloutsClass', 'accountCreationUpdate '+creation, InterfaceClass.saveRequest, response,null,tempAccount.Id);
	                }
                }else{
                    if(creation)    {
                        ResponseClass responseValue = new ResponseClass();
                        responseValue = (ResponseClass)System.JSON.deserialize(response.getBody(), ResponseClass.class);
                        tempAccount.Created_on_Mantiki__c = true;
                        tempAccount.Customer_ID__c = String.valueOf(responseValue.id);
                        tempAccount.AccountNumber = responseValue.customerNumber;

                        update tempAccount;

                        List<Contact> tempCont = [SELECT ID FROM Contact WHERE AccountId = :tempAccount.Id];

                        List<Individual> listIndividual = new List<Individual>();
                        listIndividual = AccountProcess.createIndividual(responseValue.preferences,tempAccount.FirstName,tempAccount.LastName,tempCont[0].Id,tempAccount.Store__c,String.valueOf(responseValue.id));
                        insert listIndividual;
                    }
                    CalloutRecord.insertCalloutRecordSuccess('CalloutsClass', 'accountCreationUpdate '+creation, InterfaceClass.saveRequest, response,null,tempAccount.Id);
                }
            }else{
                CalloutRecord.insertCalloutRecordError('CalloutsClass', 'accountCreationUpdate '+creation, null, null,mantikiSettings.Message__c,tempAccount.Id);
            }
        }catch(Exception e){
            System.debug('Error::'+e.getMessage());
            CalloutRecord.insertCalloutRecordError('CalloutsClass', 'accountCreationUpdate', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),tempAccount.Id);
        }
    }

    public static void individualUpdate(String individual, String mantikiCustomerID, String store)  {
        Individual tempIndividual = (Individual) JSON.deserialize(individual, Individual.class);
        try {
	        if(tokenRefreshed == FALSE){
		        mantikiSettings = SettingsClass.getSettings();
	        }
            if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE))  {
                //PREPARE JSON TO BE SEND
                Map<String,Object> mapToSerialize = new Map<String,Object>();
                String jsonVar = '';
                if(store == 'vwshop')   {
                    mapToSerialize.put('Virgin_Wines_emails',tempIndividual.Virgin_Wines_emails__c);
                    mapToSerialize.put('Virgin_Wines_other_Phone',tempIndividual.Virgin_Wines_other_Phone__c);
                    mapToSerialize.put('Virgin_Wines_other_SMS',tempIndividual.Virgin_Wines_other_SMS__c);
                    mapToSerialize.put('Virgin_Wines_other_Post',tempIndividual.Virgin_Wines_other_Post__c);
                    mapToSerialize.put('Send_a_Gift_emails',tempIndividual.Send_a_Gift_emails__c);
                    mapToSerialize.put('Send_a_Gift_other_Phone',tempIndividual.Send_a_Gift_other_Phone__c);
                    mapToSerialize.put('Send_a_Gift_other_SMS',tempIndividual.Send_a_Gift_other_SMS__c);
                    mapToSerialize.put('Send_a_Gift_other_Post',tempIndividual.Send_a_Gift_other_Post__c);
                    mapToSerialize.put('Other_Third_Parties_Email',tempIndividual.Other_Third_Parties_Email__c);
                    mapToSerialize.put('Other_Virgin_Companies_Email',tempIndividual.Other_Virgin_Companies_Email__c);
                    mapToSerialize.put('Wine_Advisor_emails',tempIndividual.Wine_Advisor_emails__c);
                }else{
                    mapToSerialize.put('Daily_Mail_emails',tempIndividual.Daily_Mail_emails__c);
                    mapToSerialize.put('Daily_Mail_other_Phone',tempIndividual.Daily_Mail_other_Phone__c);
                    mapToSerialize.put('Daily_Mail_other_SMS',tempIndividual.Daily_Mail_other_SMS__c);
                    mapToSerialize.put('Daily_Mail_other_Post',tempIndividual.Daily_Mail_other_Post__c);
                    mapToSerialize.put('Mail_Wine_club_emails',tempIndividual.Mail_Wine_club_emails__c);
                    mapToSerialize.put('Mail_Wine_club_other_Phone',tempIndividual.Mail_Wine_club_other_Phone__c);
                    mapToSerialize.put('Mail_Wine_club_other_SMS',tempIndividual.Mail_Wine_club_other_SMS__c);
                    mapToSerialize.put('Mail_Wine_club_other_Post',tempIndividual.Mail_Wine_club_other_Post__c);
                    mapToSerialize.put('Send_a_Gift_emails',tempIndividual.Send_a_Gift_emails__c);
                    mapToSerialize.put('Send_a_Gift_other_Phone',tempIndividual.Send_a_Gift_other_Phone__c);
                    mapToSerialize.put('Send_a_Gift_other_SMS',tempIndividual.Send_a_Gift_other_SMS__c);
                    mapToSerialize.put('Send_a_Gift_other_Post',tempIndividual.Send_a_Gift_other_Post__c);
                    mapToSerialize.put('Wine_Advisor_emails',tempIndividual.Wine_Advisor_emails__c);
                }

                jsonVar = '{"contactPreferences" : '+JSON.serialize(mapToSerialize)+'}';

                //CALLOUT
                Map<String,String> connectionDetails = new Map<String,String>();
                connectionDetails.put('Token','Bearer '+mantikiSettings.Token__c);
                HTTPResponse response = new HTTPResponse();
                connectionDetails.put('EndPoint',mantikiSettings.End_Point__c+mantikiSettings.Prefix__c+mantikiSettings.Individual__c+'/'+mantikiCustomerID);
                response = InterfaceClass.put(jsonVar,connectionDetails);

                //UPDATE
                if(mantikiSettings.Message__c == SettingsClass.TOKEN_REFRESH)   {
                    mantikiSettings.Message__c = '';
                    update mantikiSettings;
                }
                //TREATMENT OF RESPONSE
                if(response.getStatusCode() >= 400 && response.getStatusCode()<=500)    {
	                // REST CALLOUT: IF TOKEN IS INVALID GET A NEW ONE FROM MANTIKI
	                mantikiSettings = tokenRefresh(response.getBody(), mantikiSettings);
	                if(tokenRefreshed == TRUE){
		                //CALL METHOD WITHIN ITSELF TO RESTART THE PROCESS OF SENDING A REQUEST TO MANTIKI :
		                individualUpdate(individual, mantikiCustomerID, store);
	                }else{
                        CalloutRecord.insertCalloutRecordError('CalloutsClass', 'individualUpdate', InterfaceClass.saveRequest, response,null,tempIndividual.Id);
	                }
                }else{
                    CalloutRecord.insertCalloutRecordSuccess('CalloutsClass', 'individualUpdate', InterfaceClass.saveRequest, response,null,tempIndividual.Id);
                }
            }else{
                CalloutRecord.insertCalloutRecordError('CalloutsClass', 'individualUpdate', null, null,mantikiSettings.Message__c,tempIndividual.Id);
            }
        }catch(Exception e){
            System.debug('Error::'+e.getMessage());
            CalloutRecord.insertCalloutRecordError('CalloutsClass', 'individualUpdate', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),tempIndividual.Id);
        }
    }

    public static void subscriptionUpdate(String subscription, String subscriptionCustomerID, String action)  {
        Subscriptions__c tempSubscriptions = (Subscriptions__c) JSON.deserialize(subscription, Subscriptions__c.class);
        try{
            if(tokenRefreshed == FALSE){
                mantikiSettings = SettingsClass.getSettings();
            }
            if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE))  {
                //PREPARE JSON TO BE SEND
                Map<String,Object> mapToSerialize = new Map<String,Object>();
                String jsonVar = '';
                if(action == CANCEL){
                    mapToSerialize.put('reasonCode',tempSubscriptions.Cancel_Reason__c);
                }else if(action == SKIP){
                    mapToSerialize.put('reasonCode',tempSubscriptions.Skip_Reason__c);
                }
                jsonVar = JSON.serialize(mapToSerialize);

                // REST CALLOUT #1:
                Map<String,String> connectionDetails = new Map<String,String>();
                connectionDetails.put('Token','Bearer '+mantikiSettings.Token__c);
                HTTPResponse response = new HTTPResponse();
                connectionDetails.put('EndPoint',mantikiSettings.End_Point__c+mantikiSettings.Prefix__c+mantikiSettings.Subscriptions__c+'/'+action+'/'+subscriptionCustomerID);

                //CREATES REQUEST WITH BODY CONTAINING UPDATED FIELD AND GETS A RESPONSE FROM MANTIKI WITH A StatusCode:
                response = InterfaceClass.put(jsonVar,connectionDetails);

                //UPDATE
                if(mantikiSettings.Message__c == SettingsClass.TOKEN_REFRESH)   {
                    mantikiSettings.Message__c = '';
                    update mantikiSettings;
                }

                //TREATMENT OF RESPONSE
                if(response.getStatusCode() >= 400 && response.getStatusCode()<=500)    {
                    // REST CALLOUT #2: IF TOKEN IS INVALID GET A NEW ONE FROM MANTIKI
                    mantikiSettings = tokenRefresh(response.getBody(), mantikiSettings);
                    if(tokenRefreshed == TRUE){
                        //CALL METHOD WITHIN ITSELF TO RESTART THE PROCESS OF SENDING A REQUEST TO MANTIKI :
                        subscriptionUpdate(subscription, subscriptionCustomerID, action);
                    }else{
                        CalloutRecord.insertCalloutRecordError('CalloutsClass', 'subscriptionUpdate '+action, InterfaceClass.saveRequest, response,null,tempSubscriptions.Id);
                    }
                }else{
                    CalloutRecord.insertCalloutRecordSuccess('CalloutsClass', 'subscriptionUpdate '+action, InterfaceClass.saveRequest, response,null,tempSubscriptions.Id);
                }
            }else{
                CalloutRecord.insertCalloutRecordError('CalloutsClass', 'subscriptionUpdate', null, null,mantikiSettings.Message__c,tempSubscriptions.Id);
            }

        }catch(Exception e){
            System.debug('Error::'+e.getMessage());
            CalloutRecord.insertCalloutRecordError('CalloutsClass', 'subscriptionUpdate', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),tempSubscriptions.Id);
        }
    }


    public static void winebankUpdate(String winebank, String customerAccountID, String action)  {
        Winebank_Membership__c tempWinebank = (Winebank_Membership__c) JSON.deserialize(winebank, Winebank_Membership__c.class);
        try{
            if(tokenRefreshed == FALSE){
                mantikiSettings = SettingsClass.getSettings();
            }
            if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE))  {
                //PREPARE JSON TO BE SEND
                Map<String,Object> mapToSerialize = new Map<String,Object>();
                String jsonVar = '';
                if(action == CANCEL){
                    mapToSerialize.put('reasonCode',tempWinebank.Cancel_Reason__c);
                    mapToSerialize.put('refundBalance',true);
                }else if(action == HOLIDAY){
                    mapToSerialize.put('startDay',tempWinebank.Holiday_Start_Date__c);
                    mapToSerialize.put('endDay',tempWinebank.Holiday_End_Date__c);
                }
                jsonVar = JSON.serialize(mapToSerialize);
                //CALLOUT
                Map<String,String> connectionDetails = new Map<String,String>();
                connectionDetails.put('Token','Bearer '+mantikiSettings.Token__c);
                HTTPResponse response = new HTTPResponse();
                connectionDetails.put('EndPoint',mantikiSettings.End_Point__c+mantikiSettings.Prefix__c+mantikiSettings.Winebank__c+'/'+action+'/'+customerAccountID);
                response = InterfaceClass.put(jsonVar,connectionDetails);

                //UPDATE
                if(mantikiSettings.Message__c == SettingsClass.TOKEN_REFRESH)   {
                    mantikiSettings.Message__c = '';
                    update mantikiSettings;
                }
                //TREATMENT OF RESPONSE
                if(response.getStatusCode() >= 400 && response.getStatusCode()<=500)    {
	                // REST CALLOUT: IF TOKEN IS INVALID GET A NEW ONE FROM MANTIKI
	                mantikiSettings = tokenRefresh(response.getBody(), mantikiSettings);
	                if(tokenRefreshed == TRUE){
		                //CALL METHOD WITHIN ITSELF TO RESTART THE PROCESS OF SENDING A REQUEST TO MANTIKI :
		                winebankUpdate(winebank, customerAccountID, action);
	                }else{
                        CalloutRecord.insertCalloutRecordError('CalloutsClass', 'winebankUpdate '+action, InterfaceClass.saveRequest, response,null,tempWinebank.Id);
	                }
                }else{
                    CalloutRecord.insertCalloutRecordSuccess('CalloutsClass', 'winebankUpdate '+action, InterfaceClass.saveRequest, response,null,tempWinebank.Id);
                }
            }else{
                CalloutRecord.insertCalloutRecordError('CalloutsClass', 'winebankUpdate', null, null,mantikiSettings.Message__c,tempWinebank.Id);
            }
        }catch(Exception e){
            System.debug('Error::'+e.getMessage());
            CalloutRecord.insertCalloutRecordError('CalloutsClass', 'winebankUpdate', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),tempWinebank.Id);
        }
    }
    @AuraEnabled
    public static String getWinebank(String winebank)    {
        String returnString = '';
        System.debug('Winebank ' + winebank);

        Winebank_Membership__c winebankNew = [SELECT Customer_Account_ID__c, Customer__r.Customer_ID__c FROM Winebank_Membership__c WHERE Id = :winebank];
        System.debug('winebankNew ' + winebankNew);

        try{
	        if(tokenRefreshed == FALSE){
		        mantikiSettings = SettingsClass.getSettings();
	        }
            if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE))  {
                //CALLOUT
                Map<String,String> connectionDetails = new Map<String,String>();
                connectionDetails.put('Token','Bearer '+mantikiSettings.Token__c);
                HTTPResponse response = new HTTPResponse();
                connectionDetails.put('EndPoint',mantikiSettings.End_Point__c+mantikiSettings.Prefix__c+mantikiSettings.Winebank__c+'/'+HISTORY+'/'+winebankNew.Customer__r.Customer_ID__c);
                response = InterfaceClass.get('',connectionDetails);

                //UPDATE
                if(mantikiSettings.Message__c == SettingsClass.TOKEN_REFRESH)   {
                    mantikiSettings.Message__c = '';
                    update mantikiSettings;
                }
                //TREATMENT OF RESPONSE
                if(response.getStatusCode() >= 400 && response.getStatusCode()<=500)    {
	                // REST CALLOUT: IF TOKEN IS INVALID GET A NEW ONE FROM MANTIKI
	                mantikiSettings = tokenRefresh(response.getBody(), mantikiSettings);
	                if(tokenRefreshed == TRUE) {
		                //CALL METHOD WITHIN ITSELF TO RESTART THE PROCESS OF SENDING A REQUEST TO MANTIKI :
						returnString = getWinebank(winebank);
	                }else{
                        CalloutRecord.insertCalloutRecordError('CalloutsClass', 'getWinebank '+HISTORY, InterfaceClass.saveRequest, response,null,winebankNew.Id);
	                }
                }else{
                    CalloutRecord.insertCalloutRecordSuccess('CalloutsClass', 'getWinebank '+HISTORY, InterfaceClass.saveRequest, response,null,winebankNew.Id);
                    returnString = response.getBody();
                }
            }else{
                CalloutRecord.insertCalloutRecordError('CalloutsClass', 'getWinebank', null, null,mantikiSettings.Message__c,winebankNew.Id);
            }
        }catch(Exception e){
            System.debug('Error::'+e.getMessage());
            CalloutRecord.insertCalloutRecordError('CalloutsClass', 'getWinebank', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),null);
        }
		System.debug('returnString ' + returnString);
        return returnString;
    }

    public static void personAccountCreation(String account, boolean creation, Boolean allowContact)    {
        Account tempAccount = (Account) JSON.deserialize(account, Account.class);
        System.debug('tempAccount');
        System.debug(tempAccount);
        try {
            if(tokenRefreshed == FALSE){
                mantikiSettings = SettingsClass.getSettings();
            }

            if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE))  {
                //PREPARE JSON TO BE SEND
                Map<String,Object> mapToSerialize = new Map<String,Object>();
                String jsonVar = '';
                mapToSerialize.put('salesforceId',tempAccount.Id);
                mapToSerialize.put('store',tempAccount.Store__c);
                mapToSerialize.put('dateOfBirth',tempAccount.PersonBirthdate);
                mapToSerialize.put('allowContact',tempAccount.Allow_Contact__c);
                mapToSerialize.put('emailAddress',tempAccount.PersonEmail);
                mapToSerialize.put('firstName',tempAccount.FirstName);
                mapToSerialize.put('title',tempAccount.Salutation);
                mapToSerialize.put('corporate',tempAccount.Corporate__c);
                mapToSerialize.put('lastName',tempAccount.LastName);
                mapToSerialize.put('telephone1',tempAccount.Phone);
                mapToSerialize.put('telephone2',tempAccount.PersonHomePhone);
                mapToSerialize.put('telephone3',tempAccount.PersonOtherPhone);

                jsonVar = JSON.serialize(mapToSerialize);
                System.debug('json var');
                System.debug(jsonVar);

                //CALLOUT
                Map<String,String> connectionDetails = new Map<String,String>();
                connectionDetails.put('Token','Bearer '+mantikiSettings.Token__c);
                HTTPResponse response = new HTTPResponse();
                System.debug(' >>>>> Creation ' + creation);
                if(creation)    {
                    connectionDetails.put('EndPoint',mantikiSettings.End_Point__c+mantikiSettings.Prefix__c+mantikiSettings.Account__c);
                    response = InterfaceClass.post(jsonVar,connectionDetails);
                    System.debug(response);

                }
                //UPDATE
                if(mantikiSettings.Message__c == SettingsClass.TOKEN_REFRESH)   {
                    mantikiSettings.Message__c = '';
                    update mantikiSettings;
                }
                //TREATMENT OF RESPONSE
                if(response.getStatusCode() >= 400 && response.getStatusCode()<=500 || response.getStatusCode() == 0 || response.getStatusCode() == 208)    {

                    Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account Sync Error').getRecordTypeId();
                    // REST CALLOUT: IF TOKEN IS INVALID GET A NEW ONE FROM MANTIKI
                    mantikiSettings = tokenRefresh(response.getBody(), mantikiSettings);
                    if(tokenRefreshed == TRUE){
                        //CALL METHOD WITHIN ITSELF TO RESTART THE PROCESS OF SENDING A REQUEST TO MANTIKI :
                        personAccountCreation(account, creation, allowContact);
                    }else{
                        if(creation) {
                            Account updateAccount = [SELECT Id, Sync_Status__c, Person_Account_Duplicated__c, RecordTypeId  FROM Account WHERE id = :tempAccount.Id];
                            updateAccount.RecordTypeId = recTypeId;
                            updateAccount.Sync_Status__c = 'Error';
                            if(response.getStatusCode() == 208) {
                                updateAccount.Person_Account_Duplicated__c = true;
                            } /*else {
                                if(updateAccount != null) {
                                    System.debug('**** Report type: **** ');
                                    System.debug(recTypeId); //TO DO DELETE

                                    updateAccount.RecordTypeId = recTypeId;
                                    updateAccount.Sync_Status__c = 'Error';
                                    update updateAccount;
                                }
                            }*/
                            update updateAccount;
                        }
                    }
                    CalloutRecord.insertCalloutRecordError('CalloutsClass', 'personAccountCreation '+creation, InterfaceClass.saveRequest, response,null,tempAccount.Id);
                    Callout_Record__c calloutRecord = [SELECT Id
                                                        FROM Callout_Record__c
                                                        WHERE Class_Name__c = 'CalloutsClass'
                                                        AND Method_Name__c = 'personAccountCreation true'
                                                        AND HTTP_Method__c = :InterfaceClass.saveRequest.getMethod()
                                                        AND Request_End_Point__c = :InterfaceClass.saveRequest.getEndpoint()
                                                        AND Status_Code__c = :response.getStatusCode()
                                                        AND Status_Message__c = :response.getStatus()
                                                        AND Type_Record__c = 'Error'
                                                        AND Type__c = 'Call Out'
                                                        AND Object__c = :tempAccount.Id
                                                        ORDER BY LastModifiedDate DESC LIMIT 1];
                    Account updateCalloutRecordField = [SELECT Id, Callout_Error_Record__c FROM Account WHERE id = :tempAccount.Id];
                    updateCalloutRecordField.Callout_Error_Record__c = calloutRecord.Id;
                    updateCalloutRecordField.RecordTypeId = recTypeId;
                    update updateCalloutRecordField;
                }else{
                    if(creation)    {
                        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                        System.debug('**** Report type: **** ' + recTypeId); //TO DO DELETE

                        ResponseClass responseValue = new ResponseClass();
                        responseValue = (ResponseClass)System.JSON.deserialize(response.getBody(), ResponseClass.class);
                        tempAccount.Created_on_Mantiki__c = true;
                        tempAccount.RecordTypeId = recTypeId;
                        tempAccount.Customer_ID__c = String.valueOf(responseValue.id);
                        tempAccount.AccountNumber = responseValue.customerNumber;
                        tempAccount.Sync_Status__c = 'Success';
                        update tempAccount;

                        System.debug('tempAccount');//TO DO DELETE
                        System.debug(tempAccount);//TO DO DELETE
                        List<Contact> tempCont = [SELECT ID FROM Contact WHERE AccountId = :tempAccount.Id];

                        List<Individual> listIndividual = new List<Individual>();
                        listIndividual = AccountProcess.createIndividual(responseValue.preferences,tempAccount.FirstName,tempAccount.LastName,tempCont[0].Id,tempAccount.Store__c,String.valueOf(responseValue.id));
                        insert listIndividual;
                    }
                    CalloutRecord.insertCalloutRecordSuccess('CalloutsClass', 'personAccountCreation '+creation, InterfaceClass.saveRequest, response,null,tempAccount.Id);


                }
            }else{
                CalloutRecord.insertCalloutRecordError('CalloutsClass', 'personAccountCreation '+creation, null, null,mantikiSettings.Message__c,tempAccount.Id);
            }
        }catch(Exception e){
            System.debug('Error::'+e.getMessage());
            CalloutRecord.insertCalloutRecordError('CalloutsClass', 'personAccountCreation', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),tempAccount.Id);

        }
    }
    //METHOD TO CHECK IF TOKEN IS INVALID, IF SO REFRESH IT FROM MANTIKI USING SettingsClass:
    public static Mantiki__c tokenRefresh (String responseBody, Mantiki__c mantikiSettings)  {
         ResponseClass responseValue = new ResponseClass();
         responseValue = (ResponseClass)System.JSON.deserialize(responseBody, ResponseClass.class);

         if(responseValue.error == 'invalid_token' && responseValue.error_description.startsWith('Invalid access token')){
             tokenRefreshed = TRUE;
             //REFRESH TOKEN:
             return SettingsClass.getToken(mantikiSettings);
         } else{
             tokenRefreshed = FALSE;
             return NULL;
         }
 	}

    public class ResponseClass{
        ResponseClass(){

        }
        public Integer id {get;set;}
        public String customerNumber {get;set;}
        public String fraudStatus {get;set;}
        public String error {get;set;}
        public String error_description {get;set;}
		public String error_type {get;set;}
        public List<AccountProcess.CreateIndividualWrapper> preferences {get;set;}
    }
    
}