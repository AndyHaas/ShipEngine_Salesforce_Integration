/**
 * @description Test class for TrackingMasterRepo
 * Each test method follows naming convention: type<UnitUnderTest><Positive/Negative>
 */
@IsTest
private class TrackingMasterRepoTests {
    /**
     * @description Set up test data
     */
    @TestSetup
    static void setupTestData() {
        // Create a test user
        User testUser = TestFactory.createTestUser(true, 'System Administrator');

        // Create test data as the test user
        System.runAs(testUser) {
            // Create tracking master records
            List<Tracking_Master__c> trackingMasters = new List<Tracking_Master__c>();

            // Create a content version first
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'Test JSON';
            contentVersion.PathOnClient = 'test.json';
            contentVersion.VersionData = Blob.valueOf('{"test":"data"}');
            contentVersion.IsMajorVersion = true;
            contentVersion.ContentLocation = 'S'; // S for Salesforce, E for External
            contentVersion.Origin = 'C'; // C for Content, H for Chatter
            insert contentVersion;

            // Query for the content version ID
            contentVersion = [SELECT Id FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];

            // Create tracking masters
            trackingMasters.add(
                new Tracking_Master__c(
                    Tracking_Number__c = 'TRACK123',
                    Carrier__c = 'UPS',
                    Status_Code__c = 'DE',
                    Status_Description__c = 'In Transit',
                    Content_Version_Id__c = contentVersion.Id
                )
            );

            trackingMasters.add(
                new Tracking_Master__c(
                    Tracking_Number__c = 'TRACK456',
                    Carrier__c = 'FEDEX',
                    Status_Code__c = 'DE',
                    Status_Description__c = 'Delivered',
                    Content_Version_Id__c = contentVersion.Id
                )
            );

            insert trackingMasters;
        }
    }

    /**
     * @description Utility to create a sample tracking response DTO
     * @return ShipStationTrackingResponseDTO The sample DTO
     */
    private static ShipStationTrackingResponseDTO createSampleTrackingResponseDTO() {
        ShipStationTrackingResponseDTO dto = new ShipStationTrackingResponseDTO();
        dto.data = new ShipStationTrackingDataDTO();
        dto.data.tracking_number = 'TRACK789';
        dto.data.carrier_code = 'USPS';
        dto.data.status_code = 'DE'; // Using the two-letter code for 'Delivered'
        dto.data.status_description = 'Out for Delivery';
        dto.data.ship_date = Datetime.now().addDays(-2).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        dto.data.estimated_delivery_date = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        dto.data.actual_delivery_date = null;
        dto.data.events = new List<ShipStationTrackingEventDTO>();

        ShipStationTrackingEventDTO event = new ShipStationTrackingEventDTO();
        event.event_code = 'OUT_FOR_DELIVERY';
        event.status_code = 'IT'; // Using the two-letter code for 'In Transit'
        event.description = 'Package out for delivery';
        event.occurred_at = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        dto.data.events.add(event);

        return dto;
    }

    /**
     * @description Test fetchTrackingMastersById with valid data
     */
    @IsTest
    static void unitFetchTrackingMastersByIdPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        List<Tracking_Master__c> trackingMasters = [SELECT Id FROM Tracking_Master__c];
        List<Id> trackingMasterIds = new List<Id>();
        for (Tracking_Master__c trackingMaster : trackingMasters) {
            trackingMasterIds.add(trackingMaster.Id);
        }

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            TrackingMasterRepo repo = new TrackingMasterRepo();
            List<Tracking_Master__c> fetchedMasters = repo.fetchTrackingMastersById(trackingMasterIds);
            Test.stopTest();

            // Verify results
            Assert.areEqual(2, fetchedMasters.size(), 'Should return both tracking master records');

            // Verify fields are retrieved
            for (Tracking_Master__c trackingMaster : fetchedMasters) {
                Assert.isNotNull(trackingMaster.Tracking_Number__c, 'Tracking number should be retrieved');
                Assert.isNotNull(trackingMaster.Content_Version_Id__c, 'Content version ID should be retrieved');
            }
        }
    }

    /**
     * @description Test createTrackingMasterRecordFromDTO with valid data
     */
    @IsTest
    static void unitCreateTrackingMasterRecordFromDTOPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        ShipStationTrackingResponseDTO dto = createSampleTrackingResponseDTO();

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            TrackingMasterRepo repo = new TrackingMasterRepo();
            Database.SaveResult result = repo.createTrackingMasterRecordFromDTO(dto);
            Test.stopTest();

            // Verify results
            Assert.isTrue(result.isSuccess(), 'Insert should succeed');
            Assert.isNotNull(result.getId(), 'New record ID should be returned');

            // Verify record was inserted with correct data
            Tracking_Master__c insertedMaster = [
                SELECT
                    Id,
                    Tracking_Number__c,
                    Carrier__c,
                    Status_Code__c,
                    Status_Description__c,
                    Ship_Date__c,
                    Estimated_Delivery_Date__c,
                    Content_Version_Id__c
                FROM Tracking_Master__c
                WHERE Tracking_Number__c = 'TRACK789'
                LIMIT 1
            ];

            Assert.areEqual('TRACK789', insertedMaster.Tracking_Number__c, 'Tracking number should match');
            Assert.areEqual('USPS', insertedMaster.Carrier__c, 'Carrier should match');
            Assert.areEqual('DE', insertedMaster.Status_Code__c, 'Status code should match');
            Assert.areEqual(
                'Out for Delivery',
                insertedMaster.Status_Description__c,
                'Status description should match'
            );
            Assert.isNotNull(insertedMaster.Ship_Date__c, 'Ship date should be set');
            Assert.isNotNull(insertedMaster.Estimated_Delivery_Date__c, 'Estimated delivery date should be set');
            Assert.isNotNull(insertedMaster.Content_Version_Id__c, 'Content version ID should be set');

            // Verify content version was created
            ContentVersion contentVersion = [
                SELECT Id, VersionData
                FROM ContentVersion
                WHERE Id = :insertedMaster.Content_Version_Id__c
                LIMIT 1
            ];

            Assert.isNotNull(contentVersion, 'Content version should be created');
            String jsonData = contentVersion.VersionData.toString();
            Assert.isTrue(jsonData.contains('TRACK789'), 'Content version should contain the tracking number');
        }
    }

    /**
     * @description Test createTrackingMasterRecordFromDTO with incomplete data
     */
    @IsTest
    static void unitCreateTrackingMasterRecordFromDTOWithIncompleteDataPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        // Create DTO with minimal data
        ShipStationTrackingResponseDTO dto = new ShipStationTrackingResponseDTO();
        dto.data = new ShipStationTrackingDataDTO();
        dto.data.tracking_number = 'MINIMAL123';
        dto.data.carrier_code = 'DHL';
        dto.data.status_code = 'UNKNOWN';

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            TrackingMasterRepo repo = new TrackingMasterRepo();
            Database.SaveResult result = repo.createTrackingMasterRecordFromDTO(dto);
            Test.stopTest();

            // Verify results
            Assert.isTrue(result.isSuccess(), 'Insert should succeed even with minimal data');

            // Verify record was inserted with correct data
            Tracking_Master__c insertedMaster = [
                SELECT Id, Tracking_Number__c, Carrier__c, Status_Code__c, Content_Version_Id__c
                FROM Tracking_Master__c
                WHERE Tracking_Number__c = 'MINIMAL123'
                LIMIT 1
            ];

            Assert.areEqual('MINIMAL123', insertedMaster.Tracking_Number__c, 'Tracking number should match');
            Assert.areEqual('DHL', insertedMaster.Carrier__c, 'Carrier should match');
            Assert.areEqual('UN', insertedMaster.Status_Code__c, 'Status code should match');
            Assert.isNotNull(insertedMaster.Content_Version_Id__c, 'Content version ID should be set');
        }
    }
}
