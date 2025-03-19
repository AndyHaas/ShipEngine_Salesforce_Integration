/**
 * @description This class is responsible for fetching webhook configuration details from the ShipEngine_Webhook__mdt custom metadata type.
 * It's not wrapping a dedicated sObject, so this repo doesn't extend BaseRepo.
 */
public virtual with sharing class ShipEngineWebhookConfigurationRepo {
    /**
     * @description Gets webhook configuration by event type
     * @param type Event type to filter by (e.g., 'track', 'shipment')
     * @return ShipEngine_Webhook__mdt The matching webhook configuration or null if not found
     */
    public virtual ShipEngine_Webhook__mdt getWebhookDetailsByType(String type) {
        List<ShipEngine_Webhook__mdt> webhookConfigurations = ShipEngine_Webhook__mdt.getAll().values();
        for (ShipEngine_Webhook__mdt webhookType : webhookConfigurations) {
            if (webhookType.Webhook_Event_Type__c == type) {
                return webhookType;
            }
        }
        return null;
    }
}
