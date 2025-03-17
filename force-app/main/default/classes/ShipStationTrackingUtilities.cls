/**
 * @description This utility class provides helper methods for interacting with the ShipEngine API.
 * It includes methods for retrieving API configuration details, formatting carrier codes, and mapping tracking statuses.
 */
public with sharing class ShipStationTrackingUtilities {
    /**
     * @description Retrieves the base URL for the ShipEngine API.
     * This method returns a hardcoded URL string that serves as the endpoint for API requests.
     *
     * @return The base URL for the ShipEngine API.
     */
    public static String getBaseUrl() {
        return 'https://api.shipengine.com/v1/';
    }

    /**
     * @description Retrieves the API key from a custom setting.
     * This method accesses the `ShipEngineAuth__c` custom setting to obtain the API key used for authentication.
     *
     * @return The API key stored in the custom setting.
     */
    private static String getApiKey() {
        ShipEngineAuth__c setting = ShipEngineAuth__c.getOrgDefaults();
        return setting.API_Key__c;
        //return '4N5m/HDgxa7A5JL8UiNEITZpXWovtditUf6E98gYNS4';
    }

    /**
     * @description Creates and returns a map of HTTP headers required for API requests.
     * The headers include content type and API key for authentication.
     *
     * @return A map containing the HTTP headers for API requests.
     */
    public static Map<String, String> getHeaders() {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        headers.put('API-Key', getApiKey());
        return headers;
    }

    /**
     * @description Formats the carrier code to lowercase.
     * This method ensures consistent formatting of carrier codes by converting them to lowercase.
     *
     * @param carrier The carrier code to format.
     * @return The formatted carrier code in lowercase.
     */
    public static String formatCarrier(String carrier) {
        return carrier != null ? carrier.toLowerCase() : '';
    }

    /**
     * @description Maps a tracking status code to its corresponding human-readable status.
     * This method uses a switch statement to convert status codes into descriptive status messages.
     *
     * @param status_code The tracking status code to map.
     * @return The human-readable tracking status message.
     */
    public static String getTrackingStatus(String status_code) {
        // Convert input to upper case to ensure consistent matching
        String upperStatusCode = status_code != null ? status_code.toUpperCase() : '';

        switch on upperStatusCode {
            when 'UN' {
                return 'Unknown';
            }
            when 'AC' {
                return 'Accepted';
            }
            when 'IT' {
                return 'In Transit';
            }
            when 'DE' {
                return 'Delivered';
            }
            when 'EX' {
                return 'Exception';
            }
            when 'AT' {
                return 'Delivery Attempt';
            }
            when 'NY' {
                return 'Not Yet In System';
            }
            when 'SP' {
                return 'Delivered To Collection Location';
            }
            when else {
                return 'Unknown';
            }
        }
    }

    /**
     * @description Maps a tracking status detail code to its corresponding human-readable detail message.
     * This method uses a switch statement to convert status detail codes into descriptive detail messages.
     *
     * @param status_detail_code The tracking status detail code to map.
     * @return The human-readable tracking status detail message.
     */
    public static String getTrackingStatusDetail(String status_detail_code) {
        // Convert input to upper case to ensure consistent matching
        String upperStatusDetailCode = status_detail_code != null ? status_detail_code.toUpperCase() : '';

        // Use a switch statement to handle the different cases
        switch on upperStatusDetailCode {
            when 'COLLECTION_FAILED' {
                return 'The package collection has failed.';
            }
            when 'AWAITING_DESPATCH' {
                return 'The package is awaiting despatch.';
            }
            when 'COLLECTION_REQUESTED' {
                return 'The package collection has been requested.';
            }
            when 'DESPATCHED' {
                return 'The package has been despatched.';
            }
            when 'ELEC_ADVICE_RECD_BY_CARRIER' {
                return 'Electronic advice has been received by the carrier.';
            }
            when 'NOT_YET_RECEIVED_BY_CARRIER' {
                return 'The package has not yet been received by the carrier.';
            }
            when 'COLLECTION_MADE' {
                return 'The package collection has been made.';
            }
            when 'ATTEMPTED_DELIVERY' {
                return 'An attempted delivery has been made.';
            }
            when 'ATTEMPTED_DELIVERY_2ND' {
                return 'A second attempted delivery has been made.';
            }
            when 'ATTEMPTED_DELIVERY_3RD' {
                return 'A third attempted delivery has been made.';
            }
            when 'COD_AMOUNT_NOT_PAID' {
                return 'The COD amount has not been paid.';
            }
            when 'COD_AMOUNT_PAID' {
                return 'The COD amount has been paid.';
            }
            when 'CUSTOMER_CARDED' {
                return 'The customer has been carded.';
            }
            when 'CUSTOMER_IDENTIFICATION_FAILED' {
                return 'Customer identification has failed.';
            }
            when 'INVALID_METHOD_OF_PAYMENT' {
                return 'The method of payment is invalid.';
            }
            when 'NO_ACCESS_TO_RECIPIENTS_ADDRESS' {
                return 'There was no access to the recipient\'s address.';
            }
            when 'OUT_FOR_DELIVERY' {
                return 'The package is out for delivery.';
            }
            when 'DELIVERED' {
                return 'The package has been delivered.';
            }
            when 'DELIVERED_DAMAGED' {
                return 'The package was delivered but damaged.';
            }
            when 'DELIVERED_IN_PART' {
                return 'The package has been delivered in part.';
            }
            when 'DELIVERED_SPECIFIED_SAFE_PLACE' {
                return 'The package was delivered to a specified safe place.';
            }
            when 'DELIVERED_TO_ALTERNATIVE_DELIVERY_LOCATION' {
                return 'The package was delivered to an alternative delivery location.';
            }
            when 'DELIVERED_TO_NEIGHBOUR' {
                return 'The package was delivered to a neighbour.';
            }
            when 'DELIVERED_TO_PO_BOX' {
                return 'The package was delivered to a PO box.';
            }
            when 'PARCEL_COLLECTED_FROM_PICKUP_POINT' {
                return 'The parcel was collected from a pickup point.';
            }
            when 'POST_TRANSIT_STATUS' {
                return 'The package is in a post-transit status.';
            }
            when 'PROOF_OF_DELIVERY' {
                return 'Proof of delivery is available.';
            }
            when 'CANCELLED' {
                return 'The shipment has been cancelled.';
            }
            when 'CANCELLED_BEFORE_DESPATCH' {
                return 'The shipment was cancelled before despatch.';
            }
            when 'CUSTOMER_MOVED' {
                return 'The customer has moved.';
            }
            when 'HAZARDOUS_PROHIBITED' {
                return 'The parcel contains hazardous or prohibited items.';
            }
            when 'NOT_COLLECTED_FROM_PICKUP_POINT' {
                return 'The parcel was not collected from the pickup point.';
            }
            when 'NOT_DELIVERED' {
                return 'The parcel was not delivered.';
            }
            when 'NOT_DELIVERED_ADDRESSEE_DECEASED' {
                return 'The parcel was not delivered because the addressee is deceased.';
            }
            when 'PARCEL_DAMAGED' {
                return 'The parcel has been damaged.';
            }
            when 'PARCEL_DISPOSED' {
                return 'The parcel has been disposed of.';
            }
            when 'PARCEL_LOST' {
                return 'The parcel has been lost.';
            }
            when 'PARCEL_OUTSIDE_OF_SERVICE_CAPABILITY' {
                return 'The parcel is outside of the service capability.';
            }
            when 'REFUSED_BY_CUSTOMER' {
                return 'The parcel was refused by the customer.';
            }
            when 'RETURN_TO_SENDER' {
                return 'The parcel is being returned to the sender.';
            }
            when 'ADDRESS_QUERY' {
                return 'There is an address query for the parcel.';
            }
            when 'CARRIER_DELAYS' {
                return 'The parcel is delayed due to the carrier.';
            }
            when 'CUSTOMS_CLEARED' {
                return 'The parcel has been cleared by customs.';
            }
            when 'CUSTOMS_PROCESSING' {
                return 'The parcel is undergoing customs processing.';
            }
            when 'DELAYED_NOT_CARRIER' {
                return 'The parcel is delayed due to reasons not related to the carrier.';
            }
            when 'DELIVERY_ARRANGED_WITH_RECIPIENT' {
                return 'Delivery has been arranged with the recipient.';
            }
            when 'HELD_BY_CARRIER' {
                return 'The parcel is held by the carrier.';
            }
            when 'HELD_BY_CARRIER_FOR_CLEARANCE_PRE_PROCESSING' {
                return 'The parcel is held by the carrier for clearance pre-processing.';
            }
            when 'HELD_BY_CUSTOMS' {
                return 'The parcel is held by customs.';
            }
            when 'HELD_BY_EXPORT_CUSTOMS' {
                return 'The parcel is held by export customs.';
            }
            when 'HELD_BY_IMPORT_CUSTOMS' {
                return 'The parcel is held by import customs.';
            }
            when 'HUB_SCAN_OUT' {
                return 'The parcel has been scanned out of the hub.';
            }
            when 'IN_TRANSIT' {
                return 'The parcel is in transit.';
            }
            when 'INCORRECT_DECLARATION' {
                return 'The parcel has an incorrect declaration.';
            }
            when 'INFORMATION' {
                return 'There is an information update about the parcel.';
            }
            when 'MISSORTED' {
                return 'The parcel has been missorted.';
            }
            when 'PARCEL_OVER_LABELLED' {
                return 'The parcel has been over-labelled.';
            }
            when 'PARCEL_REPACKED' {
                return 'The parcel has been repacked.';
            }
            when 'PARCEL_UPDATE_NOTIFICATION_VIA_EMAIL' {
                return 'A parcel update notification has been sent via email.';
            }
            when 'PARCEL_UPDATE_NOTIFICATION_VIA_SMS' {
                return 'A parcel update notification has been sent via SMS.';
            }
            when 'RECEIVED_BY_CARRIER' {
                return 'The parcel has been received by the carrier.';
            }
            when 'RECEIVED_LOCAL_DELIVERY_DEPOT' {
                return 'The parcel has been received at the local delivery depot.';
            }
            when 'ROUTING_ERROR' {
                return 'The parcel has encountered a routing error.';
            }
            when 'SUB_CONTRACTOR_EVENT' {
                return 'There was a sub-contractor event related to the parcel.';
            }
            when 'SUB_CONTRACTOR_RECEIVED' {
                return 'The sub-contractor has received the parcel.';
            }
            when 'RECD_BY_CARRIER_NO_ELEC_ADVICE' {
                return 'The parcel has been received by the carrier with no electronic advice.';
            }
            when 'AWAITING_ELECTRONIC_ADVICE' {
                return 'The parcel is awaiting electronic advice.';
            }
            when 'AWAITING_COLLECTION_FROM_PICKUP_POINT' {
                return 'The parcel is awaiting collection from the pickup point.';
            }
            when 'COLLECT_AT_LOCAL_PO' {
                return 'The customer should collect the parcel at the local PO.';
            }
            when 'CUSTOMER_TO_COLLECT_FROM_CARRIER' {
                return 'The customer should collect the parcel from the carrier.';
            }
            when 'DELIVERED_TO_LOCKER_COLLECTION_POINT' {
                return 'The package was delivered to a locker collection point.';
            }
            when 'CARRIER_STATUS_NOT_MAPPED' {
                return 'The carrier status is not mapped.';
            }
            when else {
                return 'Unknown status.';
            }
        }
    }
}
