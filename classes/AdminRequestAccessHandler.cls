public class AdminRequestAccessHandler {
    
    ///////////////////// update manager field uhen user insert ihe Admin_Request_Access__c records(when insert) ///////////////////
    
    public static void UpdateManager(list<Admin_Request_Access__c> newrecords){
        set<id> useridset = new set<id>();
        for(Admin_Request_Access__c adre: newrecords){
            if(adre.User__c !=null){
                useridset.add(adre.User__c);
            }
        }
        list<user> userlist = [select id,ManagerId from user where id in:useridset];
        map<id,id> usermap = new map<id,id>();
        for(user u: userlist){
            if(u.ManagerId !=null){
                usermap.put(u.Id,u.ManagerId);
            }
        }
        for(Admin_Request_Access__c adre1: newrecords){
            if(usermap.containskey(adre1.User__c)){
                adre1.Manager__c=usermap.get(adre1.User__c);
            }
            if(adre1.Manager__c ==null && (adre1.Approver_1__c==null && adre1.Approver_2__c==null)){
                adre1.addError('User Can not save the record without providing value for either Approver 1 or Approver 2');
                adre1.Approver_1__c.adderror('User Can not save the record without providing value for either Approver 1 or Approver 2');
                adre1.Approver_2__c.adderror('User Can not save the record without providing value for either Approver 1 or Approver 2');
            }
        }
    }
    
    //////////////////// assign permission set to the user if statud field is Approved (when update)//////////////////
      
    public static void AssignPermissionSet(map<id,Admin_Request_Access__c> newmap, map<id,Admin_Request_Access__c> oldmap){
        list<permissionSet> permiSetList=[select id,name from permissionSet where name='System_Admin_Permissions'];
        if(permiSetList.isempty()) return;
        list<PermissionSetAssignment> assignListToInsert = new list<PermissionSetAssignment>();
        for(Admin_Request_Access__c adre2:newmap.values()){
            if(adre2.Status__c=='Approved' && adre2.Status__c != oldmap.get(adre2.id).Status__c){
                PermissionSetAssignment ASSIGN = new PermissionSetAssignment();
                ASSIGN.AssigneeId=adre2.User__c;
                ASSIGN.PermissionSetId=permiSetList.get(0).id;
                assignListToInsert.add(ASSIGN);
            }
        }
        insert assignListToInsert;       
    }

}