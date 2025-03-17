/**
 * @description Test class for ShipmentRepo
 * Each test method follows naming convention: type<UnitUnderTest><Positive/Negative>
 */
@IsTest
private class ShipmentRepoTests {
    /**
     * @description Set up test data
     */
    @TestSetup
    static void setupTestData() {
        // Create a test user
        User testUser = TestFactory.createTestUser(true, 'System Administrator');

        // Create test data as the test user
        System.runAs(testUser) {
            // Create shipment records
            List<Shipment__c> shipments = new List<Shipment__c>();

            shipments.add(
                new Shipment__c(
                    Tracking_Number__c = 'SHIP123',
                    Status__c = 'In Transit',
                    Status_Code__c = 'IN_TRANSIT',
                    Status_Description__c = 'Package in transit',
                    Carrier__c = 'UPS'
                )
            );

            shipments.add(
                new Shipment__c(
                    Tracking_Number__c = 'SHIP456',
                    Status__c = 'Delivered',
                    Status_Code__c = 'DELIVERED',
                    Status_Description__c = 'Package delivered',
                    Carrier__c = 'FedEx'
                )
            );

            insert shipments;
        }
    }

    /**
     * @description Test fetchShipmentByTrackingNumber with valid tracking number
     */
    @IsTest
    static void unitFetchShipmentByTrackingNumberPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        String trackingNumber = 'SHIP123';

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ShipmentRepo repo = new ShipmentRepo();
            Shipment__c shipment = repo.fetchShipmentByTrackingNumber(trackingNumber);
            Test.stopTest();

            // Verify results
            Assert.areEqual(trackingNumber, shipment.Tracking_Number__c, 'Should return the correct shipment');
            Assert.areEqual('IN_TRANSIT', shipment.Status_Code__c, 'Status code should match');
        }
    }

    /**
     * @description Test fetchShipmentByTrackingNumber with non-existent tracking number
     */
    @IsTest
    static void unitFetchShipmentByTrackingNumberNonexistentPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        String trackingNumber = 'NONEXISTENT';

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ShipmentRepo repo = new ShipmentRepo();
            Shipment__c shipment = repo.fetchShipmentByTrackingNumber(trackingNumber);
            Test.stopTest();

            // Verify results
            Assert.areEqual(null, shipment.Id, 'Should return a new empty shipment instance');
        }
    }

    /**
     * @description Test fetchShipmentsByTrackingNumbers with valid tracking numbers
     */
    @IsTest
    static void unitFetchShipmentsByTrackingNumbersPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        List<String> trackingNumbers = new List<String>{ 'SHIP123', 'SHIP456' };

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ShipmentRepo repo = new ShipmentRepo();
            List<Shipment__c> shipments = repo.fetchShipmentsByTrackingNumbers(trackingNumbers);
            Test.stopTest();

            // Verify results
            Assert.areEqual(2, shipments.size(), 'Should return both shipments');

            // Create a map for easier verification
            Map<String, Shipment__c> shipmentsByTrackingNumber = new Map<String, Shipment__c>();
            for (Shipment__c shipment : shipments) {
                shipmentsByTrackingNumber.put(shipment.Tracking_Number__c, shipment);
            }

            Assert.isTrue(shipmentsByTrackingNumber.containsKey('SHIP123'), 'Should contain first shipment');
            Assert.isTrue(shipmentsByTrackingNumber.containsKey('SHIP456'), 'Should contain second shipment');
            Assert.areEqual(
                'IN_TRANSIT',
                shipmentsByTrackingNumber.get('SHIP123').Status_Code__c,
                'First shipment status should match'
            );
            Assert.areEqual(
                'DELIVERED',
                shipmentsByTrackingNumber.get('SHIP456').Status_Code__c,
                'Second shipment status should match'
            );
        }
    }

    /**
     * @description Test fetchShipmentsByTrackingNumbers with non-existent tracking numbers
     */
    @IsTest
    static void unitFetchShipmentsByTrackingNumbersNonexistentPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        List<String> trackingNumbers = new List<String>{ 'NONEXISTENT1', 'NONEXISTENT2' };

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ShipmentRepo repo = new ShipmentRepo();
            List<Shipment__c> shipments = repo.fetchShipmentsByTrackingNumbers(trackingNumbers);
            Test.stopTest();

            // Verify results
            Assert.areEqual(0, shipments.size(), 'Should return empty list for non-existent tracking numbers');
        }
    }

    /**
     * @description Test upsertShipments for inserting new shipments
     */
    @IsTest
    static void unitUpsertShipmentsInsertPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        List<Shipment__c> newShipments = new List<Shipment__c>();

        newShipments.add(
            new Shipment__c(
                Tracking_Number__c = 'NEW123',
                Status__c = 'Delivered',
                Status_Code__c = 'Delivered',
                Status_Description__c = 'Delivered',
                Carrier__c = 'DHL'
            )
        );

        newShipments.add(
            new Shipment__c(
                Tracking_Number__c = 'NEW456',
                Status__c = 'Delivered',
                Status_Code__c = 'Delivered',
                Status_Description__c = 'Delivered',
                Carrier__c = 'UPS'
            )
        );

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ShipmentRepo repo = new ShipmentRepo();
            List<Database.UpsertResult> results = repo.upsertShipments(newShipments);
            Test.stopTest();

            // Verify results
            Assert.areEqual(2, results.size(), 'Should return two upsert results');
            for (Database.UpsertResult result : results) {
                Assert.isTrue(result.isSuccess(), 'Upsert should succeed');
                Assert.isTrue(result.isCreated(), 'Records should be created, not updated');
            }

            // Verify records were inserted
            List<Shipment__c> insertedShipments = [
                SELECT Id, Tracking_Number__c, Status_Code__c, Carrier__c
                FROM Shipment__c
                WHERE Tracking_Number__c IN ('NEW123', 'NEW456')
                ORDER BY Tracking_Number__c
            ];

            Assert.areEqual(2, insertedShipments.size(), 'Should have inserted 2 new shipments');
            Assert.areEqual('NEW123', insertedShipments[0].Tracking_Number__c, 'First tracking number should match');
            Assert.areEqual('NEW456', insertedShipments[1].Tracking_Number__c, 'Second tracking number should match');
            Assert.areEqual('Delivered', insertedShipments[0].Status_Code__c, 'First status code should match');
            Assert.areEqual('Delivered', insertedShipments[1].Status_Code__c, 'Second status code should match');
        }
    }

    /**
     * @description Test upsertShipments for updating existing shipments
     */
    @IsTest
    static void unitUpsertShipmentsUpdatePositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        List<Shipment__c> existingShipments = [
            SELECT Id, Tracking_Number__c, Status__c, Status_Code__c, Status_Description__c
            FROM Shipment__c
            WHERE Tracking_Number__c IN ('SHIP123', 'SHIP456')
            ORDER BY Tracking_Number__c
        ];

        // Update the status of existing shipments
        existingShipments[0].Status_Code__c = 'OUT_FOR_DELIVERY';
        existingShipments[0].Status__c = 'Delivered';
        existingShipments[0].Status_Description__c = 'Package out for delivery';

        existingShipments[1].Status_Code__c = 'EXCEPTION';
        existingShipments[1].Status__c = 'Exception';
        existingShipments[1].Status_Description__c = 'Delivery exception';

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ShipmentRepo repo = new ShipmentRepo();
            List<Database.UpsertResult> results = repo.upsertShipments(existingShipments);
            Test.stopTest();

            // Verify results
            Assert.areEqual(2, results.size(), 'Should return two upsert results');
            for (Database.UpsertResult result : results) {
                Assert.isTrue(result.isSuccess(), 'Upsert should succeed');
                Assert.isTrue(!result.isCreated(), 'Records should be updated, not created');
            }

            // Verify records were updated
            List<Shipment__c> updatedShipments = [
                SELECT Id, Tracking_Number__c, Status_Code__c, Status__c, Status_Description__c
                FROM Shipment__c
                WHERE Tracking_Number__c IN ('SHIP123', 'SHIP456')
                ORDER BY Tracking_Number__c
            ];

            Assert.areEqual(
                'OUT_FOR_DELIVERY',
                updatedShipments[0].Status_Code__c,
                'First status code should be updated'
            );
            Assert.areEqual('Delivered', updatedShipments[0].Status__c, 'First status should be updated');
            Assert.areEqual(
                'Package out for delivery',
                updatedShipments[0].Status_Description__c,
                'First status description should be updated'
            );

            Assert.areEqual('EXCEPTION', updatedShipments[1].Status_Code__c, 'Second status code should be updated');
            Assert.areEqual('Exception', updatedShipments[1].Status__c, 'Second status should be updated');
            Assert.areEqual(
                'Delivery exception',
                updatedShipments[1].Status_Description__c,
                'Second status description should be updated'
            );
        }
    }
}
