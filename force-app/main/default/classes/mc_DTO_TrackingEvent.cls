public with sharing class mc_DTO_TrackingEvent {
    @AuraEnabled
    public String occurred_at;
    
    @AuraEnabled
    public String carrier_occurred_at;
    
    @AuraEnabled
    public String description;
    
    @AuraEnabled
    public String city_locality;
    
    @AuraEnabled
    public String state_province;
    
    @AuraEnabled
    public String postal_code;
    
    @AuraEnabled
    public String country_code;
    
    @AuraEnabled
    public String company_name;
    
    @AuraEnabled
    public String signer;
    
    @AuraEnabled
    public String event_code;
    
    @AuraEnabled
    public String carrier_status_description;
    
    @AuraEnabled
    public String carrier_detail_code;
    
    @AuraEnabled
    public String status_code;
    
    @AuraEnabled
    public String status_detail_code;
    
    @AuraEnabled
    public String status_description;
    
    @AuraEnabled
    public String status_detail_description;
    
    @AuraEnabled
    public Decimal latitude;
    
    @AuraEnabled
    public Decimal longitude;
}