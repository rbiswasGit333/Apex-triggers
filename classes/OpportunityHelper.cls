public class OpportunityHelper {
    public static void UpdateDiscount(list<opportunity> newrecords){
        for(opportunity opp:newrecords){
            if(opp.Diccount__c!=null && opp.Amount!=null){
                decimal dis=(opp.Diccount__c*opp.Amount)/100;
                opp.Diccounted_Price__c=opp.Amount-dis;
            }
            if(opp.Amount==null){
                opp.Amount=1000;
            }
        }
    }
    /////////////////////////////////////////////////////////////////
     public static void CreatTask(list<opportunity> newrecords){
         list<task> TasklistToInsert = new list<task>();
         for(opportunity opp:newrecords){
             if(opp.AccountId==null){
                 task t = new task();
                 t.Subject = ' Opportunity is created without Account';
                 t.description = 'Opportunity is created without Account, Please assign the Correct account to Opportunity';
                 t.ActivityDate = date.today().addDays(7);
                 t.Status = 'Not Started';
                 t.Priority = 'High';
                 t.WhatId = opp.Id;
                 t.OwnerId= opp.OwnerId;
                TasklistToInsert.add(t);
             }
         }
         try{
             insert as user TasklistToInsert;
         }catch(system.dmlException ex){
             system.debug(ex.getcause());
             system.debug(ex.getmessage());
             system.debug(ex.getlinenumber());
             system.debug(ex.getTypeName());
             system.debug(ex.getStackTraceString());
         }catch(system.exception ex1){
             system.debug(ex1.getTypeName());
         }finally{
             system.debug('Finally block get executed');
         }
     }
    //////////////////////////////throw eroor whe related account's active = No///////////////////////////////////////

    public static void throwError(list<opportunity> newrecords){
        set<id> accidset = new set<id>();
        for(opportunity opp:newrecords){
            if(opp.AccountId != null){
                accidset.add(opp.AccountId);
            }
        }
        map<id,account> accmap = new map<id,account>([select id,name,active__c from account where id in:accidset]);
        for(opportunity opp1:newrecords){
            if(opp1.AccountId != null){
                if(accmap.get(opp1.AccountId).Active__c=='No'){
                opp1.addError('You can not create an opportunity under the account that is Not Active');
                }
            }            
        }
    }
    
  ////////////Update account's "sum of Open/Closed Opportunity amount" field when Opp is updated//////////////////   
    
    public static void UpdateAccountfield(set<id> accidset){
  
        if(accidset.isempty()) return;
        list<aggregateresult> closedAmountList=[select sum(Amount) ,
                                                accountid from opportunity where
                                                stageName in ('Closed Won','Closed Lost') AND accountid in:accidset 
                                                group by accountid];
        list<aggregateresult> openedAmountList=[select sum(amount),accountid from opportunity
                                                where stagename !='Closed Lost' and stagename != 'Closed Won' 
                                                and accountid in:accidset group by accountid];
        system.debug(closedAmountList);
        system.debug(openedAmountList);        
        map<id,decimal> closedAmountMap = new map<id,decimal>();
        map<id,decimal> openedAmountMap = new map<id,decimal>();       
        for(aggregateresult agr:closedAmountList){
            closedAmountMap.put((id)agr.get('AccountId'),(decimal)agr.get('expr0'));
        }
        for(aggregateresult agr2:openedAmountList){
            openedAmountMap.put((id)agr2.get('AccountId'),(decimal)agr2.get('expr0'));
        }
        list<account> openedlisttoupdate=new list<account>();
        list<account> closedlisttoupdate=new list<account>();
        list<account> zeroOppacclist=[select id, (select id from opportunities)from account where id in:accidset];   

        for(id id1:accidset){
            if(id1!=null && closedAmountMap.containskey(id1)){
                decimal amount1=closedAmountMap.get(id1);
                closedlisttoupdate.add(new account(id=id1,Sum_of_Closed_Opportunity_Amount__c=amount1));
            }
            if(id1!=null && openedAmountMap.containskey(id1)){
                decimal amount2=openedAmountMap.get(id1);
                openedlisttoupdate.add(new account(id=id1,Sum_of_Open_Opportunity_Amount__c=amount2));
            }
         }
         for(account acc:zeroOppacclist){
            if(acc.opportunities.isempty()){
               closedlisttoupdate.add(new account(id=acc.id,Sum_of_Closed_Opportunity_Amount__c=0,Sum_of_Open_Opportunity_Amount__c=0));
            }
         }
        system.debug(closedlisttoupdate);
        update closedlisttoupdate;
        update openedlisttoupdate;
    }
}