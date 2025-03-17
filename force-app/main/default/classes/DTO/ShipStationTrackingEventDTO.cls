@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class ShipStationTrackingEventDTO {
    @AuraEnabled
    public String occurred_at;

    @AuraEnabled
    public String carrier_occurred_at;

    @AuraEnabled
    public String description;

    @AuraEnabled
    public String city_locality;

    @AuraEnabled
    public String state_province;

    @AuraEnabled
    public String postal_code;

    @AuraEnabled
    public String country_code;

    @AuraEnabled
    public String company_name;

    @AuraEnabled
    public String signer;

    @AuraEnabled
    public String event_code;

    @AuraEnabled
    public String carrier_status_description;

    @AuraEnabled
    public String carrier_detail_code;

    @AuraEnabled
    public String status_code;

    @AuraEnabled
    public String status_detail_code;

    @AuraEnabled
    public String status_description;

    @AuraEnabled
    public String status_detail_description;

    @AuraEnabled
    public Decimal latitude;

    @AuraEnabled
    public Decimal longitude;

    /* This method converts the event to a Shipment_Events object. */
    public Shipment_Events__c toShipmentEvent(Id shipmentId, String shipmentStatusCode) {
        Shipment_Events__c shipmentEvent = new Shipment_Events__c();
        shipmentEvent.Shipment__c = shipmentId;

        // Use the two-letter status code from the event if available, otherwise fallback to the shipment status code
        shipmentEvent.Status_Code__c = String.isNotBlank(status_code)
            ? getValidStatusCode(status_code)
            : getValidStatusCode(shipmentStatusCode);

        shipmentEvent.Occurred_At__c = parse8601String(occurred_at);
        shipmentEvent.Description__c = description;
        shipmentEvent.Event_Code__c = event_code;
        shipmentEvent.Event_Description__c = carrier_status_description;
        shipmentEvent.City_Locality__c = city_locality;
        shipmentEvent.State_Province__c = state_province;
        shipmentEvent.Postal_Code__c = postal_code;
        return shipmentEvent;
    }

    /**
     * @description Ensures a valid two-letter status code is used
     * @param statusCode The status code to validate
     * @return String A valid two-letter status code
     */
    @TestVisible
    private static String getValidStatusCode(String statusCode) {
        if (String.isBlank(statusCode)) {
            return 'UN'; // Default to Unknown
        }

        // If it's already a valid two-letter code, return it uppercase
        if (statusCode.length() == 2) {
            return statusCode.toUpperCase();
        }

        // Map common full names to two-letter codes
        Map<String, String> statusMapping = new Map<String, String>{
            'UNKNOWN' => 'UN',
            'ACCEPTED' => 'AC',
            'IN_TRANSIT' => 'IT',
            'DELIVERED' => 'DE',
            'EXCEPTION' => 'EX',
            'DELIVERY_ATTEMPT' => 'AT',
            'NOT_YET_IN_SYSTEM' => 'NY',
            'DELIVERED_TO_COLLECTION_LOCATION' => 'SP'
        };

        String upperStatus = statusCode.toUpperCase().replaceAll(' ', '_');
        if (statusMapping.containsKey(upperStatus)) {
            return statusMapping.get(upperStatus);
        }

        // Try to match based on the description
        for (String key : statusMapping.keySet()) {
            if (upperStatus.contains(key.replace('_', ' '))) {
                return statusMapping.get(key);
            }
        }

        // If no match found, default to Unknown
        return 'UN';
    }

    /* This method converts this object to a Tracking_Event object. */
    public Tracking_Event__c toTrackingEvent(Id shipmentId, Id trackingMasterId) {
        Tracking_Event__c trackingEvent = new Tracking_Event__c();
        trackingEvent.City_Locality__c = city_locality;
        trackingEvent.Description__c = description;
        trackingEvent.Event_Code__c = event_code;
        trackingEvent.Event_Description__c = carrier_status_description;
        trackingEvent.Occurred_At__c = occurred_at != null ? parse8601String(occurred_at) : null;
        trackingEvent.Postal_Code__c = postal_code;
        trackingEvent.Shipment__c = shipmentId;
        trackingEvent.State_Province__c = state_province;
        trackingEvent.Tracking_Master__c = trackingMasterId;
        return trackingEvent;
    }

    @TestVisible
    private static Datetime parse8601String(String dateTimeString) {
        return (Datetime) JSON.deserialize(dateTimeString, Datetime.class);
    }
}
