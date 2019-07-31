/**
 * Created by ronanwilliams on 2019-07-30.
 */

({
    getSubjects : function($C,customerKeys){

        var getEmailSubjects = $C.get('c.getEmailSubjects');
        getEmailSubjects.setParams({ customerKeys : customerKeys});
        getEmailSubjects.setCallback(this, function (response){
            console.log(response.getReturnValue());

            if (response.getState() === 'SUCCESS' && response.getReturnValue()) {

                var subjects    = response.getReturnValue();
                var subjectMap  = new Map();

                if (subjects.Body && subjects.Body.RetrieveResponseMsg &&
                    subjects.Body.RetrieveResponseMsg.Results) {
                    var results = subjects.Body.RetrieveResponseMsg.Results;
                    if (results.length === undefined) {

                        console.log('length was undefined ');

                        subjectMap.set(results.CustomerKey, results);
                    } else {
                        console.log('doing else ');

                        results.forEach(function(result){
                            subjectMap.set(result.CustomerKey, result);
                        });
                    }
                }

                var emails = $C.get('v.emails');
                emails.forEach(function(email){
                    if (subjectMap.has(email.SubscriberKey)){
                        email.From      = subjectMap.get(email.SubscriberKey).FromName;
                        email.Subject   = subjectMap.get(email.SubscriberKey).EmailSubject;
                        email.EmailId   = subjectMap.get(email.SubscriberKey).Email.ID;
                    } else {
                        email.From      = 'Unavailable';
                        email.Subject   = 'Unavailable';
                    }
                });
                $C.set('v.emails',emails);
            }
        });
        $A.enqueueAction(getEmailSubjects);
    }

});