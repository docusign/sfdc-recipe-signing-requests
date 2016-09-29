@isTest
global class DSR1RequestRecipientTokenApiMock implements WebServiceMock {

      global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           DocuSignTK.RequestRecipientTokenResponse_element response_x =
               new DocuSignTK.RequestRecipientTokenResponse_element();
           response_x.RequestRecipientTokenResult = 'test-redirect-url';
           response.put('response_x', response_x); 
	}
    
}