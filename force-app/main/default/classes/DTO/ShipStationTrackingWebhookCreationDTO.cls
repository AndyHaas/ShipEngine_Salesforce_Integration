@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class ShipStationTrackingWebhookCreationDTO {
    @AuraEnabled
    public String webhook_id;
    @AuraEnabled
    public String url;
    @AuraEnabled
    public String event;
    @AuraEnabled
    public List<ShipStationTrackingHeadersDTO> headers;
}
