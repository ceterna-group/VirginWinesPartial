@isTest(SeeAllData=false)
private class Trig_Object_Test {

    // UPDATE: as at 31/07/2019 the purpose of this test class is not known
    // the class does not generate any unique code coverage, and because there
    // are no comments or assertions it is unclear what role the class was written to perform

    // UPDATE: on 31/07/2019 the class was updated to pass validation on the insert of lead records

    static testMethod void runTests() {

        Account newAccount = new Account (
            Name                = 'Test Account',
            BillingCity         ='Test City',
            BillingCountry      ='Test Country',
            BillingStreet       ='Test Street',
            BillingPostalCode   ='123456',
    		Store__c            = 'Test'
        );
        
        insert newAccount;
        
        Contact newContact = new Contact (
            FirstName           = 'MC',
            LastName            = 'Test',
            Account             = newAccount,
            Email               = 'mctest@mail.com'
        );
        
        insert newContact;
        
        Lead lead = new Lead (
            FirstName   = 'Test',
            LastName        = 'MC Test',
            Company         = 'Test Company',
            Email           = 'mctestload@mail.com',
            Status          = 'Open',
            Industry        = 'Banking',
            MobilePhone     = '07776736763',
            Phone           = '0787565655',
            Title           = 'SampleTitle',
            Street          = '3 Sample Lane'
        );
        
        insert lead;
    }
}