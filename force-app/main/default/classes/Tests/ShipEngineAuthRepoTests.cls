/**
 * @description Tests for ShipEngineAuthRepo
 * Each test method follows naming convention: type<UnitUnderTest><Positive/Negative>
 */
@IsTest
private class ShipEngineAuthRepoTests {
    /**
     * @description Sets up test data
     */
    @TestSetup
    static void setupTestData() {
        // Create test users with different permission levels
        TestFactory.createTestUser(true, 'System Administrator');
        TestFactory.createTestUser(true, 'Standard User');
    }

    /**
     * @description Tests saving API key successfully as System Administrator
     */
    @IsTest
    static void unitSaveApiKeyAsAdminPositive() {
        // Setup
        User adminUser = [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE
            LIMIT 1
        ];

        String testApiKey = 'test_api_key_123456';

        // Execute test
        Test.startTest();
        System.runAs(adminUser) {
            ShipEngineAuthRepo repo = new ShipEngineAuthRepo();
            repo.saveApiKey(testApiKey);
        }
        Test.stopTest();

        // Verify results
        ShipEngineAuth__c setting = ShipEngineAuth__c.getOrgDefaults();
        Assert.isNotNull(setting, 'Custom setting should exist');
        Assert.areEqual(testApiKey, setting.API_Key__c, 'API key should match test value');
    }

    /**
     * @description Tests updating an existing API key
     */
    @IsTest
    static void unitUpdateExistingApiKeyPositive() {
        // Setup
        User adminUser = TestFactory.createTestUser(true, 'System Administrator');
        TestFactory.assignPermSetToUser(adminUser, 'R_W_access_to_ShipEngineAuth_c');

        String initialApiKey = 'initial_key_123';
        String updatedApiKey = 'updated_key_456';

        // Create initial setting
        System.runAs(adminUser) {
            ShipEngineAuthRepo repo = new ShipEngineAuthRepo();
            repo.saveApiKey(initialApiKey);

            // Verify initial setting
            ShipEngineAuth__c setting = ShipEngineAuth__c.getOrgDefaults();
            Assert.areEqual(initialApiKey, setting.API_Key__c, 'Initial API key should be set correctly');
        }

        // Execute test - update the API key
        Test.startTest();
        System.runAs(adminUser) {
            ShipEngineAuthRepo repo = new ShipEngineAuthRepo();
            try {
                repo.saveApiKey(updatedApiKey);
            } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
            }
        }
        Test.stopTest();

        // Verify results
        ShipEngineAuth__c updatedSetting = ShipEngineAuth__c.getOrgDefaults();
        Assert.areEqual(updatedApiKey, updatedSetting.API_Key__c, 'API key should be updated to new value');
    }

    /**
     * @description Tests saving empty API key
     */
    @IsTest
    static void unitSaveEmptyApiKeyPositive() {
        // Setup
        User adminUser = TestFactory.createTestUser(false, 'System Administrator');

        String emptyApiKey = '';

        // Execute test
        Test.startTest();
        System.runAs(adminUser) {
            ShipEngineAuthRepo repo = new ShipEngineAuthRepo();
            repo.saveApiKey(emptyApiKey);
        }
        Test.stopTest();

        // Verify results
        ShipEngineAuth__c setting = ShipEngineAuth__c.getOrgDefaults();
        Assert.isNull(setting.API_Key__c, 'Empty API key should be saved');
    }

    /**
     * @description Tests saving null API key
     */
    @IsTest
    static void unitSaveNullApiKeyPositive() {
        // Setup
        User adminUser = [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE
            LIMIT 1
        ];

        String nullApiKey = null;

        // Execute test
        Test.startTest();
        System.runAs(adminUser) {
            ShipEngineAuthRepo repo = new ShipEngineAuthRepo();
            repo.saveApiKey(nullApiKey);
        }
        Test.stopTest();

        // Verify results
        ShipEngineAuth__c setting = ShipEngineAuth__c.getOrgDefaults();
        Assert.areEqual(nullApiKey, setting.API_Key__c, 'Null API key should be saved as null');
    }

    /**
     * @description Mock ShipEngineAuthRepo to verify BaseRepo method calls
     */
    private class MockShipEngineAuthRepo extends ShipEngineAuthRepo {
        public Boolean doUpsertCalled = false;
        public String savedApiKey;

        /**
         * @description Override doUpsert to track calls
         * @param record The record to upsert
         * @return Database.UpsertResult Null for testing purposes
         */
        public override Database.UpsertResult doUpsert(SObject record) {
            doUpsertCalled = true;
            ShipEngineAuth__c setting = (ShipEngineAuth__c) record;
            savedApiKey = setting.API_Key__c;
            // Don't actually perform the DML for this test
            return null;
        }
    }
}
