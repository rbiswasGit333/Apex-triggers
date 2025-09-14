trigger AccountTrigger on Account (before insert, before update , after insert, after update) {
   AccountDispatcher.Dispatch(trigger.operationtype);
}