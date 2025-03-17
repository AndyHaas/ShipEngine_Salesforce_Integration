/**
 * @description Service class for processing Tracking_Master__c records and their related tracking events
 */
public inherited sharing class TrackingMasterService {
    private final ContentRepo contentRepo;
    private final ShipmentRepo shipmentRepo;
    private final TrackingMasterRepo trackingMasterRepo;
    private final TrackingEventRepo trackingEventRepo;
    private final ShipmentEventRepo shipmentEventRepo;

    /**
     * @description Default constructor that initializes repositories
     */
    public TrackingMasterService() {
        this(
            new ContentRepo(),
            new ShipmentRepo(),
            new TrackingMasterRepo(),
            new TrackingEventRepo(),
            new ShipmentEventRepo()
        );
    }

    @TestVisible
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private TrackingMasterService(
        ContentRepo contentRepo,
        ShipmentRepo shipmentRepo,
        TrackingMasterRepo trackingMasterRepo,
        TrackingEventRepo trackingEventRepo,
        ShipmentEventRepo shipmentEventRepo
    ) {
        this.contentRepo = contentRepo;
        this.shipmentRepo = shipmentRepo;
        this.trackingMasterRepo = trackingMasterRepo;
        this.trackingEventRepo = trackingEventRepo;
        this.shipmentEventRepo = shipmentEventRepo;
    }

    /**
     * @description Processes tracking master records to create/update shipments and tracking events
     * @param trackingMasterRecords The list of Tracking_Master__c records to process
     */
    public void processTrackingMaster(List<Tracking_Master__c> trackingMasterRecords) {
        // Filter out already processed records
        List<Tracking_Master__c> unprocessedRecords = filterAlreadyProcessedRecords(trackingMasterRecords);

        if (unprocessedRecords.isEmpty()) {
            return;
        }

        // Process JSON documents
        Map<Id, String> jsonDocumentMap = buildJsonDocumentMap(unprocessedRecords);

        // Process shipments and tracking data
        List<Shipment__c> shipmentsToUpsert = new List<Shipment__c>();
        Map<Id, List<ShipStationTrackingEventDTO>> trackingEventsMap = new Map<Id, List<ShipStationTrackingEventDTO>>();

        processTrackingDocuments(unprocessedRecords, jsonDocumentMap, shipmentsToUpsert, trackingEventsMap);

        // Upsert Shipment records
        shipmentRepo.upsertShipments(shipmentsToUpsert);

        // Process Tracking Events
        processTrackingEvents(trackingEventsMap);
    }

    /**
     * @description Filters out tracking master records that have already been processed
     * @param trackingMasterRecords Records to filter
     * @return Filtered list of unprocessed records
     */
    private List<Tracking_Master__c> filterAlreadyProcessedRecords(List<Tracking_Master__c> trackingMasterRecords) {
        Set<Id> alreadyProcessedMasterIds = new Set<Id>();
        Map<Id, Integer> eventCountByMasterId = trackingEventRepo.fetchEventCountByTrackingMasterIds(
            new Map<Id, Tracking_Master__c>(trackingMasterRecords).keySet()
        );

        for (Tracking_Master__c master : trackingMasterRecords) {
            Integer existingEventCount = eventCountByMasterId.get(master.Id) != null
                ? eventCountByMasterId.get(master.Id)
                : 0;

            if (existingEventCount > 0) {
                alreadyProcessedMasterIds.add(master.Id);
            }
        }

        List<Tracking_Master__c> unprocessedRecords = new List<Tracking_Master__c>();
        for (Tracking_Master__c master : trackingMasterRecords) {
            if (!alreadyProcessedMasterIds.contains(master.Id)) {
                unprocessedRecords.add(master);
            }
        }
        return unprocessedRecords;
    }

    /**
     * @description Processes tracking documents to create shipments and extract tracking events
     * @param unprocessedRecords Records to process
     * @param jsonDocumentMap Map of JSON documents by content version ID
     * @param shipmentsToUpsert Output parameter for shipments to upsert
     * @param trackingEventsMap Output parameter for tracking events
     */
    private void processTrackingDocuments(
        List<Tracking_Master__c> unprocessedRecords,
        Map<Id, String> jsonDocumentMap,
        List<Shipment__c> shipmentsToUpsert,
        Map<Id, List<ShipStationTrackingEventDTO>> trackingEventsMap
    ) {
        for (Tracking_Master__c trackingMaster : unprocessedRecords) {
            String jsonBody = jsonDocumentMap.get(trackingMaster.Content_Version_Id__c) ?? '';

            TrackingResponseData responseData = parseTrackingData(jsonBody);
            if (responseData.isEmpty()) {
                continue;
            }

            Shipment__c shipment = createOrUpdateShipment(trackingMaster, responseData.trackingResponse);
            shipmentsToUpsert.add(shipment);

            if (responseData.hasEvents()) {
                trackingEventsMap.put(trackingMaster.Id, responseData.trackingResponse.data.events);
            }
        }
    }

    /**
     * @description Wrapper class to hold parsed tracking response data
     */
    private class TrackingResponseData {
        public ShipStationTrackingResponseDTO trackingResponse;

        /* Returns true if the tracking response is empty. */
        public Boolean isEmpty() {
            return trackingResponse == null || trackingResponse.data == null;
        }

        /* This method returns true if the tracking response has events. */
        public Boolean hasEvents() {
            return !isEmpty() && trackingResponse.data.events != null && !trackingResponse.data.events.isEmpty();
        }
    }

    /**
     * @description Parses JSON data into tracking response objects
     * @param jsonBody JSON string to parse
     * @return Parsed tracking response data
     */
    private static TrackingResponseData parseTrackingData(String jsonBody) {
        if (String.isBlank(jsonBody)) {
            return new TrackingResponseData();
        }

        TrackingResponseData result = new TrackingResponseData();

        // Try to parse as ShipStationTrackingResponseDTO
        result.trackingResponse = hydrateTrackingResponse(jsonBody);

        // If that fails, try parsing as ShipStationTrackingDataDTO
        if (result.trackingResponse == null) {
            ShipStationTrackingDataDTO trackingData = hydrateTrackingData(jsonBody);

            if (trackingData != null) {
                result.trackingResponse = new ShipStationTrackingResponseDTO();
                result.trackingResponse.data = trackingData;
            }
        }

        return result;
    }

    /**
     * @description Builds a map of JSON documents by content version ID
     * @param trackingMasterRecords Records containing Content Version IDs
     * @return Map of JSON documents by content version ID
     */
    private Map<Id, String> buildJsonDocumentMap(List<Tracking_Master__c> trackingMasterRecords) {
        List<Id> contentVersionIds = getContentVersionIdsFromTrackingMasterRecords(trackingMasterRecords);
        return contentRepo.fetchContentVersionsById(contentVersionIds);
    }

    /**
     * @description Extracts Content Version IDs from Tracking Master records
     * @param trackingMasterRecords Records to extract Content Version IDs from
     * @return List of Content Version IDs
     */
    private static List<Id> getContentVersionIdsFromTrackingMasterRecords(
        List<Tracking_Master__c> trackingMasterRecords
    ) {
        List<Id> contentVersionIds = new List<Id>();
        for (Tracking_Master__c trackingMaster : trackingMasterRecords) {
            if (trackingMaster.Content_Version_Id__c != null) {
                contentVersionIds.add(trackingMaster.Content_Version_Id__c);
            }
        }
        return contentVersionIds;
    }

    /**
     * @description Deserializes JSON into ShipStationTrackingResponseDTO
     * @param jsonBody JSON string to deserialize
     * @return Deserialized ShipStationTrackingResponseDTO, or null if parsing fails
     */
    private static ShipStationTrackingResponseDTO hydrateTrackingResponse(String jsonBody) {
        try {
            return (ShipStationTrackingResponseDTO) JSON.deserialize(jsonBody, ShipStationTrackingResponseDTO.class);
        } catch (JSONException jsonException) {
            // JSON parsing error handled
        }
        return null;
    }

    /**
     * @description Deserializes JSON into ShipStationTrackingDataDTO
     * @param jsonBody JSON string to deserialize
     * @return Deserialized ShipStationTrackingDataDTO, or null if parsing fails
     */
    private static ShipStationTrackingDataDTO hydrateTrackingData(String jsonBody) {
        try {
            return (ShipStationTrackingDataDTO) JSON.deserialize(jsonBody, ShipStationTrackingDataDTO.class);
        } catch (JSONException jsonException) {
            // JSON parsing error handled
        }
        return null;
    }

    /**
     * @description Creates or updates a Shipment record
     * @param trackingMaster Parent tracking master record
     * @param trackingResponse Tracking response data
     * @return Shipment record to be upserted
     */
    private Shipment__c createOrUpdateShipment(
        Tracking_Master__c trackingMaster,
        ShipStationTrackingResponseDTO trackingResponse
    ) {
        Shipment__c shipment = shipmentRepo.fetchShipmentByTrackingNumber(trackingMaster.Tracking_Number__c);

        shipment.Tracking_Master__c = trackingMaster.Id;
        shipment.Tracking_Number__c = trackingMaster.Tracking_Number__c;
        shipment.Status_Code__c = trackingResponse.data.status_code;
        shipment.Status_Description__c = trackingResponse.data.status_description;
        shipment.Carrier__c = getCarrierValue(trackingResponse.data.carrier_code);
        shipment.Ship_Date__c = parseDate(trackingResponse.data.ship_date);
        shipment.Estimated_Delivery_Date__c = parseDate(trackingResponse.data.estimated_delivery_date);
        shipment.Actual_Delivery_Date__c = parseDate(trackingResponse.data.actual_delivery_date);
        shipment.Exception_Description__c = trackingResponse.data.exception_description;
        shipment.Status__c = getStatusValue(trackingResponse.data.status_description);

        return shipment;
    }

    /**
     * @description Processes tracking events and creates new records
     * @param trackingEventsMap Map of tracking master IDs to event DTOs
     */
    private void processTrackingEvents(Map<Id, List<ShipStationTrackingEventDTO>> trackingEventsMap) {
        if (trackingEventsMap.isEmpty()) {
            return;
        }

        List<Id> trackingMasterIds = new List<Id>(trackingEventsMap.keySet());
        TrackingEventMetadata metadata = prepareTrackingEventMetadata(trackingMasterIds);

        Set<String> existingEventKeys = getExistingEventKeys(trackingMasterIds, metadata.trackingNumberToShipmentIdMap);

        EventBatch eventBatch = createEventBatch(trackingEventsMap, metadata, existingEventKeys);

        saveEventBatch(eventBatch);
    }

    /**
     * @description Class to hold tracking event metadata
     */
    private class TrackingEventMetadata {
        public Map<Id, String> trackingMasterToNumberMap;
        public Map<String, Id> trackingNumberToShipmentIdMap;
        public Map<Id, String> shipmentIdToShipmentStatusCode;
    }

    /**
     * @description Class to hold batches of events for insertion
     */
    private class EventBatch {
        public List<Tracking_Event__c> trackingEvents = new List<Tracking_Event__c>();
        public List<Shipment_Events__c> shipmentEvents = new List<Shipment_Events__c>();
    }

    /**
     * @description Prepares metadata for tracking event processing
     * @param trackingMasterIds IDs of tracking master records
     * @return Metadata for tracking event processing
     */
    private TrackingEventMetadata prepareTrackingEventMetadata(List<Id> trackingMasterIds) {
        TrackingEventMetadata metadata = new TrackingEventMetadata();

        metadata.trackingMasterToNumberMap = buildTrackingMasterIdToTrackingNumberMap(trackingMasterIds);

        metadata.trackingNumberToShipmentIdMap = new Map<String, Id>();
        metadata.shipmentIdToShipmentStatusCode = buildShipmentIdToShipmentStatusCode(
            metadata.trackingMasterToNumberMap,
            metadata.trackingNumberToShipmentIdMap
        );

        return metadata;
    }

    /**
     * @description Gets existing event keys to avoid duplicates
     * @param trackingMasterIds IDs of tracking master records
     * @param trackingNumberToShipmentIdMap Map of tracking numbers to shipment IDs
     * @return Set of existing event keys
     */
    private Set<String> getExistingEventKeys(
        List<Id> trackingMasterIds,
        Map<String, Id> trackingNumberToShipmentIdMap
    ) {
        Set<String> existingEventKeys = new Set<String>();

        // Fetch by tracking master ID
        Tracking_Event__c[] existingMasterEvents = trackingEventRepo.fetchTrackingEventsByTrackingMasterIds(
            trackingMasterIds
        );

        for (Tracking_Event__c event : existingMasterEvents) {
            String key = buildEventKey(event);
            if (key != null) {
                existingEventKeys.add(key);
            }
        }

        // Fetch by shipment ID as a safety check
        Tracking_Event__c[] existingShipmentEvents = trackingEventRepo.fetchTrackingEventsByShipmentIds(
            trackingNumberToShipmentIdMap.values()
        );

        for (Tracking_Event__c event : existingShipmentEvents) {
            String key = buildEventKey(event);
            if (key != null) {
                existingEventKeys.add(key);
            }
        }
        return existingEventKeys;
    }

    /**
     * @description Creates a batch of events for insertion
     * @param trackingEventsMap Map of tracking master IDs to event DTOs
     * @param metadata Tracking event metadata
     * @param existingEventKeys Set of existing event keys
     * @return Batch of events to insert
     */
    private static EventBatch createEventBatch(
        Map<Id, List<ShipStationTrackingEventDTO>> trackingEventsMap,
        TrackingEventMetadata metadata,
        Set<String> existingEventKeys
    ) {
        EventBatch eventBatch = new EventBatch();

        for (Id trackingMasterId : trackingEventsMap.keySet()) {
            List<ShipStationTrackingEventDTO> events = trackingEventsMap.get(trackingMasterId);
            String trackingNumber = metadata.trackingMasterToNumberMap.get(trackingMasterId);
            Id shipmentId = metadata.trackingNumberToShipmentIdMap.get(trackingNumber);
            String shipmentStatusCode = metadata.shipmentIdToShipmentStatusCode.get(shipmentId);

            if (shipmentId == null) {
                continue;
            }

            processEventBatch(
                events,
                trackingNumber,
                trackingMasterId,
                shipmentId,
                shipmentStatusCode,
                existingEventKeys,
                eventBatch
            );
        }

        return eventBatch;
    }

    /**
     * @description Processes events for a single tracking master
     * @param events List of event DTOs
     * @param trackingNumber Tracking number
     * @param trackingMasterId ID of tracking master record
     * @param shipmentId ID of shipment record
     * @param shipmentStatusCode Status code of shipment
     * @param existingEventKeys Set of existing event keys
     * @param eventBatch Batch of events to insert
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static void processEventBatch(
        List<ShipStationTrackingEventDTO> events,
        String trackingNumber,
        Id trackingMasterId,
        Id shipmentId,
        String shipmentStatusCode,
        Set<String> existingEventKeys,
        EventBatch eventBatch
    ) {
        for (ShipStationTrackingEventDTO eventDto : events) {
            String eventKey = buildEventKey(trackingNumber, eventDto);

            if (existingEventKeys.contains(eventKey)) {
                continue;
            }

            eventBatch.trackingEvents.add(eventDto.toTrackingEvent(shipmentId, trackingMasterId));
            eventBatch.shipmentEvents.add(eventDto.toShipmentEvent(shipmentId, shipmentStatusCode));

            existingEventKeys.add(eventKey);
        }
    }

    /**
     * @description Saves a batch of events to the database
     * @param eventBatch Batch of events to save
     */
    private void saveEventBatch(EventBatch eventBatch) {
        if (!eventBatch.trackingEvents.isEmpty()) {
            Map<String, Tracking_Event__c> uniqueEvents = deduplicateTrackingEvents(eventBatch.trackingEvents);
            trackingEventRepo.doCreate(uniqueEvents.values());
        }

        if (!eventBatch.shipmentEvents.isEmpty()) {
            Map<String, Shipment_Events__c> uniqueShipmentEvents = deduplicateShipmentEvents(eventBatch.shipmentEvents);
            shipmentEventRepo.doCreate(uniqueShipmentEvents.values());
        }
    }

    /**
     * @description Deduplicates tracking events before insertion
     * @param events List of tracking events
     * @return Map of unique tracking events
     */
    private static Map<String, Tracking_Event__c> deduplicateTrackingEvents(List<Tracking_Event__c> events) {
        Map<String, Tracking_Event__c> uniqueEvents = new Map<String, Tracking_Event__c>();

        for (Tracking_Event__c event : events) {
            String uniqueKey =
                event.Tracking_Master__c +
                '-' +
                event.Event_Code__c +
                '-' +
                (event.Occurred_At__c != null ? String.valueOf(event.Occurred_At__c.getTime()) : '');
            uniqueEvents.put(uniqueKey, event);
        }

        return uniqueEvents;
    }

    /**
     * @description Deduplicates shipment events before insertion
     * @param events List of shipment events
     * @return Map of unique shipment events
     */
    private static Map<String, Shipment_Events__c> deduplicateShipmentEvents(List<Shipment_Events__c> events) {
        Map<String, Shipment_Events__c> uniqueEvents = new Map<String, Shipment_Events__c>();

        for (Shipment_Events__c event : events) {
            String uniqueKey =
                event.Shipment__c +
                '-' +
                event.Event_Code__c +
                '-' +
                (event.Occurred_At__c != null ? String.valueOf(event.Occurred_At__c.getTime()) : '');
            uniqueEvents.put(uniqueKey, event);
        }

        return uniqueEvents;
    }

    /**
     * @description Builds an event key for deduplication
     * @param trackingNumber Tracking number
     * @param eventDto Event DTO
     * @return Event key for deduplication
     */
    private static String buildEventKey(String trackingNumber, ShipStationTrackingEventDTO eventDto) {
        String eventKey = trackingNumber + '-' + eventDto.event_code;
        return eventKey;
    }

    /**
     * @description Builds an event key for an existing tracking event
     * @param event Existing tracking event
     * @return Event key for deduplication
     */
    private static String buildEventKey(Tracking_Event__c event) {
        if (event.Occurred_At__c == null || String.isBlank(event.Event_Code__c)) {
            return null;
        }

        String trackingNumber = event.Shipment__r.Tracking_Number__c;
        String eventCode = event.Event_Code__c;

        return trackingNumber + '-' + eventCode;
    }

    /**
     * @description Builds a map of shipment IDs to status codes
     * @param trackingMasterToNumberMap Map of tracking master IDs to tracking numbers
     * @param trackingNumberToShipmentIdMap Output map of tracking numbers to shipment IDs
     * @return Map of shipment IDs to status codes
     */
    private Map<Id, String> buildShipmentIdToShipmentStatusCode(
        Map<Id, String> trackingMasterToNumberMap,
        Map<String, Id> trackingNumberToShipmentIdMap
    ) {
        Map<Id, String> shipmentIdToShipmentStatusCode = new Map<Id, String>();
        for (Shipment__c shipment : shipmentRepo.fetchShipmentsByTrackingNumbers(trackingMasterToNumberMap.values())) {
            trackingNumberToShipmentIdMap.put(shipment.Tracking_Number__c, shipment.Id);
            shipmentIdToShipmentStatusCode.put(shipment.Id, shipment.Status_Code__c);
        }
        return shipmentIdToShipmentStatusCode;
    }

    /**
     * @description Builds a map of tracking master IDs to tracking numbers
     * @param trackingMasterIds IDs of tracking master records
     * @return Map of tracking master IDs to tracking numbers
     */
    private Map<Id, String> buildTrackingMasterIdToTrackingNumberMap(List<Id> trackingMasterIds) {
        Map<Id, String> trackingMasterToNumberMap = new Map<Id, String>();
        for (Tracking_Master__c master : trackingMasterRepo.fetchTrackingMastersById(trackingMasterIds)) {
            trackingMasterToNumberMap.put(master.Id, master.Tracking_Number__c);
        }
        return trackingMasterToNumberMap;
    }

    /**
     * @description Gets carrier picklist values
     * @return List of carrier picklist values
     */
    public static List<String> getCarrierPicklistValues() {
        List<String> carrierPicklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Shipment__c.Carrier__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            carrierPicklistValues.add(picklistEntry.getValue());
        }
        return carrierPicklistValues;
    }

    /**
     * @description Gets status picklist values
     * @return List of status picklist values
     */
    public static List<String> getStatusPicklistValues() {
        List<String> statusPicklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Shipment__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            statusPicklistValues.add(picklistEntry.getValue());
        }
        return statusPicklistValues;
    }

    /**
     * @description Maps a carrier code to a picklist value
     * @param carrierCode Carrier code to map
     * @return Corresponding picklist value, or null if not found
     */
    public static String getCarrierValue(String carrierCode) {
        List<String> carrierPicklistValues = getCarrierPicklistValues();
        for (String carrierValue : carrierPicklistValues) {
            if (carrierValue.toLowerCase() == carrierCode.toLowerCase()) {
                return carrierValue;
            }
        }
        return null;
    }

    /**
     * @description Maps a status code to a picklist value
     * @param statusCode Status code to map
     * @return Corresponding picklist value, or null if not found
     */
    public static String getStatusValue(String statusCode) {
        List<String> statusPicklistValues = getStatusPicklistValues();
        for (String statusValue : statusPicklistValues) {
            if (statusValue?.toLowerCase() == statusCode?.toLowerCase()) {
                return statusValue;
            }
        }
        return null;
    }

    /**
     * @description Parses a date string into a DateTime object
     * @param dateString Date string to parse
     * @return Parsed DateTime, or null if parsing fails
     */
    private static Datetime parseDate(String dateString) {
        if (String.isNotBlank(dateString)) {
            try {
                if (dateString.contains('T')) {
                    dateString = dateString.replace('T', ' ');
                }
                return Datetime.valueOf(dateString);
            } catch (Exception e) {
                // Date parsing error handled
            }
        }
        return null;
    }
}
