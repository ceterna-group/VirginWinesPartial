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
                                    Name : sendData[x].Properties.Property[9].Value,
                                    Subject : sendData[x].Properties.Property[10].Value,
                                    EmailId : sendData[x].Properties.Property[13].Value,
                                    From : '',
                                    Status : 'Sent',
                                    Opened : false
                                });
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
                    $C.set('v.responsePending',false);
                }
            });
            $A.enqueueAction(getEmails);
        }
    },
    getEmailBody : function($C,$E,$H){

        var emailId = parseInt($E.currentTarget.getAttribute('data-emailid'));

        $C.set('v.preview',null);
        $C.set('v.previewId',emailId);

        console.log(emailId);

        if (emailId){
            var emailBodies = $C.get('v.emailBodies');
            if (emailBodies[emailId]){
                $C.set('v.preview',emailBodies[emailId]);
            } else {
                var getEmailBody = $C.get('c.getEmailBodyMarkup');
                getEmailBody.setParams({emailId : emailId});
                getEmailBody.setCallback(this, function(response){
                    console.log(response.getState());
                    console.log(response.getReturnValue());

                    var responseData    = response.getReturnValue();

                    console.log(responseData);
                    // if (responseData.Body && responseData.Body.RetrieveResponseMsg &&
                    //     responseData.Body.RetrieveResponseMsg.Results &&
                    //     responseData.Body.RetrieveResponseMsg.Results.HTMLBody){
                    //     var blob = new Blob([responseData.Body.RetrieveResponseMsg.Results.HTMLBody], {type: "text/html"});
                    //     emailBodies[emailId] = URL.createObjectURL(blob);
                    //     $C.set('v.preview',emailBodies[emailId]);
                    //
                    //     console.log(responseData.Body.RetrieveResponseMsg.Results.HTMLBody);
                    //
                    // }
                });
                $A.enqueueAction(getEmailBody);
            }
        }
    },
    resizeIframe : function ($C,$E,$H) {
        // $E.currentTarget.style.height = '500px';


    }

});