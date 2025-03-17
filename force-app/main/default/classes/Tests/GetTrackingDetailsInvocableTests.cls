/**
 * @description Tests for GetTrackingDetailsInvocable class
 * Each test method follows naming convention: type<UnitUnderTest><Positive/Negative>
 */
@IsTest
private class GetTrackingDetailsInvocableTests {
    /**
     * @description Mock class for successful tracking detail requests
     */
    private class SuccessTrackingDetailsMock implements HttpCalloutMock {
        /**
         * @description Responds with successful tracking details
         * @param req The HTTP request
         * @return HttpResponse A mock response with success data
         */
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            // Mock response for tracking details
            String mockResponseBody =
                '{' +
                '"tracking_number":"1Z999AA10123456784",' +
                '"status_code":"DE",' +
                '"status_description":"Delivered",' +
                '"carrier_code":"ups",' +
                '"ship_date":"2023-08-01T10:00:00Z",' +
                '"estimated_delivery_date":"2023-08-03T17:00:00Z",' +
                '"actual_delivery_date":"2023-08-03T16:30:00Z",' +
                '"events":[' +
                '{' +
                '"occurred_at":"2023-08-01T10:00:00Z",' +
                '"description":"Package picked up",' +
                '"city_locality":"San Francisco",' +
                '"state_province":"CA",' +
                '"postal_code":"94105",' +
                '"country_code":"US",' +
                '"event_code":"PICKUP",' +
                '"carrier_status_description":"Package picked up",' +
                '"status_code":"AC",' +
                '"status_description":"Accepted"' +
                '},' +
                '{' +
                '"occurred_at":"2023-08-03T16:30:00Z",' +
                '"description":"Package delivered",' +
                '"city_locality":"Los Angeles",' +
                '"state_province":"CA",' +
                '"postal_code":"90001",' +
                '"country_code":"US",' +
                '"event_code":"DELIVERED",' +
                '"carrier_status_description":"Package delivered",' +
                '"status_code":"DE",' +
                '"status_description":"Delivered"' +
                '}' +
                ']' +
                '}';

            res.setBody(mockResponseBody);
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     * @description Mock class for error tracking detail requests
     */
    private class ErrorTrackingDetailsMock implements HttpCalloutMock {
        /**
         * @description Responds with an error response
         * @param req The HTTP request
         * @return HttpResponse A mock response with error data
         */
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            // Mock error response
            String mockErrorBody =
                '{' +
                '"request_id":"req_error123",' +
                '"errors":[' +
                '{' +
                '"message":"Invalid tracking number or carrier code"' +
                '}' +
                ']' +
                '}';

            res.setBody(mockErrorBody);
            res.setStatusCode(400);
            return res;
        }
    }

    /**
     * @description Sets up test data
     */
    @TestSetup
    static void setupTestData() {
        // Create a test user
        User testUser = TestFactory.createTestUser(true, 'System Administrator');
    }

    /**
     * @description Tests successful retrieval of tracking details
     */
    @IsTest
    static void unitGetTrackingDetailsPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        // Create tracking details request
        GetTrackingDetailsInvocable.TrackingDetails details = new GetTrackingDetailsInvocable.TrackingDetails();
        details.trackingNumber = '1Z999AA10123456784';
        details.trackingNumberCarrierCode = 'ups';

        List<GetTrackingDetailsInvocable.TrackingDetails> detailsList = new List<GetTrackingDetailsInvocable.TrackingDetails>{
            details
        };

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new SuccessTrackingDetailsMock());

        // Execute the test
        List<GetTrackingDetailsInvocable.Response> results;

        System.runAs(testUser) {
            Test.startTest();
            results = GetTrackingDetailsInvocable.getTrackingDetails(detailsList);
            Test.stopTest();
        }

        // Verify results
        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.isNotNull(results[0].trackingResponse, 'Tracking response should not be null');
        Assert.isNotNull(results[0].trackingResponse.trackingResponse, 'Tracking response data should not be null');

        ShipStationTrackingResponseDTO trackingResponseData = results[0].trackingResponse.trackingResponse;
        Assert.areEqual(
            '1Z999AA10123456784',
            trackingResponseData.data.tracking_number,
            'Should return correct tracking number'
        );
        Assert.areEqual('DE', trackingResponseData.data.status_code, 'Should return correct status code');
        Assert.areEqual(
            'Delivered',
            trackingResponseData.data.status_description,
            'Should return correct status description'
        );
        Assert.areEqual('ups', trackingResponseData.data.carrier_code, 'Should return correct carrier code');

        // Verify events
        Assert.areEqual(2, trackingResponseData.data.events.size(), 'Should return two events');
        Assert.areEqual('PICKUP', trackingResponseData.data.events[0].event_code, 'First event should be pickup');
        Assert.areEqual('DELIVERED', trackingResponseData.data.events[1].event_code, 'Second event should be delivery');
    }

    /**
     * @description Tests error response handling
     */
    @IsTest
    static void unitGetTrackingDetailsErrorResponseNegative() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        // Create tracking details with invalid data
        GetTrackingDetailsInvocable.TrackingDetails details = new GetTrackingDetailsInvocable.TrackingDetails();
        details.trackingNumber = 'INVALID';
        details.trackingNumberCarrierCode = 'invalid';

        List<GetTrackingDetailsInvocable.TrackingDetails> detailsList = new List<GetTrackingDetailsInvocable.TrackingDetails>{
            details
        };

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new ErrorTrackingDetailsMock());

        // Execute the test
        List<GetTrackingDetailsInvocable.Response> results;

        System.runAs(testUser) {
            Test.startTest();
            results = GetTrackingDetailsInvocable.getTrackingDetails(detailsList);
            Test.stopTest();
        }

        // Verify results
        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.isNotNull(results[0].trackingResponse, 'Tracking response should not be null');
        Assert.isNotNull(results[0].trackingResponse.trackingErrorResponse, 'Error response should not be null');
        Assert.areEqual(
            'req_error123',
            results[0].trackingResponse.trackingErrorResponse.request_id,
            'Should return correct error request ID'
        );
    }

    /**
     * @description Tests handling of null values
     */
    @IsTest
    static void unitGetTrackingDetailsNullValuesNegative() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        // Create tracking details with null values
        List<GetTrackingDetailsInvocable.TrackingDetails> detailsList = new List<GetTrackingDetailsInvocable.TrackingDetails>();

        GetTrackingDetailsInvocable.TrackingDetails nullTrackingNumber = new GetTrackingDetailsInvocable.TrackingDetails();
        nullTrackingNumber.trackingNumber = null;
        nullTrackingNumber.trackingNumberCarrierCode = 'ups';
        detailsList.add(nullTrackingNumber);

        GetTrackingDetailsInvocable.TrackingDetails nullCarrierCode = new GetTrackingDetailsInvocable.TrackingDetails();
        nullCarrierCode.trackingNumber = '1Z999AA10123456784';
        nullCarrierCode.trackingNumberCarrierCode = null;
        detailsList.add(nullCarrierCode);

        // Execute the test - no need for mock as no callouts should be made
        List<GetTrackingDetailsInvocable.Response> results;

        System.runAs(testUser) {
            Test.startTest();
            results = GetTrackingDetailsInvocable.getTrackingDetails(detailsList);
            Test.stopTest();
        }

        // Verify results
        Assert.areEqual(0, results.size(), 'Should return empty list for null values');
    }

    /**
     * @description Tests handling of multiple tracking details
     */
    @IsTest
    static void unitGetTrackingDetailsMultipleItemsPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        // Create multiple tracking details
        List<GetTrackingDetailsInvocable.TrackingDetails> detailsList = new List<GetTrackingDetailsInvocable.TrackingDetails>();

        GetTrackingDetailsInvocable.TrackingDetails details1 = new GetTrackingDetailsInvocable.TrackingDetails();
        details1.trackingNumber = '1Z999AA10123456784';
        details1.trackingNumberCarrierCode = 'ups';
        detailsList.add(details1);

        GetTrackingDetailsInvocable.TrackingDetails details2 = new GetTrackingDetailsInvocable.TrackingDetails();
        details2.trackingNumber = '9400111202555842761178';
        details2.trackingNumberCarrierCode = 'usps';
        detailsList.add(details2);

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new SuccessTrackingDetailsMock());

        // Execute the test
        List<GetTrackingDetailsInvocable.Response> results;

        System.runAs(testUser) {
            Test.startTest();
            results = GetTrackingDetailsInvocable.getTrackingDetails(detailsList);
            Test.stopTest();
        }

        // Verify results
        Assert.areEqual(2, results.size(), 'Should return two results');

        // Check that all responses contain tracking data
        for (GetTrackingDetailsInvocable.Response result : results) {
            Assert.isNotNull(result.trackingResponse, 'Tracking response should not be null');
            Assert.isNotNull(result.trackingResponse.trackingResponse, 'Tracking response data should not be null');
            Assert.areEqual(
                'DE',
                result.trackingResponse.trackingResponse.data.status_code,
                'Status code should be correct'
            );
        }
    }

    /**
     * @description Tests handling of empty list
     */
    @IsTest
    static void unitGetTrackingDetailsEmptyListPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        // Create empty list
        List<GetTrackingDetailsInvocable.TrackingDetails> emptyList = new List<GetTrackingDetailsInvocable.TrackingDetails>();

        // Execute the test - no need for mock as no callouts should be made
        List<GetTrackingDetailsInvocable.Response> results;

        System.runAs(testUser) {
            Test.startTest();
            results = GetTrackingDetailsInvocable.getTrackingDetails(emptyList);
            Test.stopTest();
        }

        // Verify results
        Assert.areEqual(0, results.size(), 'Should return empty list for empty input');
    }
}
