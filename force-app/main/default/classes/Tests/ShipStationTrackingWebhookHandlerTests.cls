@IsTest
public class ShipStationTrackingWebhookHandlerTests {
    private static final String TEST_WEBHOOK_JSON = '{"resource_url":"","resource_type":"","data":{"tracking_number":"9405511899223197428490","tracking_url":"https://tools.usps.com/go/TrackConfirmAction.action?tLabels=9405511899223197428490","status_code":"DE","carrier_code":"usps","carrier_id":1,"carrier_detail_code":null,"status_description":"Delivered","carrier_status_code":"01","carrier_status_description":"Your item was delivered in or at the mailbox at 2:03 pm on September 20, 2021 in SARCOXIE, MO 64862.","ship_date":null,"estimated_delivery_date":null,"actual_delivery_date":null,"exception_description":null,"events":[{"occurred_at":"2021-09-20T19:03:00Z","carrier_occurred_at":"2021-09-20T14:03:00","description":"Delivered, In/At Mailbox","city_locality":"SARCOXIE","state_province":"MO","postal_code":"64862","country_code":"","company_name":"","signer":"","event_code":"01","carrier_detail_code":null,"status_code":null,"status_description":null,"carrier_status_code":"01","carrier_status_description":"Delivered, In/At Mailbox","latitude":37.0776,"longitude":-94.1258},{"occurred_at":"2021-09-20T13:10:00Z","carrier_occurred_at":"2021-09-20T08:10:00","description":"Out for Delivery","city_locality":"SARCOXIE","state_province":"MO","postal_code":"64862","country_code":"","company_name":"","signer":"","event_code":"OF","carrier_detail_code":null,"status_code":null,"status_description":null,"carrier_status_code":"OF","carrier_status_description":"Out for Delivery","latitude":37.0776,"longitude":-94.1258},{"occurred_at":"2021-09-20T12:59:00Z","carrier_occurred_at":"2021-09-20T07:59:00","description":"Arrived at Post Office","city_locality":"SARCOXIE","state_province":"MO","postal_code":"64862","country_code":"","company_name":"","signer":"","event_code":"07","carrier_detail_code":null,"status_code":null,"status_description":null,"carrier_status_code":"07","carrier_status_description":"Arrived at Post Office","latitude":37.0776,"longitude":-94.1258},{"occurred_at":"2021-09-18T00:00:00Z","carrier_occurred_at":"2021-09-18T00:00:00","description":"In Transit to Next Facility","city_locality":"","state_province":"","postal_code":"","country_code":"","company_name":"","signer":"","event_code":"NT","carrier_detail_code":null,"status_code":null,"status_description":null,"carrier_status_code":"NT","carrier_status_description":"In Transit to Next Facility","latitude":null,"longitude":null},{"occurred_at":"2021-09-17T02:41:00Z","carrier_occurred_at":"2021-09-16T19:41:00","description":"Arrived at USPS Regional Origin Facility","city_locality":"LAS VEGAS NV DISTRIBUTION CENTER ANNEX","state_province":"","postal_code":"","country_code":"","company_name":"","signer":"","event_code":"10","carrier_detail_code":null,"status_code":null,"status_description":null,"carrier_status_code":"10","carrier_status_description":"Arrived at USPS Regional Origin Facility","latitude":null,"longitude":null},{"occurred_at":"2021-09-16T21:06:00Z","carrier_occurred_at":"2021-09-16T14:06:00","description":"USPS picked up item","city_locality":"LAS VEGAS","state_province":"NV","postal_code":"89118","country_code":"","company_name":"","signer":"","event_code":"03","carrier_detail_code":null,"status_code":null,"status_description":null,"carrier_status_code":"03","carrier_status_description":"USPS picked up item","latitude":35.9292,"longitude":-115.1987}]}}';
    private static final String INVALID_JSON = '{invalid:"json"}';

    /**
     * @description Setup method to create a test user for system.runAs blocks
     * @return User A test user with the necessary permissions
     */
    private static User createTestUser() {
        return TestFactory.createTestUser(false, 'System Administrator');
    }

    /**
     * @description Tests successful processing of a valid webhook payload
     */
    @IsTest
    public static void unitTrackingWebhookApexHandlerPositive() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            // Set up the REST context
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/tracking/events';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(TEST_WEBHOOK_JSON);
            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            TrackingWebhookApexHandler.handlePost();
            Test.stopTest();

            // Verify the status code is set to 201 (Created)
            Assert.areEqual(201, res.statusCode, 'Expected status code 201 for successful creation');

            // Verify a Tracking_Master__c record was created
            List<Tracking_Master__c> trackingMasters = [
                SELECT Id, Tracking_Number__c
                FROM Tracking_Master__c
                WHERE Tracking_Number__c = '9405511899223197428490'
            ];
            Assert.areEqual(1, trackingMasters.size(), 'Expected one Tracking_Master__c record to be created');
        }
    }

    /**
     * @description Tests the error path for the case where deserialization fails
     */
    @IsTest
    public static void unitTrackingWebhookApexHandlerDeserializationNegative() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            // Set up the REST context with invalid JSON
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/tracking/events';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(INVALID_JSON);
            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            TrackingWebhookApexHandler.handlePost();
            Test.stopTest();

            // Verify the status code is set to 500 for the exception
            Assert.areEqual(500, res.statusCode, 'Expected status code 500 for JSON deserialization failure');

            // Verify no Tracking_Master__c record was created
            List<Tracking_Master__c> trackingMasters = [SELECT Id FROM Tracking_Master__c];
            Assert.areEqual(0, trackingMasters.size(), 'No record should be created when deserialization fails');
        }
    }

    //    /**
    //     * @description Tests the DML error branch where save fails
    //     */
    //    @IsTest
    //    public static void unitTrackingWebhookApexHandlerDMLNegative() {
    //        User testUser = createTestUser();
    //        System.runAs(testUser) {
    //            // Create a mock TrackingMasterRepo that will return a failed SaveResult
    //            TrackingMasterRepo mockRepo = (TrackingMasterRepo) new Stub.Builder(TrackingMasterRepo.class)
    //                .mockingMethodCall('createTrackingMasterRecordFromDTO')
    //                .withParameterTypes(new List<Type>{ ShipStationTrackingResponseDTO.class })
    //                .throwingException(new DmlException('failed'))
    //                .defineStub(true);
    //
    //            // Inject the mock repo into the handler using Test.setMock
    //            Test.setMock(TrackingMasterRepo.class, mockRepo);
    //
    //            // Set up the REST context
    //            RestRequest req = new RestRequest();
    //            RestResponse res = new RestResponse();
    //            req.requestURI = '/services/apexrest/tracking/events';
    //            req.httpMethod = 'POST';
    //            req.requestBody = Blob.valueOf(TEST_WEBHOOK_JSON);
    //            RestContext.request = req;
    //            RestContext.response = res;
    //
    //            Test.startTest();
    //            TrackingWebhookApexHandler.handlePost();
    //            Test.stopTest();
    //
    //            // Verify the status code is set to 207 (Multi-Status) for DML error
    //            Assert.areEqual(207, res.statusCode, 'Expected status code 207 for DML failure');
    //        }
    //    }

    /**
     * @description Tests WebhookHandler with direct ContentVersion creation
     */
    @IsTest
    public static void functionalWebhookWithDirectContentVersionsPositive() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            // Manually ensure the ContentVersion will be available to the service
            // First create a Tracking_Master__c record
            Tracking_Master__c trackingMaster = new Tracking_Master__c(
                Tracking_Number__c = '9405511899223197428490',
                Carrier__c = 'usps'
            );
            insert trackingMaster;

            // Then create a ContentVersion to store the JSON
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'Tracking Data for 9405511899223197428490';
            contentVersion.PathOnClient = 'tracking_data.json';
            contentVersion.VersionData = Blob.valueOf(TEST_WEBHOOK_JSON);
            contentVersion.IsMajorVersion = true;
            insert contentVersion;

            // Query for the ContentVersion to get the ID
            contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];

            // Link the ContentVersion to the Tracking_Master__c record
            trackingMaster.Content_Version_Id__c = contentVersion.Id;
            update trackingMaster;

            // Now manually execute the service class directly
            Test.startTest();
            TrackingMasterService service = new TrackingMasterService();
            service.processTrackingMaster(new List<Tracking_Master__c>{ trackingMaster });
            Test.stopTest();

            // Verify a Shipment record was created
            List<Shipment__c> shipments = [
                SELECT Id, Tracking_Number__c
                FROM Shipment__c
                WHERE Tracking_Number__c = '9405511899223197428490'
            ];
            Assert.areEqual(1, shipments.size(), 'Expected one Shipment__c record to be created');

            // Verify tracking events were created
            List<Tracking_Event__c> events = [
                SELECT Id
                FROM Tracking_Event__c
                WHERE Tracking_Master__c = :trackingMaster.Id
            ];
            Assert.areEqual(6, events.size(), 'Expected 6 tracking events to be created from the webhook payload');

            // Verify shipment events were also created
            List<Shipment_Events__c> shipmentEvents = [
                SELECT Id
                FROM Shipment_Events__c
                WHERE Shipment__c = :shipments[0].Id
            ];
            Assert.areEqual(
                6,
                shipmentEvents.size(),
                'Expected 6 shipment events to be created from the webhook payload'
            );
        }
    }

    /**
     * @description Tests the complete end-to-end flow from webhook receipt through
     * Queueable execution, ensuring tracking events are properly created from the webhook payload.
     */
    @IsTest
    public static void functionalWebhookToEventsEndToEndPositive() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            // Set up the REST context
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/tracking/events';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(TEST_WEBHOOK_JSON);
            RestContext.request = req;
            RestContext.response = res;

            // Call the webhook handler which will create the Tracking_Master__c record
            Test.startTest();
            TrackingWebhookApexHandler.handlePost();

            // Verify a Tracking_Master__c record was created
            List<Tracking_Master__c> trackingMasters = [
                SELECT Id, Tracking_Number__c
                FROM Tracking_Master__c
                WHERE Tracking_Number__c = '9405511899223197428490'
            ];
            Assert.areEqual(1, trackingMasters.size(), 'Expected one Tracking_Master__c record to be created');
            Assert.areEqual(201, res.statusCode, 'Expected status code 201 for successful creation');

            // The trigger should have enqueued a job to process the tracking master
            // Test.stopTest() will force the queueable job to execute
            Test.stopTest();

            // Verify a Shipment record was created
            List<Shipment__c> shipments = [
                SELECT Id, Tracking_Number__c
                FROM Shipment__c
                WHERE Tracking_Number__c = '9405511899223197428490'
            ];
            Assert.areEqual(1, shipments.size(), 'Expected one Shipment__c record to be created');

            // Verify tracking events were created - there should be 6 events from our test JSON
            List<Tracking_Event__c> events = [
                SELECT Id
                FROM Tracking_Event__c
                WHERE Tracking_Master__c = :trackingMasters[0].Id
            ];
            Assert.areEqual(6, events.size(), 'Expected 6 tracking events to be created from the webhook payload');

            // Verify shipment events were also created
            List<Shipment_Events__c> shipmentEvents = [
                SELECT Id
                FROM Shipment_Events__c
                WHERE Shipment__c = :shipments[0].Id
            ];
            Assert.areEqual(
                6,
                shipmentEvents.size(),
                'Expected 6 shipment events to be created from the webhook payload'
            );
        }
    }

    /**
     * @description Tests exception handling when a generic unexpected exception occurs
     */
    @IsTest
    public static void unitTrackingWebhookApexHandlerGenericExceptionNegative() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            // Set up the REST context with null requestBody to force an exception
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/tracking/events';
            req.httpMethod = 'POST';
            req.requestBody = null; // This will cause a NullPointerException when toString() is called
            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            TrackingWebhookApexHandler.handlePost();
            Test.stopTest();

            // Verify the status code is set to 500 for the exception
            Assert.areEqual(500, res.statusCode, 'Expected status code 500 for unexpected exception');
        }
    }
}
