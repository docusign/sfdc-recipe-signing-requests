@isTest
public class DSR1CallbackControllerTest {

    @isTest(SeeAllData=true) // System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests.
    public static void testSend() {
        Test.setMock(WebServiceMock.class, new DSR1CreateEnvelopeApiMock());
        DSR1_Signing_Request__c testSr = new DSR1_Signing_Request__c();
        testSr.Name = 'Test Siging Request';
        testSr.Signer__c = ((User)[SELECT Id FROM User LIMIT 1]).Id;
        testSr.Status__c = 'Created';
        testSr.Envelope_Id__c = 'test-envelope-id';
        insert testSr;
        
        Test.setCurrentPageReference(new PageReference('Page.DSR1Callback')); 
		System.currentPageReference().getParameters().put('stage', 'send');
        System.currentPageReference().getParameters().put('event', 'Send');
        System.currentPageReference().getParameters().put('envelopeId', 'test-envelope-id');
        DSR1CallbackController ctrl = new DSR1CallbackController();
        ctrl.callback();
    }
    
    @isTest(SeeAllData=true) // System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests.
    public static void testSign() {
        Test.setMock(WebServiceMock.class, new DSR1CreateEnvelopeApiMock());
        DSR1_Signing_Request__c testSr = new DSR1_Signing_Request__c();
        testSr.Name = 'Test Siging Request';
        testSr.Signer__c = UserInfo.getUserId();
        testSr.Status__c = 'Sent';
        testSr.Envelope_Id__c = 'test-envelope-id';
        insert testSr;
        
        Test.setCurrentPageReference(new PageReference('Page.DSR1Callback')); 
		System.currentPageReference().getParameters().put('stage', 'sign');
        System.currentPageReference().getParameters().put('event', 'signing_complete');
        System.currentPageReference().getParameters().put('envelopeId', 'test-envelope-id');
        DSR1CallbackController ctrl = new DSR1CallbackController();
        ctrl.callback();
    }
    
}