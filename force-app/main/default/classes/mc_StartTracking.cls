global class mc_StartTracking {
@InvocableMethod(label='Start Tracking' category='Tracking')
    global static List<Response> startTrackingDetails(List<trackingDetails> trackingDetailsList) {
        List<Response> responses = new List<Response>();

        mc_TrackingCallouts trackingCalloutInstance = new mc_TrackingCallouts(); 

        for (trackingDetails details : trackingDetailsList) {
            System.debug('Tracking Number: ' + details.trackingNumber);
            System.debug('Carrier Code: ' + details.trackingNumberCarrierCode.toLowerCase());
            if(details.trackingNumberCarrierCode != null && details.trackingNumber != null){
                // Add the response to the list
                Response rsp = new Response();
                rsp.startTrackingResponse = trackingCalloutInstance.startTrackingRequest(details.trackingNumber, details.trackingNumberCarrierCode.toLowerCase());
                responses.add(rsp);
                System.debug('Response: ' + rsp);
            }
        }
        System.debug('Responses: ' + responses);
        return responses;
    }

    global class trackingDetails {
        @InvocableVariable(label='Tracking Number' required=true)
        global String trackingNumber;
        @InvocableVariable(label='Carrier Code' required=true)
        global String trackingNumberCarrierCode;
    }

    global class Response {
        @InvocableVariable(label='Tracking Response' required=true)
        global mc_DTO_WebhookDetails startTrackingResponse;
    }
}
