# ShipStation Webhook Processing Flow

```mermaid
flowchart TD
    subgraph "Webhook Reception"
        A[TrackingWebhookApexHandler.handlePost] --> B[Parse request body]
        B --> C[Deserialize to ShipStationTrackingResponseDTO]
        C --> D[trackingMasterRepo.createTrackingMasterRecordFromDTO]
    end

    subgraph "Initial Record Creation"
        D --> E[ContentRepo.createContentVersion]
        E --> F[Create Tracking_Master__c record]
        F --> G[Save Tracking_Master__c]
    end

    subgraph "Trigger Processing"
        G --> H[AfterInsertOfTrackingMaster trigger]
        H --> I[AfterInsertOfTrackingMasterHandler.enqueueTrackingProcessing]
        I --> J[Create AfterInsertOfTrackingMasterHandler instance]
        J --> K[System.enqueueJob]
    end

    subgraph "Asynchronous Processing"
        K --> L[AfterInsertOfTrackingMasterHandler.execute]
        L --> M[trackingMasterRepo.fetchTrackingMastersById]
        M --> N[TrackingMasterService.processTrackingMaster]
    end

    subgraph "Tracking Master Processing"
        N --> O[filterAlreadyProcessedRecords]
        O --> P[buildJsonDocumentMap]
        P --> Q[contentRepo.fetchContentVersionsById]
        Q --> R[processTrackingDocuments]
    end

    subgraph "Document Processing"
        R --> S[parseTrackingData]
        S --> T[createOrUpdateShipment]
        T --> U[shipmentRepo.fetchShipmentByTrackingNumber]
        U --> V[shipmentRepo.upsertShipments]
    end

    subgraph "Event Processing"
        R --> W[Track events exist?]
        W -->|Yes| X[processTrackingEvents]
        X --> Y[prepareTrackingEventMetadata]
        Y --> Z[getExistingEventKeys]
        Z --> AA[trackingEventRepo.fetchTrackingEventsByTrackingMasterIds]
        Z --> AB[trackingEventRepo.fetchTrackingEventsByShipmentIds]
        AA --> AC[createEventBatch]
        AB --> AC
        AC --> AD[processEventBatch]
        AD --> AE[saveEventBatch]
        AE --> AF[trackingEventRepo.doCreate]
        AE --> AG[shipmentEventRepo.doCreate]
    end

    classDef receivingClass fill:#f9d5e5,stroke:#333,stroke-width:1px
    classDef storageClass fill:#d5e8f9,stroke:#333,stroke-width:1px
    classDef processingClass fill:#e5f9d5,stroke:#333,stroke-width:1px
    classDef queueableClass fill:#f9e5d5,stroke:#333,stroke-width:1px

    class A,B,C receivingClass
    class D,E,F,G,V,AF,AG storageClass
    class N,O,P,R,S,T,X,Y,Z,AC,AD,AE processingClass
    class H,I,J,K,L,M queueableClass
```

## Flow Description

1. **Webhook Reception**

    - A webhook payload is sent to the `TrackingWebhookApexHandler.handlePost` method
    - The request body is parsed and deserialized into a `ShipStationTrackingResponseDTO` object
    - The `TrackingMasterRepo` is used to create a tracking master record from the DTO

2. **Initial Record Creation**

    - The `ContentRepo` creates a `ContentVersion` record to store the raw webhook JSON
    - A `Tracking_Master__c` record is created with data from the webhook payload
    - The record is inserted into the database

3. **Trigger Processing**

    - The `AfterInsertOfTrackingMaster` trigger fires after the `Tracking_Master__c` record is inserted
    - The trigger calls the `AfterInsertOfTrackingMasterHandler.enqueueTrackingProcessing` method
    - A new `AfterInsertOfTrackingMasterHandler` instance is created with the tracking master IDs
    - The handler is enqueued as a queueable job using `System.enqueueJob`

4. **Asynchronous Processing**

    - The queueable job's `execute` method is called by the Salesforce platform
    - The `TrackingMasterRepo` fetches the tracking master records by their IDs
    - The `TrackingMasterService.processTrackingMaster` method is called to process the records

5. **Tracking Master Processing**

    - Already processed records are filtered out
    - The JSON documents stored in ContentVersion records are retrieved
    - The tracking documents are processed to create or update shipment records

6. **Document Processing**

    - The tracking data is parsed from the JSON documents
    - Shipment records are created or updated based on the tracking data
    - The shipments are upserted into the database

7. **Event Processing**
    - If tracking events exist in the payload, they are processed
    - Event metadata is prepared, including tracking number to shipment ID mappings
    - Existing event keys are retrieved to avoid duplicates
    - Event batches are created for tracking events and shipment events
    - The event batches are saved to the database

This diagram shows the complete flow from webhook reception to processing and storage in Salesforce, including both synchronous and asynchronous operations.
