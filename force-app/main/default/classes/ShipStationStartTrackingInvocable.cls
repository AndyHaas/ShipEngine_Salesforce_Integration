/**
 * @description This class is responsible for initiating the tracking of shipment details.
 * It uses the `mc_TrackingCallouts` class to make callouts to an external tracking service.
 */
global class ShipStationStartTrackingInvocable {
    /**
     * @description Invocable method that starts tracking for a list of shipment details.
     * It iterates over each provided tracking detail, makes a callout to start tracking,
     * and collects the responses. The method ensures that both the tracking number and
     * carrier code are not null before making the callout.
     *
     * @todo This implicitly has a hard limit 100 packages to start tracking, as each one
     * @todo is actually a callout.
     *
     * @param incomingTrackingDetails A list of tracking details containing tracking numbers and carrier codes.
     * @return A list of responses from the tracking service for each tracking detail.
     */ @InvocableMethod(Label='Start Tracking' Category='Tracking')
    global static List<TrackingResponseResult> startTrackingDetails(List<TrackingDetails> incomingTrackingDetails) {
        List<TrackingResponseResult> responses = new List<TrackingResponseResult>();

        ShipStationAPI trackingCalloutInstance = new ShipStationAPI();

        for (TrackingDetails details : incomingTrackingDetails) {
            if (details.trackingNumberCarrierCode != null && details.trackingNumber != null) {
                // Add the response to the list
                TrackingResponseResult rsp = new TrackingResponseResult();
                rsp.startTrackingResponse = trackingCalloutInstance.startTrackingRequest(
                    details.trackingNumber,
                    details.trackingNumberCarrierCode.toLowerCase()
                );
                responses.add(rsp);
            }
        }
        return responses;
    }

    /**
     * @description Represents the tracking details required to initiate tracking.
     * Contains the tracking number and carrier code, both of which are mandatory.
     */
    global class TrackingDetails {
        @InvocableVariable(Label='Tracking Number' Required=true)
        global String trackingNumber;
        @InvocableVariable(Label='Carrier Code' Required=true)
        global String trackingNumberCarrierCode;
    }

    /**
     * @description Represents the response received after initiating tracking.
     * Contains the response details from the tracking service.
     */
    global class TrackingResponseResult {
        @InvocableVariable(Label='Tracking Response' Required=true)
        global ShipStationWebhookDetailsResponseDTO startTrackingResponse;
    }
}
