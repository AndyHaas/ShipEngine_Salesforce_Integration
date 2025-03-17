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
        // Set up the mock response
        Test.startTest();

        // Mock HTTP callout response

        // Create instance of the class
        ShipStationAPI trackingCallouts = new ShipStationAPI();
        Shipment__c shipment = [SELECT Id, Tracking_Number__c, Carrier__c FROM Shipment__c LIMIT 1][0];

        // Call method
        Test.setMock(HttpCalloutMock.class, new trackingCalloutMock());
        ShipStationTrackingDetailsDTO trackingDetails = trackingCallouts.getTrackingInformation(
            shipment.Tracking_Number__c,
            shipment.Carrier__c
        );

        // Validate the response
        Assert.isNotNull(trackingDetails, 'Assert that trackingDetails is not null.');
        Test.stopTest();
    }

    @IsTest
    static void testGetTrackingInformationFailure() {
        // Set up the mock response for failure (e.g., 400 status code)

        Test.startTest();
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new trackingCalloutMock_Failure());

        // Create instance of the class
        ShipStationAPI trackingCallouts = new ShipStationAPI();
        Shipment__c shipment = [SELECT Id, Tracking_Number__c, Carrier__c FROM Shipment__c LIMIT 1][0];
        // Call method
        ShipStationTrackingDetailsDTO trackingDetails = trackingCallouts.getTrackingInformation(
            shipment.Tracking_Number__c,
            shipment.Carrier__c
        );
        // Validate that the error response is captured
        Assert.areEqual(
            trackingDetails.trackingErrorResponse.errors.size(),
            1,
            'Checks that the number of tracking errors is equal to 1.'
        );
        Test.stopTest();
    }

    @IsTest
    static void testStartTrackingRequestSuccess() {
        Test.startTest();
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new webhooksCalloutMock());

        // Create instance of the class
        ShipStationAPI trackingCallouts = new ShipStationAPI();

        Shipment__c shipment = [SELECT Id, Tracking_Number__c, Carrier__c FROM Shipment__c LIMIT 1][0];
        // Call method
        ShipStationWebhookDetailsResponseDTO webhookDetails = trackingCallouts.startTrackingRequest(
            shipment.Tracking_Number__c,
            shipment.Carrier__c
        );
        Assert.isNotNull(webhookDetails, 'Assert that webhookDetails is not null.');
        Test.stopTest();
    }

    // Mock class to simulate HTTP callouts
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private final HttpResponse mockResponse;

        public MockHttpResponseGenerator(HttpResponse mockResponse) {
            this.mockResponse = mockResponse;
        }

        /* This method returns a mock response. */
        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }
}
