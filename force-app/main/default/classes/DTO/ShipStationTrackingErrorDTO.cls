public with sharing class ShipStationTrackingErrorDTO {
    @AuraEnabled
    public String request_id { get; set; }
    @AuraEnabled
    public List<ShipStationTrackingErrorDTO> errors { get; set; }
}
