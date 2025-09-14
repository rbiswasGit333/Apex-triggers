public class AccountHandler {
    public static void HandleBeforeInsertUpdate(list<account> NewAccountRecords){
        list<account> acclist = new list<account>();
        for(account acc1:NewAccountRecords){
            acc1.Industry='Education';
            if(acc1.Description==null){
                acc1.Description='Account Description is blank';
            }else{}
            acclist.add(acc1);
        }
    AccountHelper.UpdateBillingAddress(NewAccountRecords);
    }
    
    
    ////////////////////////update the sales rep field when acc is updated////////////////////////
    public static void UpdateSalesRep(list<account> newrecords){
        for(account acc:newrecords){
            acc.Sales_Rep__c=acc.OwnerId;
            
            system.debug(acc.Sales_Rep__c);
        }
    }
    
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
    public static void HandleAfterUpdate1(List<Account> newRecords, Map<Id, Account> oldMap) {
        Set<Id> accIdSet = new Set<Id>();
        
        // Step 1: Identify which Accounts had Active__c changed
        for (Account acc : newRecords) {
            if (acc.Active__c != null && acc.Active__c != oldMap.get(acc.Id).Active__c) {
                accIdSet.add(acc.Id);
            }
        }
        
        // Step 2: Query related Contacts and Opportunities
        List<Contact> conList = [SELECT Id, AccountId, Active__c FROM Contact  WHERE AccountId IN :accIdSet];
        
        List<Opportunity> oppList = [SELECT Id, AccountId, Active__c  FROM Opportunity  WHERE AccountId IN :accIdSet ];
        
        // Step 3: Create Account-to-Active__c Map (1 loop only)
        Map<Id, string> accActiveMap = new Map<Id, string>();
        for (Account acc : newRecords) {
            if (accIdSet.contains(acc.Id)) {
                accActiveMap.put(acc.Id, acc.Active__c);
            }
        }
        
        // Step 4: Update Contacts and Opportunities in a single loop each
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (Contact con : conList) {
            if (accActiveMap.containsKey(con.AccountId)) {
                con.Active__c = accActiveMap.get(con.AccountId);
                contactsToUpdate.add(con);
            }
        }
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity opp : oppList) {
            if (accActiveMap.containsKey(opp.AccountId)) {
                opp.Active__c = accActiveMap.get(opp.AccountId);
                oppsToUpdate.add(opp);
            }
        }
        
        // Step 5: Final DML
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
    
    ///////////////update contact & opportunity owner with account owner////////////
    
    public static void changeaccountowner(map<id,account>  newmap1 , map<id,account>  oldmap1){
        set<id> accidset1 = new set<id>();
        for(id accid:newmap1.keyset() ){
            if(newmap1.get(accid).OwnerId != oldmap1.get(accid).ownerid){
                accidset1.add(accid);
            }
        }
        list<contact> conlist2=[select id,accountid,ownerid from contact where accountid in:accidset1];
        list<opportunity> opplist2=[select id,accountid,ownerid from opportunity where accountid in:accidset1];
        map<id,id> accmap = new map<id,id>();
        for(id accid1 : accidset1){
            accmap.put(accid1,newmap1.get(accid1).ownerid);
        }
        list<contact> conlisttoupdate1= new list<contact>();
        list<opportunity> opplisttoupdate1 = new list<opportunity>();
        for(contact con3:conlist2){
            con3.ownerid=accmap.get(con3.accountid);
            conlisttoupdate1.add(con3);
        }
        for(opportunity opp3:opplist2){
            opp3.ownerid=accmap.get(opp3.accountid);
            opplisttoupdate1.add(opp3);
        }
        if(!opplisttoupdate1.isEmpty()){   
            update opplisttoupdate1;
        }
        if(!conlisttoupdate1.isEmpty()){
            update conlisttoupdate1;
        }
    }
    
    
    //////////////////////////sendind email to account owner////////////////////// 
    public static void handleafterinsert(list<account> newrecords3){
        AccountHelper.sendemail(newrecords3);
    }
    
    
    ////////////////////////prevent Duplicate account Records/////////////////
    public static void HandleBeforeInsert(list<account> newrecords2){
        AccountHelper.preventDuplicacy(newrecords2);
    }
    
}
///////////////////////////////////////////////////////////////////////////////////////
 //  or you can write------------
 /*    public static void HandleAfterUpdate(list<account> newrecords, map<id,account> oldmap){
        set<id> accidset = new set<id>();
        for(account acc :newrecords){
            if(acc.Active__c!=null && acc.Active__c!=oldmap.get(acc.Id).active__c){
                accidset.add(acc.Id);
            }
        }
        list<contact> conlist=[select id,accountid,active__c from contact where accountid in:accidset];
        list<opportunity> opplist=[select id,accountid,active__c from opportunity where accountid in:accidset];
        map<id,list<contact>>  conmap = new map<id,list<contact>>();
        map<id,list<opportunity>>  oppmap = new map<id,list<opportunity>>();
        for(contact con1:conlist){
            if(!conmap.containskey(con1.accountid)){
                conmap.put(con1.AccountId,new list<contact>());
                conmap.get(con1.AccountId).add(con1);
            }else{
                conmap.get(con1.AccountId).add(con1);
            }
            
        }
        for(opportunity opp1:opplist){
            if(!oppmap.containskey(opp1.accountid)){
                oppmap.put(opp1.AccountId,new list<opportunity>());
                oppmap.get(opp1.AccountId).add(opp1);
            }else{
                oppmap.get(opp1.AccountId).add(opp1);
            }
            
        }
        list<contact> conlisttoupdate= new list<contact>();
        list<opportunity> opplisttoupdate = new list<opportunity>();
        for(account acc2:newrecords){
            for(contact con2:conmap.get(acc2.Id)){
                con2.Active__c=acc2.Active__c;
                conlisttoupdate.add(con2);
            }
            for(opportunity opp2:oppmap.get(acc2.Id)){
                opp2.active__c=acc2.Active__c;
                opplisttoupdate.add(opp2);
            }
        }
        update opplisttoupdate;
        update conlisttoupdate;
    }
*/