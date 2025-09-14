public class AccountRequestHandler {
    public static void InsertAccShare(list<Account_Request__c> newaccreq){
        list<AccountShare> accSharetoinsert = new list<AccountShare>();
        for(Account_Request__c accreq:newaccreq){
            AccountShare  accsh = new accountshare();
            accsh.AccountAccessLevel=accreq.Access_Level__c;
            
            accsh.AccountId=accreq.Account__c;
            accsh.RowCause='Manual';
            accsh.OpportunityAccessLevel=accreq.Access_Level__c;
            accsh.UserOrGroupId=accreq.User__c;
            accSharetoinsert.add(accsh);
        }
        system.debug(accSharetoinsert);
            insert as user  accSharetoinsert; 
    }
    public static void DeleteAccShare(map<id,Account_Request__c> oldmap){
        set<id> accidset =new set<id>();
        for(Account_Request__c accreq:oldmap.values()){
            accidset.add(accreq.Account__c);
        }
        list<AccountShare> accsharelist=[select id from AccountShare where AccountId in:accidset];
        system.debug(accsharelist);
        delete  as user accsharelist;
    }

}