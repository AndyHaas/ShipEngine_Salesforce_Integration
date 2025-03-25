/**
 * @description Tests for ShipStationStartTrackingInvocable class
 * Each test method follows naming convention: type<UnitUnderTest><Positive/Negative>
 */
@IsTest
private class ShipStationStartTrackingInvocableTests {
    /**
     * @description Creates an HttpCalloutMockFactory for successful tracking responses
     * @return HttpCalloutMockFactory configured with appropriate responses
     */
    private static HttpCalloutMockFactory createSuccessMockFactory() {
        // Set up the responses in order they'll be called
        List<HttpResponse> responses = new List<HttpResponse>();
        Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };

        // First for webhook subscription (environment/webhooks endpoint)
        HttpResponse webhookResponse = HttpCalloutMockFactory.generateHttpResponse(204, 'No Content', '', headers);
        responses.add(webhookResponse);

        // Second for tracking start request (tracking/start endpoint)
        String trackingBody = '{"webhook_id":"wh_123456","url":"https://example.com/webhook","event":"TRACKING_UPDATE","headers":[{"key":"Authorization","value":"Bearer token123"}]}';
        HttpResponse trackingResponse = HttpCalloutMockFactory.generateHttpResponse(200, 'OK', trackingBody, headers);
        responses.add(trackingResponse);

        return new HttpCalloutMockFactory(responses);
    }

    /**
     * @description Creates an HttpCalloutMockFactory for failed tracking responses
     * @return HttpCalloutMockFactory configured with error responses
     */
    private static HttpCalloutMockFactory createFailureMockFactory() {
        Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
        String errorBody = '{"request_id":"req_error123","errors":[{"message":"Invalid tracking number or carrier code"}]}';

        return new HttpCalloutMockFactory(400, 'Bad Request', errorBody, headers);
    }

    /**
     * @description Sets up a tracking metadata record for testing
     */
    @TestSetup
    static void setupTestData() {
        // Create a test user
        User testUser = TestFactory.createTestUser(true, 'Standard User');
    }

    /**
     * @description Tests successful tracking start
     */
    @IsTest
    static void unitStartTrackingDetailsPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        // Create tracking details
        ShipStationStartTrackingInvocable.TrackingDetails details = new ShipStationStartTrackingInvocable.TrackingDetails();
        details.trackingNumber = '1Z999AA10123456784';
        details.trackingNumberCarrierCode = 'ups';

        List<ShipStationStartTrackingInvocable.TrackingDetails> detailsList = new List<ShipStationStartTrackingInvocable.TrackingDetails>{
            details
        };

        // Set the mock callout class using HttpCalloutMockFactory
        Test.setMock(HttpCalloutMock.class, createSuccessMockFactory());

        // Execute the test
        List<ShipStationStartTrackingInvocable.TrackingResponseResult> results;

        System.runAs(testUser) {
            Test.startTest();
            results = ShipStationStartTrackingInvocable.startTrackingDetails(detailsList);
            Test.stopTest();
        }

        // Verify results
        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.isNotNull(results[0].startTrackingResponse, 'Response should not be null');
        Assert.isNotNull(
            results[0].startTrackingResponse.trackingWebhookCreationResponse,
            'Webhook creation response should not be null'
        );
        Assert.areEqual(
            'wh_123456',
            results[0].startTrackingResponse.trackingWebhookCreationResponse.webhook_id,
            'Should return the correct webhook ID'
        );
    }

    /**
     * @description Tests failed tracking start due to error
     */
    @IsTest
    static void unitStartTrackingDetailsErrorResponseNegative() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        // Create tracking details
        ShipStationStartTrackingInvocable.TrackingDetails details = new ShipStationStartTrackingInvocable.TrackingDetails();
        details.trackingNumber = 'INVALID';
        details.trackingNumberCarrierCode = 'invalid';

        List<ShipStationStartTrackingInvocable.TrackingDetails> detailsList = new List<ShipStationStartTrackingInvocable.TrackingDetails>{
            details
        };

        // Set the mock callout class using HttpCalloutMockFactory
        Test.setMock(HttpCalloutMock.class, createFailureMockFactory());

        // Execute the test
        List<ShipStationStartTrackingInvocable.TrackingResponseResult> results;

        System.runAs(testUser) {
            Test.startTest();
            results = ShipStationStartTrackingInvocable.startTrackingDetails(detailsList);
            Test.stopTest();
        }

        // Verify results
        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.isNotNull(results[0].startTrackingResponse, 'Response should not be null');
        Assert.isNotNull(results[0].startTrackingResponse.trackingErrorResponse, 'Error response should not be null');
        Assert.areEqual(
            'req_error123',
            results[0].startTrackingResponse.trackingErrorResponse.request_id,
            'Should return the correct error request ID'
        );
    }

    /**
     * @description Tests multiple tracking details
     */
    @IsTest
    static void unitStartTrackingDetailsMultipleItemsPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        // Create multiple tracking details
        List<ShipStationStartTrackingInvocable.TrackingDetails> detailsList = new List<ShipStationStartTrackingInvocable.TrackingDetails>();

        ShipStationStartTrackingInvocable.TrackingDetails details1 = new ShipStationStartTrackingInvocable.TrackingDetails();
        details1.trackingNumber = '1Z999AA10123456784';
        details1.trackingNumberCarrierCode = 'ups';
        detailsList.add(details1);

        ShipStationStartTrackingInvocable.TrackingDetails details2 = new ShipStationStartTrackingInvocable.TrackingDetails();
        details2.trackingNumber = '9400111202555842761178';
        details2.trackingNumberCarrierCode = 'usps';
        detailsList.add(details2);

        // Set the mock callout class using HttpCalloutMockFactory
        // We need multiple responses for multiple items
        List<HttpResponse> responses = new List<HttpResponse>();
        Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };

        // Add 4 responses (webhook + tracking for each of 2 items)
        for (Integer i = 0; i < 4; i++) {
            if (Math.mod(i, 2) == 0) {
                // Webhook response
                responses.add(HttpCalloutMockFactory.generateHttpResponse(204, 'No Content', '', headers));
            } else {
                // Tracking response
                String trackingBody = '{"webhook_id":"wh_123456","url":"https://example.com/webhook","event":"TRACKING_UPDATE","headers":[{"key":"Authorization","value":"Bearer token123"}]}';
                responses.add(HttpCalloutMockFactory.generateHttpResponse(200, 'OK', trackingBody, headers));
            }
        }

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockFactory(responses));

        // Execute the test
        List<ShipStationStartTrackingInvocable.TrackingResponseResult> results;

        System.runAs(testUser) {
            Test.startTest();
            results = ShipStationStartTrackingInvocable.startTrackingDetails(detailsList);
            Test.stopTest();
        }

        // Verify results
        Assert.areEqual(2, results.size(), 'Should return two results');

        // Verify both responses contain webhook creation responses
        for (ShipStationStartTrackingInvocable.TrackingResponseResult result : results) {
            Assert.isNotNull(
                result.startTrackingResponse.trackingWebhookCreationResponse,
                'Webhook creation response should not be null'
            );
            Assert.areEqual(
                'wh_123456',
                result.startTrackingResponse.trackingWebhookCreationResponse.webhook_id,
                'Should return the correct webhook ID'
            );
        }
    }

    /**
     * @description Tests handling of null tracking details
     */
    @IsTest
    static void unitStartTrackingDetailsNullValueNegative() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        // Create tracking details with null values
        List<ShipStationStartTrackingInvocable.TrackingDetails> detailsList = new List<ShipStationStartTrackingInvocable.TrackingDetails>();

        ShipStationStartTrackingInvocable.TrackingDetails nullTrackingNumber = new ShipStationStartTrackingInvocable.TrackingDetails();
        nullTrackingNumber.trackingNumber = null;
        nullTrackingNumber.trackingNumberCarrierCode = 'ups';
        detailsList.add(nullTrackingNumber);

        ShipStationStartTrackingInvocable.TrackingDetails nullCarrierCode = new ShipStationStartTrackingInvocable.TrackingDetails();
        nullCarrierCode.trackingNumber = '1Z999AA10123456784';
        nullCarrierCode.trackingNumberCarrierCode = null;
        detailsList.add(nullCarrierCode);

        // Set the mock callout class - although it's not expected to be used in this test
        // since the method should return empty list when tracking number or carrier code is null
        Test.setMock(HttpCalloutMock.class, createSuccessMockFactory());

        // Execute the test
        List<ShipStationStartTrackingInvocable.TrackingResponseResult> results;

        System.runAs(testUser) {
            Test.startTest();
            results = ShipStationStartTrackingInvocable.startTrackingDetails(detailsList);
            Test.stopTest();
        }

        // Verify results
        Assert.areEqual(0, results.size(), 'Should return no results for null values');
    }

    /**
     * @description Tests handling of empty list
     */
    @IsTest
    static void unitStartTrackingDetailsEmptyListPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        // Create empty list
        List<ShipStationStartTrackingInvocable.TrackingDetails> emptyList = new List<ShipStationStartTrackingInvocable.TrackingDetails>();

        // Execute the test
        List<ShipStationStartTrackingInvocable.TrackingResponseResult> results;

        System.runAs(testUser) {
            Test.startTest();
            results = ShipStationStartTrackingInvocable.startTrackingDetails(emptyList);
            Test.stopTest();
        }

        // Verify results
        Assert.areEqual(0, results.size(), 'Should return empty list for empty input');
    }
}
