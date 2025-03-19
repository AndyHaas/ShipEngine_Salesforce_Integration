@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
public class ShipStationTrackingCalloutTests {
    /* Setup method for testability. */
    @TestSetup
    public static void setup() {
        ShipEngineAuth__c setting = ShipEngineAuth__c.getOrgDefaults();
        setting.API_Key__c = 'asd';
        upsert setting;

        // Mock HTTP callout response

        // Create instance of the class

        Shipment__c shipment = new Shipment__c(
            Carrier__c = 'UPS',
            Status_Code__c = 'UN',
            Status__c = 'Unknown',
            Status_Description__c = 'Unknown',
            Tracking_Number__c = '1Z6Y21Y60300230254'
        );

        insert shipment;
    }

    @IsTest
    static void testGetTrackingInformationSuccess() {
        // Set up the mock response using HttpCalloutMockFactory
        Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
        String responseBody = '{"tracking_number":"1Z6Y21Y60300230254","tracking_url":"http://wwwapps.ups.com/WebTracking/processRequest?HTMLVersion=5.0&Requester=NES&AgreeToTermsAndConditions=yes&loc=en_US&tracknum=1Z6Y21Y60300230254","status_code":"UN","status_detail_code":null,"status_detail_description":null,"carrier_code":"ups","carrier_id":3,"carrier_detail_code":null,"status_description":"Unknown","carrier_status_code":null,"carrier_status_description":"Invalid tracking number","ship_date":null,"estimated_delivery_date":null,"actual_delivery_date":null,"exception_description":null,"events":[]}';
        HttpCalloutMockFactory mock = new HttpCalloutMockFactory(200, 'OK', responseBody, headers);

        Test.startTest();
        // Create instance of the class
        ShipStationAPI trackingCallouts = new ShipStationAPI();
        Shipment__c shipment = [SELECT Id, Tracking_Number__c, Carrier__c FROM Shipment__c LIMIT 1][0];

        // Call method with HttpCalloutMockFactory
        Test.setMock(HttpCalloutMock.class, mock);
        ShipStationTrackingDetailsDTO trackingDetails = trackingCallouts.getTrackingInformation(
            shipment.Tracking_Number__c,
            shipment.Carrier__c
        );

        // Validate the response
        Assert.isNotNull(trackingDetails, 'Assert that trackingDetails is not null.');
        Assert.isNotNull(trackingDetails.trackingResponse, 'Response should not be null');
        Assert.isNotNull(trackingDetails.trackingResponse.data, 'Data should not be null');
        Assert.areEqual(
            '1Z6Y21Y60300230254',
            trackingDetails.trackingResponse.data.tracking_number,
            'Tracking number should match'
        );
        Test.stopTest();
    }

    @IsTest
    static void testGetTrackingInformationFailure() {
        // Set up the mock response for failure using HttpCalloutMockFactory
        Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
        String responseBody = '{"request_id":"9b7e727e-a623-4b3d-8dd1-32d3fcbfd59d","errors":[{"error_source":"shipengine","error_type":"system","error_code":"unspecified","message":"trackingNumber.String: A value is required but was not present in the request."}]}';
        HttpCalloutMockFactory mock = new HttpCalloutMockFactory(400, 'Bad Request', responseBody, headers);

        Test.startTest();
        // Create instance of the class
        ShipStationAPI trackingCallouts = new ShipStationAPI();
        Shipment__c shipment = [SELECT Id, Tracking_Number__c, Carrier__c FROM Shipment__c LIMIT 1][0];

        // Call method with HttpCalloutMockFactory
        Test.setMock(HttpCalloutMock.class, mock);
        ShipStationTrackingDetailsDTO trackingDetails = trackingCallouts.getTrackingInformation(
            shipment.Tracking_Number__c,
            shipment.Carrier__c
        );

        // Validate that the error response is captured
        Assert.isNotNull(trackingDetails.trackingErrorResponse, 'Error response should not be null');
        Assert.areEqual(
            trackingDetails.trackingErrorResponse.errors.size(),
            1,
            'Checks that the number of tracking errors is equal to 1.'
        );
        Assert.areEqual(
            '9b7e727e-a623-4b3d-8dd1-32d3fcbfd59d',
            trackingDetails.trackingErrorResponse.request_id,
            'Should return the correct request ID'
        );
        Test.stopTest();
    }

    @IsTest
    static void testStartTrackingRequestSuccess() {
        // Set up the mock response using HttpCalloutMockFactory
        Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
        String responseBody = '{"event": "track", "url": "https://your-domain-here.com/some/path"}';
        HttpCalloutMockFactory mock = new HttpCalloutMockFactory(204, 'No Content', responseBody, headers);

        Test.startTest();
        // Create instance of the class
        ShipStationAPI trackingCallouts = new ShipStationAPI();
        Shipment__c shipment = [SELECT Id, Tracking_Number__c, Carrier__c FROM Shipment__c LIMIT 1][0];

        // Call method with HttpCalloutMockFactory
        Test.setMock(HttpCalloutMock.class, mock);
        ShipStationWebhookDetailsResponseDTO webhookDetails = trackingCallouts.startTrackingRequest(
            shipment.Tracking_Number__c,
            shipment.Carrier__c
        );

        // Validate response
        Assert.isNotNull(webhookDetails, 'Assert that webhookDetails is not null.');
        Test.stopTest();
    }

    // Note: We are now using HttpCalloutMockFactory instead of this custom mock class
}
