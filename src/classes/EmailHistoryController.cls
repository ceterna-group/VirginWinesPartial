/*
 * @class EmailHistoryController
 * Created by ronan williams on 2019-07-29.
 * @desc - used as controller for <c:EmailHistory> lightning component.
 */

public class EmailHistoryController {

    /*
     * @method getEmailHistory()
     * @desc - Used to retrieve email information for a custom lightning component.
     * @param {String} sObjectType - used to fetch the sObject type which contains the component (can be
     *                  any of Person Account, Contact or Lead
     * @param {String} recordId - id passed by the force:recordId attribute in the component.
     * @param {String} emailField - because the component can be used on multiple sObjects, a design parameter on
     *                  the component is used to determine which field to check for the records' email address.
     * @return {Object} - returns a JSON string containing information from Marketing Cloud about emails sent and opened.
     */
    @AuraEnabled
    public static Object getEmailHistory(String sObjectType, String recordId, String emailField){

        // define default response object
        Map<String,Object> responseMap  = new Map<String,Object> ();
        String subscriberKey            = '';

        // obtain the email address for the relevant record type and pass the value to the soap xml string method
        try {
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
            } else {
              responseMap.put('ERROR', 'No MC Subscriber Key found for this record.');
            }

            // if we have successfully obtained a subscriber key, perform callouts to get sent and opened emails based on the subscriber keys
            if (subscriberKey != '' && emailString != null){

                HttpResponse sendEventCallout = doSoapCallout('DataExtensionObject[CustomerSentEmailData]',
                        new List<String>{'SubscriberKey','EventDate','TriggererSendDefinitionObjectID','JobID',
                                'TriggeredSendCustomerKey','EventDate', 'FromEmail','FromName','JobType',
                                'JobStatus','EmailName','EmailSubject','SendType','EmailSendDefinition','EmailID'},
                        new List<String>{'SubscriberKey::equals::' + subscriberKey});

                if (sendEventCallout.getStatusCode() == 200) {
                    // parse the sent event objects into JSON
                    Dom.Document doc        = sendEventCallout.getBodyDocument();
                    String sendEventString  = XmlToJson.parseDocumentToJson(doc);
                    responseMap.put('SEND',JSON.deserializeUntyped(sendEventString));
                }

                HttpResponse openEventCallout = doSoapCallout('DataExtensionObject[CustomerOpenEmailData]',
                        new List<String>{'SubscriberKey','EventDate','TriggererSendDefinitionObjectID','JobID',
                                'TriggeredSendCustomerKey','EventDate', 'FromEmail','FromName','JobType',
                                'JobStatus','EmailName','EmailSubject','SendType','EmailSendDefinition','EmailID'},
                        new List<String>{'SubscriberKey::equals::' + subscriberKey});

                if (openEventCallout.getStatusCode() == 200) {
                    // parse the sent event objects into JSON
                    Dom.Document doc        = openEventCallout.getBodyDocument();
                    String openEventString  = XmlToJson.parseDocumentToJson(doc);
                    responseMap.put('OPEN',JSON.deserializeUntyped(openEventString));
                }
            } else {
              responseMap.put('ERROR', 'No MC Subscriber key found for this record.');
            }
        } catch(Exception e) {
           responseMap.put('ERROR', e.getMessage());
        }        
        
        return responseMap;
        
    }

    /*
     * @method getEmailBodyMarkup()
     * @desc - retrieves the HTML body of a given email in Marketing Cloud
     * @param {String} emailId - the id of the email record in Marketing Cloud
     * @return {Object} - HttpResponse body converted JSON response
     */
    @AuraEnabled
    public static Object getEmailBodyMarkup(String emailId){

        String accessToken = getToken();
        Http http       = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://mcp-tdn-c0l602t4nkc4hjyh22c4.rest.marketingcloudapis.com/asset/v1/content/assets/' +
                '?$filter=data.email.legacy.legacyId%20eq%20\'' + emailId + '\'');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);


        HttpResponse res = http.send(req);

        return res.getBody();
    }


    /*
     * @method doSoapCallout()
     * @desc - Used to construct the XML body of the soap callout to marketing cloud.
     * @param {String} objectType - the soap api Object reference
     * @param {String[]} properties - list of object properties to be retrieved by the soap call.
     * @param {String} filters - any query filters to be applied to the query.
     * @return {HttpResponse} - returns the HttpResponse from the soap callout
     */
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

    public static String getToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://mcp-tdn-c0l602t4nkc4hjyh22c4.auth.marketingcloudapis.com/v2/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        Map<String, String> params = new Map<String, String>();
        params.put('grant_type', 'client_credentials');
        params.put('client_id', 'spzkfzsanck0ew9lkpl79wo6');
        params.put('client_secret', 'VOSaL3J4wEA1YgPKFgjcns02');
        params.put('scope', 'documents_and_images_read email_read saved_content_read');
        params.put('account_id', '6261229');
        req.setBody(JSON.serialize(params));
        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() == 200){
            Map<String,Object> resMap = ( Map<String,Object> ) JSON.deserializeUntyped(res.getBody());
            if (resMap.containsKey('access_token')){
                return (String)resMap.get('access_token');
            } else {
                return 'error';
            }
        } else {
            return 'error';
        }
    }

}