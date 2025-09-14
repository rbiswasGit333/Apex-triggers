public class AdminRequestAccessDispatcher {
    public static void Dispatch(system.triggeroperation operation){
        switch on operation{
            when before_update{
                
            }when before_insert{
                AdminRequestAccessHandler.UpdateManager(trigger.new);
            }when after_update{
                AdminRequestAccessHandler.AssignPermissionSet((map<id,Admin_Request_Access__c>)trigger.newmap,
                                                              (map<id,Admin_Request_Access__c>)trigger.oldmap);
            }when after_insert{
               
            }when before_delete{
                
            }when after_delete{
                
            }when after_undelete{
                
            }
        }
    }

}