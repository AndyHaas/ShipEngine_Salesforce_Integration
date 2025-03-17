public with sharing class TrackingMasterRepo extends BaseRepo {
    final ContentRepo contentRepo {
        get {
            return contentRepo ?? new ContentRepo();
        }
    }

    public TrackingMasterRepo() {
        super(Tracking_Master__c.SObjectType, true);
    }

    /* This method creates a new record in the database from a ShipStationTrackingResponseDTO. */
    public Database.SaveResult createTrackingMasterRecordFromDTO(ShipStationTrackingResponseDTO trackingResponse) {
        Database.SaveResult contentVersionSaveResult = contentRepo.createContentVersion(
            Blob.valueOf(JSON.serialize(trackingResponse))
        );

        Tracking_Master__c trackingMaster = new Tracking_Master__c();
        trackingMaster.Tracking_Number__c = trackingResponse.data.tracking_number;
        trackingMaster.Actual_Delivery_Date__c = trackingResponse.data.actual_delivery_date != null
            ? iso8601ToDatetime(trackingResponse.data.actual_delivery_date)
            : null;
        trackingMaster.Carrier__c = trackingResponse.data.carrier_code;
        trackingMaster.Estimated_Delivery_Date__c = trackingResponse.data.estimated_delivery_date != null
            ? iso8601ToDatetime(trackingResponse.data.estimated_delivery_date)
            : null;
        trackingMaster.Ship_Date__c = trackingResponse.data.ship_date != null
            ? iso8601ToDatetime(trackingResponse.data.ship_date)
            : null;
        trackingMaster.Status_Code__c = getValidStatusCode(trackingResponse.data.status_code);
        trackingMaster.Status_Description__c = trackingResponse.data.status_description;
        trackingMaster.Content_Version_Id__c = contentVersionSaveResult.getId();

        Database.SaveResult trackingMasterInsertResult = doCreateUnsafe(trackingMaster);

        return trackingMasterInsertResult;
    }

    /* Fetch a list of tracking masters by their ids. */
    public Tracking_Master__c[] fetchTrackingMastersById(List<Id> trackingMasterIds) {
        String selectClause = this.calculateSelectClause(
            new Set<String>{ 'Id', 'Tracking_Number__c', 'Content_Version_Id__c' }
        );
        String fromObj = 'FROM Tracking_Master__c';
        String whereClause = ' WHERE Id IN :trackingMasterIds';
        String query = selectClause + ' ' + fromObj + ' ' + whereClause;
        return this.fetch(query, new Map<String, Object>{ 'trackingMasterIds' => trackingMasterIds });
    }

    private static Datetime iso8601ToDatetime(String iso8601String) {
        return (Datetime) JSON.deserialize(iso8601String, Datetime.class);
    }

    /**
     * @description Ensures a valid two-letter status code is used
     * @param statusCode The status code to validate
     * @return String A valid two-letter status code
     */
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

        String upperStatus = statusCode.toUpperCase();
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
}
