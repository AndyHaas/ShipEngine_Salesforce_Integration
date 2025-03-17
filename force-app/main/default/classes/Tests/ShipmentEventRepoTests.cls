/**
 * @description Test class for ShipmentEventRepo
 * Each test method follows naming convention: type<UnitUnderTest><Positive/Negative>
 */
@IsTest
private class ShipmentEventRepoTests {
    /**
     * @description Set up test data
     */
    @TestSetup
    static void setupTestData() {
        // Create a test user
        User testUser = TestFactory.createTestUser(true, 'System Administrator');

        // Create test data as the test user
        System.runAs(testUser) {
            // Create shipment record
            Shipment__c shipment = new Shipment__c(
                Tracking_Number__c = 'SHIP789',
                Status__c = 'In Transit',
                Status_Code__c = 'IN_TRANSIT',
                Status_Description__c = 'Package in transit',
                Carrier__c = 'UPS'
            );

            insert shipment;

            // Create shipment event records
            List<Shipment_Events__c> shipmentEvents = new List<Shipment_Events__c>();

            shipmentEvents.add(
                new Shipment_Events__c(
                    Shipment__c = shipment.Id,
                    Event_Code__c = 'PICKUP',
                    Occurred_At__c = DateTime.now().addHours(-48),
                    Description__c = 'Package picked up',
                    City_Locality__c = 'New York',
                    State_Province__c = 'NY',
                    Postal_Code__c = '10001'
                )
            );

            shipmentEvents.add(
                new Shipment_Events__c(
                    Shipment__c = shipment.Id,
                    Event_Code__c = 'PROCESSING',
                    Occurred_At__c = DateTime.now().addHours(-36),
                    Description__c = 'Package processing at facility',
                    City_Locality__c = 'New York',
                    State_Province__c = 'NY',
                    Postal_Code__c = '10001'
                )
            );

            shipmentEvents.add(
                new Shipment_Events__c(
                    Shipment__c = shipment.Id,
                    Event_Code__c = 'IN_TRANSIT',
                    Occurred_At__c = DateTime.now().addHours(-24),
                    Description__c = 'Package in transit',
                    City_Locality__c = 'Chicago',
                    State_Province__c = 'IL',
                    Postal_Code__c = '60601'
                )
            );

            insert shipmentEvents;
        }
    }

    /**
     * @description Test fetchShipmentEventsByShipmentId with valid shipment ID
     */
    @IsTest
    static void unitFetchShipmentEventsByShipmentIdPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        Shipment__c shipment = [SELECT Id FROM Shipment__c WHERE Tracking_Number__c = 'SHIP789' LIMIT 1];

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ShipmentEventRepo repo = new ShipmentEventRepo();
            List<Shipment_Events__c> events = repo.fetchShipmentEventsByShipmentId(shipment.Id);
            Test.stopTest();

            // Verify results
            Assert.areEqual(3, events.size(), 'Should return all 3 events');

            // Sort events by occurred_at to verify in chronological order
            Map<DateTime, Shipment_Events__c> eventsByTime = new Map<DateTime, Shipment_Events__c>();
            for (Shipment_Events__c event : events) {
                eventsByTime.put(event.Occurred_At__c, event);
            }

            List<DateTime> orderedTimes = new List<DateTime>(eventsByTime.keySet());
            orderedTimes.sort();

            // Verify first event (earliest)
            Shipment_Events__c firstEvent = eventsByTime.get(orderedTimes[0]);
            Assert.areEqual('PICKUP', firstEvent.Event_Code__c, 'First event should be PICKUP');
            Assert.areEqual('New York', firstEvent.City_Locality__c, 'First event city should match');

            // Verify third event (latest)
            Shipment_Events__c lastEvent = eventsByTime.get(orderedTimes[2]);
            Assert.areEqual('IN_TRANSIT', lastEvent.Event_Code__c, 'Last event should be IN_TRANSIT');
            Assert.areEqual('Chicago', lastEvent.City_Locality__c, 'Last event city should match');

            // Verify all events have shipment information
            for (Shipment_Events__c event : events) {
                Assert.areEqual(shipment.Id, event.Shipment__c, 'Event should be associated with the correct shipment');
                Assert.isNotNull(event.Shipment__r.Tracking_Number__c, 'Shipment tracking number should be retrieved');
            }
        }
    }

    /**
     * @description Test fetchShipmentEventsByShipmentId with non-existent shipment ID
     */
    @IsTest
    static void unitFetchShipmentEventsByShipmentIdNonexistentPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        Id nonExistentId = IdFactory.get('Shipment__c');

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ShipmentEventRepo repo = new ShipmentEventRepo();
            List<Shipment_Events__c> events = repo.fetchShipmentEventsByShipmentId(nonExistentId);
            Test.stopTest();

            // Verify results
            Assert.areEqual(0, events.size(), 'Should return empty list for non-existent shipment ID');
        }
    }

    /**
     * @description Test doCreate for single shipment event
     */
    @IsTest
    static void unitDoCreateSinglePositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        Shipment__c shipment = [SELECT Id FROM Shipment__c WHERE Tracking_Number__c = 'SHIP789' LIMIT 1];

        Shipment_Events__c newEvent = new Shipment_Events__c(
            Shipment__c = shipment.Id,
            Event_Code__c = 'OUT_FOR_DELIVERY',
            Occurred_At__c = DateTime.now(),
            Description__c = 'Package out for delivery',
            City_Locality__c = 'Dallas',
            State_Province__c = 'TX',
            Postal_Code__c = '75201'
        );

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ShipmentEventRepo repo = new ShipmentEventRepo();
            Database.SaveResult result = repo.doCreate(newEvent);
            Test.stopTest();

            // Verify results
            Assert.isTrue(result.isSuccess(), 'Insert should succeed');
            Assert.isNotNull(result.getId(), 'New record ID should be returned');

            // Verify record was inserted
            List<Shipment_Events__c> insertedEvents = [
                SELECT Id, Event_Code__c, City_Locality__c
                FROM Shipment_Events__c
                WHERE Event_Code__c = 'OUT_FOR_DELIVERY'
            ];

            Assert.areEqual(1, insertedEvents.size(), 'One new event should be inserted');
            Assert.areEqual(
                'OUT_FOR_DELIVERY',
                insertedEvents[0].Event_Code__c,
                'Inserted event should have correct event code'
            );
            Assert.areEqual('Dallas', insertedEvents[0].City_Locality__c, 'Inserted event should have correct city');
        }
    }

    /**
     * @description Test doCreate for multiple shipment events
     */
    @IsTest
    static void unitDoCreateMultiplePositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        Shipment__c shipment = [SELECT Id FROM Shipment__c WHERE Tracking_Number__c = 'SHIP789' LIMIT 1];

        List<Shipment_Events__c> newEvents = new List<Shipment_Events__c>{
            new Shipment_Events__c(
                Shipment__c = shipment.Id,
                Event_Code__c = 'OUT_FOR_DELIVERY',
                Occurred_At__c = DateTime.now().addHours(-2),
                Description__c = 'Package out for delivery',
                City_Locality__c = 'Dallas',
                State_Province__c = 'TX',
                Postal_Code__c = '75201'
            ),
            new Shipment_Events__c(
                Shipment__c = shipment.Id,
                Event_Code__c = 'DELIVERED',
                Occurred_At__c = DateTime.now(),
                Description__c = 'Package delivered',
                City_Locality__c = 'Dallas',
                State_Province__c = 'TX',
                Postal_Code__c = '75201'
            )
        };

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ShipmentEventRepo repo = new ShipmentEventRepo();
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
                FROM Shipment_Events__c
                WHERE Event_Code__c = 'OUT_FOR_DELIVERY' OR Event_Code__c = 'DELIVERED'
            ];

            Assert.areEqual(2, newEventCount, 'Two new events should be inserted');
        }
    }
}
