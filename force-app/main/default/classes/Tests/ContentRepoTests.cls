/**
 * @description Test class for ContentRepo
 * Each test method follows naming convention: type<UnitUnderTest><Positive/Negative>
 */
@IsTest
private class ContentRepoTests {
    /**
     * @description Set up test data
     */
    @TestSetup
    static void setupTestData() {
        // Create a test user
        User testUser = TestFactory.createTestUser(true, 'Standard User');

        // Create test data as the test user
        System.runAs(testUser) {
            List<ContentVersion> contentVersions = new List<ContentVersion>();

            // Create content versions
            for (Integer i = 1; i <= 3; i++) {
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Test JSON ' + i;
                cv.PathOnClient = 'test' + i + '.json';
                cv.VersionData = Blob.valueOf('{"test":"data' + i + '"}');
                cv.IsMajorVersion = true;
                cv.ContentLocation = 'S'; // S for Salesforce, E for External
                cv.Origin = 'C'; // C for Content, H for Chatter
                contentVersions.add(cv);
            }

            insert contentVersions;
        }
    }

    /**
     * @description Test createContentVersion with valid data
     */
    @IsTest
    static void unitCreateContentVersionPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];
        Blob testData = Blob.valueOf('{"test":"new content version"}');

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ContentRepo repo = new ContentRepo();
            Database.SaveResult result = repo.createContentVersion(testData);
            Test.stopTest();

            // Verify results
            Assert.isTrue(result.isSuccess(), 'Insert should succeed');
            Assert.isNotNull(result.getId(), 'New record ID should be returned');

            // Verify record was inserted with correct data
            ContentVersion insertedCV = [
                SELECT Id, VersionData, Title, ContentLocation, PathOnClient, IsMajorVersion, Origin
                FROM ContentVersion
                WHERE Id = :result.getId()
                LIMIT 1
            ];

            String decodedData = insertedCV.VersionData.toString();
            Assert.areEqual('{"test":"new content version"}', decodedData, 'Content data should match');
            Assert.isTrue(
                insertedCV.Title.startsWith('Tracking_Response_'),
                'Title should start with Tracking_Response_'
            );
            Assert.areEqual('S', insertedCV.ContentLocation, 'ContentLocation should be S');
            Assert.isTrue(insertedCV.IsMajorVersion, 'IsMajorVersion should be true');
            Assert.areEqual('C', insertedCV.Origin, 'Origin should be C');
        }
    }

    /**
     * @description Test fetchContentVersionBodyById with valid data
     */
    @IsTest
    static void unitFetchContentVersionBodyByIdPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];
        ContentVersion testCV;

        System.runAs(testUser) {
            testCV = [
                SELECT Id
                FROM ContentVersion
                WHERE PathOnClient = 'test1.json'
                LIMIT 1
            ];
        }

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ContentRepo repo = new ContentRepo();
            String body = repo.fetchContentVersionBodyById(testCV.Id);
            Test.stopTest();

            // Verify results
            Assert.areEqual('{"test":"data1"}', body, 'Content body should match');
        }
    }

    /**
     * @description Test fetchContentVersionsById with valid data
     */
    @IsTest
    static void unitFetchContentVersionsByIdPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];
        List<ContentVersion> testCVs;

        System.runAs(testUser) {
            testCVs = [
                SELECT Id
                FROM ContentVersion
                ORDER BY PathOnClient
                LIMIT 3
            ];
        }

        List<Id> cvIds = new List<Id>();
        for (ContentVersion cv : testCVs) {
            cvIds.add(cv.Id);
        }

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ContentRepo repo = new ContentRepo();
            Map<Id, String> contentMap = repo.fetchContentVersionsById(cvIds);
            Test.stopTest();

            // Verify results
            Assert.areEqual(3, contentMap.size(), 'Should return all 3 content versions');

            for (Id cvId : contentMap.keySet()) {
                Assert.isTrue(contentMap.get(cvId).contains('{"test":"data'), 'Content should contain test data');
            }
        }
    }

    /**
     * @description Test fetchContentVersionsById with empty list
     */
    @IsTest
    static void unitFetchContentVersionsByIdWithEmptyListPositive() {
        // Setup
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND IsActive = TRUE LIMIT 1];
        List<Id> emptyList = new List<Id>();

        // Execute test
        System.runAs(testUser) {
            Test.startTest();
            ContentRepo repo = new ContentRepo();
            Map<Id, String> contentMap = repo.fetchContentVersionsById(emptyList);
            Test.stopTest();

            // Verify results
            Assert.areEqual(0, contentMap.size(), 'Should return empty map for empty input');
        }
    }
}
