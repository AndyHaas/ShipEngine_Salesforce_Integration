public with sharing class mc_DTO_TrackingData {
    @AuraEnabled
    public String tracking_number;
    
    @AuraEnabled
    public String status_code;
    
    @AuraEnabled
    public String status_detail_code;
    
    @AuraEnabled
    public String status_detail_description;
    
    @AuraEnabled
    public String carrier_detail_code;

    @AuraEnabled
    public String carrier_code;

    @AuraEnabled
    public String carrier_id;
    
    @AuraEnabled
    public String status_description;
    
    @AuraEnabled
    public String carrier_status_code;
    
    @AuraEnabled
    public String carrier_status_description;
    
    @AuraEnabled
    public String ship_date;
    
    @AuraEnabled
    public String estimated_delivery_date;
    
    @AuraEnabled
    public String actual_delivery_date;
    
    @AuraEnabled
    public String exception_description;
    
    @AuraEnabled
    public List<mc_DTO_TrackingEvent> events;
}