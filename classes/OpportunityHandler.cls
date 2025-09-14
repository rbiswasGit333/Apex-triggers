public class OpportunityHandler {
    public static void HandleBeforeInsert(list<opportunity> newrecords){
        OpportunityHelper.UpdateDiscount(newrecords);
        OpportunityHelper.throwError(newrecords);
    }
    public static void HandleAfterInsert(list<opportunity> newrecords1){
        OpportunityHelper.CreatTask(newrecords1);
    }
    
    //////////////throw Error if amount and account changes when stagename =closed won////////////
    
    public static void HandleBeforeUpdate(map<id,opportunity> newrecords2, map<id,opportunity> oldrecords2){
        for(opportunity opp:newrecords2.values()){
            if(opp.StageName=='Closed Won'&& oldrecords2.get(opp.Id).stagename=='Closed Won'){
                if(opp.AccountId != oldrecords2.get(opp.Id).AccountId || opp.Amount != oldrecords2.get(opp.Id).Amount ){
                    opp.AddError('Amount & Account can not be changed when Stage Name set to Closed Won');
                    opp.Amount.AddError('Amount can not be changed when Stage Name set to Closed Won');
                    opp.AccountId.AddError('Account can not be changed when Stage Name set to Closed Won');
                }
            }
        }
    }
  ////////////Update account's "sum of Open/Closed Opportunity amount" field when Opp is updated//////////////////   
  
    public static void HandleAfterUpdate(map<id,opportunity> newrecords,map<id,opportunity> oldrecords){
        
        set<id> accidset = new set<id>();
        system.debug(accidset);
        for(opportunity opp:newrecords.values()){
            if(opp.AccountId !=null){
                accidset.add(opp.AccountId);
            }
            if(oldrecords.get(opp.id).AccountId != null){
                accidset.add(oldrecords.get(opp.id).AccountId);
            }                
        }
        OpportunityHelper.UpdateAccountfield(accidset);
    }
    public static void HandleAfterInsertDeleteUndelete(list<opportunity> newlist){
        set<id> accidset1 = new set<id>();
        for(opportunity opp:newlist){
            if(opp.accountid !=null){
                accidset1.add(opp.AccountId);
            }
        }
        OpportunityHelper.UpdateAccountfield(accidset1);
    }
///////////////////////////////////
    public static void throwerror(list<Opportunity> oldlist){
        set<id> oppidset = new set<id>();
        for(opportunity op:oldlist){
            oppidset.add(op.Id);
        }
        list<opportunitylineitem> olilist= [select id,opportunityId from opportunitylineitem where opportunityId in:oppidset];
        system.debug(olilist);
        for(opportunity op1:oldlist){
            if(!olilist.isempty()){
                op1.adderror('Opportunity can not be deleted first delete all the products');
            }
        }
    }

    
        
    
    
    
///////////////////// Insert A 'Deleted Opportunity' when an Opprtunity get deleted ///////////////

    public static void InsertDelOpp(list<Opportunity> oldlist){
        
        list<Deleted_Opportunity__c> listtoinsert = new list<Deleted_Opportunity__c>();
        for(Opportunity opp : oldlist){
            Deleted_Opportunity__c DelOpp = new Deleted_Opportunity__c();
            DelOpp.Account_Name__c=opp.AccountId;
            DelOpp.Opportunity_Id__c=opp.Id;
            DelOpp.Stage_Name__c=opp.StageName;
            DelOpp.Opportunity_Amount__c=opp.Amount;
            DelOpp.Closed_Date__c=opp.CloseDate;
            DelOpp.Name=opp.Name;
            listtoinsert.add(DelOpp);
        }
        insert listtoinsert;
    }

  /////////////////////// Delete 'Deleted Opportunity' when Opportunity undeleted //////////////////////////  
    
    public static void DeleteDelOpp(list<opportunity> newrecords){
        set<id> oppidset = new set<id>();
        for(opportunity opp: newrecords){
            oppidset.add(opp.Id);
        }
        system.debug(oppidset);
        list<Deleted_Opportunity__c> listtodelete1 = [select id from Deleted_Opportunity__c where Opportunity_Id__c	 in:oppidset];
        system.debug(listtodelete1);
        delete listtodelete1;
    }

//////////////////// Create product,opp product,price book entry when opp inserted///////////////

    public static void creatproduct(list<opportunity> newopp){
        list<Product2> productlist = new list<Product2>();
        map<string,opportunity> ProNameOppmap = new map<string,opportunity>();// (id:pricebook2Id , id:Opportunity id)
        for(opportunity opp:newopp){
            if(opp.Product_Name__c!=null && opp.Create_Line_Items__c==true && opp.Product_Standard_Price__c!=null){
                ProNameOppmap.put(opp.Product_Name__c.trim(),opp);
                productlist.add(new product2(Name=opp.Product_Name__c,Standard_Price__c=opp.Product_Standard_Price__c ,isactive=true));
            }
        }
        insert productlist;   
        
        pricebook2 book = [select id from pricebook2 where isstandard=true limit 1];   
        map<id,opportunity> ProIdOppmap = new map<id,opportunity>();///(id:ProductId , id:OppId)
        list<PricebookEntry> entrylist = new list<PricebookEntry>();        
        for(Product2 pro:productlist){
            ProIdOppmap.put(pro.Id,ProNameOppmap.get(pro.Name.trim()));
            PricebookEntry bookentry = new PricebookEntry();
            bookentry.Pricebook2Id=book.id;
            bookentry.Product2Id=pro.id;
            bookentry.UnitPrice=pro.Standard_Price__c;
            bookentry.IsActive=true;
            entrylist.add(bookentry);
        }
        insert entrylist; 
        
        list<PricebookEntry> customentrylist = entrylist.deepclone(false,false,false);
        for(PricebookEntry en:customentrylist){
            en.Pricebook2Id=ProIdOppmap.get(en.Product2Id).Pricebook2Id;
            en.UnitPrice=ProIdOppmap.get(en.Product2Id).Product_Custom_Price__c;
        }
        insert customentrylist;
        
        list<OpportunityLineItem> oppitemlist = new list<OpportunityLineItem>();
        for(PricebookEntry entry:customentrylist){
            OpportunityLineItem oppitem = new OpportunityLineItem();
            oppitem.OpportunityId=ProIdOppmap.get(entry.Product2Id).id;
            oppitem.Product2Id=entry.Product2Id;
            oppitem.PricebookEntryId=entry.Id;            
            oppitem.Quantity=1;
            oppitem.UnitPrice=entry.UnitPrice;
            oppitemlist.add(oppitem);
        }
        insert oppitemlist;
    }
    
    ////////////////// Update account's multiselect values to opportunity's multiselect values ////////////////////
    public static void upacc(map<id,opportunity> newmap,map<id,opportunity> oldmap){
        set<id> accid = new set<id>();
        for(opportunity opp:newmap.values()){
            if(opp.AccountId!=null){
                accid.add(opp.AccountId);
            }
        }
        map<id,account> accmap = new map<id,account>([select id,OPP_VALUE__C from account where id in:accid]);
        for(opportunity opp:newmap.values()){
            if(opp!=oldmap.get(opp.Id) && accmap.containskey(opp.AccountId)){
                accmap.get(opp.AccountId).OPP_VALUE__C=opp.ACC__c;
            }
        }
        update accmap.values();
    }
}