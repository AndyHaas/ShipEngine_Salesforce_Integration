/**
 * @description This class is responsible for processing `Tracking_Master__c` records asynchronously using the Queueable interface.
 * It ensures that a batch of tracking master records can be processed without blocking the main execution thread.
 */
public inherited sharing class AfterInsertOfTrackingMasterHandler implements Queueable {
    @SuppressWarnings('PMD.FieldNamingConventions')
    private static final TrackingMasterRepo trackingMasterRepo = new TrackingMasterRepo();

    /**
     * @description A list of IDs representing the `Tracking_Master__c` records to be processed.
     * This list is initialized when an instance of the class is created.
     */
    private final List<Id> trackingMasterIds;

    /**
     * @description Constructor that initializes the queueable job with a list of tracking master record IDs.
     *
     * @param trackingMasterIds The list of IDs for `Tracking_Master__c` records to be processed.
     */
    public AfterInsertOfTrackingMasterHandler(List<Id> trackingMasterIds) {
        this.trackingMasterIds = trackingMasterIds;
    }

    /**
     * @description Executes the queueable job to process the `Tracking_Master__c` records.
     * It queries the records based on the provided IDs and passes them to a handler for processing.
     * If no records are found, or if an error occurs during processing, appropriate logging is performed.
     *
     * @param context The context in which the queueable job is executed.
     */
    public void execute(QueueableContext context) {
        // Query the Tracking_Master__c records to ensure data integrity
        Tracking_Master__c[] trackingMasters = trackingMasterRepo.fetchTrackingMastersById(trackingMasterIds) ??
            new List<Tracking_Master__c>();
        if (trackingMasters == null || trackingMasters.isEmpty()) {
            return;
        }
        TrackingMasterService trackingService = new TrackingMasterService();
        trackingService.processTrackingMaster(trackingMasters);
    }

    /**
     * @description Static method to enqueue the processing of `Tracking_Master__c` records.
     * It extracts the IDs from the provided records and enqueues a new instance of the queueable job.
     *
     * @param trackingMasters A list of `Tracking_Master__c` records to be processed.
     */
    public static void enqueueTrackingProcessing(List<Tracking_Master__c> trackingMasters) {
        // fast return if there's nothing to do.
        if (trackingMasters == null || trackingMasters.isEmpty()) {
            return;
        }

        // Extract the Ids from the List of Tracking_Master__c records
        List<Id> trackingMasterIds = new List<Id>(new Map<Id, Tracking_Master__c>(trackingMasters).keySet());
        System.enqueueJob(new AfterInsertOfTrackingMasterHandler(trackingMasterIds));
    }
}
