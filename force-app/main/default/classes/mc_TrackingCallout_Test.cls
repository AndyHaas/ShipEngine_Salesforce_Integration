@isTest
public class mc_TrackingCallout_Test {
    @testsetup
    public static void setup(){
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

    @isTest
    static void testGetTrackingInformation_Success() {
        // Set up the mock response             
        Test.startTest();
       
        
        
        // Mock HTTP callout response
        

        // Create instance of the class
        mc_TrackingCallouts trackingCallouts = new mc_TrackingCallouts();
        Shipment__c shipment =[SELECT Id,Tracking_Number__c,Carrier__c FROM Shipment__c LIMIT 1][0];
        
        
        // Call method
        Test.setMock(HttpCalloutMock.class,new trackingCalloutMock());
        mc_DTO_TrackingDetails trackingDetails = trackingCallouts.getTrackingInformation(shipment.Tracking_Number__c, shipment.Carrier__c);
        
        // Validate the response
        System.assertNotEquals(trackingDetails, null, 'Assert that trackingDetails is not null.');
        //System.assertEquals(trackingDetails.trackingResponse.data.status, 'delivered');
        Test.stopTest();
    }

    @isTest
    static void testGetTrackingInformation_Failure() {
        // Set up the mock response for failure (e.g., 400 status code)
        
        Test.startTest();
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class,new trackingCalloutMock_Failure());

        // Create instance of the class
        mc_TrackingCallouts trackingCallouts = new mc_TrackingCallouts();
        Shipment__c shipment =[SELECT Id,Tracking_Number__c,Carrier__c FROM Shipment__c LIMIT 1][0];
        // Call method
        mc_DTO_TrackingDetails trackingDetails = trackingCallouts.getTrackingInformation(shipment.Tracking_Number__c, shipment.Carrier__c);
        System.debug('from test => '+JSON.serializePretty(trackingDetails));
        // Validate that the error response is captured
        //System.assertNotEquals(trackingDetails.trackingErrorResponse, null);
        System.assertEquals(trackingDetails.trackingErrorResponse.errors.size(), 1, 'Checks that the number of tracking errors is equal to 1.');
        Test.stopTest();
    }
    
   @isTest
    static void testStartTrackingRequest_Success() {
        
        
        Test.startTest();
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new webhooksCalloutMock());

        // Create instance of the class
        mc_TrackingCallouts trackingCallouts = new mc_TrackingCallouts();
        
        Shipment__c shipment =[SELECT Id,Tracking_Number__c,Carrier__c FROM Shipment__c LIMIT 1][0];
        // Call method
        mc_DTO_WebhookDetails webhookDetails = trackingCallouts.startTrackingRequest(shipment.Tracking_Number__c, shipment.Carrier__c);
        
        // Validate the response
        //System.assertNotEquals(webhookDetails, null);
        //System.assertEquals(webhookDetails.trackingWebhookCreationResponse.status, 'success');
        Test.stopTest();
    }

    /* @isTest
    static void testSubscribeToTrackingEvents() {
        // Set up the mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(204);
        
        Test.startTest();
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Create instance of the class
        mc_TrackingCallouts trackingCallouts = new mc_TrackingCallouts();
        
        // Call method
       // mc_DTO_WebhookDetails webhookDetails = trackingCallouts.subscribeToTrackingEvents();
        
        // Validate that no error is returned
        //System.assertEquals(webhookDetails.trackingErrorResponse, null);
        Test.stopTest();
    }*/

    // Mock class to simulate HTTP callouts
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse mockResponse;

        public MockHttpResponseGenerator(HttpResponse mockResponse) {
            this.mockResponse = mockResponse;
        }

        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }
}