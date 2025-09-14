trigger AdminRequestAccessTrigger on Admin_Request_Access__c (before insert,before update,after insert ,after update,before delete ,
                                                              after delete,after undelete) {
    AdminRequestAccessDispatcher.Dispatch(Trigger.operationtype);                                                            

}