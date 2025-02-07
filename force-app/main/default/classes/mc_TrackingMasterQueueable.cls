public class mc_TrackingMasterQueueable implements Queueable{
    private List<Id> trackingMasterIds;

    public mc_TrackingMasterQueueable(List<Id> trackingMasterIds) {
        this.trackingMasterIds = trackingMasterIds;
    }

    public void execute(QueueableContext context) {
        // Nebula.Logger.info('Started processing Tracking Master records');

        // Query the Tracking_Master__c records to ensure data integrity
        List<Tracking_Master__c> trackingMasters = [
            SELECT Id, Webhook_JSON_Body__c, Tracking_Number__c
            FROM Tracking_Master__c
            WHERE Id IN :trackingMasterIds
        ];
        
        if (!trackingMasters.isEmpty()) {
            try {
                // Pass records to the handler for processing
                mc_TrackingMasterTriggerHandler.processTrackingMaster(trackingMasters);
                
                // Nebula.Logger.info('Successfully processed Tracking Master records', trackingMasters);
            } catch (Exception ex) {
                // Nebula.Logger.error('Error processing Tracking Master records', trackingMasters, ex);
            }
        } else {
            // Nebula.Logger.warn('No Tracking Master records found for processing', trackingMasters);
        }
    }

    // Enqueue processing for Tracking Master records
    public static void enqueueTrackingProcessing(List<Tracking_Master__c> trackingMasters) {
        if (trackingMasters == null || trackingMasters.isEmpty()) {
            // Nebula.Logger.warn('No Tracking Master records provided for enqueueing.');
            return;
        }

        // Extract the Ids from the List of Tracking_Master__c records
        List<Id> trackingMasterIds = new List<Id>();
        for (Tracking_Master__c tm : trackingMasters) {
            trackingMasterIds.add(tm.Id);
        }

        // Now enqueue the records using the extracted Ids
        System.enqueueJob(new mc_TrackingMasterQueueable(trackingMasterIds));
        // Nebula.Logger.info('Enqueued Tracking Master records for processing', trackingMasters);
    }
}