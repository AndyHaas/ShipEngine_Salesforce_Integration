public with sharing class mc_DTO_WebhookDetails {
    @AuraEnabled
    public mc_DTO_TrackingWebhookCreationResponse trackingWebhookCreationResponse {get; set;}
    @AuraEnabled
    public mc_DTO_TrackingErrorResponse trackingErrorResponse {get; set;}
    @AuraEnabled
    public List<mc_DTO_TrackingWebhookCreationResponse> webhookList {get; set;}
}