public class OpportunityDispatcher {
    public static void Dispatch(system.TriggerOperation OperationType){
        switch on OperationType{
            when before_insert{
                
                OpportunityHandler.HandleBeforeInsert(trigger.new);
            }when before_update{
                
                OpportunityHandler.HandleBeforeUpdate((map<id,opportunity>)trigger.newmap , (map<id,opportunity>)trigger.oldmap);                
            }when after_insert{                
                OpportunityHandler.HandleAfterInsert(trigger.new);
                OpportunityHandler.HandleAfterInsertDeleteUndelete(trigger.new);
               // OpportunityHandler.creatproduct(trigger.new);
            }when after_update{
                
                OpportunityHandler.HandleAfterUpdate((map<id,opportunity>)trigger.newmap , (map<id,opportunity>)trigger.oldmap);                
                OpportunityHandler.upacc((map<id,opportunity>)trigger.newmap , (map<id,opportunity>)trigger.oldmap);
            }when after_delete{
                OpportunityHandler.HandleAfterInsertDeleteUndelete(trigger.old);
                OpportunityHandler.InsertDelOpp(trigger.old);
            }when after_undelete{
                OpportunityHandler.HandleAfterInsertDeleteUndelete(trigger.new);
                OpportunityHandler.DeleteDelOpp(trigger.new);
            }when before_delete{
                OpportunityHandler.throwerror(trigger.old);
            }
        }
    }

}