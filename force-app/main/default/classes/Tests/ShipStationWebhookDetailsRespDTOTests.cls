/**
 * @description Test class for ShipStationWebhookDetailsResponseDTO
 * Each test method follows naming convention: type<UnitUnderTest><Positive/Negative>
 */
@IsTest
private class ShipStationWebhookDetailsRespDTOTests {
    /**
     * @description Tests serialization and deserialization of the DTO with a tracking webhook creation response
     */
    @IsTest
    static void unitSerializeDeserializeWithTrackingWebhookCreationPositive() {
        // Setup
        User testUser = TestFactory.createTestUser(true, 'Standard User');

        System.runAs(testUser) {
            Test.startTest();

            // Create a ShipStationWebhookDetailsResponseDTO with webhook creation data
            ShipStationWebhookDetailsResponseDTO responseDTO = new ShipStationWebhookDetailsResponseDTO();

            // Create a webhook creation response
            ShipStationTrackingWebhookCreationDTO creationDTO = new ShipStationTrackingWebhookCreationDTO();
            creationDTO.webhook_id = 'webhook_123456';
            creationDTO.url = 'https://example.com/webhook';
            creationDTO.event = 'TRACKING_UPDATE';

            // Create headers
            List<ShipStationTrackingHeadersDTO> headers = new List<ShipStationTrackingHeadersDTO>();
            ShipStationTrackingHeadersDTO header1 = new ShipStationTrackingHeadersDTO();
            header1.key = 'Authorization';
            header1.value = 'Bearer token123';
            headers.add(header1);

            ShipStationTrackingHeadersDTO header2 = new ShipStationTrackingHeadersDTO();
            header2.key = 'Content-Type';
            header2.value = 'application/json';
            headers.add(header2);

            creationDTO.headers = headers;

            // Set the creation response in the main DTO
            responseDTO.trackingWebhookCreationResponse = creationDTO;

            // Test serialization
            String jsonString = JSON.serialize(responseDTO);

            // Test deserialization
            ShipStationWebhookDetailsResponseDTO deserializedDTO = (ShipStationWebhookDetailsResponseDTO) JSON.deserialize(
                jsonString,
                ShipStationWebhookDetailsResponseDTO.class
            );

            // Verify
            Assert.areNotEqual(null, deserializedDTO, 'Deserialized DTO should not be null');
            Assert.areNotEqual(
                null,
                deserializedDTO.trackingWebhookCreationResponse,
                'trackingWebhookCreationResponse should not be null'
            );
            Assert.areEqual(
                'webhook_123456',
                deserializedDTO.trackingWebhookCreationResponse.webhook_id,
                'webhook_id should match'
            );
            Assert.areEqual(
                'https://example.com/webhook',
                deserializedDTO.trackingWebhookCreationResponse.url,
                'url should match'
            );
            Assert.areEqual(
                'TRACKING_UPDATE',
                deserializedDTO.trackingWebhookCreationResponse.event,
                'event should match'
            );

            // Verify headers
            Assert.areEqual(2, deserializedDTO.trackingWebhookCreationResponse.headers.size(), 'Should have 2 headers');
            Assert.areEqual(
                'Authorization',
                deserializedDTO.trackingWebhookCreationResponse.headers[0].key,
                'First header key should match'
            );
            Assert.areEqual(
                'Bearer token123',
                deserializedDTO.trackingWebhookCreationResponse.headers[0].value,
                'First header value should match'
            );
            Assert.areEqual(
                'Content-Type',
                deserializedDTO.trackingWebhookCreationResponse.headers[1].key,
                'Second header key should match'
            );
            Assert.areEqual(
                'application/json',
                deserializedDTO.trackingWebhookCreationResponse.headers[1].value,
                'Second header value should match'
            );

            Test.stopTest();
        }
    }

    /**
     * @description Tests serialization and deserialization of the DTO with a tracking error response
     */
    @IsTest
    static void unitSerializeDeserializeWithTrackingErrorPositive() {
        // Setup
        User testUser = TestFactory.createTestUser(true, 'Standard User');

        System.runAs(testUser) {
            Test.startTest();

            // Create a ShipStationWebhookDetailsResponseDTO with error data
            ShipStationWebhookDetailsResponseDTO responseDTO = new ShipStationWebhookDetailsResponseDTO();

            // Create a tracking error response
            ShipStationTrackingErrorDTO errorDTO = new ShipStationTrackingErrorDTO();
            errorDTO.request_id = 'req_abcdef123456';

            // Create nested errors
            List<ShipStationTrackingErrorDTO> errors = new List<ShipStationTrackingErrorDTO>();
            ShipStationTrackingErrorDTO nestedError = new ShipStationTrackingErrorDTO();
            nestedError.request_id = 'internal_error_123';
            errors.add(nestedError);

            errorDTO.errors = errors;

            // Set the error response in the main DTO
            responseDTO.trackingErrorResponse = errorDTO;

            // Test serialization
            String jsonString = JSON.serialize(responseDTO);

            // Test deserialization
            ShipStationWebhookDetailsResponseDTO deserializedDTO = (ShipStationWebhookDetailsResponseDTO) JSON.deserialize(
                jsonString,
                ShipStationWebhookDetailsResponseDTO.class
            );

            // Verify
            Assert.areNotEqual(null, deserializedDTO, 'Deserialized DTO should not be null');
            Assert.areNotEqual(null, deserializedDTO.trackingErrorResponse, 'trackingErrorResponse should not be null');
            Assert.areEqual(
                'req_abcdef123456',
                deserializedDTO.trackingErrorResponse.request_id,
                'request_id should match'
            );

            // Verify nested errors
            Assert.areEqual(1, deserializedDTO.trackingErrorResponse.errors.size(), 'Should have 1 nested error');
            Assert.areEqual(
                'internal_error_123',
                deserializedDTO.trackingErrorResponse.errors[0].request_id,
                'Nested error request_id should match'
            );

            Test.stopTest();
        }
    }

    /**
     * @description Tests serialization and deserialization of the DTO with a webhook list
     */
    @IsTest
    static void unitSerializeDeserializeWithWebhookListPositive() {
        // Setup
        User testUser = TestFactory.createTestUser(true, 'Standard User');

        System.runAs(testUser) {
            Test.startTest();

            // Create a ShipStationWebhookDetailsResponseDTO with webhook list
            ShipStationWebhookDetailsResponseDTO responseDTO = new ShipStationWebhookDetailsResponseDTO();

            // Create a list of webhooks
            List<ShipStationTrackingWebhookCreationDTO> webhooks = new List<ShipStationTrackingWebhookCreationDTO>();

            // First webhook
            ShipStationTrackingWebhookCreationDTO webhook1 = new ShipStationTrackingWebhookCreationDTO();
            webhook1.webhook_id = 'webhook_111';
            webhook1.url = 'https://example.com/webhook1';
            webhook1.event = 'TRACKING_UPDATE';

            // Headers for first webhook
            List<ShipStationTrackingHeadersDTO> headers1 = new List<ShipStationTrackingHeadersDTO>();
            ShipStationTrackingHeadersDTO header1 = new ShipStationTrackingHeadersDTO();
            header1.key = 'Authorization';
            header1.value = 'Bearer token1';
            headers1.add(header1);
            webhook1.headers = headers1;

            // Second webhook
            ShipStationTrackingWebhookCreationDTO webhook2 = new ShipStationTrackingWebhookCreationDTO();
            webhook2.webhook_id = 'webhook_222';
            webhook2.url = 'https://example.com/webhook2';
            webhook2.event = 'SHIPMENT_CREATE';

            // Headers for second webhook
            List<ShipStationTrackingHeadersDTO> headers2 = new List<ShipStationTrackingHeadersDTO>();
            ShipStationTrackingHeadersDTO header2 = new ShipStationTrackingHeadersDTO();
            header2.key = 'Authorization';
            header2.value = 'Bearer token2';
            headers2.add(header2);
            webhook2.headers = headers2;

            webhooks.add(webhook1);
            webhooks.add(webhook2);

            // Set the webhook list in the main DTO
            responseDTO.webhookList = webhooks;

            // Test serialization
            String jsonString = JSON.serialize(responseDTO);

            // Test deserialization
            ShipStationWebhookDetailsResponseDTO deserializedDTO = (ShipStationWebhookDetailsResponseDTO) JSON.deserialize(
                jsonString,
                ShipStationWebhookDetailsResponseDTO.class
            );

            // Verify
            Assert.areNotEqual(null, deserializedDTO, 'Deserialized DTO should not be null');
            Assert.areNotEqual(null, deserializedDTO.webhookList, 'webhookList should not be null');
            Assert.areEqual(2, deserializedDTO.webhookList.size(), 'Should have 2 webhooks');

            // Verify first webhook
            Assert.areEqual('webhook_111', deserializedDTO.webhookList[0].webhook_id, 'First webhook_id should match');
            Assert.areEqual(
                'https://example.com/webhook1',
                deserializedDTO.webhookList[0].url,
                'First webhook url should match'
            );
            Assert.areEqual(
                'TRACKING_UPDATE',
                deserializedDTO.webhookList[0].event,
                'First webhook event should match'
            );
            Assert.areEqual(1, deserializedDTO.webhookList[0].headers.size(), 'First webhook should have 1 header');
            Assert.areEqual(
                'Authorization',
                deserializedDTO.webhookList[0].headers[0].key,
                'First webhook header key should match'
            );
            Assert.areEqual(
                'Bearer token1',
                deserializedDTO.webhookList[0].headers[0].value,
                'First webhook header value should match'
            );

            // Verify second webhook
            Assert.areEqual('webhook_222', deserializedDTO.webhookList[1].webhook_id, 'Second webhook_id should match');
            Assert.areEqual(
                'https://example.com/webhook2',
                deserializedDTO.webhookList[1].url,
                'Second webhook url should match'
            );
            Assert.areEqual(
                'SHIPMENT_CREATE',
                deserializedDTO.webhookList[1].event,
                'Second webhook event should match'
            );
            Assert.areEqual(1, deserializedDTO.webhookList[1].headers.size(), 'Second webhook should have 1 header');
            Assert.areEqual(
                'Authorization',
                deserializedDTO.webhookList[1].headers[0].key,
                'Second webhook header key should match'
            );
            Assert.areEqual(
                'Bearer token2',
                deserializedDTO.webhookList[1].headers[0].value,
                'Second webhook header value should match'
            );

            Test.stopTest();
        }
    }

    /**
     * @description Tests serialization and deserialization of a complex DTO with all properties populated
     */
    @IsTest
    static void unitSerializeDeserializeComplexDTOPositive() {
        // Setup
        User testUser = TestFactory.createTestUser(true, 'Standard User');

        System.runAs(testUser) {
            Test.startTest();

            // Create a complex ShipStationWebhookDetailsResponseDTO with all properties
            ShipStationWebhookDetailsResponseDTO responseDTO = new ShipStationWebhookDetailsResponseDTO();

            // Create webhook creation response
            ShipStationTrackingWebhookCreationDTO creationDTO = new ShipStationTrackingWebhookCreationDTO();
            creationDTO.webhook_id = 'webhook_main';
            creationDTO.url = 'https://example.com/main_webhook';
            creationDTO.event = 'TRACKING_UPDATE';

            // Headers for creation response
            List<ShipStationTrackingHeadersDTO> creationHeaders = new List<ShipStationTrackingHeadersDTO>();
            ShipStationTrackingHeadersDTO creationHeader = new ShipStationTrackingHeadersDTO();
            creationHeader.key = 'Authorization';
            creationHeader.value = 'Bearer main_token';
            creationHeaders.add(creationHeader);
            creationDTO.headers = creationHeaders;

            // Set creation response
            responseDTO.trackingWebhookCreationResponse = creationDTO;

            // Create error response
            ShipStationTrackingErrorDTO errorDTO = new ShipStationTrackingErrorDTO();
            errorDTO.request_id = 'req_main_error';
            responseDTO.trackingErrorResponse = errorDTO;

            // Create webhook list
            List<ShipStationTrackingWebhookCreationDTO> webhooks = new List<ShipStationTrackingWebhookCreationDTO>();

            // Webhook in the list
            ShipStationTrackingWebhookCreationDTO webhook = new ShipStationTrackingWebhookCreationDTO();
            webhook.webhook_id = 'webhook_list_item';
            webhook.url = 'https://example.com/list_webhook';
            webhook.event = 'SHIPMENT_CREATE';

            // Headers for webhook in list
            List<ShipStationTrackingHeadersDTO> listHeaders = new List<ShipStationTrackingHeadersDTO>();
            ShipStationTrackingHeadersDTO listHeader = new ShipStationTrackingHeadersDTO();
            listHeader.key = 'Content-Type';
            listHeader.value = 'application/json';
            listHeaders.add(listHeader);
            webhook.headers = listHeaders;

            webhooks.add(webhook);

            // Set webhook list
            responseDTO.webhookList = webhooks;

            // Test serialization
            String jsonString = JSON.serialize(responseDTO);

            // Test deserialization
            ShipStationWebhookDetailsResponseDTO deserializedDTO = (ShipStationWebhookDetailsResponseDTO) JSON.deserialize(
                jsonString,
                ShipStationWebhookDetailsResponseDTO.class
            );

            // Verify all properties
            Assert.areNotEqual(
                null,
                deserializedDTO.trackingWebhookCreationResponse,
                'trackingWebhookCreationResponse should not be null'
            );
            Assert.areEqual(
                'webhook_main',
                deserializedDTO.trackingWebhookCreationResponse.webhook_id,
                'Main webhook_id should match'
            );

            Assert.areNotEqual(null, deserializedDTO.trackingErrorResponse, 'trackingErrorResponse should not be null');
            Assert.areEqual(
                'req_main_error',
                deserializedDTO.trackingErrorResponse.request_id,
                'Error request_id should match'
            );

            Assert.areNotEqual(null, deserializedDTO.webhookList, 'webhookList should not be null');
            Assert.areEqual(1, deserializedDTO.webhookList.size(), 'Should have 1 webhook in the list');
            Assert.areEqual(
                'webhook_list_item',
                deserializedDTO.webhookList[0].webhook_id,
                'List webhook_id should match'
            );

            Test.stopTest();
        }
    }

    /**
     * @description Tests parsing JSON from a real-world example
     */
    @IsTest
    static void unitParseRealWorldJsonPositive() {
        // Setup
        User testUser = TestFactory.createTestUser(true, 'Standard User');

        System.runAs(testUser) {
            Test.startTest();

            // Create a sample JSON response that would come from the ShipStation API
            String jsonResponse =
                '{' +
                '"trackingWebhookCreationResponse": {' +
                '  "webhook_id": "wh_real123456",' +
                '  "url": "https://my-salesforce-instance.my.salesforce.com/services/apexrest/webhooks/tracking",' +
                '  "event": "TRACKING_UPDATE",' +
                '  "headers": [' +
                '    {"key": "Authorization", "value": "Bearer SF_AUTH_TOKEN"},' +
                '    {"key": "Content-Type", "value": "application/json"}' +
                '  ]' +
                '},' +
                '"webhookList": [' +
                '  {' +
                '    "webhook_id": "wh_existing001",' +
                '    "url": "https://example.com/endpoint1",' +
                '    "event": "TRACKING_UPDATE",' +
                '    "headers": [{"key": "X-API-Key", "value": "api_key_1"}]' +
                '  },' +
                '  {' +
                '    "webhook_id": "wh_existing002",' +
                '    "url": "https://example.com/endpoint2",' +
                '    "event": "SHIPMENT_CREATE",' +
                '    "headers": [{"key": "X-API-Key", "value": "api_key_2"}]' +
                '  }' +
                ']' +
                '}';

            // Deserialize the JSON into our DTO
            ShipStationWebhookDetailsResponseDTO deserializedDTO = (ShipStationWebhookDetailsResponseDTO) JSON.deserialize(
                jsonResponse,
                ShipStationWebhookDetailsResponseDTO.class
            );

            // Verify
            Assert.areNotEqual(null, deserializedDTO, 'Deserialized DTO should not be null');

            // Verify webhook creation response
            Assert.areNotEqual(
                null,
                deserializedDTO.trackingWebhookCreationResponse,
                'trackingWebhookCreationResponse should not be null'
            );
            Assert.areEqual(
                'wh_real123456',
                deserializedDTO.trackingWebhookCreationResponse.webhook_id,
                'webhook_id should match'
            );
            Assert.areEqual(
                'https://my-salesforce-instance.my.salesforce.com/services/apexrest/webhooks/tracking',
                deserializedDTO.trackingWebhookCreationResponse.url,
                'url should match'
            );
            Assert.areEqual(
                'TRACKING_UPDATE',
                deserializedDTO.trackingWebhookCreationResponse.event,
                'event should match'
            );

            // Verify headers
            Assert.areEqual(2, deserializedDTO.trackingWebhookCreationResponse.headers.size(), 'Should have 2 headers');
            Assert.areEqual(
                'Authorization',
                deserializedDTO.trackingWebhookCreationResponse.headers[0].key,
                'First header key should match'
            );
            Assert.areEqual(
                'Bearer SF_AUTH_TOKEN',
                deserializedDTO.trackingWebhookCreationResponse.headers[0].value,
                'First header value should match'
            );

            // Verify webhook list
            Assert.areEqual(2, deserializedDTO.webhookList.size(), 'Should have 2 webhooks in the list');
            Assert.areEqual(
                'wh_existing001',
                deserializedDTO.webhookList[0].webhook_id,
                'First webhook_id should match'
            );
            Assert.areEqual(
                'wh_existing002',
                deserializedDTO.webhookList[1].webhook_id,
                'Second webhook_id should match'
            );

            Test.stopTest();
        }
    }
}
