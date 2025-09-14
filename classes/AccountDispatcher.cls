public class AccountDispatcher {
    public static void Dispatch(system.triggerOperation operationtype){
        switch on operationtype{
            when before_insert{
                AccountHandler.HandleBeforeInsertUpdate(trigger.new);
                AccountHandler.HandleBeforeInsert(trigger.new);
                AccountHandler.UpdateSalesRep(trigger.new);
            }when before_update{
                AccountHandler.UpdateSalesRep(trigger.new);               
                AccountHandler.HandleBeforeInsertUpdate(trigger.new);
            }when after_insert{
                AccountHelper.CreatTask(trigger.new);
                AccountHandler.handleafterinsert(trigger.new);
            }when after_update{
                AccountHandler.HandleAfterUpdate1(trigger.new, (map<id,account>)trigger.oldmap);
                AccountHandler.changeaccountowner((map<id,account>)trigger.newmap , (map<id,account>)trigger.oldmap);
            }  
        }
    }
}