public class AccountHelper {
    public static void UpdateBillingAddress(list<account> newrecords){
        for(account acc : newrecords){
            if(acc.ShippingCity==null){
                acc.ShippingCity=acc.BillingCity;
            }if(acc.ShippingCountry==null){
                acc.ShippingCountry=acc.BillingCountry;
            }if(acc.ShippingPostalCode==null){
                acc.ShippingPostalCode=acc.BillingPostalCode;
            }if(acc.ShippingState==null){
                acc.ShippingState=acc.BillingState;
            }if(acc.ShippingStreet==null){
                acc.ShippingStreet=acc.BillingStreet;
            }
        }
    }
    public static void CreatTask(list<account> newrecords1){
        list<task> TaskToInsert =new list<task>();
        for(account acc1 :newrecords1){
            task t = new task();
            t.Subject = 'Created from Apex Trigger';
            t.description = 'Created from Apex Trigger';
            t.ActivityDate = date.today().addDays(7);
            t.Status = 'Not Started';
            t.Priority = 'High';
            t.WhatId = acc1.Id;
            t.OwnerId= acc1.OwnerId;
            TaskToInsert.add(t);
        }
        insert as user TaskToInsert;
    }
    
    /////////////////////////prevent duplicate records with same name and rating ///////////////////////////////
    
    public static void preventDuplicacy(list<account> newrecords2){
        set<string> namelist=new set<string>();
        set<string> ratinglist=new set<string>();
        set<string> extcompositlist=new set<string>();
        for(account acc2:newrecords2){
            if(string.isnotblank(acc2.rating) && string.isnotblank(acc2.name)){
                namelist.add(acc2.name);
                ratinglist.add(acc2.rating);
            }
        }
        list<account> comparedlist = [select id,name,rating from account where name in: namelist and rating in: ratinglist limit 50000];
        if(comparedlist.isempty()) return;
        for(account a:comparedlist){
            string k = a.name.trim().toLowerCase() +'###'+ a.Rating.trim().toLowerCase();
            extcompositlist.add(k);
        }
        for(account acc3:newrecords2){
            if(string.isnotblank(acc3.rating) && string.isnotblank(acc3.name)){
                string key2 = acc3.name.trim().toLowerCase() +'###'+ acc3.Rating.trim().toLowerCase();
                if(extcompositlist.contains(key2)){
                    acc3.addError(' contains another record with the same Name and Rating');
                        }else{extcompositlist.add(key2); ////(this prevents further coming (containing itself) duplicate records )
                             }
            }
        }
    }

   /////////////////sendind email to account owner////////////////////// 
    
    public static void sendemail(list<account> newrecords3){
        list<messaging.singleEmailMessage>  messagelist = new list<messaging.singleEmailMessage>();
        for(account acc4:newrecords3){
            if(acc4.phone==null){
                messaging.singleEmailMessage message = new messaging.singleEmailMessage();
                message.Subject ='New account assign to you, Account Name:'+ acc4.name;
                message.settoaddresses(new list<string>{acc4.OwnerId,'rajabiswas633@gmail.com'}); // OR message.toaddresses = new list<string>{acc4.OwnerId};
                string body='dear <b>'+acc4.owner.name + '</b><br><br> A new account<b>'+ acc4.Name +'</b>has been created in Salesforce';
                body+= 'The account is missing some important information about Phone & Industry. <br><br>';
                body+='Please try to collect this information and update the account ASAP.<br><br><b>Thanks & Regards,<br>R Biswas Private Limited</b>';
               system.debug(new list<string>{acc4.OwnerId,'rajabiswas633@gmail.com'});
                message.sethtmlBody(body);
                messagelist.add(message);
            }
        }
        list<messaging.sendEmailError> errorlist2 = new list<messaging.sendEmailError>();
        list<messaging.sendEmailResult> resultlist = messaging.sendEmail(messagelist ,false);
        for(messaging.sendEmailResult result:resultlist){
            if(result.isSuccess()){
                system.debug('message sent successfully');
            }else{
                list<messaging.sendEmailError> errorlist= result.getErrors();
                errorlist2.addAll(errorlist);
            }
        }
        for(messaging.sendEmailError error:errorlist2){
            system.debug(error.getMessage());
            system.debug(error.getFields());
            system.debug(error.getStatusCode());
            system.debug(error.getTargetObjectId());
        }
    }
}