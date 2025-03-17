/**
 * @description This class is responsible for making callouts to the ShipEngine API.
 * It extends the `RestClientLib` class, leveraging its HTTP request methods to interact with the ShipEngine service.
 * The primary functions include retrieving tracking information and initiating tracking requests.
 */
public with sharing class ShipStationAPI extends RestClientLib {
    @TestVisible
    private static final String NAMED_CREDENTIAL_NAME = 'MC_SE__ShipEngine_Legacy';

    /**
     * @description Default constructor that initializes the class with a named credential.
     * It uses a default named credential if none is provided.
     */
    public ShipStationAPI() {
        this(NAMED_CREDENTIAL_NAME);
    }

    /**
     * @description Constructor that allows specifying a named credential for API authentication.
     * @param namedCredentialName The name of the credential to use for API requests.
     */
    public ShipStationAPI(String namedCredentialName) {
        super(namedCredentialName ?? NAMED_CREDENTIAL_NAME);
    }

    /**
     * @description Retrieves tracking information from the ShipEngine API.
     * It constructs a GET request to fetch tracking details based on the provided tracking number and carrier code.
     * The method handles different response statuses and parses the response accordingly.
     *
     * @param trackingNumber The tracking number for which information is requested.
     * @param carrierCode The carrier code associated with the tracking number.
     * @return An instance of `mc_DTO_TrackingDetails` containing the tracking information or error details.
     */
    public ShipStationTrackingDetailsDTO getTrackingInformation(String trackingNumber, String carrierCode) {
        // Endpoint URL
        String endpoint = 'tracking';
        String query = 'carrier_code=' + carrierCode + '&tracking_number=' + trackingNumber;

        // Prep the response
        ShipStationTrackingDetailsDTO response = new ShipStationTrackingDetailsDTO();
        ShipStationTrackingDataDTO trackingData = new ShipStationTrackingDataDTO();

        //Construct request for logging purposes
        HttpRequest loggerRequest = new HttpRequest();
        loggerRequest.setEndpoint(endpoint + '?' + query);
        loggerRequest.setMethod('GET');
        // Nebula.Logger.debug('Tracking API Request').setHttpRequestDetails(loggerRequest);
        //made changes here
        HttpResponse result = get(endpoint, query, '', ShipStationTrackingUtilities.getHeaders(), false);
        // Nebula.Logger.debug('Tracking API Response').setHttpResponseDetails(result);
        // Parse the response
        if (result.getStatusCode() == 200) {
            // Parse the response body
            ShipStationTrackingDataDTO trackingResponse = (ShipStationTrackingDataDTO) JSON.deserialize(
                result.getBody(),
                ShipStationTrackingDataDTO.class
            );
            // Return the tracking response

            if (response.trackingResponse == null) {
                response.trackingResponse = new ShipStationTrackingResponseDTO();
            }

            if (response.trackingResponse.data == null) {
                response.trackingResponse.data = new ShipStationTrackingDataDTO();
            }

            response.trackingResponse.data = trackingResponse;

            // Add the json response
            response.json = result.getBody();
        } else if (result.getStatusCode() == 404 || result.getStatusCode() == 400 || result.getStatusCode() == 500) {
            // Log the error
            // Nebula.Logger.error('Error getting tracking information: ' + result.getBody());
            ShipStationTrackingErrorDTO errorResponse = (ShipStationTrackingErrorDTO) JSON.deserialize(
                result.getBody(),
                ShipStationTrackingErrorDTO.class
            );

            if (response.trackingErrorResponse == null) {
                response.trackingErrorResponse = new ShipStationTrackingErrorDTO();
            }
            response.trackingErrorResponse = errorResponse;
        }

        return response;
    }

    /**
     * @description Initiates a tracking request with the ShipEngine API.
     * It checks for existing webhook subscriptions and creates one if necessary before sending a POST request.
     *
     * @param trackingNumber The tracking number to start tracking.
     * @param carrierCode The carrier code associated with the tracking number.
     * @return An instance of `mc_DTO_WebhookDetails` containing the response from the API.
     */
    public ShipStationWebhookDetailsResponseDTO startTrackingRequest(String trackingNumber, String carrierCode) {
        String endpoint = 'tracking/start';
        String query = 'carrier_code=' + carrierCode + '&tracking_number=' + trackingNumber;

        // Prep the response
        ShipStationWebhookDetailsResponseDTO response = new ShipStationWebhookDetailsResponseDTO();

        // We need to query ShipEngine_Webhook__mdt and ensure that Webhook_Event_Type__c = 'track'
        // if not, we need to create a new webhook with the event type 'track'
        // if it does, then continue with the request
        List<ShipEngine_Webhook__mdt> webhook = [
            SELECT Id, Webhook_URL__c, Webhook_Event_Type__c
            FROM ShipEngine_Webhook__mdt
            WHERE Webhook_Event_Type__c = 'track'
            LIMIT 1
        ];

        if (webhook.size() == 0) {
            subscribeToTrackingEvents();
        }

        // Construct request for logging purposes
        HttpRequest loggerRequest = new HttpRequest();
        loggerRequest.setEndpoint(endpoint + '?' + query);
        loggerRequest.setMethod('POST');
        // Nebula.Logger.debug('Tracking API Request').setHttpRequestDetails(loggerRequest);

        HttpResponse result = post(endpoint, query, null, ShipStationTrackingUtilities.getHeaders(), false);
        // Nebula.Logger.debug('Tracking API Response').setHttpResponseDetails(result);

        if (result.getStatusCode() == 200) {
            // Nebula.Logger.info('Tracking request started successfully');
            // Parse the response body
            response.trackingWebhookCreationResponse = (ShipStationTrackingWebhookCreationDTO) JSON.deserialize(
                result.getBody(),
                ShipStationTrackingWebhookCreationDTO.class
            );
        } else {
            // Nebula.Logger.error('Error starting tracking request: ' + result.getBody());
            response.trackingErrorResponse = (ShipStationTrackingErrorDTO) JSON.deserialize(
                result.getBody(),
                ShipStationTrackingErrorDTO.class
            );
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
     * @description Subscribes to tracking updates for packages by creating a webhook subscription.
     * Sends a POST request to the ShipEngine API to register for tracking event notifications.
     *
     * @return An instance of `mc_DTO_WebhookDetails` containing the response from the API.
     */
    public ShipStationWebhookDetailsResponseDTO subscribeToTrackingEvents() {
        // Endpoint URL
        String endpoint = 'environment/webhooks';
        // Method
        String method = 'POST';

        // Construct response
        ShipStationWebhookDetailsResponseDTO response = new ShipStationWebhookDetailsResponseDTO();

        // This will not have a response body but we will get a 204 response

        // Construct request for logging purposes
        HttpRequest loggerRequest = new HttpRequest();
        loggerRequest.setEndpoint(endpoint);
        loggerRequest.setMethod(method);
        // Nebula.Logger.debug('Starting Tracking API Request').setHttpRequestDetails(loggerRequest);

        HttpResponse result = post(endpoint, null, null, ShipStationTrackingUtilities.getHeaders(), false);
        // Nebula.Logger.debug('Starting Tracking API Response').setHttpResponseDetails(result);

        if (result.getStatusCode() == 204) {
            // Nebula.Logger.info('Starting Tracking request started successfully');
        } else {
            // Nebula.Logger.error('Error starting tracking webhook: ' + result.getBody());
            response.trackingErrorResponse = (ShipStationTrackingErrorDTO) JSON.deserialize(
                result.getBody(),
                ShipStationTrackingErrorDTO.class
            );
        }

        return response;
    }
}
