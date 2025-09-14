global class soap_Integration_Server {
    webservice static string creatLeadFromClient(string name ,string company, string status){
        try{
             lead l = new lead();
        l.Status=status;
        l.Company=company;
        l.LastName=name;
        insert l;
            return l.Id;
        }catch(exception ex){
            return 'error during creating Lead Record from Client';
        }
       
    }

}