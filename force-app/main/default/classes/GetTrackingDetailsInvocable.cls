/**
 * @description Provides an invocable entry point for Flow/Process Builder to retrieve
 * shipping tracking information from external carrier systems. This class exists as a wrapper
 * to make tracking information accessible in declarative tools rather than requiring code.
 * @group Shipping
 */
global with sharing class GetTrackingDetailsInvocable {
    /**
     * @description Entry point for Flow/Process Builder to retrieve tracking details.
     * This method exists to transform simple tracking inputs into detailed tracking status
     * information that can be used in automation or displayed to users.
     *
     * @param trackingDetailsList List of tracking numbers and carriers to look up
     * @return List<Response> Wrapper containing detailed tracking information for each request
     * @example
     * List<mc_GetTrackingDetails.TrackingDetails> inputs = new List<mc_GetTrackingDetails.TrackingDetails>();
     * // ... populate inputs
     * List<mc_GetTrackingDetails.Response> results = mc_GetTrackingDetails.getTrackingDetails(inputs);
     */
    @InvocableMethod(Label='Get Tracking Details' Category='Tracking')
    global static List<Response> getTrackingDetails(List<TrackingDetails> trackingDetailsList) {
        List<Response> responses = new List<Response>();

        ShipStationAPI trackingCalloutInstance = new ShipStationAPI();

        for (TrackingDetails details : trackingDetailsList) {
            if (details.trackingNumberCarrierCode != null && details.trackingNumber != null) {
                // Add the response to the list
                Response rsp = new Response();
                rsp.trackingResponse = trackingCalloutInstance.getTrackingInformation(
                    details.trackingNumber,
                    details.trackingNumberCarrierCode.toLowerCase()
                );
                responses.add(rsp);
            }
        }
        return responses;
    }

    /**
     * @description Inner class to structure tracking request parameters for Flow/Process Builder.
     * Separated into its own class to maintain clean separation between input parameters
     * and to support potential future expansion of tracking parameters.
     */
    global class TrackingDetails {
        @InvocableVariable(Label='Tracking Number' Required=true)
        global String trackingNumber;
        @InvocableVariable(Label='Carrier Code' Required=true)
        global String trackingNumberCarrierCode;
    }

    /**
     * @description Response wrapper class to maintain consistent structure for Flow/Process Builder.
     * Encapsulates tracking response data in a format that can be easily consumed by automation tools
     * while maintaining flexibility for future enhancements to the tracking response structure.
     */
    global class Response {
        @InvocableVariable(Label='Tracking Response' Required=true)
        global ShipStationTrackingDetailsDTO trackingResponse;
    }
}
