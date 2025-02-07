public class mc_DTO_TrackingDetails {
    @AuraEnabled
    public mc_DTO_TrackingResponse trackingResponse {get; set;}
    @AuraEnabled
    public mc_DTO_TrackingErrorResponse trackingErrorResponse {get; set;}
    @AuraEnabled
    public String json {get; set;}
}