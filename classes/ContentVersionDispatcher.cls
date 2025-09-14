public class ContentVersionDispatcher {
    public static void Dispatch(system.triggeroperation operation){
        switch on operation{
            when Before_Insert{
                
            }when Before_Update{
               
            }when After_Insert{
                ContentVersionHandler.GetPublicLink(trigger.new); 
                ContentVersionHandler.Filetoacc(trigger.new);
            }when After_Update{

            }when after_delete{
                
            }when after_undelete{

            }when before_delete{
                
            }
        }
    }

}