public with sharing class integration_Indian_Postal_Code {
 
    @AuraEnabled(cacheable=true)
    public static list<responseWraper> getPostalDetails(String postalCode){
        list<responseWraper> postalList = new list<responseWraper>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        String endPoint = 'https://api.postalpincode.in/pincode/'+ postalCode;

        request.setEndpoint(endPoint);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        system.debug(response.getStatusCode());
        if(response.getStatusCode() ==200 ){ 
            system.JSONParser jp= JSON.createParser(response.getBody());
            while(jp.nextToken()!=null){
                if(jp.getText()=='PostOffice'){
                    jp.nextToken();                   
                    while(jp.nextToken()==jsontoken.START_OBJECT){
                        responseWraper res = (responseWraper)jp.readvalueas(responseWraper.class);
                        postalList.add(res);
                        system.debug(res);
                    }
                }
            }
        }
        system.debug(postalList);
        return postalList;
    }

    public class responseWraper{
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public string Description;
        @AuraEnabled
        public string BranchType;
        @AuraEnabled
        public string DeliveryStatus;
        @AuraEnabled
        public string Circle;
        @AuraEnabled
        public string District;
        @AuraEnabled
        public string Division;
        @AuraEnabled
        public string Region;
        @AuraEnabled
        public string State;
        @AuraEnabled
        public string Country;
    }
}