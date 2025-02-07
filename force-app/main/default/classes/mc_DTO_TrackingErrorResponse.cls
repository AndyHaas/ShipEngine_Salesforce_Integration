public with sharing class mc_DTO_TrackingErrorResponse {
    @AuraEnabled
    public String request_id {get; set;}
    @AuraEnabled
    public List<mc_DTO_TrackingErrorResponse> errors {get; set;}
}