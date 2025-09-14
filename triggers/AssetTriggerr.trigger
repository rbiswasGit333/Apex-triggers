trigger AssetTriggerr on Asset (before insert,after insert,after delete,before delete ,after update) {
    AssetDispatcher.Dispatch(trigger.operationtype);

}