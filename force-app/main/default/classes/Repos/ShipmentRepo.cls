public with sharing class ShipmentRepo extends BaseRepo {
    public ShipmentRepo() {
        super(Shipment__c.SObjectType);
    }

    public Database.UpsertResult[] upsertShipments(Shipment__c[] shipments) {
        return this.doUpsert(shipments);
    }

    public Shipment__c fetchShipmentByTrackingNumber(String trackingNumber) {
        Shipment__c shipment = new Shipment__c();
        Shipment__c[] shipments;
        try {
            shipments = (List<Shipment__c>) fetchShipmentsByTrackingNumbers(new List<String>{ trackingNumber });
        } catch (ListException error) {
            return new Shipment__c();
        }
        shipment = shipments.isEmpty() ? shipment : shipments[0];
        return shipment;
    }

    public Shipment__c[] fetchShipmentsByTrackingNumbers(List<String> trackingNumbers) {
        String selectClause = this.calculateSelectClause(
            new Set<String>{
                'Id',
                'Tracking_Number__c',
                'Status_Code__C',
                'Tracking_Master__c',
                'Shipment__c.Status_Description__c'
            }
        );
        String fromObj = this.calculateFromClause();
        String whereClause = ' WHERE Tracking_Number__c IN :trackingNumbers';
        String query = selectClause + ' ' + fromObj + ' ' + whereClause;
        return fetch(query, new Map<String, Object>{ 'trackingNumbers' => trackingNumbers });
    }
}
