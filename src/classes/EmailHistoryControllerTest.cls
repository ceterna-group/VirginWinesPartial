/*
 *  @class - EmailHistoryController
 *    Created by Ronan <ronan@ceterna.com> on 2019-07-29.
 *    Edited by Elliott <elliott@appitek> on 2019-09-23.
 *  @desc - test class for EmailHistoryController.class
 */
@IsTest
public class EmailHistoryControllerTest {

    // create a fake lead record
    private static Lead createLead() {
        Lead l      = new Lead();
        l.FirstName = 'Test';
        l.LastName  = 'Test';
        l.Email     = 'test@test.com';
        l.Title     = 'Chief Test Officer';
        l.Phone     = '00000 000 000';
        l.Company   = 'Test Ltd.';
        l.Industry  = 'Banking';
        l.Street    = '1 Test Road';
        insert l;
        return l;
    }

    // create a fake mock response class
    public class EchoHttpMock implements HttpCalloutMock {
        HttpResponse res;
        public EchoHttpMock(HttpResponse r) {
            res = r;
        }
        // This is the HttpCalloutMock interface method
        public HttpResponse respond(HttpRequest req) {
            return res;
        }
    }

    /*
     *  @method - setMock()
     *  @desc - Sets a specific mock body to the rest context to act as
     * 	the mock respoonse for our callout
     */
    private static HttpResponse createMock(String name) {
        HttpResponse res = new HttpResponse();
        String mockBody;
        switch on name {
            // no subscriber key in body
            when 'NoSubscriberKey' {
                mockBody = '';
            }
            // empty subscriber key value
            when 'EmptySubscriberKey' {
                mockBody = '<SubscriberKey></SubscriberKey>';
            }
            // actual subscriber key value
            when 'ValidSubscriberKey' {
                mockBody = '<SubscriberKey>1111</SubscriberKey>';
            }
            // email body markup
            when 'EmailBodyMarkup' {
                mockBody = '{ "body": "<div>Hello</div>"}';
            }
        }
        res.setBody(mockBody);
        res.setStatusCode(200);
        return res;
    }

    // test for if the email field name is invalid
    @IsTest
    public static void testInvalidEmailField() {
        Lead testLead = createLead();
        Test.startTest();
        // check invalid email field name
        Map < String, Object > invalidEmailField = (Map < String, Object > ) EmailHistoryController.getEmailHistory('Lead', testLead.Id, 'Test');
        Test.stopTest();
        // for invalid email field we should of get an error message to show the user
        System.assertNotEquals(null, invalidEmailField);
        System.assertNotEquals(null, invalidEmailField.get('ERROR'));
    }


    // test for if there is no subscriber key returned from MC
    @IsTest
    public static void testNoSubscriberKey() {
        Lead testLead = createLead();
        // set mock response
        HttpResponse res = createMock('NoSubscriberKey');
        Test.setMock(HttpCalloutMock.class, new EchoHttpMock(res));
        Test.startTest();
        // check no subscriber key returned
        Map < String, Object > noSubscriberKey = (Map < String, Object > ) EmailHistoryController.getEmailHistory('Lead', testLead.Id, 'Email');
        Test.stopTest();
        // we should get no key for SEND or OPEN if subscriber key is blank
        System.assertNotEquals(null, noSubscriberKey);
        System.assertEquals(null, noSubscriberKey.get('SEND'));
        System.assertEquals(null, noSubscriberKey.get('OPEN'));
    }


    // test for if there a blank subscriber key returned from MC
    @IsTest
    public static void testEmptySubscriberKey() {
        Lead testLead = createLead();
        // set mock response
        HttpResponse res = createMock('EmptySubscriberKey');
        Test.setMock(HttpCalloutMock.class, new EchoHttpMock(res));
        Test.startTest();
        // check empty key
        Map < String, Object > emptySubscriberKey = (Map < String, Object > ) EmailHistoryController.getEmailHistory('Lead', testLead.Id, 'Email');
        Test.stopTest();
        // we should get no key for SEND or OPEN if subscriber key is empty
        System.assertNotEquals(null, emptySubscriberKey);
        System.assertEquals(null, emptySubscriberKey.get('SEND'));
        System.assertEquals(null, emptySubscriberKey.get('OPEN'));
    }


    // test for if there is a valid subscriber key returned from MC
    @IsTest
    public static void testValidSubscriberKey() {
        Lead testLead = createLead();
        // set mock response
        HttpResponse res = createMock('ValidSubscriberKey');
        Test.setMock(HttpCalloutMock.class, new EchoHttpMock(res));
        Test.startTest();
        // check valid key
        Map < String, Object > validSubscriberKey = (Map < String, Object > ) EmailHistoryController.getEmailHistory('Lead', testLead.Id, 'Email');
        Test.stopTest();
        // for valid subscriber keys we actuall get a value for both keys thats parsed by the component
        System.assertNotEquals(null, validSubscriberKey);
        System.assertNotEquals(null, validSubscriberKey.get('SEND'));
        System.assertNotEquals(null, validSubscriberKey.get('OPEN'));
    }


    // test for getting the email markup
    @IsTest
    public static void testGetEmailBodyMarkup() {
        // set mock response
        HttpResponse res = createMock('EmailBodyMarkup');
        Test.setMock(HttpCalloutMock.class, new EchoHttpMock(res));
        Test.startTest();
        // check email body returned
        String emailBody = (String) EmailHistoryController.getEmailBodyMarkup('1');
        Test.stopTest();
        // will always give us an actual string even if no email was found
        System.assertNotEquals(null, emailBody);
    }

}