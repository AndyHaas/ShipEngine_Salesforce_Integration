/**
 * @description Repository class for handling ShipEngine authentication settings
 */
public virtual with sharing class ShipEngineAuthRepo extends BaseRepo {
    /**
     * @description Constructor initializing with ShipEngineAuth__c SObject type
     */
    public ShipEngineAuthRepo() {
        super(ShipEngineAuth__c.SObjectType, true);
    }

    /**
     * @description Saves or updates the API key in the ShipEngineAuth__c custom setting
     * @justification This method has to update a custom setting's orgDefaults record, which requires system context.
     * @param apiKey The API key to save
     */
    public void saveApiKey(String apiKey) {
        ShipEngineAuth__c setting = ShipEngineAuth__c.getOrgDefaults();
        setting.API_Key__c = apiKey;
        this.doUpsertUnsafe(setting);
    }
}
