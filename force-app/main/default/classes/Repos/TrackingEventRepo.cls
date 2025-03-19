public with sharing class TrackingEventRepo extends BaseRepo {
    public TrackingEventRepo() {
        super(Tracking_Event__c.SObjectType, true);
    }

    @TestVisible
    private static Datetime parse8601String(String dateTimeString) {
        String jsonDatetime = '"' + dateTimeString + '"';
        system.debug('Converting: ' + jsonDatetime);
        return (Datetime) JSON.deserialize(jsonDatetime, Datetime.class);
    }

    /**
     * @description Fetches event count grouped by tracking master ID
     * @param trackingMasterIds Set of tracking master IDs
     * @return Map of tracking master ID to event count
     */
    public Map<Id, Integer> fetchEventCountByTrackingMasterIds(Set<Id> trackingMasterIds) {
        Map<Id, Integer> eventCountByMasterId = new Map<Id, Integer>();

        if (trackingMasterIds == null || trackingMasterIds.isEmpty()) {
            return eventCountByMasterId;
        }

        AggregateResult[] results = [
            SELECT Tracking_Master__c, COUNT(Id) eventCount
            FROM Tracking_Event__c
            WHERE Tracking_Master__c IN :trackingMasterIds
            GROUP BY Tracking_Master__c
        ];

        for (AggregateResult result : results) {
            Id trackingMasterId = (Id) result.get('Tracking_Master__c');
            Integer eventCount = (Integer) result.get('eventCount');
            eventCountByMasterId.put(trackingMasterId, eventCount);
        }

        return eventCountByMasterId;
    }

    /**
     * @description Fetches tracking events by shipment IDs
     * @param shipmentIds List of shipment IDs
     * @return List of tracking events
     */
    public Tracking_Event__c[] fetchTrackingEventsByShipmentIds(Id[] shipmentIds) {
        String selectClause = this.calculateSelectClause(
            new Set<String>{
                'Id',
                'Occurred_At__c',
                'Description__c',
                'Event_Code__c',
                'Event_Description__c',
                'City_Locality__c',
                'Postal_Code__c',
                'State_Province__c',
                'Shipment__c',
                'Tracking_Master__c',
                'Shipment__r.Tracking_Number__c'
            }
        );
        String fromObj = this.calculateFromClause();
        String whereClause = ' WHERE Shipment__c IN :shipmentIds';
        String query = selectClause + ' ' + fromObj + ' ' + whereClause;
        return this.fetch(query, new Map<String, Object>{ 'shipmentIds' => shipmentIds });
    }

    /**
     * @description Fetches tracking events by tracking master IDs
     * @param trackingMasterIds List of tracking master IDs
     * @return List of tracking events
     */
    public Tracking_Event__c[] fetchTrackingEventsByTrackingMasterIds(Id[] trackingMasterIds) {
        String selectClause = this.calculateSelectClause(
            new Set<String>{
                'Id',
                'Event_Code__c',
                'Description__c',
                'Occurred_At__c',
                'Shipment__c',
                'Tracking_Master__c',
                'Shipment__r.Tracking_Number__c'
            }
        );
        String fromObj = this.calculateFromClause();
        String whereClause = ' WHERE Tracking_Master__c IN :trackingMasterIds';
        String query = selectClause + ' ' + fromObj + ' ' + whereClause;
        return this.fetch(query, new Map<String, Object>{ 'trackingMasterIds' => trackingMasterIds });
    }
}
