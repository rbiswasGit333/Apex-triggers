trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert,after insert,after delete) {
    OpportunityLineItemDispatcher.Dispatch(trigger.operationtype);
}