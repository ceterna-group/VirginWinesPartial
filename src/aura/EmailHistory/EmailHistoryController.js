/**
 * Created by ronanwilliams on 2019-07-29.
 */

({
    doInit : function($C, $E, $H){

        var objType     = $C.get('v.sobjecttype');
        var recordId    = $C.get('v.recordId');
        var emailField  = $C.get('v.EmailField');

        if (objType && recordId && emailField){
            var getEmails = $C.get('c.getEmailHistory');
            getEmails.setParams({
                sObjectType : objType,
                recordId : recordId,
                emailField : emailField
            });
            getEmails.setCallback(this,function(response){
                console.log(response.getReturnValue());

                if (response.getState() === 'SUCCESS' && response.getReturnValue()){

                    var responseData    = response.getReturnValue();
                    var emailMap        = new Map();
                    var customerKeys    = [];
                    var sent            = responseData['SEND'];

                    if (sent && sent.Body && sent.Body.RetrieveResponseMsg &&
                        sent.Body.RetrieveResponseMsg.Results){

                        var sendData = sent.Body.RetrieveResponseMsg.Results;
                        for (var x = 0; x < sendData.length; x++){
                            emailMap.set(sendData[x].Properties.Property[3].Value,
                                {
                                    Date : new Date(sendData[x].Properties.Property[1].Value),
                                    DateString : new Date(sendData[x].Properties.Property[1].Value).toString().substring(0,24),
                                    JobId : sendData[x].Properties.Property[3].Value,
                                    ObjectId : sendData[x].Properties.Property[2].Value,
                                    SubscriberKey : sendData[x].Properties.Property[4].Value,
                                    Subject : '',
                                    From : '',
                                    Status : 'Sent',
                                    Opened : false
                                });
                            if (sendData[x].Properties.Property[4].Value){
                                customerKeys.push(sendData[x].Properties.Property[4].Value);
                            }
                        }
                    }

                    var opened = responseData['OPEN'];
                    if (opened && opened.Body && opened.Body.RetrieveResponseMsg &&
                        opened.Body.RetrieveResponseMsg.Results){

                        var openData = opened.Body.RetrieveResponseMsg.Results;
                        for (var x = 0; x < openData.length; x++){

                            if (emailMap.has(openData[x].Properties.Property[3].Value)){
                                var email = emailMap.get(openData[x].Properties.Property[3].Value);
                                email.Status = 'Opened';
                                email.Opened = true;
                                emailMap.set(openData[x].Properties.Property[3].Value,email);
                            }
                        }
                    }

                    var emails = Array.from(emailMap.values());
                    emails.sort(function(a,b){
                       return b.Date - a.Date
                    });
                    $C.set('v.emails',emails);
                    $C.set('v.customerKeys',customerKeys);
                    // $H.getSubjects($C,customerKeys);
                }
            });
            $A.enqueueAction(getEmails);
        }
    },
    getEmailBody : function($C,$E,$H){

        console.log('bodyget');

        if ($E.currentTarget.getAttribute('data-emailid')){

            console.log('will trigger');

            var emailId = $E.currentTarget.getAttribute('data-emailid');

            console.log('sending id ' + emailId);

            var getEmailBody = $C.get('c.getEmailBodyMarkup');
            getEmailBody.setParams({emailId : emailId});
            getEmailBody.setCallback(this, function(response){
                console.log('callback');

                console.log(response.getState());
                console.log(response.getReturnValue());
            });
            $A.enqueueAction(getEmailBody);

            // $E.currentTarget.setAttribute('data-hello','goobye');
            // console.log('mtd called');
            // console.log($E.currentTarget.getAttribute('data-emailId'));



        }
    }

});