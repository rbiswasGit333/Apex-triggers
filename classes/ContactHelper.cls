public class ContactHelper {
    public static void UpdateAddress(list<contact> newrecords){
        list<id> AccIdList = new list<id>();
        for(contact con:newrecords){
            AccIdList.add(con.accountid);
        }
        map<id,account> accmap = new map<id,account>();
        try{
            accmap = new map<id,account>([select id,ShippingStreet,
                                                      ShippingCity,ShippingState,ShippingPostalCode,ShippingLatitude,
                                                      ShippingCountry,BillingStreet,BillingCity,BillingLatitude,
                                                      BillingState,BillingPostalCode,BillingLongitude,
                                                      BillingCountry from account where id in:AccIdList with user_mode]);
        }catch(QueryException ex){
            system.debug(ex.getMessage());
            map<string,set<string>> inaccessible = ex.getInaccessibleFields();
            if(inaccessible.ContainsKey('Account')){
                set<string> acc2 = inaccessible.get('Account');
                system.debug(acc2);
            }
            
        }
        
        for(contact con1:newrecords){
            account acc1 = accmap.get(con1.AccountId);
            if(con1.AccountId != null){
                con1.MailingCity=acc1.ShippingCity;
                con1.MailingCountry=acc1.ShippingCountry;
                con1.MailingLatitude=acc1.ShippingLatitude;
                con1.MailingPostalCode=acc1.ShippingPostalCode;
                con1.MailingState=acc1.ShippingState;
                con1.MailingStreet=acc1.ShippingStreet;
                con1.OtherCity=acc1.BillingCity;
                con1.OtherCountry=acc1.BillingCountry;
                con1.OtherLatitude=acc1.BillingLatitude;
                con1.OtherLongitude=acc1.BillingLongitude;
                con1.OtherPostalCode=acc1.BillingPostalCode;
                con1.OtherState=acc1.BillingState;
                con1.OtherStreet=acc1.BillingStreet;
            }
        }
    }
    
    //////////////// throw eroor whe related account's active = No /////////////
    public static void throwError(list<contact> newrecords){
        set<id> accidset = new set<id>();
        for(contact con:newrecords){
            accidset.add(con.AccountId);
        }
        list<account> acclist=[select id,name,active__c from account where id in:accidset];
        map<id,string> accmap = new map<id,string>();
        for(account acc :acclist){
            accmap.put(acc.Id,acc.Active__c);
        }
        for(contact con: newrecords){
            if(accmap.get(con.AccountId)=='No'){
                con.addError('You can not create a contact under the account that is Not Active');
            }
        }
    }
////////////////////update no of contacts to account field when Update contact////////////////////
public static void UpdateContactToAccount(map<id,contact> newconmap ,map<id,contact> oldconmap){
        set<id> accidset1 = new set<id>();
        for(contact con1:newconmap.values()){
            if( con1.AccountId !=oldconmap.get(con1.Id).accountid){
                accidset1.add(con1.AccountId);
                accidset1.add(oldconmap.get(con1.Id).AccountId);
                system.debug(con1.AccountId);
                system.debug(oldconmap.get(con1.Id).AccountId);
            } 
        }
        if(accidset1.isempty()) return;
        
        map<id,integer> contactCountmap=new map<id,integer>();
        
        list<aggregateresult> Aggregatelist =[select count(id),accountid from contact where accountid in:accidset1 group by accountid ];
    system.debug(Aggregatelist);
        for(aggregateresult agr: Aggregatelist){
            if((id)agr.get('accountid') != null){
                contactCountmap.put((id)agr.get('accountid') , (integer)agr.get('expr0'));
            }            
        }
    system.debug(contactCountmap);
        list<account> listToUpdate = new list<account>();
        for(id id1:accidset1){
            if(id1 != null){
                integer count=contactCountmap.containskey(id1) ? contactCountmap.get(id1) : 0;
            listToUpdate.add(new account(id=id1, Number_Of_Contacts__c=count));
            }            
        }
        update listToUpdate;
    }
    
 ///////////////update no of contacts to account field  when insert,delete,undelete contact////////////////////   
    
    public static void UpdateContactToAccount2(list<contact> newconlist){
        set<id> accidset2 = new set<id>();
        for(contact con2:newconlist){
            if(con2.AccountId != null){
                accidset2.add(con2.AccountId);
            }
        }
        if(accidset2.isempty()) return;
        list<aggregateresult> noOfContact2 = [select count(id),AccountId from contact where accountid in:accidset2 group by AccountId];
        map<id,integer> accmap2 = new map<id, integer>();
        for(aggregateresult agr2:noOfContact2){
            accmap2.put((id)agr2.get('AccountId'),(integer)agr2.get('expr0'));
        }
        list<account> listtoupdate2 = new list<account>();
        for(id ids2:accidset2){
            if(ids2 != null){
                integer count2 = accmap2.containskey(ids2) ? accmap2.get(ids2) : 0;
                listtoupdate2.add(new account(id=ids2,Number_Of_Contacts__c=count2));
            }            
        }
        update listtoupdate2;
    }
}