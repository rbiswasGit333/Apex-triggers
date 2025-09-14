public class AccountRequestDispatcher {
    public static void Dispatch(system.triggeroperation operation){
        switch on operation{
            when before_update{
                
            }when before_insert{
                
            }when after_update{
                
            }when after_insert{
               AccountRequestHandler.InsertAccShare(trigger.new);
            }when before_delete{
                
            }when after_delete{
                AccountRequestHandler.DeleteAccShare((map<id,Account_Request__c>)trigger.oldmap);
            }when after_undelete{
                
            }
        }
    }

}