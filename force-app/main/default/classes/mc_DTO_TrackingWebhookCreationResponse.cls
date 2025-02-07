public with sharing class mc_DTO_TrackingWebhookCreationResponse {
    @AuraEnabled
    public String webhook_id;
    @AuraEnabled
    public String url;
    @AuraEnabled
    public String event;
    @AuraEnabled
    public List<mc_DTO_TrackingHeaders> headers;
}