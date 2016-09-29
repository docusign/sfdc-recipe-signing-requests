@isTest
global class DSR1CreateEnvelopeApiMock implements WebServiceMock {
    
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
           DocuSignTK.CreateEnvelopeResponse_element response_x =
               new DocuSignTK.CreateEnvelopeResponse_element();
           response_x.CreateEnvelopeResult = new DocuSignTK.EnvelopeStatus();
           response_x.CreateEnvelopeResult.EnvelopeID = 'test-envelope-id';
           response.put('response_x', response_x); 
   }
}