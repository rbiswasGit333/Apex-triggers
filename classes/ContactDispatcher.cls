public class ContactDispatcher {
    public static void Dispatch(system.TriggerOperation Operation){
        switch on Operation{
            when Before_Insert{
                ContactHandler.HandleBeforeInsert(Trigger.New);
                ContactHandler.preventDuplicacy(trigger.new);
            }when Before_Update{
                ContactHandler.HandleBeforeUpdate(Trigger.New);
                ContactHandler.preventDuplicacy(trigger.new);
            }when After_Insert{
                ContactHandler.creatAccount(trigger.new);
                ContactHandler.HandleAfterInsert(Trigger.New);
                ContactHandler.HandleAfterInsertDeleteUndelete(Trigger.New);
                ContactHandler.sendemail(trigger.new);
                ContactHandler.primarycon(trigger.new);
            }when After_Update{
                ContactHandler.HandleAfterUpdate((map<id,contact>)trigger.newmap,(map<id,contact>)trigger.oldmap);
            }when after_delete{
                ContactHandler.HandleAfterInsertDeleteUndelete(trigger.old);
            }when after_undelete{
                ContactHandler.HandleAfterInsertDeleteUndelete(Trigger.New);
            }
        }
    }
}