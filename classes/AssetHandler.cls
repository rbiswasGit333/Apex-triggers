public class AssetHandler {
    public static void CreatOppOppLine(list<Asset> newasset){
        pricebook2 price = [SELECT Id, IsStandard FROM Pricebook2 where IsStandard=true limit 1];
        set<id> proidset = new set<id>();
        list<opportunity> opplist = new list<opportunity>();
        map<id,opportunity> oppmap =new map<id,opportunity>();
        
        for(Asset ast1:newasset){
            proidset.add(ast1.Product2Id);
        }
        list<pricebookentry> entrylist =[SELECT Id, Name,Product2Id, Pricebook2Id FROM PricebookEntry 
                                         where Pricebook2Id=:price.Id and product2id in:proidset and isActive=true]; 
        map<id,pricebookentry> entrymap = new map<id,pricebookentry>();
        
        for(pricebookentry en:entrylist){
            entrymap.put(en.Product2Id,en);
        }
        for(Asset ast:newasset){
            if(entrymap.containskey(ast.Product2Id)){
                opportunity opp = new opportunity();
                opp.name=ast.AccountId+'opportunity';
                opp.CloseDate=Date.today()+30;
                opp.AccountId=ast.AccountId;
                opp.Pricebook2Id= price.Id;
                opp.StageName='Prospecting'; 
                opplist.add(opp);
                oppmap.put(ast.AccountId,opp);                
            }else{
                ast.adderror('First add the Selected  "Product"  to Standard PriceBook and Activate it');
            }                       
        }
        insert opplist;
        list<opportunityLineItem> itemlist= new list<opportunityLineItem>();        
        for(asset astt:newasset){
            if(entrymap.containskey(astt.Product2Id)){
                opportunityLineItem it= new opportunityLineItem();           
                it.Quantity=astt.Quantity;
                it.UnitPrice=astt.Price;
                it.OpportunityId=oppmap.get(astt.AccountId).id;
                it.PricebookEntryId=entrymap.get(astt.Product2Id).id;
                itemlist.add(it);
            }        
        }
        insert itemlist;
    }
////////////// Update account's asset min expi date when asset insert/delete ////////////

    public static void upinsertOrdelete(list<asset> assetlist){
        set<id> accidset = new set<id>();
        for(asset a:assetlist){
            if(a.AccountId!=null){
                accidset.add(a.AccountId);
            }
        }
        map<id,account> accmap = new map<id,account>([select id, Asset_Minimum_Expiration_Date__c from account where id in:accidset]);
        list<aggregateresult> resultlist= [select min(usageEndDate),accountid from asset where accountid in:accidset group by accountid ];
        for(aggregateresult re:resultlist){
            if(accmap.containskey((string)re.get('accountid'))){
                accmap.get((string)re.get('accountid')).Asset_Minimum_Expiration_Date__c=(date)re.get('expr0');
            }
        }
        update accmap.values();
    }
    /////////// Update account's asset min expi date when asset Updated///////////
  
    public static void UpaccUpadate(map<id,asset> newmap ,map<id,asset> oldmap){
        set<id> accidset = new set<id>();        
        for(asset a:newmap.values()){
            if(a.AccountId!=null && (a.AccountId!=oldmap.get(a.Id).accountid || a.UsageEndDate!=oldmap.get(a.Id).UsageEndDate)){
                accidset.add(a.AccountId);
                accidset.add(oldmap.get(a.Id).accountid);
            }
        }
        system.debug(accidset);
        map<id,account> accmap = new map<id,account>([select id,Asset_Minimum_Expiration_Date__c from account where id in:accidset]);
        system.debug(accmap);
        list<aggregateresult> resultlist= [select min(usageEndDate),accountid from asset where accountid in :accidset group by accountid];
        system.debug(resultlist);
        for(aggregateresult re:resultlist){
            if(accmap.containskey((string)re.get('accountid'))){
                accmap.get((string)re.get('accountid')).Asset_Minimum_Expiration_Date__c=(date)re.get('expr0');
            }
        }
        update accmap.values();
    }
}