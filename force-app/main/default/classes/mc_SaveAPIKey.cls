public class mc_SaveAPIKey {
	/* Save the API key. */
 @Auraenabled
    public static void saveApiKey(String apiKey){
        try{
        	ShipEngineAuth__c setting = ShipEngineAuth__c.getOrgDefaults();
        	setting.API_Key__c = apiKey;
        	upsert setting;    
        }catch(exception e){
            System.debug(e.getMessage() +' : '+e.getLineNumber());
        }
        
    }
}