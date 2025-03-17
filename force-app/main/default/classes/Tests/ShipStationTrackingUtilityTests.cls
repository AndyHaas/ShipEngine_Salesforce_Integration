@IsTest
public class ShipStationTrackingUtilityTests {
    /* Get the base URL of the tracking utility. */
    @IsTest
    public static void getBaseURLTest() {
        Test.startTest();
        String baseURL = ShipStationTrackingUtilities.getBaseUrl();
        Assert.areEqual(
            baseURL,
            'https://api.shipengine.com/v1/',
            'Checks that the base URL is the same as the API URL.'
        );
        Test.stopTest();
    }

    /* formatCarrierTest - Test method for tracking a carrier */
    @IsTest
    public static void formatCarrierTest() {
        Test.startTest();
        String result = ShipStationTrackingUtilities.formatCarrier('asd');
        Assert.areEqual(result, 'asd', 'Assert that result is not empty asd.');
        Test.stopTest();
    }

    /* This method checks the tracking status of a specific node. */
    @IsTest
    public static void getTrackingStatusTest() {
        Test.startTest();
        String unknown = ShipStationTrackingUtilities.getTrackingStatus('UN');
        String accepted = ShipStationTrackingUtilities.getTrackingStatus('AC');
        String inTransit = ShipStationTrackingUtilities.getTrackingStatus('IT');
        String delivered = ShipStationTrackingUtilities.getTrackingStatus('DE');
        String exceptions = ShipStationTrackingUtilities.getTrackingStatus('EX');
        String delivertAttempt = ShipStationTrackingUtilities.getTrackingStatus('AT');
        String notYetInSystem = ShipStationTrackingUtilities.getTrackingStatus('NY');
        String deliveredToCollectionLocation = ShipStationTrackingUtilities.getTrackingStatus('SP');
        String emptyParam = ShipStationTrackingUtilities.getTrackingStatus('unknown');

        Assert.areEqual(unknown, 'Unknown', 'Tests that unknown is a string.');
        Assert.areEqual(accepted, 'Accepted', 'Checks that the accepted values are equal to the accepted values.');
        Assert.areEqual(inTransit, 'In Transit', 'Assert that inTransit is the same as inTransit.');
        Assert.areEqual(delivered, 'Delivered', 'Test for equality of the message.');
        Assert.areEqual(exceptions, 'Exception', 'Assert that all exceptions are null.');
        Assert.areEqual(
            delivertAttempt,
            'Delivery Attempt',
            'This method asserts that the given delivery attempt string is equal to the given string.'
        );
        Assert.areEqual(notYetInSystem, 'Not Yet In System', 'Assert Not Yet In System');
        Assert.areEqual(
            deliveredToCollectionLocation,
            'Delivered To Collection Location',
            'This method is used to assert that the given string is equal to the given string.'
        );
        Assert.areEqual(emptyParam, 'Unknown', 'Tests if the string is empty');
        Test.stopTest();
    }

    /* This method is used to check the status of the current tracking. */
    @IsTest
    public static void testm() {
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('COLLECTION_FAILED'),
            'The package collection has failed.',
            'This method checks that the package collection has failed.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('AWAITING_DESPATCH'),
            'The package is awaiting despatch.',
            'The package is awaiting despatch.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('COLLECTION_REQUESTED'),
            'The package collection has been requested.',
            'This method asserts that the collection has been requested.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('DESPATCHED'),
            'The package has been despatched.',
            'The package has been despatched.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('ELEC_ADVICE_RECD_BY_CARRIER'),
            'Electronic advice has been received by the carrier.',
            'This method is used to assert that the Electic Advice has been received by the'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('NOT_YET_RECEIVED_BY_CARRIER'),
            'The package has not yet been received by the carrier.',
            'Checks that the package has not yet been received by the carrier.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('COLLECTION_MADE'),
            'The package collection has been made.',
            'This method is called when the tracking status of the package collection has been made.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('ATTEMPTED_DELIVERY'),
            'An attempted delivery has been made.',
            'An attempted delivery has been made.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('ATTEMPTED_DELIVERY_2ND'),
            'A second attempted delivery has been made.',
            'A second attempted delivery has been made.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('ATTEMPTED_DELIVERY_3RD'),
            'A third attempted delivery has been made.',
            'A third attempted delivery has been made.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('COD_AMOUNT_NOT_PAID'),
            'The COD amount has not been paid.',
            'This method asserts that the COD amount has not been paid.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('COD_AMOUNT_PAID'),
            'The COD amount has been paid.',
            'The COD amount has been paid.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('CUSTOMER_CARDED'),
            'The customer has been carded.',
            'This method asserts that the customer has been carded.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('CUSTOMER_IDENTIFICATION_FAILED'),
            'Customer identification has failed.',
            'This method is used to assert that the customer identification has failed.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('INVALID_METHOD_OF_PAYMENT'),
            'The method of payment is invalid.',
            'This method is called when the method of payment is invalid.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('NO_ACCESS_TO_RECIPIENTS_ADDRESS'),
            'There was no access to the recipient\'s address.',
            'This method checks that there was no access to the recipient s address.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('OUT_FOR_DELIVERY'),
            'The package is out for delivery.',
            'The package is out for delivery.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('DELIVERED'),
            'The package has been delivered.',
            'This method asserts that the package has been delivered.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('DELIVERED_DAMAGED'),
            'The package was delivered but damaged.',
            'The package was delivered but damaged.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('DELIVERED_IN_PART'),
            'The package has been delivered in part.',
            'This method asserts that the package has been delivered in part.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('DELIVERED_SPECIFIED_SAFE_PLACE'),
            'The package was delivered to a specified safe place.',
            'The package was delivered to a specified safe place.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('DELIVERED_TO_ALTERNATIVE_DELIVERY_LOCATION'),
            'The package was delivered to an alternative delivery location.',
            'The package was delivered to an alternative delivery location.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('DELIVERED_TO_NEIGHBOUR'),
            'The package was delivered to a neighbour.',
            'This method is used to assert that the package was delivered to a neighbour.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('DELIVERED_TO_PO_BOX'),
            'The package was delivered to a PO box.',
            'This method checks that the package was delivered to a PO box.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('PARCEL_COLLECTED_FROM_PICKUP_POINT'),
            'The parcel was collected from a pickup point.',
            'This function asserts that the parcel was collected from a pickup point.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('POST_TRANSIT_STATUS'),
            'The package is in a post-transit status.',
            'This test asserts that the package is in a post - transit status.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('PROOF_OF_DELIVERY'),
            'Proof of delivery is available.',
            'Checks that the Proof of Delivery is available.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('CANCELLED'),
            'The shipment has been cancelled.',
            'The shipment has been cancelled.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('CANCELLED_BEFORE_DESPATCH'),
            'The shipment was cancelled before despatch.',
            'The shipment was cancelled before despatch.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('CUSTOMER_MOVED'),
            'The customer has moved.',
            'This method checks if the customer has moved.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('HAZARDOUS_PROHIBITED'),
            'The parcel contains hazardous or prohibited items.',
            'The parcel contains hazardous or prohibited items.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('NOT_COLLECTED_FROM_PICKUP_POINT'),
            'The parcel was not collected from the pickup point.',
            'This function asserts that the parcel was not collected from the pickup point.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('NOT_DELIVERED'),
            'The parcel was not delivered.',
            'This is a test function to assert that the parcel was not delivered.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('NOT_DELIVERED_ADDRESSEE_DECEASED'),
            'The parcel was not delivered because the addressee is deceased.',
            'This is a bug in the parcels tracking system.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('PARCEL_DAMAGED'),
            'The parcel has been damaged.',
            'This method checks that the parcel has been damaged.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('PARCEL_DISPOSED'),
            'The parcel has been disposed of.',
            'This method asserts that the parcel has been disposed.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('PARCEL_LOST'),
            'The parcel has been lost.',
            'This function asserts that the parcel has been lost.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('PARCEL_OUTSIDE_OF_SERVICE_CAPABILITY'),
            'The parcel is outside of the service capability.',
            'This function checks that the parcel is outside of the service capability.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('REFUSED_BY_CUSTOMER'),
            'The parcel was refused by the customer.',
            'This method asserts that the parcel was refused by the customer.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('RETURN_TO_SENDER'),
            'The parcel is being returned to the sender.',
            'This is a test function.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('ADDRESS_QUERY'),
            'There is an address query for the parcel.',
            'This method is used to check if there is an address query for the parcel.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('CARRIER_DELAYS'),
            'The parcel is delayed due to the carrier.',
            'The parcel is delayed due to the carrier.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('CUSTOMS_CLEARED'),
            'The parcel has been cleared by customs.',
            'This method is used to assert that the parcel has been cleared by customs.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('CUSTOMS_PROCESSING'),
            'The parcel is undergoing customs processing.',
            'This code is used to assert that the parcel is undergoing customs processing.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('DELAYED_NOT_CARRIER'),
            'The parcel is delayed due to reasons not related to the carrier.',
            'This is a bug in the parcels tracking system.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('DELIVERY_ARRANGED_WITH_RECIPIENT'),
            'Delivery has been arranged with the recipient.',
            'This method is used to assert that the delivery has been arranged with the recipient.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('HELD_BY_CARRIER'),
            'The parcel is held by the carrier.',
            'This method is used to assert that the parcel is held by the carrier.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('HELD_BY_CARRIER_FOR_CLEARANCE_PRE_PROCESSING'),
            'The parcel is held by the carrier for clearance pre-processing.',
            'The parcel is held by the carrier for clearance pre - processing.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('HELD_BY_CUSTOMS'),
            'The parcel is held by customs.',
            'This method is used to assert that the parcel is held by customs.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('HELD_BY_EXPORT_CUSTOMS'),
            'The parcel is held by export customs.',
            'This method is used to assert that the parcel is held by export customs.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('HELD_BY_IMPORT_CUSTOMS'),
            'The parcel is held by import customs.',
            'The parcel is held by import customs.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('HUB_SCAN_OUT'),
            'The parcel has been scanned out of the hub.',
            'This function asserts that the parcel has been scanned out of the hub.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('IN_TRANSIT'),
            'The parcel is in transit.',
            'This function asserts that the parcel is in transit.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('INCORRECT_DECLARATION'),
            'The parcel has an incorrect declaration.',
            'This function asserts that the parcel has an incorrect declaration.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('INFORMATION'),
            'There is an information update about the parcel.',
            'This method asserts that there is an information update about the parcel.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('MISSORTED'),
            'The parcel has been missorted.',
            'This routine asserts that the parcel has been missorted.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('PARCEL_OVER_LABELLED'),
            'The parcel has been over-labelled.',
            'This routine asserts that the parcel has been over - labelled.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('PARCEL_REPACKED'),
            'The parcel has been repacked.',
            'This routine asserts that the parcel has been repacked.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('PARCEL_UPDATE_NOTIFICATION_VIA_EMAIL'),
            'A parcel update notification has been sent via email.',
            'This is a bug in the McWebTracker interface.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('PARCEL_UPDATE_NOTIFICATION_VIA_SMS'),
            'A parcel update notification has been sent via SMS.',
            'This method asserts that the parcel update notification has been sent via SMS.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('RECEIVED_BY_CARRIER'),
            'The parcel has been received by the carrier.',
            'This method is used to assert that the parcel has been received by the carrier.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('RECEIVED_LOCAL_DELIVERY_DEPOT'),
            'The parcel has been received at the local delivery depot.',
            'This method is used to assert that the parcel has been received at the local delivery dep'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('ROUTING_ERROR'),
            'The parcel has encountered a routing error.',
            'This method is used to assert that the parcel has encountered a routing error.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('SUB_CONTRACTOR_EVENT'),
            'There was a sub-contractor event related to the parcel.',
            'This method is used to assert that there was a sub - contractor event related to the'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('SUB_CONTRACTOR_RECEIVED'),
            'The sub-contractor has received the parcel.',
            'This function asserts that the sub - contractor has received the parcel.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('RECD_BY_CARRIER_NO_ELEC_ADVICE'),
            'The parcel has been received by the carrier with no electronic advice.',
            'This method is used to assert that the parcel has been received by the carrier with no'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('AWAITING_ELECTRONIC_ADVICE'),
            'The parcel is awaiting electronic advice.',
            'The parcel is awaiting electronic advice.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('AWAITING_COLLECTION_FROM_PICKUP_POINT'),
            'The parcel is awaiting collection from the pickup point.',
            'This method is used to assert that the parcel is awaiting collection from the pickup'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('COLLECT_AT_LOCAL_PO'),
            'The customer should collect the parcel at the local PO.',
            'This is a test.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('CUSTOMER_TO_COLLECT_FROM_CARRIER'),
            'The customer should collect the parcel from the carrier.',
            'The customer should collect the parcel from the carrier.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('DELIVERED_TO_LOCKER_COLLECTION_POINT'),
            'The package was delivered to a locker collection point.',
            'This method is used to assert that the package was delivered to a locker collection point.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('CARRIER_STATUS_NOT_MAPPED'),
            'The carrier status is not mapped.',
            'This method is used to assert that the carrier status is not mapped.'
        );
        Assert.areEqual(
            ShipStationTrackingUtilities.getTrackingStatusDetail('asd'),
            'Unknown status.',
            'System. Asserts that the tracking status detail is the same as the status of the system'
        );
    }
}
