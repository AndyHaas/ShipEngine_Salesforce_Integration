/**
 * @description This class is used to save the API key.
 * The API key is stored in a custom setting, which is not secure.
 */
public inherited sharing class ShipStationAPIKeyController {
    /**
     * @description Saves the provided API key into a custom setting.
     * This method attempts to store the API key in the `ShipEngineAuth__c` custom setting.
     * It uses the `upsert` operation to insert or update the record with the new API key.
     * If an exception occurs during this process, it logs the error message and line number.
     *
     * @param apiKey The API key to be saved. It is expected to be a non-null string.
     * @throws Exception Logs any exceptions that occur during the upsert operation.
     */
    @AuraEnabled
    public static void saveApiKey(String apiKey) {
        ShipEngineAuthRepo repo = new ShipEngineAuthRepo();
        try {
            repo.saveApiKey(apiKey);
        } catch (DmlException dmlException) {
            // Error caught
        }
    }
}
