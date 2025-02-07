@isTest
global class trackingCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"tracking_number":"1Z6Y21Y60300230254","tracking_url":"http://wwwapps.ups.com/WebTracking/processRequest?HTMLVersion=5.0&Requester=NES&AgreeToTermsAndConditions=yes&loc=en_US&tracknum=1Z6Y21Y60300230254","status_code":"UN","status_detail_code":null,"status_detail_description":null,"carrier_code":"ups","carrier_id":3,"carrier_detail_code":null,"status_description":"Unknown","carrier_status_code":null,"carrier_status_description":"Invalid tracking number","ship_date":null,"estimated_delivery_date":null,"actual_delivery_date":null,"exception_description":null,"events":[]}');
        res.setStatusCode(200);
        return res;
    }
}