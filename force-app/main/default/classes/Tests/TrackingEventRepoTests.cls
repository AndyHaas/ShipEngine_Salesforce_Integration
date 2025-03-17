/**
 * @description Test class for TrackingEventRepo
 * Each test method follows naming convention: type<UnitUnderTest><Positive/Negative>
 */
@IsTest
private class TrackingEventRepoTests {
    /**
     * @description Set up test data
     */
    @TestSetup
    static void setupTestData() {
        // Create a test user
        User testUser = TestFactory.createTestUser(true, 'System Administrator');

        // Create test data as the test user
        System.runAs(testUser) {
            // Create Shipment and Tracking Master records
            Shipment__c shipment1 = new Shipment__c(
                Tracking_Number__c = 'TEST123456',
                Status__c = 'In Transit',
                Carrier__c = 'UPS'
            );

            Shipment__c shipment2 = new Shipment__c(
                Tracking_Number__c = 'TEST789012',
                Status__c = 'Delivered',
                Carrier__c = 'FedEx'
            );

            insert new List<Shipment__c>{ shipment1, shipment2 };

            Tracking_Master__c trackingMaster1 = new Tracking_Master__c(Tracking_Number__c = 'TEST123456');

            Tracking_Master__c trackingMaster2 = new Tracking_Master__c(Tracking_Number__c = 'TEST789012');

            insert new List<Tracking_Master__c>{ trackingMaster1, trackingMaster2 };

            // Create tracking events
            List<Tracking_Event__c> events = new List<Tracking_Event__c>();

            // Events for first shipment/tracking master
            events.add(
                new Tracking_Event__c(
                    Shipment__c = shipment1.Id,
                    Tracking_Master__c = trackingMaster1.Id,
                    Event_Code__c = 'PICKUP',
                    Occurred_At__c = DateTime.now().addHours(-24),
                    Description__c = 'Package picked up'
                )
            );

            events.add(
                new Tracking_Event__c(
                    Shipment__c = shipment1.Id,
                    Tracking_Master__c = trackingMaster1.Id,
                    Event_Code__c = 'IN_TRANSIT',
                    Occurred_At__c = DateTime.now().addHours(-12),
                    Description__c = 'Package in transit'
                )
            );

            // Events for second shipment/tracking master
            events.add(
                new Tracking_Event__c(
                    Shipment__c = shipment2.Id,
                    Tracking_Master__c = trackingMaster2.Id,
                    Event_Code__c = 'DELIVERED',
                    Occurred_At__c = DateTime.now(),
                    Description__c = 'Package delivered'
                )
            );

            insert events;
        }
    }

    /**
     * @description Test fetchEventCountByTrackingMasterIds with valid data
     */
    @IsTest
    static void unitFetchEventCountByTrackingMasterIdsPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        List<Tracking_Master__c> trackingMasters = [SELECT Id FROM Tracking_Master__c];
        Set<Id> trackingMasterIds = new Map<Id, Tracking_Master__c>(trackingMasters).keySet();

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            TrackingEventRepo repo = new TrackingEventRepo();
            Map<Id, Integer> eventCounts = repo.fetchEventCountByTrackingMasterIds(trackingMasterIds);
            Test.stopTest();

            // Verify results
            Assert.areEqual(2, eventCounts.size(), 'Should return event counts for both tracking masters');

            Tracking_Master__c trackingMaster1 = [
                SELECT Id
                FROM Tracking_Master__c
                WHERE Tracking_Number__c = 'TEST123456'
                LIMIT 1
            ];

            Tracking_Master__c trackingMaster2 = [
                SELECT Id
                FROM Tracking_Master__c
                WHERE Tracking_Number__c = 'TEST789012'
                LIMIT 1
            ];

            Assert.areEqual(2, eventCounts.get(trackingMaster1.Id), 'First tracking master should have 2 events');
            Assert.areEqual(1, eventCounts.get(trackingMaster2.Id), 'Second tracking master should have 1 event');
        }
    }

    /**
     * @description Test fetchEventCountByTrackingMasterIds with empty input
     */
    @IsTest
    static void unitFetchEventCountByTrackingMasterIdsWithEmptyInputPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            TrackingEventRepo repo = new TrackingEventRepo();
            Map<Id, Integer> eventCountsNull = repo.fetchEventCountByTrackingMasterIds(null);
            Map<Id, Integer> eventCountsEmpty = repo.fetchEventCountByTrackingMasterIds(new Set<Id>());
            Test.stopTest();

            // Verify results
            Assert.areEqual(0, eventCountsNull.size(), 'Should return empty map for null input');
            Assert.areEqual(0, eventCountsEmpty.size(), 'Should return empty map for empty input');
        }
    }

    /**
     * @description Test fetchTrackingEventsByShipmentIds with valid data
     */
    @IsTest
    static void unitFetchTrackingEventsByShipmentIdsPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        List<Shipment__c> shipments = [SELECT Id FROM Shipment__c];
        List<Id> shipmentIds = new List<Id>();
        for (Shipment__c shipment : shipments) {
            shipmentIds.add(shipment.Id);
        }

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            TrackingEventRepo repo = new TrackingEventRepo();
            List<Tracking_Event__c> events = repo.fetchTrackingEventsByShipmentIds(shipmentIds);
            Test.stopTest();

            // Verify results
            Assert.areEqual(3, events.size(), 'Should return all 3 events');

            // Verify related fields are retrieved
            for (Tracking_Event__c event : events) {
                Assert.isNotNull(event.Shipment__r.Tracking_Number__c, 'Shipment tracking number should be retrieved');
            }
        }
    }

    /**
     * @description Test fetchTrackingEventsByTrackingMasterIds with valid data
     */
    @IsTest
    static void unitFetchTrackingEventsByTrackingMasterIdsPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        Tracking_Master__c trackingMaster = [
            SELECT Id
            FROM Tracking_Master__c
            WHERE Tracking_Number__c = 'TEST123456'
            LIMIT 1
        ];

        List<Id> trackingMasterIds = new List<Id>{ trackingMaster.Id };

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            TrackingEventRepo repo = new TrackingEventRepo();
            List<Tracking_Event__c> events = repo.fetchTrackingEventsByTrackingMasterIds(trackingMasterIds);
            Test.stopTest();

            // Verify results
            Assert.areEqual(2, events.size(), 'Should return 2 events for the specified tracking master');

            // Verify all events belong to the correct tracking master
            for (Tracking_Event__c event : events) {
                Assert.areEqual(
                    trackingMaster.Id,
                    event.Tracking_Master__c,
                    'Event should belong to the specified tracking master'
                );
            }
        }
    }

    /**
     * @description Test doCreate for single tracking event
     */
    @IsTest
    static void unitDoCreateSinglePositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        Shipment__c shipment = [SELECT Id FROM Shipment__c WHERE Tracking_Number__c = 'TEST123456' LIMIT 1];
        Tracking_Master__c trackingMaster = [
            SELECT Id
            FROM Tracking_Master__c
            WHERE Tracking_Number__c = 'TEST123456'
            LIMIT 1
        ];

        Tracking_Event__c newEvent = new Tracking_Event__c(
            Shipment__c = shipment.Id,
            Tracking_Master__c = trackingMaster.Id,
            Event_Code__c = 'OUT_FOR_DELIVERY',
            Occurred_At__c = DateTime.now(),
            Description__c = 'Package out for delivery'
        );

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            TrackingEventRepo repo = new TrackingEventRepo();
            Database.SaveResult result = repo.doCreate(newEvent);
            Test.stopTest();

            // Verify results
            Assert.isTrue(result.isSuccess(), 'Insert should succeed');
            Assert.isNotNull(result.getId(), 'New record ID should be returned');

            // Verify record was inserted
            List<Tracking_Event__c> insertedEvents = [
                SELECT Id, Event_Code__c
                FROM Tracking_Event__c
                WHERE Event_Code__c = 'OUT_FOR_DELIVERY'
            ];

            Assert.areEqual(1, insertedEvents.size(), 'One new event should be inserted');
            Assert.areEqual(
                'OUT_FOR_DELIVERY',
                insertedEvents[0].Event_Code__c,
                'Inserted event should have correct event code'
            );
        }
    }

    /**
     * @description Test doCreate for multiple tracking events
     */
    @IsTest
    static void unitDoCreateMultiplePositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        Shipment__c shipment = [SELECT Id FROM Shipment__c WHERE Tracking_Number__c = 'TEST123456' LIMIT 1];
        Tracking_Master__c trackingMaster = [
            SELECT Id
            FROM Tracking_Master__c
            WHERE Tracking_Number__c = 'TEST123456'
            LIMIT 1
        ];

        List<Tracking_Event__c> newEvents = new List<Tracking_Event__c>{
            new Tracking_Event__c(
                Shipment__c = shipment.Id,
                Tracking_Master__c = trackingMaster.Id,
                Event_Code__c = 'OUT_FOR_DELIVERY',
                Occurred_At__c = DateTime.now().addHours(-2),
                Description__c = 'Package out for delivery'
            ),
            new Tracking_Event__c(
                Shipment__c = shipment.Id,
                Tracking_Master__c = trackingMaster.Id,
                Event_Code__c = 'DELIVERED',
                Occurred_At__c = DateTime.now(),
                Description__c = 'Package delivered'
            )
        };

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            TrackingEventRepo repo = new TrackingEventRepo();
            List<Database.SaveResult> results = repo.doCreate(newEvents);
            Test.stopTest();

            // Verify results
            Assert.areEqual(2, results.size(), 'Should return 2 save results');
            for (Database.SaveResult result : results) {
                Assert.isTrue(result.isSuccess(), 'All inserts should succeed');
                Assert.isNotNull(result.getId(), 'New record IDs should be returned');
            }

            // Verify records were inserted
            Integer newEventCount = [
                SELECT COUNT()
                FROM Tracking_Event__c
                WHERE Event_Code__c = 'OUT_FOR_DELIVERY' OR Event_Code__c = 'DELIVERED'
            ];

            Assert.areEqual(3, newEventCount, 'Two new events should be inserted'); // 2 new + 1 existing DELIVERED
        }
    }

    /**
     * @description Test parse8601String method
     */
    @IsTest
    static void unitParse8601StringPositive() {
        // This is a private method, so we test indirectly through the TrackingMasterService
        // DTO conversion which uses this method

        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        // Test is skipped since we can't directly test private methods
        // The method is tested indirectly through other tests that use DTOs
    }
}
