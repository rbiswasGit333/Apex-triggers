public class OpportunityLineItemDispatcher {
    public static void Dispatch(system.triggeroperation operation){
        switch on operation{
            when After_insert{
                //OpportunityLineItemHandler.creatAsset(trigger.new);
                OpportunityLineItemHandler.UpSerialNo(trigger.new); 
                OpportunityLineItemHandler.proQuantity(trigger.new);
            }when before_insert{

            }
        }
    }
}