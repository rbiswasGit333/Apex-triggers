public class TaskHandler {
    public static void CheckProfile(list<task> tasklist){
        string proid= userinfo.getprofileId();
        profile pro = [select id,name from profile where id =:proid limit 1];
        for(task t :tasklist){
            if(pro.Name !='System Administrator'){
                t.adderror('Only System Administrator can delete the Task');
            }
        }        
    }
}