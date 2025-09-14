public class OpportunityLineItemHandler {

    public static void creatAsset(list<opportunitylineitem> itemlist){
        set<id> oppIdset = new set<id>();
        set<id> proIdset= new set<id>();
        for(opportunitylineitem item:itemlist){
            oppIdset.add(item.OpportunityId);
            proIdset.add(item.Product2Id);
        }
        map<id,product2> promap = new map<id,product2>([select id,name,productCode,family from product2 where id in:proIdset]);
        map<id,opportunity> oppmap = new map<id,opportunity>([SELECT Id, AccountId, Name,Product_Type__c,
                                                              CloseDate, CreatedDate FROM Opportunity where id in:oppIdset]);
        if(promap.isempty()) return;
        if(oppmap.isempty()) return;   
        list<asset> assetlist= new list<asset>();
        for(opportunitylineitem item1:itemlist){
            if(promap.containskey(item1.Product2Id) && oppmap.containskey(item1.OpportunityId) 
               && promap.get(item1.Product2Id).family != oppmap.get(item1.OpportunityId).Product_Type__c){
                item1.adderror(' "Product Type" on Opportunity and "Product family" on Product can not be different');
            }
            if(oppmap.get(item1.OpportunityId).AccountId!=null){
            asset ast = new asset();
            ast.AccountId=oppmap.get(item1.OpportunityId).AccountId;
            ast.Name=promap.get(item1.Product2Id).name;
            ast.Product2Id=item1.Product2Id;
            ast.Quantity=item1.Quantity;
            ast.Price=item1.TotalPrice;
            ast.State='Registerd';
            ast.PurchaseDate=oppmap.get(item1.OpportunityId).CreatedDate.date();
            ast.UsageEndDate=oppmap.get(item1.OpportunityId).CloseDate;
            ast.InstallDate=item1.CreatedDate.date();
            ast.SerialNumber=promap.get(item1.Product2Id).productCode;
            assetlist.add(ast);
            }           
        }
        if(!assetlist.isempty()){
            insert assetlist;
        }
        
    }
    
    ///////// update opplineItem's Serial No///////
    public static void UpSerialNo(list<opportunitylineitem> itemlist1){
        SerialNumberSetting__c s = [SELECT Id ,LastSerialNo__c FROM SerialNumberSetting__c];
        if(s==null){
            s=new SerialNumberSetting__c(LastSerialNo__c=0);
            insert s;            
        }
        Decimal currentSerial=s.LastSerialNo__c;
        list<opportunitylineitem> oplitmlist = new list<opportunitylineitem>();
        for(integer i=0; i<itemlist1.size();i++){
            currentSerial++;
            opportunitylineitem oli= new opportunitylineitem(id=itemlist1[i].id,Serial_No__c=currentSerial);
            oplitmlist.add(oli);
        }
        s.LastSerialNo__c=currentSerial;
        update s;
        update oplitmlist;
        
    }
    
    ////////////////// update product quantity /////////////////
    public static void proQuantity(list<OpportunityLineItem> ItemList){
        set<id> proidset1= new set<id>();
        for(OpportunityLineItem item:ItemList){
            if(item.Product2Id!=null){
                proidset1.add(item.Product2Id);                
            }
        }
        map<id,product2> promap1=new map<id,product2>([SELECT Id, name,Total_Quantity__c,Available_Quantity__c FROM Product2 where id in:proidset1]);
        for(OpportunityLineItem item1:ItemList){
            if(promap1.containskey(item1.Product2Id) && item1.Quantity <= promap1.get(item1.Product2Id).Available_Quantity__c){               
                decimal xx =promap1.get(item1.Product2Id).Available_Quantity__c-item1.Quantity;
                promap1.get(item1.Product2Id).Available_Quantity__c=xx;
            }else{
                item1.adderror('only  '+promap1.get(item1.Product2Id).Available_Quantity__c+'  '+
                promap1.get(item1.Product2Id).name+'   Products available out of  '+promap1.get(item1.Product2Id).Total_Quantity__c);
            }
        }
        update promap1.values();
    }
}