public class LeadHandler {
    public static void FillAccount(list<lead> newrecords){
        list<string> namelist =new list<string>();
        for(lead l:newrecords){
            if(l.Company!=null){
                namelist.add(l.Company);
            }
        }
        system.debug(namelist);
        if(namelist.isempty()) return;
        map<string,account> accmap = new map<string,account>();
        list<account> acclist = [select id,name from account where name in:namelist];
        for(account acc:acclist){
            if(acc.name!=null){
                accmap.put(acc.name,acc);
            }
        }
        system.debug(acclist);
        system.debug(accmap);
        for(Lead le:newrecords){
            if(accmap.containskey(le.company)){
                le.Matching_Account__c=accmap.get(le.Company).id;
            }
        }
    }

   ///////////////////////////    convert lead     /////////////////////////
   
    public static void convertLead(map<id,lead> newmap, map<id,lead> oldmap){
        set<id> leadidset = new set<id>();
        for(lead l: newmap.values()){
            if( l.Status != oldmap.get(l.Id).Status && l.Status=='Qualified' && !l.IsConverted){
                leadidset.add(l.Id);                          
            }
        }
        if (leadidset.isEmpty()) return ;
        system.enqueuejob(new LeadQueueable(leadidset));
    }
}