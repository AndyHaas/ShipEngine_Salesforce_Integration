public with sharing class ShipStationTrackingHeadersDTO {
    @AuraEnabled
    public String key { get; set; }
    @AuraEnabled
    public String value { get; set; }
}
