public class JSON_Jenerator {
    /*
    public string result{set;get;}
        
    public JSON_Jenerator(){
        
        system.JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        list<account> acclist = [SELECT Id, Name, Phone, Industry, Type, Rating FROM Account where type!=null AND rating !=null limit 5];
        for(account acc:acclist){
                gen.writeIdField('id',acc.id);
                gen.writeStringField('Name',acc.name);
                gen.writeStringField('Phone',acc.phone);
                gen.writeStringField('Industry',acc.industry);
                gen.writeStringField('Type',acc.type);
                gen.writeStringField('Rating',acc.rating);
                gen.writeStringField('message:',' Account data change into JSON Successfully');
                gen.writeNumberField('Code',201);            
        }
        gen.writeEndObject();
        result = gen.getAsString();
        system.debug(result);
    }
*/  
    public string se{set;get;}
    public JSON_Jenerator(){
    account acc=[SELECT Id, Name, Type, Rating, Industry, (SELECT Id, LastName, FirstName, Email FROM Contacts where email!=null and firstname!=null limit 3) from Account where type != null and rating != null limit 1];
     se = JSON.serialize(acc,true);
}
    
}