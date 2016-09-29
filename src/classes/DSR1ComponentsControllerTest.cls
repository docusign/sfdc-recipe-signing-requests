@isTest
public class DSR1ComponentsControllerTest {

    @isTest
    public static void testGetSigningRequestById() {
        DSR1_Signing_Request__c testSr = new DSR1_Signing_Request__c();
        testSr.Name = 'Test Siging Request';
        testSr.Signer__c = ((User)[SELECT Id FROM User LIMIT 1]).Id;
        testSr.Status__c = 'Created';
        testSr.Envelope_Id__c = 'test-envelope-id';
        insert testSr;
        DSR1ComponentsController.getSigningRequestById(testSr.Id);
    }
    
    @isTest
    public static void testSendEnvelope() {
        Test.setMock(WebServiceMock.class, new DSR1RequestSenderTokenApiMock());
        DSR1_Signing_Request__c testSr = new DSR1_Signing_Request__c();
        testSr.Name = 'Test Siging Request';
        testSr.Signer__c = ((User)[SELECT Id FROM User LIMIT 1]).Id;
        testSr.Status__c = 'Created';
        testSr.Envelope_Id__c = 'test-envelope-id';
        insert testSr;
        Test.startTest();
        String result = DSR1ComponentsController.sendEnvelope(testSr.Id, 'test', 'test', 'test');
        System.assertEquals('test-redirect-url', result);
        Test.stopTest();
    }
    
    @isTest
    public static void testSignEnvelope() {
        Test.setMock(WebServiceMock.class, new DSR1RequestRecipientTokenApiMock());
        DSR1_Signing_Request__c testSr = new DSR1_Signing_Request__c();
        testSr.Name = 'Test Siging Request';
        testSr.Signer__c = UserInfo.getUserId();
        testSr.Status__c = 'Sent';
        testSr.Envelope_Id__c = 'test-envelope-id';
        insert testSr;
        Test.startTest();
        String result = DSR1ComponentsController.signEnvelope(testSr.Id, 'test', 'test', 'test', 'test');
        System.assertEquals('test-redirect-url', result);
        Test.stopTest();
    }
    
}