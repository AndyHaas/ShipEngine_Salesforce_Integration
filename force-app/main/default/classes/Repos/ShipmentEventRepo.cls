public with sharing class ShipmentEventRepo extends BaseRepo {
    public ShipmentEventRepo() {
        super(Shipment_Events__c.SObjectType, true);
    }

    public Shipment_Events__c[] fetchShipmentEventsByShipmentId(Id shipmentId) {
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
                'Shipment__r.Tracking_Number__c'
            }
        );
        String fromObj = this.calculateFromClause();
        String whereClause = ' WHERE Shipment__c = :shipmentId';
        String query = selectClause + ' ' + fromObj + ' ' + whereClause;
        return this.fetch(query, new Map<String, Object>{ 'shipmentId' => shipmentId });
    }
}
