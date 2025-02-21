@isTest
global class trackingCalloutMock_Failure implements HttpCalloutMock{
    /* This function returns a response object with the header and body filled with the request id. */
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"request_id":"9b7e727e-a623-4b3d-8dd1-32d3fcbfd59d","errors":[{"error_source":"shipengine","error_type":"system","error_code":"unspecified","message":"trackingNumber.String: A value is required but was not present in the request."}]}');
        res.setStatusCode(400);
        return res;
    }
}