trigger StudentTrigger on Student__c (before insert, after insert) {
    if(trigger.isafter && trigger.isinsert){
        list<Student__Share> sharelist = new list<Student__Share>();
        list<Profile> pro = [select id,name from profile where name='Standard User' limit 2];
        list<user> userlist= [select id,profileId from user where ProfileId in:pro];
        if(userlist.isempty()) return;
        for(Student__c stu:trigger.new){
            for(user us:userlist){
                Student__Share share = new Student__Share();
                share.AccessLevel= 'Read';
                share.ParentId=stu.Id;
                share.RowCause='Manual';
                share.UserOrGroupId=us.Id; 
                sharelist.add(share);
            }
            insert sharelist;
        }
    }

}