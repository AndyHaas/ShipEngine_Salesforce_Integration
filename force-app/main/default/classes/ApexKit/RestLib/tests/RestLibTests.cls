@IsTest
private class RestLibTests {
    /**
     * @description Creates a test user for system.runAs
     * @return User The created User record
     */
    private static User createTestUser() {
        return TestFactory.createTestUser(true, 'System Administrator');
    }

    /**
     * @description Executes a positive test case of the Constructor.
     * Expects the named credential to be set.
     */
    @IsTest
    private static void testConstructorPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClient restClient;

            Test.startTest();
            restClient = new RestClient('dummyNamedCredential');
            Test.stopTest();

            Assert.areEqual(
                'dummyNamedCredential',
                restClient.namedCredentialName,
                'Expected the name credential to match'
            );
        }
    }

    /**
     * Note: we do not have a constructor test for the no param
     * constructor. Because it's access modifier is protected
     * we cannot use that constructor - the compiler throws an error
     * noting the method is not visible
     */

    /**
     * @description Executes a positive test case against the RestClients'
     * makeApiCall method, this time specifying all the method params
     */
    @IsTest
    private static void testStaticMakeApiCallFullParamsPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = RestClient.makeApiCall(
                'DummyNamedCredential',
                new RestLibApiCall(HttpVerb.GET, '/', '', '', null)
            );
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected the return status code to be 200');
        }
    }

    @IsTest
    private static void testStaticMakeApiCallNoHeadersOrBodyParamsPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = RestClient.makeApiCall(
                'DummyNamedCredential',
                new RestLibApiCall(HttpVerb.GET, '/', '', '')
            );
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected the return status code to be 200');
        }
    }

    @IsTest
    private static void testStaticMakeApiCallNoHeadersOrBodyOrQueryParamsPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            RestLibApiCall call = new RestLibApiCall(HttpVerb.GET, '/', '', '');
            HttpResponse response = RestClient.makeApiCall('DummyNamedCredential', call);
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected the return status code to be 200');
        }
    }

    /**
     * Convenience, Instance Methods
     * These 6 methods are not utilized by our API service
     * class.
     */

    /**
     * @description Positive test case for convenience method needing only
     * path and query params.
     */
    @IsTest
    private static void testGetWithPathAndQueryPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = restClientLib.get('/', '?test');
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    /**
     * @description Positive test case for convenience method needing only
     * path and query params.
     */
    @IsTest
    private static void testGetWithPathPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = restClientLib.get('/');
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    @IsTest
    private static void testDelWithPathPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = restClientLib.del('/');
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    @IsTest
    private static void testDelWithPathAndQueryPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = restClientLib.del('/', 'foo');
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    @IsTest
    private static void testPostWithPathAndBodyPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(201, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = restClientLib.post('/', '{"Id": "003ae3fn12df25k309"}');
            Test.stopTest();

            Assert.areEqual(201, response.getStatusCode(), 'Expected to get the 201 response code');
        }
    }

    @IsTest
    private static void testPostWithPathQueryAndBodyPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(201, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = restClientLib.post('/', '', '{"Id": "003ae3fn12df25k309"}');
            Test.stopTest();

            Assert.areEqual(201, response.getStatusCode(), 'Expected to get the 201 response code');
        }
    }

    @IsTest
    private static void testPutWithPathAndBodyPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(201, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = restClientLib.put('/', '{"Id": "003ae3fn12df25k309"}');
            Test.stopTest();

            Assert.areEqual(201, response.getStatusCode(), 'Expected to get the 201 response code');
        }
    }

    @IsTest
    private static void testPutWithPathQueryAndBodyPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(201, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = restClientLib.put('/', '', '{"Id": "003ae3fn12df25k309"}');
            Test.stopTest();

            Assert.areEqual(201, response.getStatusCode(), 'Expected to get the 201 response code');
        }
    }

    @IsTest
    private static void testPatchWithPathQueryAndBodyPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(201, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = restClientLib.patch('/', 'q=foo', '{"Id": "003ae3fn12df25k309"}');
            Test.stopTest();

            Assert.areEqual(201, response.getStatusCode(), 'Expected to get the 201 response code');
        }
    }

    @IsTest
    private static void testPatchWithPathAndBodyPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(201, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = restClientLib.patch('/', '{"Id": "003ae3fn12df25k309"}');
            Test.stopTest();

            Assert.areEqual(201, response.getStatusCode(), 'Expected to get the 201 response code');
        }
    }

    @IsTest
    private static void testProtectedRestLibConstructorPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestLib restLib = new RestLib();
            Assert.areNotEqual(null, restLib, 'Expected the RestLib to be created');
        }
    }

    @IsTest
    private static void testEnsureStringEndsInSlashPositiveStartWithoutSlash() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            Test.startTest();
            String result = RestLibApiCall.ensureStringEndsInSlash('noSlash');
            Test.stopTest();
            Assert.isTrue(result.endsWith('/'), 'Expected the result to end with a slash');
        }
    }

    /* Additional tests to improve coverage of RestClientLib methods */

    @IsTest
    private static void testMakeApiCallWithPathQueryBodyPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            HttpResponse response = restClientLib.makeApiCall(HttpVerb.GET, '/', 'test=1', 'body');
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    @IsTest
    private static void testMakeApiCallWithPathQueryBodyHeadersPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
            HttpResponse response = restClientLib.makeApiCall(HttpVerb.GET, '/', 'test=1', 'body', headers);
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    @IsTest
    private static void testMakeApiCallWithPathQueryBodyHeadersEncodeQueryPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
            HttpResponse response = restClientLib.makeApiCall(HttpVerb.GET, '/', 'test=1', 'body', headers, true);
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    @IsTest
    private static void testMakeApiCallWithPathAndHeadersPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
            HttpResponse response = restClientLib.makeApiCall(HttpVerb.GET, '/', headers);
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    @IsTest
    private static void testGetWithPathBodyHeadersPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
            HttpResponse response = restClientLib.get('/', 'body', headers);
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    @IsTest
    private static void testGetWithPathQueryBodyHeadersEncodeQueryPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
            HttpResponse response = restClientLib.get('/', 'test=1', 'body', headers, true);
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    @IsTest
    private static void testDelWithPathQueryHeadersPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
            HttpResponse response = restClientLib.del('/', 'test=1', headers);
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    @IsTest
    private static void testPostWithPathQueryBodyHeadersPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(201, 'Created', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
            HttpResponse response = restClientLib.post('/', 'test=1', '{"data":"value"}', headers);
            Test.stopTest();

            Assert.areEqual(201, response.getStatusCode(), 'Expected to get the 201 response code');
        }
    }

    @IsTest
    private static void testPostWithPathQueryBodyHeadersEncodeQueryPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(201, 'Created', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
            HttpResponse response = restClientLib.post('/', 'test=1', '{"data":"value"}', headers, true);
            Test.stopTest();

            Assert.areEqual(201, response.getStatusCode(), 'Expected to get the 201 response code');
        }
    }

    @IsTest
    private static void testPutWithPathQueryBodyHeadersPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
            HttpResponse response = restClientLib.put('/', 'test=1', '{"data":"value"}', headers);
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }

    @IsTest
    private static void testPatchWithPathQueryBodyHeadersPositive() {
        User testUser = createTestUser();

        System.runAs(testUser) {
            RestClientLib restClientLib = new RestClientLib('DummyNamedCredential');
            HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', 'OK', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
            HttpResponse response = restClientLib.patch('/', 'test=1', '{"data":"value"}', headers);
            Test.stopTest();

            Assert.areEqual(200, response.getStatusCode(), 'Expected to get the 200 response code');
        }
    }
}
