/*
 * @class EmailHistoryController
 * Created by ronan williams on 2019-07-29.
 * @desc test class for EmailHistoryController.class
 */
@IsTest
public class EmailHistoryControllerTest {

    @isTest public static void getEmailHistory() {

        EmailCalloutClassMock sendMock = new EmailCalloutClassMock();

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
//        endpoint2TestResp.put('');

        // This causes a fake response to be generated
        Test.setMock(HttpCalloutMock.class, new EmailCalloutClassMock());

        // Call the method that invokes a callout
        Map<String, Object> output = (Map<String, Object>) EmailHistoryController.getEmailHistory('Lead', '1231231', 'test');

        //verify that a result from the mock has been returned

    }

    @isTest public static void getEmailBody() {
        // This causes a fake response to be generated
        Test.setMock(HttpCalloutMock.class, new EmailCalloutClassMock());

        // Call the method that invokes a callout
        Map<String, Object> output = (Map<String, Object>) EmailHistoryController.getEmailBodyMarkup('90967');

        //verify that a result from the mock has been returned

    }

}