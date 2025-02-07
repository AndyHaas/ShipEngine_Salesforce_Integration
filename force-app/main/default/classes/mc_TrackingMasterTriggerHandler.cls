public class mc_TrackingMasterTriggerHandler {
    /**
    * Process Tracking Master records and create related Shipment and Tracking Event records
    * @param trackingMasterRecords The list of Tracking Master records to process
    */
    public static void processTrackingMaster(List<Tracking_Master__c> trackingMasterRecords) {
        Map<Id, List<mc_DTO_TrackingEvent>> trackingEventsMap = new Map<Id, List<mc_DTO_TrackingEvent>>();
        List<Shipment__c> shipmentsToUpsert = new List<Shipment__c>();

        // Iterate over Tracking Master records to process Shipments and parse events
        for (Tracking_Master__c   trackingMaster: trackingMasterRecords) {
            if (String.isNotBlank(trackingMaster.Webhook_JSON_Body__c)) {
                try {
                    // Parse JSON into DTO
                    mc_DTO_TrackingResponse trackingData = (mc_DTO_TrackingResponse) JSON.deserialize(
                        trackingMaster.Webhook_JSON_Body__c,
                        mc_DTO_TrackingResponse.class
                    );

                    // Create or update Shipment record
                    Shipment__c shipment = createOrUpdateShipment(trackingMaster, trackingData);
                    shipmentsToUpsert.add(shipment);

                    // Map events to their parent Tracking Master record
                    if (trackingData.data.events != null && !trackingData.data.events.isEmpty()) {
                        trackingEventsMap.put(trackingMaster.Id, trackingData.data.events);
                    }
                } catch (Exception e) {
                    // Log the error or add additional error handling here
                    System.debug('Error parsing JSON for Tracking_Master__c ID: ' + trackingMaster.Id + ' - ' + e.getMessage());
                    try {
                        // Parse the JSON body as a Tracking Data
                        mc_DTO_TrackingData trackingData = (mc_DTO_TrackingData) JSON.deserialize(
                            trackingMaster.Webhook_JSON_Body__c,
                            mc_DTO_TrackingData.class
                        );

                        mc_DTO_TrackingResponse trackingResponse = new mc_DTO_TrackingResponse();

                        if (trackingResponse.data == null) {
                            trackingResponse.data = new mc_DTO_TrackingData();
                        }

                        trackingResponse.data = trackingData;

                        // Create or update Shipment record
                        Shipment__c shipment = createOrUpdateShipment(trackingMaster, trackingResponse);
                        shipmentsToUpsert.add(shipment);

                        // Map events to their parent Tracking Master record
                        if (trackingData.events != null && !trackingData.events.isEmpty()) {
                            trackingEventsMap.put(trackingMaster.Id, trackingData.events);
                        }
                    } catch (Exception ex) {
                        // Log the error or add additional error handling here
                        System.debug('Error parsing JSON as Tracking Data: ' + ex.getMessage());
                    }

                }
            }
        }

        System.debug('Shipments to Upsert: ' + shipmentsToUpsert);
        // Upsert Shipment records in bulk
        if (!shipmentsToUpsert.isEmpty()) {
            upsert shipmentsToUpsert;
        }

        System.debug('Tracking Events Map: ' + trackingEventsMap);
        // Process Tracking Events
        if (!trackingEventsMap.isEmpty()) {
            processTrackingEvents(trackingEventsMap);
        }
    }

    /**
    * Create or update a Shipment record based on the Tracking Master and Tracking Data
    * @param trackingMaster The parent Tracking Master record
    * @param trackingResponse The tracking response to populate the Shipment record
    * @return The new or updated Shipment record
    */
    private static Shipment__c createOrUpdateShipment(Tracking_Master__c trackingMaster, mc_DTO_TrackingResponse trackingResponse) {
        // Query for an existing Shipment record with the same Tracking Number
        Shipment__c shipment = null;
        if (String.isNotBlank(trackingMaster.Tracking_Number__c)) {
            // Use a list to safely handle no rows
            List<Shipment__c> shipments = [
                SELECT Id, Tracking_Number__c, Tracking_Master__c
                FROM Shipment__c
                WHERE Tracking_Number__c = :trackingMaster.Tracking_Number__c
                LIMIT 1
            ];

            if (!shipments.isEmpty()) {
                shipment = shipments[0];
                System.debug('Existing Shipment found: ' + shipment);
            } else {
                System.debug('No existing Shipment found for Tracking Number: ' + trackingMaster.Tracking_Number__c);
                shipment = new Shipment__c();
            }
        }
        
        // Populate Shipment fields
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

        System.debug('New Data Shipment: ' + shipment);
        return shipment;
    }

    /**
    * Process Tracking Events and create new Tracking Event records
    * @param trackingEventsMap The map of Tracking Master IDs to Tracking Events
    */
    private static void processTrackingEvents(Map<Id, List<mc_DTO_TrackingEvent>> trackingEventsMap) {
        List<Tracking_Event__c> newEvents = new List<Tracking_Event__c>();
        List<Shipment_events__c> newShipmentEvetns = new List<Shipment_events__c>();
        Set<String> existingEventKeys = new Set<String>();

        // Convert the Map keys to a list for querying
        List<Id> trackingMasterIds = new List<Id>(trackingEventsMap.keySet());
        System.debug('Tracking Master IDs: ' + trackingMasterIds);
        // Step 1: Fetch Tracking Numbers for Tracking_Master__c records
        Map<Id, String> trackingMasterToNumberMap = new Map<Id, String>();
        for (Tracking_Master__c master : [
            SELECT Id, Tracking_Number__c
            FROM Tracking_Master__c
            WHERE Id IN :trackingMasterIds
        ]) {
            trackingMasterToNumberMap.put(master.Id, master.Tracking_Number__c);
        }
        System.debug('Tracking Master to Number Map: ' + trackingMasterToNumberMap);

        // Step 2: Fetch related Shipment records
        Map<String, Id> trackingNumberToShipmentIdMap = new Map<String, Id>();
        Map<Id, String> shipmentIdtoShipmentStatusCode = new Map<Id, String>();
        for (Shipment__c shipment : [
            SELECT Id, Tracking_Number__c, Status_Code__c
            FROM Shipment__c
            WHERE Tracking_Number__c IN :trackingMasterToNumberMap.values()
        ]) {
            trackingNumberToShipmentIdMap.put(shipment.Tracking_Number__c, shipment.Id);
            shipmentIdtoShipmentStatusCode.put(shipment.Id,shipment.Status_Code__c);
        }
        System.debug('Tracking Number to Shipment ID Map: ' + trackingNumberToShipmentIdMap);

        System.debug('Tracking Events Map: ' + trackingEventsMap.keySet());
        // Step 3: Fetch existing Tracking Events using Shipment__c
        for (Tracking_Event__c event : [
            SELECT Shipment__c, Occurred_At__c, Event_Code__c, Shipment__r.Tracking_Number__c
            FROM Tracking_Event__c
            WHERE Shipment__c IN :trackingNumberToShipmentIdMap.values()
        ]) {
            if (event.Occurred_At__c != null && String.isNotBlank(event.Event_Code__c)) {
                String eventKey = event.Shipment__r.Tracking_Number__c + '-' + formatDateForKey(event.Occurred_At__c) + '-' + event.Event_Code__c;
                existingEventKeys.add(eventKey);
                System.debug('Added Existing Event Key: ' + eventKey);
            }
        }
        System.debug('Final Existing Event Keys: ' + existingEventKeys);

        // Step 4: Iterate over Tracking Events and create new records
        for (Id trackingMasterId : trackingEventsMap.keySet()) {
            List<mc_DTO_TrackingEvent> events = trackingEventsMap.get(trackingMasterId);
            String trackingNumber = trackingMasterToNumberMap.get(trackingMasterId);
            Id shipmentId = trackingNumberToShipmentIdMap.get(trackingNumber);            
            String shipmentStatusCode = shipmentIdtoShipmentStatusCode.get(shipmentId);
            if (shipmentId == null) {
                System.debug('No Shipment found for Tracking Number: ' + trackingNumber);
                // Depending on requirements, either skip the event or throw an exception
                continue;
            }

            for (mc_DTO_TrackingEvent eventDto : events) {
                String eventKey = trackingNumber + '-' + formatDateForKey(parseDate(eventDto.occurred_at)) + '-' + eventDto.event_code;
                System.debug('New Event Key: ' + eventKey);

                // Check if the event is a duplicate
                if (!existingEventKeys.contains(eventKey)) {
                    Tracking_Event__c trackingEvent = new Tracking_Event__c();
                    trackingEvent.Tracking_Master__c = trackingMasterId; // Link to Tracking Master
                    trackingEvent.Shipment__c = shipmentId; // Link to Shipment
                    trackingEvent.Occurred_At__c = parseDate(eventDto.occurred_at);
                    trackingEvent.Description__c = eventDto.description;
                    trackingEvent.Event_Code__c = eventDto.event_code;
                    trackingEvent.Event_Description__c = eventDto.carrier_status_description;
                    trackingEvent.City_Locality__c = eventDto.city_locality;
                    trackingEvent.State_Province__c = eventDto.state_province;
                    trackingEvent.Postal_Code__c = eventDto.postal_code;
                    
                    //Create Shipment Event
                    Shipment_events__c shipmentEvent = new Shipment_events__c();
                    shipmentEvent.Shipment__c = shipmentId;
                    shipmentEvent.Status_Code__c = shipmentStatusCode;
					shipmentEvent.Occurred_At__c = parseDate(eventDto.occurred_at);
                    shipmentEvent.Description__c = eventDto.description;
                    shipmentEvent.Event_Code__c = eventDto.event_code;
                    shipmentEvent.Event_Description__c = eventDto.carrier_status_description;
                    shipmentEvent.City_Locality__c = eventDto.city_locality;
                    shipmentEvent.State_Province__c = eventDto.state_province;
                    shipmentEvent.Postal_Code__c = eventDto.postal_code;
                    
                    newShipmentEvetns.add(shipmentEvent);
                    newEvents.add(trackingEvent);
                    existingEventKeys.add(eventKey); // Add key to prevent further duplicates
                } else {
                    System.debug('Duplicate Event Skipped: ' + eventKey);
                }
            }
        }

        System.debug('New Tracking Events to Insert: ' + newEvents);
        // Step 5: Insert new Tracking Events
        if (!newEvents.isEmpty()) {
            insert newShipmentEvetns;
            insert newEvents;
        }
    }

    /**
    * Get the Carrier's picklist values from the Shipment object
    * @return The list of Carrier picklist values
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
    * Get the Status picklist values from the Shipment object
    * @return The list of Status picklist values
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
    * Map the Carrier picklist values to their respective API codes
    * @return The Salesforce picklist value to API code map
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
    * Map the Status picklist values to their respective API codes
    * @return The Salesforce picklist value to API code map
    */
    public static String getStatusValue(String statusCode) {
        List<String> statusPicklistValues = getStatusPicklistValues();
        for (String statusValue : statusPicklistValues) {
            if (statusValue.toLowerCase() == statusCode.toLowerCase()) {
                return statusValue;
            }
        }
        return null;
    }

    // Helper method to parse date strings to DateTime
    private static DateTime parseDate(String dateString) {
        if (String.isNotBlank(dateString)) {
            try {
                // Check if the string is in ISO 8601 format (with "T")
                if (dateString.contains('T')) {
                    // Replace "T" with a space to match Salesforce's expected format
                    dateString = dateString.replace('T', ' ');
                }

                // Convert to DateTime
                return DateTime.valueOf(dateString);
            } catch (Exception e) {
                System.debug('Invalid date format: ' + dateString + ' | Error: ' + e.getMessage());
            }
        }
        return null;
    }

    private static String formatDateForKey(DateTime dt) {
        if (dt != null) {
            return dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); // ISO 8601 format
        }
        return null;
    }

}