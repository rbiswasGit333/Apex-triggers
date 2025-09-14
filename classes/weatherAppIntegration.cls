public class weatherAppIntegration {
    @AuraEnabled(cacheable=true)
    public static string getWeatherDetails(string cityName1){

        string id ; 
        http h = new http();
        httprequest req = new httprequest();
        string key = '008cdf26aad9b458992a9e21ac072d37';
        string endpoint= 'https://api.openweathermap.org/data/2.5/weather?q='+cityName1+'&units=metric&appid='+key;
        req.setmethod('GET');
        req.setendpoint(endpoint);
        httpresponse res = h.send(req);
        system.debug(res.getbody());
        return res.getbody();

    }

}