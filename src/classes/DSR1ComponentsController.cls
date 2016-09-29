global class DSR1ComponentsController {
    
    @AuraEnabled
    public static DSR1_Signing_Request__c getSigningRequestById(Id signingRequestId) {
        List<DSR1_Signing_Request__c> signingRequestList = [SELECT Id, Name, Status__c, Signer__c,
                                                              Description__c
                                                       FROM DSR1_Signing_Request__c
                                                       WHERE Id = :signingRequestId
                                                       LIMIT 1];
        if (signingRequestList.isEmpty()) {
            return null;
        } else {
            return signingRequestList[0];
        }
    }
    
    @AuraEnabled
    public static String sendEnvelope(Id signingRequestId, String successRedirect, String failRedirect, String namedCredentialAPIName) {
        
        successRedirect = successRedirect == null ? '' : successRedirect;
        failRedirect = failRedirect == null ? '' : failRedirect;
        
        String callbackUrl = URL.getSalesforceBaseUrl().toExternalForm() +
            '/apex/DSR1Callback' +
            '?stage=send' +
            '&successRedirect=' + EncodingUtil.urlEncode(successRedirect, 'UTF-8') +
            '&failRedirect=' + EncodingUtil.urlEncode(failRedirect, 'UTF-8');
        
        
        Id currentUserId = getCurrentUserId();
        List<DSR1_Signing_Request__c> signingRequestList = [SELECT Envelope_Id__c
                                                       FROM DSR1_Signing_Request__c
                                                       WHERE Id = :signingRequestId
                                                       AND CreatedById = :currentUserId
                                                       AND Status__c = 'Created'
                                                       LIMIT 1];
        if (signingRequestList.isEmpty()) {
            return null;
        }
        DSR1_Signing_Request__c signingRequest = signingRequestList[0];

        try {
            DocuSignTK.APIServiceSoap api = DSR1APIServiceSoapFactory.getDocuSignAPIServiceSoap(namedCredentialAPIName);
        	DSR1Integration dsr1Integration = new DSR1Integration();
            String redirectUrl = api.RequestSenderToken(signingRequest.Envelope_Id__c,
                                                        dsr1Integration.accountId,
                                                        callbackUrl);
            if (String.isNotBlank(redirectUrl)) {
                return redirectUrl;
            } else {
                return null;
            }
        } catch (Exception e) {
            signingRequest.Error_Message__c = 'Error while sending envelope: ' + e.getMessage();
            signingRequest.Status__c = 'Error';
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String signEnvelope(Id signingRequestId, String successRedirect, String failRedirect, String communityUrl, String namedCredentialAPIName) {
        
        Id currentUserId = getCurrentUserId();
        List<DSR1_Signing_Request__c> signingRequestList = [SELECT Envelope_Id__c, Signer__c,
                                                       Signer__r.Email, Signer__r.LastName,
                                                       Signer__r.FirstName
                                                       FROM DSR1_Signing_Request__c
                                                       WHERE Id = :signingRequestId
                                                       AND Signer__c = :currentUserId
                                                       AND Status__c = 'Sent'
                                                       LIMIT 1];
        if (signingRequestList.isEmpty()) {
            return null;
        }
        DSR1_Signing_Request__c signingRequest = signingRequestList[0];
        try {
            DocuSignTK.APIServiceSoap api = DSR1APIServiceSoapFactory.getDocuSignAPIServiceSoap(namedCredentialAPIName);
            DocuSignTK.RequestRecipientTokenAuthenticationAssertion assertion = 
                new DocuSignTK.RequestRecipientTokenAuthenticationAssertion();
            assertion.AssertionID = String.valueOf(String.valueOf(Datetime.now()).hashCode());
            assertion.AuthenticationInstant = Datetime.now();
            assertion.AuthenticationMethod = 'Password';
            assertion.SecurityDomain = namedCredentialAPIName;
            
            DocuSignTK.RequestRecipientTokenClientURLs urls = new DocuSignTK.RequestRecipientTokenClientURLs();
            String return_url_base = communityUrl + '/DSR1Callback' +
                '?stage=sign' +
                '&envelopeId=' + signingRequest.Envelope_Id__c +
                '&successRedirect=' + EncodingUtil.urlEncode(successRedirect, 'UTF-8') +
                '&failRedirect=' + EncodingUtil.urlEncode(failRedirect, 'UTF-8');
            urls.OnSigningComplete  = return_url_base + '&event=signing_complete';
            urls.OnViewingComplete  = return_url_base + '&event=viewing_complete';
            urls.OnCancel           = return_url_base + '&event=cancel';
            urls.OnDecline          = return_url_base + '&event=decline';
            urls.OnSessionTimeout   = return_url_base + '&event=session_timeout';
            urls.OnTTLExpired       = return_url_base + '&event=ttl_expired';
            urls.OnException        = return_url_base + '&event=exception';
            urls.OnAccessCodeFailed = return_url_base + '&event=failed_access_code';
            urls.OnIdCheckFailed    = return_url_base + '&event=failed_id_check';
            urls.OnFaxPending       = return_url_base + '&event=fax_pending';
            
            
            String signer_view_url = api.RequestRecipientToken(
                signingRequest.Envelope_Id__c,
                signingRequest.Signer__c,
                signingRequest.Signer__r.FirstName + ' ' + signingRequest.Signer__r.LastName,
                signingRequest.Signer__r.Email,
                assertion,
                urls);
            
            return signer_view_url;
            
        } catch (Exception e) {
            signingRequest.Error_Message__c = 'Error while signing envelope: ' + e.getMessage();
            signingRequest.Status__c = 'Error';
            update signingRequest;
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String getCurrentUserId() {
        return UserInfo.getUserId();
    }
    
}