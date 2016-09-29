public class DSR1APIServiceSoapFactory {
    
    //private static String trace_value = 'DSR1_DocuSign_Signing_Recipe'; // Used for tracing API calls
    //private static String trace_key = 'X-ray';

    // If you choose to not use a named credential:
    // Private static string ds_server = 'https://demo.docusign.net/api/3.0/dsapi.asmx';
    
    
    public static DocuSignTK.APIServiceSoap getDocuSignAPIServiceSoap(String namedCredentialName){
        DSR1Integration dsr1Integration = new DSR1Integration();
        DocuSignTK.APIServiceSoap api_sender = new DocuSignTK.APIServiceSoap();
        String ds_server = 'callout:' + namedCredentialName + '/api/3.0/dsapi.asmx';
        api_sender.endpoint_x = ds_server;
        api_sender.inputHttpHeaders_x = new Map<String, String>();
        String auth =   '<DocuSignCredentials><Username>{!$Credential.Username}</Username>' 
                      + '<Password>{!$Credential.Password}</Password>' 
                      + '<IntegratorKey>' + dsr1Integration.integrationKey + '</IntegratorKey></DocuSignCredentials>';
        api_sender.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);
        //api_sender.inputHttpHeaders_x.put(trace_key, trace_value);
        return api_sender;
    }
    
}