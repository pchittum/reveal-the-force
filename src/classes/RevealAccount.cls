public class RevealAccount{
    
    private Id topAcctId; 
    
    public RevealAccount(){
 		topAcctId = getTopLevelAccountId('001b000000PX5gF');
    }
    
/**
* there is a theoretical infinite number of levels of account hierarchy. This opens a potential 
* governor limit problem as we can query 5 levels at a time working our way up the tree, but to do this 
* in a loop, we risk running into the 
*/
    private Id getTopLevelAccountId (Id rootAcctId){
        //use two helper methods to iterate up to find the ultimate top level account
        String topId; 
        Id workingAcctId = rootAcctId; 
        
        //at some point I might want to set an upper limit of how far up the 
        //hierarchy to search, but for now I'm going to go for it
        while (topId == null || topId.equals('')){
            Account workingAcct = retrieveFiveLevelsAccounts(workingAcctId);
            topId = scanFiveLevelsAccounts(workingAcct);
            if (topId.equals('')){//topId should only be an empty string if we've run out of account hierarchy and need to requery
                workingAcctId = workingAcct.Parent.Parent.Parent.Parent.Parent.ParentId; 
            }
        }
        System.debug('found a top accountId. it is: ' + topId);
        return topId;
    }
    
    private Account retrieveFiveLevelsAccounts(Id rootAcctId){
        Account acct = new Account();
        try {
            acct = [select Id, name, ParentId,
                Parent.ParentId, 
                    Parent.Parent.ParentId, 
                        Parent.Parent.Parent.ParentId, 
                            Parent.Parent.Parent.Parent.ParentId,
                                Parent.Parent.Parent.Parent.Parent.ParentId
                 from account 
                 where id = : rootAcctId];       
        } catch (QueryException e) {
        	ApexPages.Message noResultWarning = new ApexPages.Message(ApexPages.Severity.WARNING, 
                                                                      'Unexpected Query Result', 
                     'The Query for the account failed. The requested account was not retrieved or something else even more unexpected happened. Seek help from a professional.');
        }
        return acct;
    }
    
    private String scanFiveLevelsAccounts(Account a){
        //try and find a null ParentId to determine the top
        //we can do this for 6 generations off one  SOQL
        System.debug('running scanFiveLevels'); 
    	String acctId; 

        if (a.ParentId != null) {
            if (a.Parent.ParentId != null) {
                if (a.Parent.Parent.ParentId != null) {
                    if (a.Parent.Parent.Parent.ParentId != null) {
                        if (a.Parent.Parent.Parent.Parent.ParentId != null) {
                            if (a.Parent.Parent.Parent.Parent.Parent.ParentId != null) {
                                System.debug('found parent id at fifth level need to keep going up');
                                acctId = '';
                            } else {
                                acctId = a.Parent.Parent.Parent.Parent.ParentId; 
                            }
                        } else {
                            acctId = a.Parent.Parent.Parent.ParentId; 
                        }
                    } else {
                        acctId = a.Parent.Parent.ParentId; 
                    }
                } else {
                    acctId = a.Parent.ParentId; 
                }
            } else {
                acctId = a.ParentId; 
            }
        } else {
            acctId = a.Id;
        }
        System.debug('returning the following id: ' + acctId);
        return acctId;
    }

}