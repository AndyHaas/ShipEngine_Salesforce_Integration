@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class ShipStationTrackingResponseDTO {
    @AuraEnabled
    public String resouce_url;
    @AuraEnabled
    public String resource_type;
    @AuraEnabled
    public ShipStationTrackingDataDTO data;
}
