public class DSR1CallbackController {
    
    public class RequiredParameterMissingOrInvalidException extends Exception {}
    
    private Map<String, String> parametersMap;
    private String stage;
    private String event;
    private String envelopeId;
    private String successRedirect;
    private String failRedirect;
    
    private DSR1_Signing_Request__c signingRequest;
    
    
    public PageReference callback() {
        
        parametersMap = ApexPages.currentPage().getParameters();
        parseRequiredCallbackParameters();
        
        if (stage == 'send') {
            signingRequest = obtainSigningRequest([SELECT Id, Signer__c
                                                   FROM DSR1_Signing_Request__c
                                                   WHERE Envelope_Id__c = :envelopeId
                                                   AND Status__c = 'Created'
                                                   AND OwnerId = :UserInfo.getUserId()
                                                   LIMIT 1]);
            parseRedirectUrlsParameters(); // we can have redirect urls only after we have record Id
            
            if (event == 'Send') {
                signingRequest.Status__c = 'Sent';
                signingRequest.Error_Message__c = '';
                update signingRequest;
                postOnChatterFeed(signingRequest.Signer__c, signingRequest.Id);
                return new PageReference(EncodingUtil.urlDecode(successRedirect, 'UTF-8'));
            } else {
                signingRequest.Error_Message__c = 'Envelope not sent (' + event + ')';
                update signingRequest;
                return new PageReference(EncodingUtil.urlDecode(failRedirect, 'UTF-8'));
            }
            
        } else if (stage == 'sign') {
            signingRequest = obtainSigningRequest([SELECT Id
                                                   FROM DSR1_Signing_Request__c
                                                   WHERE Envelope_Id__c = :envelopeId
                                                   AND Status__c = 'Sent'
                                                   AND Signer__c = :UserInfo.getUserId()
                                                   LIMIT 1]);
            parseRedirectUrlsParameters(); // we can have redirect urls only after we have record Id
            if (event == 'signing_complete') {
                signingRequest.Status__c = 'Signed';
                signingRequest.Error_Message__c = '';
                update signingRequest;
                return new PageReference(EncodingUtil.urlDecode(successRedirect, 'UTF-8'));
            } else {
                signingRequest.Error_Message__c = 'You have not finished signing the document (' + event + ')';
                update signingRequest;
                return new PageReference(EncodingUtil.urlDecode(failRedirect, 'UTF-8'));
            }
        } else {
            throw new RequiredParameterMissingOrInvalidException('Unknown stage: "' + stage + '"');
        }  
    }
    
    private void parseRequiredCallbackParameters() {
        
        //   Required callback parameters are:
        //   
        //     * stage (required): can be "send" (after send process completed by Sender)
        //       or "sign" (after sign process completed by Signer)
        //       THIS PARAMETER IS NOT FROM STANDARD DOCUSIGN PARAMETERS,
        //       it is managed from the SF side to distinguish between processes
        //       caused the callback;
        //       
        //     * event (required): depends on DocuSign result;
        //     
        //     * envelopeId (required): DocuSign Id of the envelope;
        
        if (!parametersMap.containsKey('stage') ||
            !parametersMap.containsKey('event') ||
            !parametersMap.containsKey('envelopeId')) {
                throw new RequiredParameterMissingOrInvalidException('Required parameter missing.');
            }
        
        stage = parametersMap.get('stage');
        event = parametersMap.get('event');
        envelopeId = parametersMap.get('envelopeId');
        
    }
    
    private void parseRedirectUrlsParameters() {
        
        //     Redirect URL parameters are:
        //
        //     * successRedirect: SF URL to be redirected to when send / sign process
        //       was successfully completed.
        //       Default is Signing Request record page URL.
        //       
        //     * failRedirect: SF URL to be redirected to when send / sign process
        //       was not completed
        //       Default is Signing Request record page URL.
        //       
        //       REDIRECT PARAMETERS ARE NOT FROM STANDARD DOCUSIGN PARAMETERS
        
        successRedirect = (parametersMap.containsKey('successRedirect') &&
                           String.isNotBlank(parametersMap.get('successRedirect')))
            ? parametersMap.get('successRedirect')
            : '/' + signingRequest.Id;
        
        
        failRedirect = (parametersMap.containsKey('failRedirect') &&
                        String.isNotBlank(parametersMap.get('failRedirect')))
            ? parametersMap.get('failRedirect')
            : '/' + signingRequest.Id;
        
    }
    
    private DSR1_Signing_Request__c obtainSigningRequest(List<DSR1_Signing_Request__c> signingRequestList) {
        if (signingRequestList.isEmpty()) {
            throw new RequiredParameterMissingOrInvalidException('Signing request not found or you ' +
                                                                 'are not authorised to access it.');
        } else {
            return signingRequestList[0];
        }
    }
    
    public static void postOnChatterFeed(Id userToMentionId, Id signingRequestId) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        mentionSegmentInput.id = userToMentionId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        textSegmentInput.text = ', you have a new signing request.';
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = signingRequestId;
        feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement('internal', feedItemInput);
    }
    
}