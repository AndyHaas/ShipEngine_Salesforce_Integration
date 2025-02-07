@RestResource(urlMapping='/tracking/events/*')
global class mc_TrackingResource {

    @HttpPost
    global static void handlePost() {
        try{
            //Get the body and parse with DTO mc_DTO_TrackingResponse
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String bodyString = body.toString();
            mc_DTO_TrackingResponse trackingData = (mc_DTO_TrackingResponse) JSON.deserialize(bodyString, mc_DTO_TrackingResponse.class);

            //Insert the tracking data into Tracking_Master__c
            Tracking_Master__c trackingMaster = new Tracking_Master__c();
            trackingMaster.Tracking_Number__c = trackingData.data.tracking_number;
            trackingMaster.Webhook_JSON_Body__c = truncateJson(minifyJson(bodyString));

            insert trackingMaster;

            RestContext.response.statusCode = 201;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }

    }

    // Helper method to minify JSON
    private static String minifyJson(String jsonString) {
        try {
            // Deserialize and re-serialize to remove unnecessary characters
            Object jsonObject = JSON.deserializeUntyped(jsonString);
            return JSON.serialize(jsonObject);
        } catch (Exception e) {
            // Log or handle minification error
            return jsonString; // Fallback to raw JSON if an error occurs
        }
    }

    private static String truncateJson(String jsonString) {
        Integer maxLength = 131072; // Max length for Long Text Area
        return jsonString.length() > maxLength ? jsonString.substring(0, maxLength) : jsonString;
    }
}