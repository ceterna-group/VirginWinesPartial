/**
 * Created by ronanwilliams on 2019-07-29.
 */

public class EmailHistoryController {


    @AuraEnabled
    public static Object getEmailHistory(String sObjectType, String recordId, String emailField){

        // define default response object
        Map<String,Object> responseMap  = new Map<String,Object> ();
        String subscriberKey            = '';

        // obtain the email address for the relevant record type and pass the value to the soap xml string method
        SObject recordObject            = Database.query('SELECT ' + emailField + ' FROM ' + sObjectType + ' WHERE Id = \'' + recordId + '\'');
        String emailString              = (String)recordObject.getPopulatedFieldsAsMap().get(emailField);

        // if we can locate an email address for the record check for the subscriber key in Marketing Cloud
        if (emailString != '' && emailString != null){
            HttpResponse subsriberKeyCallout = doSoapCallout('Subscriber',
                    new List<String>{'SubscriberKey'},
                    new List<String>{'EmailAddress::equals::' + emailString});

            if (subsriberKeyCallout.getStatusCode() == 200){
                String responseString = subsriberKeyCallout.getBody();

                // if the initial soap callout has returned a subscriber key return the value, otherwise return an empty string
                subscriberKey = responseString.indexOf('<SubscriberKey>')!= -1 ?
                        responseString.substring(responseString.indexOf('<SubscriberKey>') + 15,responseString.indexOf('</SubscriberKey>')) : '';
            }
        }

        // if we have successfully obtained a subscriber key, perform callouts to get sent and opened emails based on the subscriber keys
        if (subscriberKey != '' && emailString != null){

            HttpResponse sendEventCallout = doSoapCallout('DataExtensionObject[CustomerSentEmailData]',
                    new List<String>{'SubscriberKey','EventDate','TriggererSendDefinitionObjectID','JobID','TriggeredSendCustomerKey','EventDate'},
                    new List<String>{'SubscriberKey::equals::' + subscriberKey});

            if (sendEventCallout.getStatusCode() == 200) {
                // parse the sent event objects into JSON
                Dom.Document doc        = sendEventCallout.getBodyDocument();
                String sendEventString  = XmlToJson.parseDocumentToJson(doc);
                responseMap.put('SEND',JSON.deserializeUntyped(sendEventString));
            }

            HttpResponse openEventCallout = doSoapCallout('DataExtensionObject[CustomerOpenEmailData]',
                    new List<String>{'SubscriberKey','EventDate','TriggererSendDefinitionObjectID','JobID','TriggeredSendCustomerKey','EventDate'},
                    new List<String>{'SubscriberKey::equals::' + subscriberKey});

            if (openEventCallout.getStatusCode() == 200) {
                // parse the sent event objects into JSON
                Dom.Document doc        = openEventCallout.getBodyDocument();
                String openEventString  = XmlToJson.parseDocumentToJson(doc);
                responseMap.put('OPEN',JSON.deserializeUntyped(openEventString));
            }
        }

        return responseMap;
    }

    @AuraEnabled
    public static Object getEmailSubjects(String[] customerKeys){

        // define default response object
        Object response  = 'ERROR';

        String filterStrings = '';
        for (String customerKey : customerKeys){
            filterStrings += '::' + customerKey;
        }

        HttpResponse emailSubjectCallout = doSoapCallout('TriggeredSendDefinition',
                new List<String>{'EmailSubject','Email.ID','CustomerKey','FromAddress','FromName','CategoryID'},
                new List<String>{'CustomerKey::' + (customerKeys.size() == 1 ? 'equals' : 'IN') + filterStrings});

        if (emailSubjectCallout.getStatusCode() == 200){
            // parse the sent event objects into JSON
            Dom.Document doc        = emailSubjectCallout.getBodyDocument();
            String openEventString  = XmlToJson.parseDocumentToJson(doc);
            response                = JSON.deserializeUntyped(openEventString);
        }

        return response;
    }

    @AuraEnabled
    public static Object getEmailBodyMarkup(String emailId){

        // define default response object
        Object response  = 'ERROR';

        HttpResponse emailBodyCallout = doSoapCallout('Email',
                new List<String>{'HTMLBody','ID','Status','Subject','PartnerKey','TextBody'},
                new List<String>{'ID::equals::' + emailId});

        if (emailBodyCallout.getStatusCode() == 200){
            // parse the sent event objects into JSON
            Dom.Document doc        = emailBodyCallout.getBodyDocument();
            String bodyString       = XmlToJson.parseDocumentToJson(doc);
            response                = JSON.deserializeUntyped(bodyString);
        }

//        return response;
        return emailBodyCallout.getBody();
    }

    // helper method to construct XML callout
    @TestVisible
    private static HttpResponse doSoapCallout(String objectType, String[] properties, String[] filters){

        // get username and password credentials from custom label
        String userName = Label.EmailHistoryCredentials.split('::')[1];
        String password = Label.EmailHistoryCredentials.split('::')[3];

        // build xml soap body based on parameters send to the method
        String requestXML =
                        '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> '+
                        '   <Header> '+
                        '       <Security xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"> '+
                        '           <UsernameToken> '+
                        '               <Username>' + userName + '</Username> '+
                        '               <Password>' + password + '</Password> '+
                        '           </UsernameToken> '+
                        '       </Security> '+
                        '   </Header> '+
                        '   <Body> '+
                        '       <RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI"> '+
                        '           <RetrieveRequest> '+
                        '               <ObjectType>' + objectType + '</ObjectType>';

        for (String property : properties){
            requestXML += '<Properties>' + property + '</Properties>';
        }

        for (String filter : filters){
                requestXML +=
                        '<Filter xsi:type="SimpleFilterPart"> '+
                        '    <Property>' + filter.split('::')[0] + '</Property> '+
                        '    <SimpleOperator>' + filter.split('::')[1] + '</SimpleOperator> ';

                for (Integer x = 2; x < filter.split('::').size(); x++){
                    requestXML += '<Value>' + filter.split('::')[x] + '</Value> ';
                }

                requestXML += '</Filter> ';
        }

        requestXML +=
                        '           </RetrieveRequest> '+
                        '       </RetrieveRequestMsg> '+
                        '   </Body> '+
                        '</Envelope> ';

        // perform the callout to the soap api endpoint, adding the xml string as the request body
        Http subscriberKeyHttp              = new Http();
        HttpRequest subscriberKeyRequest    = new HttpRequest();
        subscriberKeyRequest.setEndpoint('https://mcp-tdn-c0l602t4nkc4hjyh22c4.soap.marketingcloudapis.com/Service.asmx');
        subscriberKeyRequest.setMethod('POST');
        subscriberKeyRequest.setHeader('SOAPAction','Retrieve');
        subscriberKeyRequest.setHeader('Content-Type', 'text/xml');
        subscriberKeyRequest.setBody(requestXML);
        HttpResponse subscriberKeyResponse  = subscriberKeyHttp.send(subscriberKeyRequest);

       return subscriberKeyResponse;

    }

}