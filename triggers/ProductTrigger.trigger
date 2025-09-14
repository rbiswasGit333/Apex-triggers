trigger ProductTrigger on Product2 (after insert,after delete) {
    if(trigger.isafter && (trigger.isinsert||trigger.isdelete)){
        aggregateresult result = [select count(id) from product2];
        list<product2> prolist = [select id , Total_Quantity__c from product2];
        for(product2 pro:prolist){
            pro.Total_Quantity__c=(decimal)result.get('expr0');
        }
        update prolist;
    }
}