public with sharing class mc_TrackingCallouts extends RestClientLib {
    @TestVisible
	private static final String NAMED_CREDENTIAL_NAME = 'ShipEngine_Legacy';

    public mc_TrackingCallouts(){
		this(NAMED_CREDENTIAL_NAME);
	}
	public mc_TrackingCallouts(String namedCredentialName){
		super(namedCredentialName != null ? namedCredentialName : NAMED_CREDENTIAL_NAME);
	}

    /**
     * Get tracking information from ShipEngine
     * @param trackingNumber The tracking number to get information for
     * @param carrierCode The carrier code to get information for
     * @return The response from the ShipEngine API
     */
    public mc_DTO_TrackingDetails getTrackingInformation(String trackingNumber, String carrierCode) {
        // Endpoint URL
        String endpoint = 'tracking';
        String query = 'carrier_code=' + carrierCode + '&tracking_number=' + trackingNumber;

        // Prep the response
        mc_DTO_TrackingDetails response = new mc_DTO_TrackingDetails();
        mc_DTO_TrackingData trackingData = new mc_DTO_TrackingData();

        //Construct request for logging purposes
        HttpRequest loggerRequest = new HttpRequest();
        loggerRequest.setEndpoint(endpoint + '?' + query);
        loggerRequest.setMethod('GET');
        // Nebula.Logger.debug('Tracking API Request').setHttpRequestDetails(loggerRequest);
		//made changes here 
        HttpResponse result = get(endpoint, query, '', mc_TrackingUltility.getHeaders(), false);
        // Nebula.Logger.debug('Tracking API Response').setHttpResponseDetails(result);  		
        // Parse the response
        if (result.getStatusCode() == 200) {
            System.debug('Tracking response: ' + result.getBody());
            // Parse the response body
            mc_DTO_TrackingData trackingResponse = (mc_DTO_TrackingData) JSON.deserialize(result.getBody(), mc_DTO_TrackingData.class);
            // Return the tracking response
            System.debug('Tracking response: ' + trackingResponse);
            
            if (response.trackingResponse == null) {
                response.trackingResponse = new mc_DTO_TrackingResponse();
            }

            if (response.trackingResponse.data == null) {
                response.trackingResponse.data = new mc_DTO_TrackingData();
            }

            response.trackingResponse.data = trackingResponse;

            // Add the json response
            response.json = result.getBody();
        } else if (result.getStatusCode() == 404 || result.getStatusCode() == 400 || result.getStatusCode() == 500) {
            // Log the error
            System.debug('Error: ' + result.getStatusCode() + ' ' + result.getStatus());
            // Nebula.Logger.error('Error getting tracking information: ' + result.getBody());
            mc_DTO_TrackingErrorResponse errorResponse = (mc_DTO_TrackingErrorResponse) JSON.deserialize(result.getBody(), mc_DTO_TrackingErrorResponse.class);

            if (response.trackingErrorResponse == null) {
                response.trackingErrorResponse = new mc_DTO_TrackingErrorResponse();
            }
            response.trackingErrorResponse = errorResponse;
        }

        return response;
    }

    /**
     * Start tracking requests with ShipEngine
     * @param trackingNumber The tracking number to start tracking
     * @param carrierCode The carrier code to start tracking
     * @return The response from the ShipEngine API
     */
    public mc_DTO_WebhookDetails startTrackingRequest(String trackingNumber, String carrierCode) {
        String endpoint = 'tracking';
        String query = 'carrier_code=' + carrierCode + '&tracking_number=' + trackingNumber;

        // Prep the response
        mc_DTO_WebhookDetails response = new mc_DTO_WebhookDetails();

        // We need to query ShipEngine_Webhook__mdt and ensure that Webhook_Event_Type__c = 'track'
        // if not, we need to create a new webhook with the event type 'track'
        // if it does, then continue with the request
        List<ShipEngine_Webhook__mdt> webhook = [SELECT Id, Webhook_URL__c, Webhook_Event_Type__c FROM ShipEngine_Webhook__mdt WHERE Webhook_Event_Type__c = 'track' LIMIT 1];

        if (webhook.size() == 0) {
            subscribeToTrackingEvents();
        }

        // Construct request for logging purposes
        HttpRequest loggerRequest = new HttpRequest();
        loggerRequest.setEndpoint(endpoint + '?' + query);
        loggerRequest.setMethod('POST');
        // Nebula.Logger.debug('Tracking API Request').setHttpRequestDetails(loggerRequest);

        HttpResponse result = post(endpoint, query, null, mc_TrackingUltility.getHeaders(), false);
        // Nebula.Logger.debug('Tracking API Response').setHttpResponseDetails(result);

        if (result.getStatusCode() == 200) {
            // Nebula.Logger.info('Tracking request started successfully');
            // Parse the response body
            response.trackingWebhookCreationResponse = (mc_DTO_TrackingWebhookCreationResponse) JSON.deserialize(result.getBody(), mc_DTO_TrackingWebhookCreationResponse.class);

        } else {
            // Nebula.Logger.error('Error starting tracking request: ' + result.getBody());
            response.trackingErrorResponse = (mc_DTO_TrackingErrorResponse) JSON.deserialize(result.getBody(), mc_DTO_TrackingErrorResponse.class);
        }

        return response;
        
    }

    /**
     * View tracking requests from ShipEngine
     * @param webhookId The webhook ID to view
     * @return The response from the ShipEngine API
     */
    // public mc_DTO_WebhookDetails viewTrackingRequests(String webhookId) {
    //     // Endpoint URL
    //     String endpoint = 'environment/webhooks/' + webhookId;
    //     // Method
    //     String method = 'GET';

    //     // Construct request for logging purposes
    //     HttpRequest loggerRequest = new HttpRequest();
    //     loggerRequest.setEndpoint(endpoint);
    //     loggerRequest.setMethod(method);
    //     Nebula.Logger.debug('Getting List of Webhooks Request').setHttpRequestDetails(loggerRequest);

    //     HttpResponse result = get(endpoint, null, mc_TrackingUltility.getHeaders(), false);
    //     Nebula.Logger.debug('Getting List of Webhooks Response').setHttpResponseDetails(result);

    //     if (result.getStatusCode() == 200) {
    //         Nebula.Logger.info('Getting List of Webhooks successful');
    //         // Parse the response body
    //         response.webhookList = (mc_DTO_WebhookList) JSON.deserialize(result.getBody(), mc_DTO_WebhookList.class);
    //     } else {
    //         Nebula.Logger.error('Error getting list of webhooks: ' + result.getBody());
    //         response.trackingErrorResponse = (mc_DTO_TrackingErrorResponse) JSON.deserialize(result.getBody(), mc_DTO_TrackingErrorResponse.class);
    //     }

    //     return response;

    // }

    /**
     * Delete a tracking request from ShipEngine
     * @param webhookId The webhook ID to delete
     * @return The response from the ShipEngine API
     */
    // public mc_DTO_WebhookDetails deleteTrackingRequest(String webhookId) {
    //     // Endpoint URL
    //     String endpoint = 'environment/webhooks/' + webhookId;
    //     // Method
    //     String method = 'DELETE';

    //     // Check if the webhookId is null
    //     if (webhookId == null) {
    //         Nebula.Logger.error('Error deleting tracking request: webhookId is null');
    //         return null;
    //     } else {
    //         // This will not have a response body but we will get a 204 response
    
    //         // Construct request for logging purposes
    //         HttpRequest loggerRequest = new HttpRequest();
    //         loggerRequest.setEndpoint(endpoint);
    //         loggerRequest.setMethod(method);
    //         Nebula.Logger.debug('Starting Tracking API Request').setHttpRequestDetails(loggerRequest);
    
    //         HttpResponse result = del(endpoint, null, mc_TrackingUltility.getHeaders());
    //         Nebula.Logger.debug('Starting Tracking API Response').setHttpResponseDetails(result);
    
    //         if (result.getStatusCode() == 204) {
    //             Nebula.Logger.info('Starting Tracking request started successfully');
    
    //         } else {
    //             Nebula.Logger.error('Error starting tracking webhook: ' + result.getBody());
    //             response.trackingErrorResponse = (mc_DTO_TrackingErrorResponse) JSON.deserialize(result.getBody(), mc_DTO_TrackingErrorResponse.class);
    //         }
    //     }
    //     return response;
    // }

    /**
     * Allows you to subscribe to tracking updates for a package.
     * @return The response from the ShipEngine API
     */
    public mc_DTO_WebhookDetails subscribeToTrackingEvents() {
        // Endpoint URL
        String endpoint = 'environment/webhooks';
        // Method
        String method = 'POST';

        // Construct response
        mc_DTO_WebhookDetails response = new mc_DTO_WebhookDetails();

        // This will not have a response body but we will get a 204 response

        // Construct request for logging purposes
        HttpRequest loggerRequest = new HttpRequest();
        loggerRequest.setEndpoint(endpoint);
        loggerRequest.setMethod(method);
        // Nebula.Logger.debug('Starting Tracking API Request').setHttpRequestDetails(loggerRequest);

        HttpResponse result = post(endpoint, null, null, mc_TrackingUltility.getHeaders(), false);
        // Nebula.Logger.debug('Starting Tracking API Response').setHttpResponseDetails(result);

        if (result.getStatusCode() == 204) {
            // Nebula.Logger.info('Starting Tracking request started successfully');

        } else {
            // Nebula.Logger.error('Error starting tracking webhook: ' + result.getBody());
            response.trackingErrorResponse = (mc_DTO_TrackingErrorResponse) JSON.deserialize(result.getBody(), mc_DTO_TrackingErrorResponse.class);
        }

        return response;
    }
}