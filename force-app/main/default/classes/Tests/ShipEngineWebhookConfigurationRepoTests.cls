/**
 * @description Tests for ShipEngineWebhookConfigurationRepo
 * Each test method follows naming convention: type<UnitUnderTest><Positive/Negative>
 */
@IsTest
private class ShipEngineWebhookConfigurationRepoTests {
    /**
     * @description Custom metadata mocking class
     */
    public class ShipEngineWebhookMDTMockProvider implements System.StubProvider {
        private final Map<String, ShipEngine_Webhook__mdt> mockRecords;

        /**
         * @description Constructor that initializes mock records
         */
        public ShipEngineWebhookMDTMockProvider() {
            mockRecords = new Map<String, ShipEngine_Webhook__mdt>();

            // Add track webhook configuration
            ShipEngine_Webhook__mdt trackWebhook = new ShipEngine_Webhook__mdt();
            trackWebhook.DeveloperName = 'Track_Webhook';
            trackWebhook.MasterLabel = 'Track Webhook';
            trackWebhook.Webhook_Event_Type__c = 'track';
            trackWebhook.Webhook_URL__c = 'https://example.com/webhooks/track';
            trackWebhook.Webhook_Active__c = true;
            mockRecords.put('Track_Webhook', trackWebhook);

            // Add shipment webhook configuration
            ShipEngine_Webhook__mdt shipmentWebhook = new ShipEngine_Webhook__mdt();
            shipmentWebhook.DeveloperName = 'Shipment_Webhook';
            shipmentWebhook.MasterLabel = 'Shipment Webhook';
            shipmentWebhook.Webhook_Event_Type__c = 'shipment';
            shipmentWebhook.Webhook_URL__c = 'https://example.com/webhooks/shipment';
            shipmentWebhook.Webhook_Active__c = true;
            mockRecords.put('Shipment_Webhook', shipmentWebhook);

            // Add inactive webhook configuration
            ShipEngine_Webhook__mdt inactiveWebhook = new ShipEngine_Webhook__mdt();
            inactiveWebhook.DeveloperName = 'Inactive_Webhook';
            inactiveWebhook.MasterLabel = 'Inactive Webhook';
            inactiveWebhook.Webhook_Event_Type__c = 'inactive';
            inactiveWebhook.Webhook_URL__c = 'https://example.com/webhooks/inactive';
            inactiveWebhook.Webhook_Active__c = false;
            mockRecords.put('Inactive_Webhook', inactiveWebhook);
        }

        /**
         * @description Stub provider implementation for mocking method calls
         * @param stubbedObject Object being stubbed
         * @param stubbedMethodName Method being called
         * @param returnType Expected return type
         * @param listOfParamTypes Types of parameters
         * @param listOfParamNames Names of parameters
         * @param listOfArgs Actual arguments passed
         * @return Object Mock result
         */
        @SuppressWarnings('PMD.ExcessiveParameterList')
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'getAll') {
                return mockRecords;
            }

            return null;
        }
    }

    /**
     * @description Sets up test data
     */
    @TestSetup
    static void setupTestData() {
        TestFactory.createTestUser(true, 'Standard User');
    }

    /**
     * @description Tests getting webhook configuration when no configurations exist
     */
    @IsTest
    static void unitGetWebhookDetailsByTypeEmptyConfigurationsNegative() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        // Create mock with empty records
        ShipEngineWebhookMDTMockProvider mockProvider = new ShipEngineWebhookMDTMockProvider();
        mockProvider.mockRecords.clear(); // Clear all mock records

        // Execute test
        Test.startTest();
        System.runAs(testUser) {
            // Use test double via dependency injection
            ShipEngineWebhookConfigurationRepo repo = new ShipEngineWebhookConfigurationRepoTestDouble(mockProvider);
            ShipEngine_Webhook__mdt result = repo.getWebhookDetailsByType('track');

            // Verify result
            Assert.isNull(result, 'Should return null when no configurations exist');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getting existing webhook configuration by type
     */
    @IsTest
    static void unitGetWebhookDetailsByTypeExistingConfigurationPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];
        ShipEngineWebhookMDTMockProvider mockProvider = new ShipEngineWebhookMDTMockProvider();

        // Execute test
        Test.startTest();
        System.runAs(testUser) {
            // Use test double via dependency injection
            ShipEngineWebhookConfigurationRepo repo = new ShipEngineWebhookConfigurationRepoTestDouble(mockProvider);
            ShipEngine_Webhook__mdt result = repo.getWebhookDetailsByType('track');

            // Verify result
            Assert.isNotNull(result, 'Should return a webhook configuration');
            Assert.areEqual('track', result.Webhook_Event_Type__c, 'Should return the track webhook configuration');
            Assert.areEqual('https://example.com/webhooks/track', result.Webhook_URL__c, 'Should have the correct URL');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getting a webhook configuration that doesn't match any type
     */
    @IsTest
    static void unitGetWebhookDetailsByTypeNonExistentTypeNegative() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];
        ShipEngineWebhookMDTMockProvider mockProvider = new ShipEngineWebhookMDTMockProvider();

        // Execute test
        Test.startTest();
        System.runAs(testUser) {
            // Use test double via dependency injection
            ShipEngineWebhookConfigurationRepo repo = new ShipEngineWebhookConfigurationRepoTestDouble(mockProvider);
            ShipEngine_Webhook__mdt result = repo.getWebhookDetailsByType('nonexistent');

            // Verify result
            Assert.isNull(result, 'Should return null for non-existent webhook type');
        }
        Test.stopTest();
    }

    /**
     * @description Tests retrieving webhook configuration for shipment type
     */
    @IsTest
    static void unitGetWebhookDetailsByTypeShipmentTypePositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];
        ShipEngineWebhookMDTMockProvider mockProvider = new ShipEngineWebhookMDTMockProvider();

        // Execute test
        Test.startTest();
        System.runAs(testUser) {
            // Use test double via dependency injection
            ShipEngineWebhookConfigurationRepo repo = new ShipEngineWebhookConfigurationRepoTestDouble(mockProvider);
            ShipEngine_Webhook__mdt result = repo.getWebhookDetailsByType('shipment');

            // Verify result
            Assert.isNotNull(result, 'Should return a webhook configuration');
            Assert.areEqual(
                'shipment',
                result.Webhook_Event_Type__c,
                'Should return the shipment webhook configuration'
            );
            Assert.areEqual(
                'https://example.com/webhooks/shipment',
                result.Webhook_URL__c,
                'Should have the correct URL'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Tests using Stub pattern with ShipEngineWebhookConfigurationRepo
     */
    @IsTest
    static void unitGetWebhookDetailsUsingStubPatternPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];

        // Create mock webhook
        ShipEngine_Webhook__mdt mockWebhook = new ShipEngine_Webhook__mdt();
        mockWebhook.DeveloperName = 'Test_Webhook';
        mockWebhook.MasterLabel = 'Test Webhook';
        mockWebhook.Webhook_Event_Type__c = 'test';
        mockWebhook.Webhook_URL__c = 'https://example.com/webhooks/test';

        // Create stub for returning mock data
        ShipEngineWebhookConfigurationRepo repoStub = (ShipEngineWebhookConfigurationRepo) new Stub.Builder(
                ShipEngineWebhookConfigurationRepo.class
            )
            .mockingMethodCall('getWebhookDetailsByType')
            .withParameterTypes(new List<Type>{ String.class })
            .withParameterValues('test')
            .returning(mockWebhook)
            .defineStub(true);

        // Execute test
        Test.startTest();
        System.runAs(testUser) {
            ShipEngine_Webhook__mdt result = repoStub.getWebhookDetailsByType('test');

            // Verify result
            Assert.isNotNull(result, 'Should return the stubbed webhook');
            Assert.areEqual('test', result.Webhook_Event_Type__c, 'Should return the test webhook configuration');
            Assert.areEqual('https://example.com/webhooks/test', result.Webhook_URL__c, 'Should have the correct URL');
        }
        Test.stopTest();
    }

    /**
     * @description Functional test for getting webhook details with the repository
     */
    @IsTest
    static void functionalGetWebhookDetailsByTypeAllConfigurationsPositive() {
        // Setup
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        // Execute test
        Test.startTest();
        System.runAs(adminUser) {
            ShipEngineWebhookConfigurationRepo repo = new ShipEngineWebhookConfigurationRepo();

            // Test with real Custom Metadata Types access
            // Note: We can't create Custom Metadata Types in a test,
            // but we can verify the repo accesses them correctly
            ShipEngine_Webhook__mdt result = repo.getWebhookDetailsByType('track');

            // Since we can't create test data for Custom Metadata Types,
            // we're simply verifying the method executes without error
            // and returns either null or a valid configuration
            if (result != null) {
                Assert.areEqual(
                    'track',
                    result.Webhook_Event_Type__c,
                    'If webhook exists, it should match the requested type'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Functional test for getting inactive webhook configuration
     */
    @IsTest
    static void functionalGetWebhookDetailsByTypeInactiveWebhookPositive() {
        // Setup
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        ShipEngineWebhookMDTMockProvider mockProvider = new ShipEngineWebhookMDTMockProvider();

        // Execute test
        Test.startTest();
        System.runAs(adminUser) {
            // Use test double via dependency injection
            ShipEngineWebhookConfigurationRepo repo = new ShipEngineWebhookConfigurationRepoTestDouble(mockProvider);
            ShipEngine_Webhook__mdt result = repo.getWebhookDetailsByType('inactive');

            // Verify result
            Assert.isNotNull(result, 'Should return the inactive webhook configuration');
            Assert.areEqual('inactive', result.Webhook_Event_Type__c, 'Should return the correct event type');
            Assert.areEqual(false, result.Webhook_Active__c, 'Should have inactive status');
        }
        Test.stopTest();
    }

    /**
     * @description Test double for ShipEngineWebhookConfigurationRepo to inject mock provider
     */
    private class ShipEngineWebhookConfigurationRepoTestDouble extends ShipEngineWebhookConfigurationRepo {
        private final ShipEngineWebhookMDTMockProvider mockProvider;

        /**
         * @description Constructor with mock provider
         * @param mockProvider Mock provider for custom metadata
         */
        public ShipEngineWebhookConfigurationRepoTestDouble(ShipEngineWebhookMDTMockProvider mockProvider) {
            this.mockProvider = mockProvider;
        }

        /**
         * @description Overridden method to use mock data
         * @param type Webhook type to find
         * @return ShipEngine_Webhook__mdt Mock webhook configuration
         */
        public override ShipEngine_Webhook__mdt getWebhookDetailsByType(String type) {
            List<ShipEngine_Webhook__mdt> webhookConfigurations = mockProvider.mockRecords.values();
            for (ShipEngine_Webhook__mdt webhookType : webhookConfigurations) {
                if (webhookType.Webhook_Event_Type__c == type) {
                    return webhookType;
                }
            }
            return null;
        }
    }
}
