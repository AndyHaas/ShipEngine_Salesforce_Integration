/**
 * @description This REST resource class handles incoming HTTP POST requests (Webhooks) for tracking events.
 * It processes the request body, deserializes it into a DTO, and inserts the data into the `Tracking_Master__c` object.
 */
@RestResource(UrlMapping='/tracking/events/*')
global inherited sharing class TrackingWebhookApexHandler {
    @SuppressWarnings('PMD.FieldNamingConventions')
    private static final TrackingMasterRepo trackingMasterRepo = new TrackingMasterRepo();

    /**
     * @description Handles HTTP POST requests by parsing the request body and inserting tracking data.
     * It deserializes the JSON payload into a `mc_DTO_TrackingResponse` object and creates a new `Tracking_Master__c` record.
     * The method sets the response status code to 201 upon successful insertion.
     *
     * Because we're dealing with an unauthenticated rest call, this method does little more than save the record.
     * Main processing happens in a queueable job triggered by the insert of this record.
     *
     * @throws Exception Logs any exceptions that occur during processing, such as deserialization errors or DML exceptions.
     */
    @HttpPost
    global static void handlePost() {
        Boolean dmlException = false;
        try {
            RestRequest req = RestContext.request;
            String bodyString = req.requestBody.toString();
            ShipStationTrackingResponseDTO trackingData = (ShipStationTrackingResponseDTO) JSON.deserialize(
                bodyString,
                ShipStationTrackingResponseDTO.class
            );
            // This call translates the DTO to the Tracking_Master__c object
            Database.SaveResult results = trackingMasterRepo.createTrackingMasterRecordFromDTO(trackingData);
            // If we have an error, then we can return 207 - Mixed Success
            if (!results.isSuccess()) {
                dmlException = true;
            }

            RestContext.response.statusCode = dmlException ? 207 : 201;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Generic Error Occurred processing webhook: ' + e.getStackTraceString());
            RestContext.response.statusCode = 500;
            return;
        }
    }
}
