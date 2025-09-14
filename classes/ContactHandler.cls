public class ContactHandler {
    public static void HandleBeforeInsert(list<contact> NewRecords){
        ContactHelper.UpdateAddress(NewRecords);
        ContactHelper.throwError(NewRecords);
    }
    public static void HandleBeforeUpdate(list<contact> NewRecords1){
        for (contact con:NewRecords1){
            con.Fax=con.Phone;
        }
    }
    public static void HandleAfterInsert(list<contact> contactlist){
        set<id> accIdSet = new set<id>();
        for (contact con:contactlist){
            if(con.AccountId !=null){
                accIdSet.add(con.AccountId);
            }
        }
        list<opportunity> opplist1=new list<opportunity>();
        list<opportunity> opplist = [select id,AccountId,Account.Industry,
                                     Account.Rating,Account.Phone,Account_industry__c,
                                     Account_rating__c,Account_phone__c from Opportunity where AccountId in:accIdSet with user_mode];
        for(opportunity opp :opplist){
            opportunity opp1 = new opportunity();
            opp1.Id=opp.Id;
            opp1.Account_Phone__c=opp.Account.Phone;
            opp1.Account_Rating__c=opp.Account.Rating;
            opp1.Account_Industry__c=opp.Account.Industry;
            opplist1.add(opp1);
        }
        try{
            Update as user opplist1;
        }catch(system.dmlexception ex){
            system.debug(ex.getmessage());
            system.debug(ex.getstacktracestring());
            system.debug(ex.getcause());
        }
        
    }
    public static void HandleAfterUpdate(map<id,contact> newcontactlist,map<id,contact> oldcontactlist ){
        ContactHelper.UpdateContactToAccount(newcontactlist,oldcontactlist);
    }
    public static void HandleAfterInsertDeleteUndelete(list<contact> newconlist){
        ContactHelper.UpdateContactToAccount2(newconlist);
    }
    ////////////////send email//////////////
    public static void sendemail(list<contact> newcon){
        list<messaging.singleemailmessage> emaillist = new list<messaging.singleemailmessage>();
        for(contact con:newcon){
            if(con.Email !=null){
                messaging.singleemailmessage email = new messaging.singleemailmessage();
                email.setsubject('A new contact'+ con.Name +'has been assigned!');
                string body = 'Dear'+con.OwnerId+'<br/>';
                    body+='A new contact' +con.name+ 'has been assigned to you. Here are the details about the contact <br/>';
                    body+='Name :-'+con.Name+ '<br/>';
                    body+= 'Email:'+Con.Email+'<br/>';
                    body+='Phone: '+Con.Phone+'<br/>';
                    body+='Account: '+Con.account.name+'<br/>';
                    body+='link to access Contact:'+'https://empathetic-koala-ln3pze-dev-ed.';
                    body+= 'trailblaze.lightning.force.com/lightning/r/Contact/'+Con.Id+'/ view'+ '<br/>';
                    body+= 'Thanks & Regards,<br/>';
                    body+= '<br/>'+con.account.owner.name +'<br/>';
                email.settoaddresses(new string[]{con.OwnerId});
                email.sethtmlbody(body);
                emaillist.add(email);
            }
        }
        if (emaillist.isempty()) return;
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emaillist);
        if (results[0].success){
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '+ results[0].errors[0].message);
        }
    } 
    
    /////////////// prevent duplicacy///////////
    public static void preventDuplicacy(list<contact> newcon1){
        list<string> conphonelist = new list<string>();
        list<string> conemaillist= new list<string>();
        set<string> conset =new set<string>();
        for(contact con2:newcon1){
            if(string.isnotblank(con2.phone) || string.isnotblank(con2.email)){
                conphonelist.add(con2.Phone);
                conemaillist.add(con2.Email);
            }
        }
        list<contact> conlist = [select id,phone,email from contact where phone in:conphonelist and email in:conemaillist];
        if(conlist.isempty()) return;
        for(contact con1: conlist){
            conset.add(con1.phone+'###'+con1.Email);            
        }
        for(contact con:newcon1){
            if(string.isnotblank(con.phone) || string.isnotblank(con.email)){
                if(conset.contains(con.phone+'###'+con.Email)){
                    con.adderror('same Phone And Email exist in database');
                }else{
                    conset.add(con.phone+'###'+con.Email);
                }
            }
        }              
     }
    
    //////////////////// upadte account's primary contact field///////////
    public static void primarycon(list<contact> conlist1){
        set<id> accidset = new set<id>();
        for(contact con:conlist1){
            if(con.AccountId!=null)
            accidset.add(con.AccountId);            
        }
        if(accidset.isempty()) return;
        map<id,account> accmap = new map<id,account>([select id ,primary_contact__c from account where id in:accidset]);
        for(contact con:conlist1){
            accmap.get(con.AccountId).Primary_contact__c=con.id;
        }
        update accmap.values();
    }
    ///////////////////  if there is no account associate matched account to contact if there is no match creat one//////////
    public static void creatAccount(list<contact> newlist){
        list<string> accnamelist = new list<string>();
        for(contact con:newlist){
            if(con.AccountId==null){
                accnamelist.add(string.valueof(con.FirstName)+string.valueof(con.LastName));
            }            
        }
        system.debug(accnamelist);
        list<account> acclist = [select id, name from account where name in:accnamelist];
        system.debug(acclist);
        map<string,account> accmap = new map<string,account>();
        if(!acclist.isempty()){
            for(account acc:acclist){
                accmap.put(acc.name.trim().tolowercase(),acc);
            }
        }
        map<string,account> accmapforinsert = new map<string,account>();
        list<contact> listforupdate = new list<contact>();
        for(contact con:newlist){
            if( con.AccountId==null && accmap.containskey(string.valueof(con.FirstName)+string.valueof(con.LastName))){
                contact con1 = new contact();
                con1.id=con.id;
                con1.AccountId= accmap.get(string.valueof(con.FirstName)+string.valueof(con.LastName)).id;
                listforupdate.add(con1);
            }
            if(con.AccountId==null && accmap.isempty()){
                account acc = new account();
                acc.name=con.FirstName+con.LastName;
                acc.Rating='Hot';
                acc.Phone=con.Phone;
                acc.Description=con.Description;
                acc.ShippingCity=con.MailingCity;
                acc.ShippingCountry=con.MailingCountry;
                acc.ShippingGeocodeAccuracy=con.MailingGeocodeAccuracy;
                acc.ShippingPostalCode=con.MailingPostalCode;
                acc.ShippingState=con.MailingState;
                acc.ShippingStreet=con.MailingStreet;
                acc.BillingCity=con.OtherCity;
                acc.BillingCountry=con.OtherCountry;
                acc.BillingGeocodeAccuracy=con.OtherGeocodeAccuracy;
                acc.BillingPostalCode=con.OtherPostalCode;
                acc.BillingState=con.OtherState;
                acc.BillingStreet=con.OtherStreet;
                acc.Industry='Education';
                acc.Fax=con.Fax;
                accmapforinsert.put(acc.name,acc);
            }
        }
        insert accmapforinsert.values();

        for(contact con:newlist){
            string key=con.FirstName+con.LastName;
            if(con.AccountId==null && accmapforinsert.containskey(key)){
                contact con1 = new contact();
                con1.id=con.id;
                con1.AccountId=accmapforinsert.get(key).id;
                listforupdate.add(con1);
            }
        }
        update listforupdate;
    }
}