/**
 * @description Tests for ShipStationTrackingEventDTO
 * Each test method follows naming convention: type<UnitUnderTest><Positive/Negative>
 */
@IsTest
private class ShipStationTrackingEventDTOTests {
    /**
     * @description Sets up test data
     */
    @TestSetup
    static void setupTestData() {
        User testUser = TestFactory.createTestUser(true, 'Standard User');
    }

    /**
     * @description Tests getValidStatusCode method with valid two-letter codes
     */
    @IsTest
    static void functionalGetValidStatusCodeTwoLetterCodesPositive() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            // Test valid two-letter codes
            String result1 = ShipStationTrackingEventDTO.getValidStatusCode('DE');
            String result2 = ShipStationTrackingEventDTO.getValidStatusCode('it');
            String result3 = ShipStationTrackingEventDTO.getValidStatusCode('ac');

            // Assert results
            Assert.areEqual('DE', result1, 'Should return uppercase DE for DE');
            Assert.areEqual('IT', result2, 'Should return uppercase IT for it');
            Assert.areEqual('AC', result3, 'Should return uppercase AC for ac');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getValidStatusCode method with full mapped status names
     */
    @IsTest
    static void functionalGetValidStatusCodeFullStatusNamesPositive() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            // Test full status names that are mapped
            String result1 = ShipStationTrackingEventDTO.getValidStatusCode('DELIVERED');
            String result2 = ShipStationTrackingEventDTO.getValidStatusCode('in_transit');
            String result3 = ShipStationTrackingEventDTO.getValidStatusCode('Delivery_Attempt');

            // Assert results
            Assert.areEqual('DE', result1, 'Should return DE for DELIVERED');
            Assert.areEqual('IT', result2, 'Should return IT for in_transit');
            Assert.areEqual('AT', result3, 'Should return AT for Delivery_Attempt');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getValidStatusCode method with partial status descriptions
     */
    @IsTest
    static void functionalGetValidStatusCodePartialDescriptionsPositive() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            // Test partial descriptions
            String result1 = ShipStationTrackingEventDTO.getValidStatusCode('DELIVERED');
            String result2 = ShipStationTrackingEventDTO.getValidStatusCode('IN TRANSIT');
            String result3 = ShipStationTrackingEventDTO.getValidStatusCode('DELIVERY ATTEMPT');

            // Assert results
            Assert.areEqual('DE', result1, 'Should return DE for description containing DELIVERED');
            Assert.areEqual('IT', result2, 'Should return IT for description containing IN TRANSIT');
            Assert.areEqual('AT', result3, 'Should return AT for description containing DELIVERY ATTEMPT');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getValidStatusCode method with null or empty input
     */
    @IsTest
    static void functionalGetValidStatusCodeNullOrEmptyNegative() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            // Test null or empty input
            String result1 = ShipStationTrackingEventDTO.getValidStatusCode(null);
            String result2 = ShipStationTrackingEventDTO.getValidStatusCode('');
            String result3 = ShipStationTrackingEventDTO.getValidStatusCode('   ');

            // Assert results
            Assert.areEqual('UN', result1, 'Should return UN for null input');
            Assert.areEqual('UN', result2, 'Should return UN for empty input');
            Assert.areEqual('UN', result3, 'Should return UN for blank input');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getValidStatusCode method with unmapped status codes
     */
    @IsTest
    static void functionalGetValidStatusCodeUnmappedCodesNegative() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            // Test unmapped values
            String result1 = ShipStationTrackingEventDTO.getValidStatusCode('RANDOM_STATUS');
            String result2 = ShipStationTrackingEventDTO.getValidStatusCode('Package dispatched');
            String result3 = ShipStationTrackingEventDTO.getValidStatusCode('XX');

            // Assert results
            Assert.areEqual('UN', result1, 'Should return UN for unmapped status code');
            Assert.areEqual('UN', result2, 'Should return UN for unmapped description');
            Assert.areEqual('XX', result3, 'Should return XX as is since it is already a two-letter code');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getValidStatusCode method with delivered_to_collection_location
     */
    @IsTest
    static void functionalGetValidStatusCodeCollectionLocationPositive() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            // Test delivered to collection location
            String result1 = (String) ShipStationTrackingEventDTO.getValidStatusCode(
                'DELIVERED_TO_COLLECTION_LOCATION'
            );
            String result2 = (String) ShipStationTrackingEventDTO.getValidStatusCode(
                'Delivered to Collection Location'
            );

            // Assert results
            Assert.areEqual('SP', result1, 'Should return SP for DELIVERED_TO_COLLECTION_LOCATION');
            Assert.areEqual('SP', result2, 'Should return SP for "Delivered to Collection Location"');
        }
        Test.stopTest();
    }

    /**
     * @description Tests the toShipmentEvent method for correct status code handling
     */
    @IsTest
    static void functionalToShipmentEventStatusCodeHandlingPositive() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        // Create test data
        Account testAccount = (Account) TestFactory.createSObject(new Account(Name = 'Test Account'));
        Shipment__c testShipment = new Shipment__c(
            Account__c = testAccount.Id,
            Tracking_Number__c = '1Z999AA10123456789',
            Carrier__c = 'UPS'
        );
        insert testShipment;

        Test.startTest();
        System.runAs(testUser) {
            // Create DTO with status_code
            ShipStationTrackingEventDTO dto = new ShipStationTrackingEventDTO();
            dto.status_code = 'DE';
            dto.occurred_at = String.valueOf(Datetime.now());
            dto.description = 'Package delivered';
            dto.city_locality = 'New York';
            dto.state_province = 'NY';
            dto.postal_code = '10001';

            // Test with DTO status code
            Shipment_Events__c event1 = dto.toShipmentEvent(testShipment.Id, 'UN');
            Assert.areEqual('DE', event1.Status_Code__c, 'Should use status_code from DTO when available');

            // Test fallback to shipment status code
            dto.status_code = null;
            Shipment_Events__c event2 = dto.toShipmentEvent(testShipment.Id, 'IT');
            Assert.areEqual(
                'IT',
                event2.Status_Code__c,
                'Should fallback to shipment status code when DTO status_code is null'
            );
        }
        Test.stopTest();
    }
}
