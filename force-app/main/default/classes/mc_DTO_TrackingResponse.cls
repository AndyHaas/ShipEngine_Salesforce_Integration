public with sharing class mc_DTO_TrackingResponse {
    @AuraEnabled
    public String resouce_url;
    @AuraEnabled
    public String resource_type;
    @AuraEnabled
    public mc_DTO_TrackingData data;
}