public with sharing class mc_DTO_TrackingHeaders {
    @AuraEnabled
    public String key {get; set;}
    @AuraEnabled
    public String value {get; set;}
}