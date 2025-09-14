public with sharing class integration_currency_converter {
    
@AuraEnabled(cacheable=true)
    public static string getConvert(string from1,string to){
        string apikey= '9e549dfec0a15d43139a55e9';
        string url='https://v6.exchangerate-api.com/v6/'+apikey+'/pair/'+from1+'/'+to;
        http h = new http();
        httprequest req = new httpRequest();
        req.setmethod('GET');
        req.setEndPoint(url);
        httpResponse res = h.send(req);
        system.debug(res.getbody());
        return res.getbody();
    }
}