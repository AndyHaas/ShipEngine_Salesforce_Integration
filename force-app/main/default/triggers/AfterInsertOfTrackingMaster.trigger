/**
 * @description Trigger on Tracking_Master__c to initiate asynchronous tracking status updates.
 * Deliberately minimal to follow best practices of moving logic to handler classes.
 * Uses queueable processing to handle bulk operations and respect governor limits when
 * making callouts to shipping carriers.
 *
 * @group Shipping
 * @object Tracking_Master__c
 * @trigger-context after insert
 *
 * @see AfterInsertOfTrackingMasterHandler
 */
trigger AfterInsertOfTrackingMaster on Tracking_Master__c(after insert) {
    AfterInsertOfTrackingMasterHandler.enqueueTrackingProcessing(Trigger.new);
}
