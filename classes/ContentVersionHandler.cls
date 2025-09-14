public class ContentVersionHandler {
    public static void GetPublicLink(list<ContentVersion> newrecords){
        map<id,id> docidmap =new map<id,id>();
        for(ContentVersion conver:newrecords){
            docidmap.put(conver.ContentDocumentId,conver.Id);
        }
        map<id,id> docAndentityidmap=new map<id,id>();
        list<ContentDistribution> condislistToinsert = new list<ContentDistribution>();
        list<ContentDocumentLink>  doclinklist= [select id,linkedentityid,                           
                                                   ContentDocumentId from ContentDocumentLink where contentdocumentid in:  docidmap.keyset() ];
                for(ContentDocumentLink link:doclinklist){
                    if(link.linkedentityid.getsobjecttype().getdescribe().getname()=='Account'){
                        ContentDistribution condis = new ContentDistribution();
                        condis.ContentVersionId=docidmap.get(link.ContentDocumentId);
                        condis.PreferencesAllowOriginalDownload = true;
                        condis.PreferencesAllowPDFDownload = true;
                        condis.PreferencesAllowViewInBrowser = true;
                        condis.Name = 'Distribution  ';
                        condis.PreferencesNotifyOnVisit=false;
                        condislistToinsert.add(condis);
                        docAndentityidmap.put(link.ContentDocumentId,link.LinkedEntityId);
                    }
               }
        insert condislistToinsert;
        list<ContentDistribution> condislist=[select id,ContentDownloadUrl,name, PdfDownloadUrl,ContentDocumentId from 
                                               ContentDistribution where ContentDocumentId in:docAndentityidmap.keyset()];
        if(condislist.isempty()) return;
        list<Public_File_Link__c> linlsToInsert = new list<Public_File_Link__c>();
        map<id,account> accmap = new map<id,account>([select id,name from account where id in:docAndentityidmap.values()]);
        for(ContentDistribution dis:condislist){
            account acc = accmap.get(docAndentityidmap.get(dis.ContentDocumentId));
                linlsToInsert.add(new Public_File_Link__c(name='link'+dis.Name,
                                                          Link_To_File__c=dis.ContentDownloadUrl,Parent_Object_Id__c=acc.Id,
                                                         Parent_Object_Name__c=acc.Name));
            
        }
        insert linlsToInsert;
    }

    //////////////////insert file to account which is inserted inyto case,event or task////////////
    
    public static void Filetoacc(list<contentversion> newlist){
        set<id> docidset = new set<id>();
        for(contentversion ver: newlist){
            docidset.add(ver.contentdocumentid);
        }
        list<contentdocumentlink>  linklist = [select id , linkedentityid  from contentdocumentlink where contentdocumentid in:docidset];
        if(linklist.isempty()) return;
        set<id> caseidset = new set<id>();
        set<id> eventidset = new set<id>();
        set<id> taskidset = new set<id>();
        for(contentdocumentlink link:linklist){
            string obj = link.linkedentityId.getsObjectType().getDescribe().getName();
            if(obj=='case'){
                caseidset.add(link.LinkedEntityId);
            }if(obj=='event'){
                eventidset.add(link.LinkedEntityId);                
            }if(obj=='task'){
                taskidset.add(link.LinkedEntityId);
            }
        }
        list<contentdocumentlink> linktoinsert = new list<contentdocumentlink>();
        map<id,case> casemap = new map<id,case>([select id,accountid from case where id in:caseidset and accountid!=null]);
        map<id,event> eventmap = new map<id,event>([select id,whatId  from event where id in:eventidset and what.type='account']);
        map<id,task> taskmap = new map<id,task>([select id,WhatId from task where id in:taskidset and what.type='account']);
        for(contentdocumentlink link2:linklist){
            if(!casemap.isEmpty() && casemap.containskey(link2.LinkedEntityId)){
                contentdocumentlink link3 = link2.clone(false,false,false,false);
                link3.LinkedEntityId=casemap.get(link2.LinkedEntityId).AccountId;
                linktoinsert.add(link3);
            }if(!eventmap.isEmpty() && eventmap.containskey(link2.LinkedEntityId)){
                contentdocumentlink link4 = link2.clone(false,false,false,false);
                link4.LinkedEntityId=eventmap.get(link2.LinkedEntityId).WhatId;
                linktoinsert.add(link4);
            }if(!taskmap.isEmpty() && taskmap.containskey(link2.LinkedEntityId)){
                contentdocumentlink link5 = link2.clone(false,false,false,false);
                link5.LinkedEntityId=taskmap.get(link2.LinkedEntityId).WhatId;
                linktoinsert.add(link5);
            }
        }
        insert linktoinsert;
    }
}