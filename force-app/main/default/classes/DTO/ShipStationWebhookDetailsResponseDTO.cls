public with sharing class ShipStationWebhookDetailsResponseDTO {
    @AuraEnabled
    public ShipStationTrackingWebhookCreationDTO trackingWebhookCreationResponse { get; set; }
    @AuraEnabled
    public ShipStationTrackingErrorDTO trackingErrorResponse { get; set; }
    @AuraEnabled
    public List<ShipStationTrackingWebhookCreationDTO> webhookList { get; set; }
}
