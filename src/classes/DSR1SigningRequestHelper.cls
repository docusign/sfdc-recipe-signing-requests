public class DSR1SigningRequestHelper {

    @future(callout=true)
    public static void onSigningRequestInserted(Id signingRequestId) {

        DSR1_Signing_Request__c signingRequest = [SELECT Name, Description__c, Signer__r.Id,
                                             		Signer__r.LastName, Signer__r.FirstName,
                                             		Signer__r.Email
                                               FROM DSR1_Signing_Request__c
                                              WHERE Id = :signingRequestId];
        DocuSignTK.Envelope envelope = new DocuSignTK.Envelope();
        envelope.Subject = 'Please sign "' + signingRequest.Name + '"';
        DSR1Integration dsr1Integration = new DSR1Integration();
        envelope.AccountId  = DSR1Integration.accountId;
        
        DocuSignTK.Recipient recipient = DSR1RecipientFactory.makeRecipientFromUser(signingRequest.Signer__r);
        
        envelope.Recipients = new DocuSignTK.ArrayOfRecipient();
        envelope.Recipients.Recipient = new DocuSignTK.Recipient[1];
        envelope.Recipients.Recipient.add(recipient);
        
        try {
            DocuSignTK.APIServiceSoap api = DSR1APIServiceSoapFactory.getDocuSignAPIServiceSoap(
            														dsr1Integration.namedCredentialAPIName);   
            DocuSignTK.EnvelopeStatus result = api.CreateEnvelope(envelope);
            signingRequest.Envelope_Id__c = result.EnvelopeID;
            signingRequest.Status__c = 'Created';
        } catch ( CalloutException e) {
            signingRequest.Error_Message__c = 'Error while creating envelope: ' + e.getMessage();
            signingRequest.Status__c = 'Error';
        }
        
        update signingRequest;
        
    }
    
    
    
}