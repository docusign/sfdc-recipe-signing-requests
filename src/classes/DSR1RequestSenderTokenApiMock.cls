@isTest
global class DSR1RequestSenderTokenApiMock implements WebServiceMock {

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
           DocuSignTK.RequestSenderTokenResponse_element response_x =
               new DocuSignTK.RequestSenderTokenResponse_element();
           response_x.RequestSenderTokenResult = 'test-redirect-url';
           response.put('response_x', response_x); 
	}
    
}