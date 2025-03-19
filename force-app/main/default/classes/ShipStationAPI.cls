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
        // ShipStationTrackingDataDTO trackingData = new ShipStationTrackingDataDTO();

        //Construct request for logging purposes
        HttpRequest loggerRequest = new HttpRequest();
        loggerRequest.setEndpoint(endpoint + '?' + query);
        loggerRequest.setMethod('GET');
        // Nebula.Logger.debug('Tracking API Request').setHttpRequestDetails(loggerRequest);
        //made changes here
        HttpResponse result = get(endpoint, query, '', ShipStationTrackingHelper.getHeaders(), false);
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
        try {
            ShipEngine_Webhook__mdt webhook = new ShipEngineWebhookConfigurationRepo().getWebhookDetailsByType('track');
            if (webhook == null || !webhook.Webhook_Active__c) {
                subscribeToTrackingEvents();
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error getting webhook details: ' + e.getStackTraceString());
        }

        HttpResponse result = post(endpoint, query, null, ShipStationTrackingHelper.getHeaders(), false);

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

        HttpResponse result = post(endpoint, null, null, ShipStationTrackingHelper.getHeaders(), false);
        // Nebula.Logger.debug('Starting Tracking API Response').setHttpResponseDetails(result);

        if (result.getStatusCode() == 204) {
            System.debug(LoggingLevel.INFO, 'Starting Tracking request started successfully');
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
