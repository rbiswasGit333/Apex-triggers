public class TaskDispatcher {
    public static void Dispatch(system.triggerOperation operation){
        switch on operation{
            when before_insert{
                
            }when before_update{
                
            }when after_insert{
                
            }when after_update{
                
            }when before_delete{
                TaskHandler.CheckProfile(trigger.old);
            }when after_delete{
                
            }when after_undelete{
                
            }
        }
    }
}