public with sharing virtual class RestClientLib extends RestClient {
    public RestClientLib(String namedCredentialName) {
        super(namedCredentialName);
    }

    /**
     * @description  Makes an HTTP Callout to an api resource.
     * Convenience method that assumes the Default Headers.
     * @param method HTTPVerb to use. See the enum above.
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @param body   Body to send with this call.
     * @return      `HttpResponse`
     */
    @TestVisible
    @SuppressWarnings('PMD.ExcessiveParameterList')
    protected HttpResponse makeApiCall(HttpVerb method, String path, String query, String body) {
        return this.makeApiCall(new RestLibApiCall(method, path, query, body));
    }

    /**
     * @description  convenience version of makeApiCall without body param.
     * Invokes omnibus version above, with blank body param and default headers.
     * @param method HTTPVerb to use. See the enum above.
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @return      `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse makeApiCall(HttpVerb method, String path, String query) {
        return this.makeApiCall(new RestLibApiCall(method, path, query, ''));
    }

    /**
     * @description convenience version of makeApiCall without body param.
     * Invokes omnibus version above, with blank body param and default headers.
     *
     * @param method HTTPVerb to use. See the enum above.
     * @param path Http path component of the URL. ie: `/path/to/resource`
     * @param query Query component of the URL ie: after `?foo=bar`
     * @param body Map<String,String> of headers to send with this call.
     * @param headers Map<String,String> of headers to send with this call.
     *
     * @return `HTTPResponse`
     */
    @TestVisible
    @SuppressWarnings('PMD.ExcessiveParameterList')
    protected HttpResponse makeApiCall(
        HttpVerb method,
        String path,
        String query,
        String body,
        Map<String, String> headers
    ) {
        return this.makeApiCall(new RestLibApiCall(method, path, query, body, headers));
    }

    /**
     * @description convenience version of makeApiCall without body param.
     * Invokes omnibus version above, with blank body param and default headers.
     *
     * @param method HTTPVerb to use. See the enum above.
     * @param path Http path component of the URL. ie: `/path/to/resource`
     * @param query Query component of the URL ie: after `?foo=bar`
     * @param body Map<String,String> of headers to send with this call.
     * @param headers Map<String,String> of headers to send with this call.
     * @param encodeQuery Boolean to determine if the query should be encoded
     *
     * @return `HTTPResponse`
     */
    //makeApiCall(HttpVerb, String, String, String, Map<String,String>)
    @TestVisible
    @SuppressWarnings('PMD.ExcessiveParameterList')
    protected HttpResponse makeApiCall(
        HttpVerb method,
        String path,
        String query,
        String body,
        Map<String, String> headers,
        Boolean encodeQuery
    ) {
        return this.makeApiCall(new RestLibApiCall(method, path, query, body, headers, encodeQuery));
    }

    /**
     * @description  convenience version of makeApiCall without body or query
     * params.
     * Invokes omnibus version above, with blank body and query params
     * @param method HTTPVerb to use. See the enum above.
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @return      `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse makeApiCall(HttpVerb method, String path) {
        return this.makeApiCall(new RestLibApiCall(method, path, '', ''));
    }

    /**
     * @description convenience version of makeApiCall without body or query
     * params.
     * Invokes omnibus version above, with blank body and query params
     *
     * @param method HTTPVerb to use. See the enum above.
     * @param path Http path component of the URL. ie: `/path/to/resource`
     * @param headers Map of headers to send with this call.
     *
     * @return `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse makeApiCall(HttpVerb method, String path, Map<String, String> headers) {
        return this.makeApiCall(new RestLibApiCall(method, path, '', '', new Map<String, String>{}));
    }

    /**
     * @description convenience method for a GET Call that only requires a path
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse get(String path) {
        return this.makeApiCall(HttpVerb.GET, path);
    }

    /**
     * @description convenience method for a GET Call that only requires a path
     * and query
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse get(String path, String query) {
        return this.makeApiCall(HttpVerb.GET, path, query);
    }

    /**
     * @description convenience method for a GET Call that only requires a path
     * body, and headers
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param body   JSON string to post
     * @param headers Map<String,String> of headers to send with this call.
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse get(String path, String body, Map<String, String> headers) {
        return this.makeApiCall(HttpVerb.GET, path, '', body, headers);
    }

    /**
     * @description convenience method for a GET Call that only requires a path
     * body, and headers
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @param body   JSON string to post
     * @param headers Map<String,String> of headers to send with this call.
     * @param encodeQuery Boolean to determine if the query should be encoded
     * @return     `HTTPResponse`
     */
    @TestVisible
    @SuppressWarnings('PMD.ExcessiveParameterList')
    protected HttpResponse get(
        String path,
        String query,
        String body,
        Map<String, String> headers,
        Boolean encodeQuery
    ) {
        return this.makeApiCall(HttpVerb.GET, path, query, body, headers, encodeQuery);
    }

    /**
     * @description convenience method for deleting a resource based only on
     * path
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse del(String path) {
        return this.makeApiCall(HttpVerb.DEL, path);
    }

    /**
     * @description convenience method for a Delete Call that only requires a
     * path and query
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse del(String path, String query) {
        return this.makeApiCall(HttpVerb.DEL, path, query);
    }

    /**
     * @description convenience method for a Delete Call that only requires a
     * path, query, and headers
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @param headers Map<String,String> of headers to send with this call.
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse del(String path, String query, Map<String, String> headers) {
        return this.makeApiCall(HttpVerb.DEL, path, query, '', headers);
    }

    /**
     * @description convenience method for a POST Call that only requires a path
     * and body
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param body   JSON string to post
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse post(String path, String body) {
        return this.makeApiCall(HttpVerb.POST, path, '', body);
    }

    /**
     * @description convenience method for a POST Call that only requires a
     * path, query and body
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @param body   JSON string to post
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse post(String path, String query, String body) {
        return this.makeApiCall(HttpVerb.POST, path, query, body);
    }

    /**
     * @description convenience method for a POST Call that only requires a
     * path, query, body, and headers
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @param body   JSON string to post
     * @param headers Map<String,String> of headers to send with this call.
     * @return     `HTTPResponse`
     */
    @TestVisible
    public HttpResponse post(String path, String query, String body, Map<String, String> headers) {
        return this.makeApiCall(HttpVerb.POST, path, query, body, headers);
    }

    /**
     * @description convenience method for a POST Call that only requires a
     * path, query, body, headers, and encodeQuery
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @param body   JSON string to post
     * @param headers Map<String,String> of headers to send with this call.
     * @param encodeQuery Boolean to determine if the query should be encoded
     * @return     `HTTPResponse`
     */
    @TestVisible
    @SuppressWarnings('PMD.ExcessiveParameterList')
    protected HttpResponse post(
        String path,
        String query,
        String body,
        Map<String, String> headers,
        Boolean encodeQuery
    ) {
        return this.makeApiCall(HttpVerb.POST, path, query, body, headers, encodeQuery);
    }

    /**
     * @description convenience method for a PUT Call that only requires a path
     * and body
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param body   JSON string to post
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse put(String path, String body) {
        return this.makeApiCall(HttpVerb.PUT, path, '', body);
    }

    /**
     * @description convenience method for a PUT Call that only requires a path,
     * query and body
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @param body   JSON string to post
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse put(String path, String query, String body) {
        return this.makeApiCall(HttpVerb.PUT, path, query, body);
    }

    /**
     * @description convenience method for a POST Call that only requires a
     * path, query, body, and headers
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @param body   JSON string to post
     * @param headers Map<String,String> of headers to send with this call.
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse put(String path, String query, String body, Map<String, String> headers) {
        return this.makeApiCall(HttpVerb.POST, path, query, body, headers);
    }

    /**
     * @description convenience method for a PATCH Call that only requires a
     * path and body
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param body   JSON string to post
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse patch(String path, String body) {
        return this.makeApiCall(HttpVerb.PATCH, path, '', body);
    }

    /**
     * @description convenience method for a PATCH Call that only requires a
     * path, query and body
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @param body   JSON string to post
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse patch(String path, String query, String body) {
        return this.makeApiCall(HttpVerb.PATCH, path, query, body);
    }

    /**
     * @description convenience method for a PATCH Call that only requires a
     * path, query, body, and headers
     * @param path   Http path component of the URL. ie: `/path/to/resource`
     * @param query  Query component of the URL ie: after `?foo=bar`
     * @param body   JSON string to post
     * @param headers Map<String,String> of headers to send with this call.
     * @return     `HTTPResponse`
     */
    @TestVisible
    protected HttpResponse patch(String path, String query, String body, Map<String, String> headers) {
        return this.makeApiCall(HttpVerb.PATCH, path, query, body, headers);
    }
}
