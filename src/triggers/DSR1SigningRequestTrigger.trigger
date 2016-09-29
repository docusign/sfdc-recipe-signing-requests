trigger DSR1SigningRequestTrigger on DSR1_Signing_Request__c (after insert, after update) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
        if (Trigger.new[0].Status__c == 'Pending') {
            DSR1SigningRequestHelper.onSigningRequestInserted(Trigger.new[0].Id);
        }
    }
	
	if (Trigger.isAfter && Trigger.isUpdate) {
		List<DSR1_Signing_Request__Share> srShares = new List<DSR1_Signing_Request__Share>();

	    for(DSR1_Signing_Request__c sr : trigger.new) {
			
			if (sr.Status__c == 'Sent' && Trigger.oldMap.get(sr.Id).Status__c != 'Sent') {
				DSR1_Signing_Request__Share shShare = new DSR1_Signing_Request__Share();
	        	shShare.ParentId = sr.Id;
	        	shShare.UserOrGroupId = sr.Signer__c;
	        	shShare.AccessLevel = 'edit';
	        	shShare.RowCause = Schema.DSR1_Signing_Request__Share.RowCause.DSR1_Sharing_with_Signer__c;
	        	srShares.add(shShare);
			}
			
	    }
        
    	Database.SaveResult[] srShareInsertResult = Database.insert(srShares,false);
    	
	}
    
    
}