trigger ContentVersionTrigger on ContentVersion (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    ContentVersionDispatcher.Dispatch(trigger.operationtype);

}