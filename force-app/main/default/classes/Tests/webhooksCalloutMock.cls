@isTest
global class webhooksCalloutMock implements HttpCalloutMock {
    /* Respond with a 204 status */
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{	"event": "track",	"url": "https://your-domain-here.com/some/path"}');
        res.setStatusCode(204);
        return res;
    }
}
