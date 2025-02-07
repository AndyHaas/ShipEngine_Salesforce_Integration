trigger mc_TrackingMasterTrigger on Tracking_Master__c (after insert) {
    if (Trigger.isAfter) {
        // Queue up the processing using a future or queuable class
        mc_TrackingMasterQueueable.enqueueTrackingProcessing(Trigger.new);
        
        // // Log Each record
        // Nebula.Logger.info('Record Enqueued for Processing', Trigger)
    }
}