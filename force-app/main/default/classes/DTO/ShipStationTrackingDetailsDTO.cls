public class ShipStationTrackingDetailsDTO {
    @AuraEnabled
    public ShipStationTrackingResponseDTO trackingResponse { get; set; }
    @AuraEnabled
    public ShipStationTrackingErrorDTO trackingErrorResponse { get; set; }
    @AuraEnabled
    public String json { get; set; }
}
