public without sharing class noteTakingApex {
    @AuraEnabled
    public static boolean createNote( string title, string description){
        try{
            if(title != null && description != null){
         Note_Taking_App__c note= new Note_Taking_App__c(Name = title,Description__c = description);
        insert note;
        return true;
            } 
            else{
                return false;
            }
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

    }
    @AuraEnabled(cacheable=true)
    public static list<Note_Taking_App__c> getNotes(){
        try {
            return [SELECT Id,Name,Description__c,LastModifiedDate FROM Note_Taking_App__c order by LastModifiedDate DESC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static boolean editNote(string noteId,string title, string description){
        try {
            Note_Taking_App__c note=[SELECT Id,Name,Description__c FROM Note_Taking_App__c WHERE Id =:noteId];
            note.Name = title;
            note.Description__c = description;
            update note;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static boolean deleteNote(string noteId){
        try {
            Note_Taking_App__c note=new Note_Taking_App__c(Id=noteId);
            delete note;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}