@IsTest
public class ShipStationAPIKeyControllerTests {
    /* Test for upserting API key in custom setting. */
    @IsTest
    public static void testUpsertCustomSettingPositive() {
        User testUser = TestFactory.createTestUser(false, 'System Administrator');
        System.runAs(testUser) {
            ShipStationAPIKeyController.saveApiKey('asd');
        }
        Assert.areEqual(
            'asd',
            ShipEngineAuth__c.getOrgDefaults().API_Key__c,
            'Assert that the API key is the same as the API key in the custom setting.'
        );
    }
}
