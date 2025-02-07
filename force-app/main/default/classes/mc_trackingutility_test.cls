@isTest
public class mc_trackingutility_test {
	@isTest
    public static void getBaseURLTest(){
        Test.startTest();
        String baseURL = mc_TrackingUltility.getBaseUrl();
        System.AssertEquals(baseURL, 'https://api.shipengine.com/v1/');
        Test.stopTest();
    }
    
    @isTest
    public static void formatCarrierTest(){
        Test.StartTest();
        String result = mc_TrackingUltility.formatCarrier('asd');
        System.AssertEquals(result,'asd');
        Test.StopTest();
    }
    
    @isTest
    public static void getTrackingStatusTest(){
        Test.StartTest();
        String unknown = mc_TrackingUltility.getTrackingStatus('UN');
        String accepted = mc_TrackingUltility.getTrackingStatus('AC');
        String inTransit = mc_TrackingUltility.getTrackingStatus('IT');
        String delivered = mc_TrackingUltility.getTrackingStatus('DE');
        String exceptions = mc_TrackingUltility.getTrackingStatus('EX');
        String delivertAttempt = mc_TrackingUltility.getTrackingStatus('AT');
        String notYetInSystem = mc_TrackingUltility.getTrackingStatus('NY');
        String deliveredToCollectionLocation = mc_TrackingUltility.getTrackingStatus('SP');
        String emptyParam = mc_TrackingUltility.getTrackingStatus('unknown');
        
        
        System.assertEquals(unknown,'Unknown');
        System.assertEquals(accepted,'Accepted');
        System.assertEquals(inTransit,'In Transit');
        System.assertEquals(delivered,'Delivered');
        System.assertEquals(exceptions,'Exception');
        System.assertEquals(delivertAttempt,'Delivery Attempt');
        System.assertEquals(notYetInSystem,'Not Yet In System');
        System.assertEquals(deliveredToCollectionLocation,'Delivered To Collection Location');
        System.assertEquals(emptyParam,'Unknown');
        Test.StopTest();
    }
    
    @isTest
    public static void testm(){
         
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('COLLECTION_FAILED'), 'The package collection has failed.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('AWAITING_DESPATCH'), 'The package is awaiting despatch.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('COLLECTION_REQUESTED'), 'The package collection has been requested.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('DESPATCHED'), 'The package has been despatched.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('ELEC_ADVICE_RECD_BY_CARRIER'), 'Electronic advice has been received by the carrier.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('NOT_YET_RECEIVED_BY_CARRIER'), 'The package has not yet been received by the carrier.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('COLLECTION_MADE'), 'The package collection has been made.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('ATTEMPTED_DELIVERY'), 'An attempted delivery has been made.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('ATTEMPTED_DELIVERY_2ND'), 'A second attempted delivery has been made.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('ATTEMPTED_DELIVERY_3RD'), 'A third attempted delivery has been made.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('COD_AMOUNT_NOT_PAID'), 'The COD amount has not been paid.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('COD_AMOUNT_PAID'), 'The COD amount has been paid.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('CUSTOMER_CARDED'), 'The customer has been carded.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('CUSTOMER_IDENTIFICATION_FAILED'), 'Customer identification has failed.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('INVALID_METHOD_OF_PAYMENT'), 'The method of payment is invalid.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('NO_ACCESS_TO_RECIPIENTS_ADDRESS'), 'There was no access to the recipient\'s address.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('OUT_FOR_DELIVERY'), 'The package is out for delivery.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('DELIVERED'), 'The package has been delivered.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('DELIVERED_DAMAGED'), 'The package was delivered but damaged.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('DELIVERED_IN_PART'), 'The package has been delivered in part.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('DELIVERED_SPECIFIED_SAFE_PLACE'), 'The package was delivered to a specified safe place.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('DELIVERED_TO_ALTERNATIVE_DELIVERY_LOCATION'), 'The package was delivered to an alternative delivery location.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('DELIVERED_TO_NEIGHBOUR'), 'The package was delivered to a neighbour.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('DELIVERED_TO_PO_BOX'), 'The package was delivered to a PO box.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('PARCEL_COLLECTED_FROM_PICKUP_POINT'), 'The parcel was collected from a pickup point.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('POST_TRANSIT_STATUS'), 'The package is in a post-transit status.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('PROOF_OF_DELIVERY'), 'Proof of delivery is available.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('CANCELLED'), 'The shipment has been cancelled.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('CANCELLED_BEFORE_DESPATCH'), 'The shipment was cancelled before despatch.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('CUSTOMER_MOVED'), 'The customer has moved.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('HAZARDOUS_PROHIBITED'), 'The parcel contains hazardous or prohibited items.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('NOT_COLLECTED_FROM_PICKUP_POINT'), 'The parcel was not collected from the pickup point.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('NOT_DELIVERED'), 'The parcel was not delivered.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('NOT_DELIVERED_ADDRESSEE_DECEASED'), 'The parcel was not delivered because the addressee is deceased.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('PARCEL_DAMAGED'), 'The parcel has been damaged.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('PARCEL_DISPOSED'), 'The parcel has been disposed of.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('PARCEL_LOST'), 'The parcel has been lost.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('PARCEL_OUTSIDE_OF_SERVICE_CAPABILITY'), 'The parcel is outside of the service capability.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('REFUSED_BY_CUSTOMER'), 'The parcel was refused by the customer.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('RETURN_TO_SENDER'), 'The parcel is being returned to the sender.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('ADDRESS_QUERY'), 'There is an address query for the parcel.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('CARRIER_DELAYS'), 'The parcel is delayed due to the carrier.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('CUSTOMS_CLEARED'), 'The parcel has been cleared by customs.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('CUSTOMS_PROCESSING'), 'The parcel is undergoing customs processing.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('DELAYED_NOT_CARRIER'), 'The parcel is delayed due to reasons not related to the carrier.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('DELIVERY_ARRANGED_WITH_RECIPIENT'), 'Delivery has been arranged with the recipient.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('HELD_BY_CARRIER'), 'The parcel is held by the carrier.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('HELD_BY_CARRIER_FOR_CLEARANCE_PRE_PROCESSING'), 'The parcel is held by the carrier for clearance pre-processing.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('HELD_BY_CUSTOMS'), 'The parcel is held by customs.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('HELD_BY_EXPORT_CUSTOMS'), 'The parcel is held by export customs.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('HELD_BY_IMPORT_CUSTOMS'), 'The parcel is held by import customs.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('HUB_SCAN_OUT'), 'The parcel has been scanned out of the hub.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('IN_TRANSIT'), 'The parcel is in transit.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('INCORRECT_DECLARATION'), 'The parcel has an incorrect declaration.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('INFORMATION'), 'There is an information update about the parcel.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('MISSORTED'), 'The parcel has been missorted.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('PARCEL_OVER_LABELLED'), 'The parcel has been over-labelled.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('PARCEL_REPACKED'), 'The parcel has been repacked.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('PARCEL_UPDATE_NOTIFICATION_VIA_EMAIL'), 'A parcel update notification has been sent via email.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('PARCEL_UPDATE_NOTIFICATION_VIA_SMS'), 'A parcel update notification has been sent via SMS.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('RECEIVED_BY_CARRIER'), 'The parcel has been received by the carrier.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('RECEIVED_LOCAL_DELIVERY_DEPOT'), 'The parcel has been received at the local delivery depot.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('ROUTING_ERROR'), 'The parcel has encountered a routing error.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('SUB_CONTRACTOR_EVENT'), 'There was a sub-contractor event related to the parcel.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('SUB_CONTRACTOR_RECEIVED'), 'The sub-contractor has received the parcel.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('RECD_BY_CARRIER_NO_ELEC_ADVICE'), 'The parcel has been received by the carrier with no electronic advice.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('AWAITING_ELECTRONIC_ADVICE'), 'The parcel is awaiting electronic advice.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('AWAITING_COLLECTION_FROM_PICKUP_POINT'), 'The parcel is awaiting collection from the pickup point.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('COLLECT_AT_LOCAL_PO'), 'The customer should collect the parcel at the local PO.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('CUSTOMER_TO_COLLECT_FROM_CARRIER'), 'The customer should collect the parcel from the carrier.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('DELIVERED_TO_LOCKER_COLLECTION_POINT'), 'The package was delivered to a locker collection point.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('CARRIER_STATUS_NOT_MAPPED'), 'The carrier status is not mapped.');
        System.assertEquals(mc_TrackingUltility.getTrackingStatusDetail('asd'), 'Unknown status.');
        
        
    }
    
}