public class DSR1Integration {

    public class DSR1IntegrationException extends Exception {}
    
    private final DSR1_Integration__mdt integrationMdt;
    
    public DSR1Integration() {
        List<DSR1_Integration__mdt> integrationMdtList = [SELECT AccountId__c, IntegrationKey__c,
                                                          		 NamedCredentialAPIName__c
                                                          FROM DSR1_Integration__mdt];
        if (integrationMdtList.isEmpty()) {
            throw new DSR1IntegrationException('No integration configuration found.');
        } else {
            integrationMdt = integrationMdtList[0];
        }
    }    
    
    public String integrationKey { get { return integrationMdt.IntegrationKey__c; } }
    
    public String accountId { get { return integrationMdt.AccountId__c; } }
    
    public String namedCredentialAPIName { get { return integrationMdt.NamedCredentialAPIName__c; } }
    
}