public with sharing virtual class RestLib {
    /**
     * @description The name of the Named Credential to use
     */
    @TestVisible
    protected final String namedCredentialName { get; set; }

    /**
     * @description Constructor that sets Named Credential
     * @param  namedCredential name of the Named Credential to use
     */
    public RestLib(String namedCredential) {
        this.namedCredentialName = namedCredential;
    }

    /**
     * @description This constructor isn't intended for use, which is why it's
     * access modifier is 'Protected'. However, any child class extending
     * this class will either have to implement constructors matching the one
     * above, or this constructor must exist. In order to make this abstraction
     * as useful as possible, we've elected to leave this constructor here,
     * but unavailable to anything but inner classes and classes that
     * extend this one.
     */
    @TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected RestLib() {
    }

    /**
     * @description Omnibus callout method. This is the primary method for
     * making a REST callout. Most of the other methods in this class serve
     * as convenient, syntactic sugar on this method.
     *
     * @param apiCall Enum HTTP verb to use. i.e. GET
     *
     * @return HttpResponse  HttpResponse Obj
     */
    @TestVisible
    @SuppressWarnings('PMD.ExcessiveParameterList')
    protected HttpResponse makeApiCall(RestLibApiCall apiCall) {
        HttpRequest apiRequest = new HttpRequest();
        if (apiCall.method == HttpVerb.DEL) {
            apiRequest.setMethod('DELETE');
        } else {
            apiRequest.setMethod(String.valueOf(apiCall.method));
        }
        for (String header : apiCall.functionalHeaders.keySet()) {
            apiRequest.setHeader(header, apiCall.functionalHeaders.get(header) ?? '');
        }
        if (apiCall.hasBody) {
            apiRequest.setBody(apiCall.body);
        }

        String path = apiCall.path;
        // Check that path starts with a '/'
        if (!path.startsWith('/')) {
            path = '/' + path;
        }

        String encodedQuery = apiCall.encodedQuery;
        // If encodedQuery is not null ensure that path does not end with a '/'
        if (encodedQuery != null && path.endsWith('/')) {
            path = path.substring(0, path.length() - 1);
        }

        // Check that the encoded query starts with a '?'
        if (encodedQuery != null && !encodedQuery.startsWith('?')) {
            encodedQuery = '?' + encodedQuery;
        }

        apiRequest.setEndpoint('callout:' + this.namedCredentialName + path + encodedQuery);
        if (apiCall.timeout != null) {
            apiRequest.setTimeout(apiCall.timeout);
        } else {
            apiRequest.setTimeout(120000);
        }

        // Assuming you have a predefined list of header keys you've set in your HttpRequest
        String[] headerKeys = new List<String>{ 'Content-Type', 'Authorization', 'Accept' };

        // Get all the headers and store them in a StringBuilder
        String headers = '';
        for (String headerKey : headerKeys) {
            String headerValue = apiRequest.getHeader(headerKey);
            if (headerValue != null) {
                if (headerValue != null) {
                    headers += headerKey + ': ' + headerValue + '\n';
                }
            }
        }

        Http http = new Http();
        return http.send(apiRequest);
    }
}
