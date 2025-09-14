public class LeadDispatcher {
    public static void Dispatch(system.triggeroperation operation){
        switch on operation{
            when Before_Insert{
                LeadHandler.FillAccount(trigger.new); 
            }when Before_Update{
               
            }when After_Insert{
                                       
            }when After_Update{
                LeadHandler.convertLead((map<id,lead>)trigger.newmap, (map<id,lead>)trigger.oldmap);

            }when after_delete{
                
            }when after_undelete{

            }when before_delete{
                
            }
        }
    }
}