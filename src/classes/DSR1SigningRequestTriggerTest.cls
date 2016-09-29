@isTest
public class DSR1SigningRequestTriggerTest {

    @isTest
    public static void testDSR1SigningRequestTrigger() {
        Test.setMock(WebServiceMock.class, new DSR1CreateEnvelopeApiMock());
        DSR1_Signing_Request__c testSr = new DSR1_Signing_Request__c();
        testSr.Name = 'Test Siging Request';
        testSr.Signer__c = ((User)[SELECT Id FROM User LIMIT 1]).Id;
        insert testSr;
        testSr.Status__c = 'Sent';
        update testSr;
    }
    
}