trigger AccountRequestTrigger on Account_Request__c (before insert,before update,after insert,
                                                     after update, before delete, after delete, after undelete) {
AccountRequestDispatcher.Dispatch(Trigger.operationtype);
}