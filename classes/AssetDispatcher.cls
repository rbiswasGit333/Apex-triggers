public class AssetDispatcher {
    public static void Dispatch(system.triggeroperation operation){
        switch on operation{
            when after_update{
                AssetHandler.UpaccUpadate((map<id,asset>)trigger.newmap ,(map<id,asset>)trigger.oldmap);
            }when after_insert{
                AssetHandler.CreatOppOppLine(trigger.new);
                AssetHandler.upinsertOrdelete(trigger.new);
            }when after_delete{
                
            }when before_delete{
                AssetHandler.upinsertOrdelete(trigger.old);
            }
        }
    }

}