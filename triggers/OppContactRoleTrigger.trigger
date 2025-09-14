trigger OppContactRoleTrigger on OpportunityContactRole (before insert,after insert) {
    if(trigger.isinsert && trigger.isAfter){
        set<id> oppidset = new set<id>();
        for(OpportunityContactRole ocr:trigger.new){
            if(ocr.OpportunityId!=null){
                oppidset.add(ocr.OpportunityId);
            }
        }
        map<id,opportunity> oppmap = new map<id,opportunity>([select id,amount from opportunity where id in:oppidset]);
        list<contact> listforupdate=new list<contact>();
        for(OpportunityContactRole ocr:trigger.new){
            if(ocr.OpportunityId!=null && ocr.ContactId!=null && oppmap.containskey(ocr.OpportunityId)){
                contact con = new contact(id=ocr.ContactId,Total_Opportunity_Amount__c=oppmap.get(ocr.OpportunityId).amount);
                listforupdate.add(con);
            }
        }
        update listforupdate;
    }
}