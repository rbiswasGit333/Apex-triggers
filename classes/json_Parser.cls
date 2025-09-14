public class json_Parser {
    public static void ParserDemo(){
        map<string,object> result = new map<string,object>();
         string js = '{"Name": "Edge Communications","Id": "0015j000016AoJUAA0","Type": "Customer - Direct","Rating": "Hot","Industry": "Electronics", "Id": "0035j0000175qmPAAQ","LastName": "Gonzalez","FirstName": "Rose","Email": "rose@edge.com"}';
        system.JSONParser jp = JSON.CreateParser(js);
        while(jp.nextToken() !=null){
            result.put(jp.getText(),jp.getCurrentToken());
        }
        system.debug(result);
    }

}