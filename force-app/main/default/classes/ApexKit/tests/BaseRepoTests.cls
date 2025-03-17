/**
 * @description  Tests for BaseRepo class. This is a functional test as the Repository being tested executes
 *      DML and is the data layer
 * NOTE: This class is declared Public as its inner class, MyAccountRepo, is used by the
 *      AccountRepositoryTest so it needs to be visible.
 *
 * @see BaseRepo for class being tested
 */
@IsTest
@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
public class BaseRepoTests {
    private static User generateStandardTestUser() {
        return TestFactory.createTestUser(true, 'Standard User');
    }

    /**
     * @description Build test data for use in test methods
     */
    @TestSetup
    private static void buildData() {
        List<Account> accounts = new List<Account>();
        for (Integer idx = 0; idx < 5; idx++) {
            accounts.add(new Account(Name = 'Test Name #' + idx, AccountNumber = '000' + idx));
        }
        insert accounts;
    }

    /**
     * @description Test fetchById() for success path
     */
    @IsTest
    static void unitFetchByIdPositive() {
        Account testAcct = [SELECT Id, AccountNumber FROM Account LIMIT 1];
        BaseRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            SObject record = repo.fetchById(testAcct.Id);
            Assert.areEqual(
                testAcct,
                record,
                'Expected fetchById() to return ' + testAcct + ' but observed return record of ' + record
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test fetchById() for failure path - using an Id of a deleted record
     */
    @IsTest
    static void unitFetchByIdNegative() {
        Boolean errorThrown = false;
        BaseRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            try {
                repo.fetchById(null);
            } catch (ListException error) {
                errorThrown = true;
            }
        }
        Test.stopTest();
        Assert.isTrue(errorThrown, 'Expected fetchById to throw an error when no records are returned');
    }

    /**
     * @description Test fetch() for success path - passing in SOQL and bind variables (in test subclass)
     */
    @IsTest
    static void unitFetchPositive() {
        Account testAcct = [SELECT Id, Name FROM Account LIMIT 1];
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            SObject record = repo.fetchByName(testAcct.Name)[0];
            Assert.areEqual(
                testAcct,
                record,
                'Expected fetchByName(' +
                    testAcct.Name +
                    ') to return ' +
                    testAcct +
                    ' but observed a return of ' +
                    record
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test fetch() for success path - passing in SOQL with no bind variables (in test subclass)
     */
    @IsTest
    static void unitFetchNoParamsPositive() {
        Account testAcct = [SELECT Id, Name FROM Account LIMIT 1];
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            List<SObject> records = repo.fetchByName(testAcct.Name, false);
            Assert.areEqual(
                testAcct,
                records[0],
                'Expected fetchByName() to return ' + testAcct + ' but returned ' + records[0]
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test doUpdate() for success path - called from updateRecord in test subclass
     */
    @IsTest
    static void unitUpdateRecordPositive() {
        Account testAcct = [SELECT Id, Name FROM Account LIMIT 1];
        testAcct.Name = 'New Name';
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Database.SaveResult result = repo.updateRecord(testAcct);
            Assert.areEqual(
                result.isSuccess(),
                true,
                'Expected updateRecord to succeed but DML failed with errors : ' + result.getErrors()
            );
            Assert.areEqual(
                testAcct.Name,
                [SELECT Name FROM Account WHERE Id = :testAcct.Id].Name,
                'Expected Account Name to change to ' +
                    testAcct.Name +
                    ' but observed Account Name as ' +
                    [SELECT Name FROM Account WHERE Id = :testAcct.Id]
                    .Name
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test doUpdate() for success path for multiple records - called from updateRecords in test subclass
     */
    @IsTest
    static void unitUpdateRecordsPositive() {
        List<Account> testAccts = [SELECT Id, Name FROM Account];
        Integer idx = 1;
        for (Account acct : testAccts) {
            acct.Name = 'Test Name #' + idx;
            idx++;
        }
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Database.SaveResult> results = repo.updateRecords(testAccts);
            Assert.areEqual(results.size(), 5, 'Expected 5 records to be updated but observed ' + results.size());
        }
        Test.stopTest();
    }

    /**
     * @description Test doUpsert() for success path for single record - called from upsertRecord in test subclass
     */
    @IsTest
    static void unitUpsertRecordPositive() {
        Account testAcct = [SELECT Id, Name FROM Account LIMIT 1];
        testAcct.Name = 'New Name';
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            Database.UpsertResult result = repo.upsertRecord(testAcct);
            Assert.areEqual(result.isSuccess(), true, 'Failed to upsert record successfully.');
        }
        Test.stopTest();
    }

    /**
     * @description Test doUpsert() for success path for multiple records - called from upsertRecords in test subclass
     */
    @IsTest
    static void unitUpsertRecordsPositive() {
        List<Account> testAccts = [SELECT Id, Name FROM Account];
        Integer idx = 1;
        for (Account acct : testAccts) {
            acct.Name = 'Test Name #' + idx;
            idx++;
        }
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            List<Database.UpsertResult> results = repo.upsertRecords(testAccts);
            Assert.areEqual(results.size(), 5, 'Failed to return correct # of upsert results successfully.');
        }
        Test.stopTest();
    }

    /**
     * @description Test doCreate() for success path for multiple records - called from createRecords in test subclass
     */
    @IsTest
    static void unitCreateRecordsPositive() {
        Integer initialNumAccts = [SELECT COUNT() FROM Account];
        List<Account> testAccts = new List<Account>();
        for (Integer idx = 0; idx < 5; idx++) {
            Account acct = new Account(Name = 'Test Name #' + idx);
            testAccts.add(acct);
        }
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            List<Database.SaveResult> results = repo.createRecords(testAccts);

            Assert.areEqual(results.size(), 5, 'Failed to create correct # of save results successfully.');
            Integer totalNumAccts = initialNumAccts + testAccts.size();
            Assert.areEqual(
                totalNumAccts,
                [SELECT COUNT() FROM Account],
                'Expected ' +
                    totalNumAccts +
                    ' Accounts to be inserted but observed ' +
                    [SELECT COUNT() FROM Account] +
                    ' Accounts in DB.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test doCreate() for success path for single record - called from createRecord in test subclass
     */
    @IsTest
    static void unitCreateRecordPositive() {
        Account testAcct = new Account(Name = 'Test Name');
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            Database.SaveResult result = repo.createRecord(testAcct);
            Assert.areEqual(result.isSuccess(), true, 'Failed to successfully create a record.');
        }
        Test.stopTest();
    }

    /**
     * @description Test doDelete() for success path for single record - called from deleteRecord in test subclass
     */
    @IsTest
    static void unitDeleteRecordPositive() {
        Account testAcct = [SELECT Id FROM Account LIMIT 1];
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Database.DeleteResult result = repo.deleteRecord(testAcct);
            Assert.areEqual(result.isSuccess(), true, 'Failed to successfully delete a record.');
        }
        Test.stopTest();
    }

    /**
     * @description Test doDelete() for success path for multiple records - called from deleteRecords in test subclass
     */
    @IsTest
    static void unitDeleteRecordsPositive() {
        List<Account> testAccts = [SELECT Id FROM Account];
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Database.DeleteResult> results = repo.deleteRecords(testAccts);
            Assert.areEqual(results.size(), testAccts.size(), 'Failed to successfully delete list of records.');
        }
        Test.stopTest();
    }

    /**
     * @description Test class that extends class being tested so we can test the protected methods.
     * NOTE: This class is declared Public as it is used by the CF_AccountRepositoryTest.
     */
    public class MyAccountRepo extends BaseRepo {
        /**
         * @description Create an instance of our test repository
         */
        public MyAccountRepo() {
            super(Account.SObjectType);
            defaultSelectFields.add('AccountNumber');
        }

        /**
         * @description Create an instance of our test repository
         * @param allowUnsafe true if unsafe DML operations are allowed, false (default) otherwise
         */
        public MyAccountRepo(Boolean allowUnsafe) {
            super(Account.SObjectType, allowUnsafe);
            defaultSelectFields.add('AccountNumber');
        }

        /**
         * @description Get all Account records with Name='name'
         * @param name String with Account Name to query on
         * @return `sObject[]` Collection of sObject records.
         */
        public SObject[] fetchByName(String name) {
            String query = 'SELECT Id, Name FROM Account WHERE Name=:name LIMIT 1';
            Map<String, Object> bindVars = new Map<String, Object>{ 'Name' => name };
            return super.fetch(query, bindVars);
        }

        /**
         * @description Get all Account records with Name='name' not using bindVars
         * @param name String with Account Name to query on
         * @param useBindVars Boolean - if true, create a map for bind variables in query, if false, hard-code it in SOQL
         * @return `sObject[]` Collection of sObject records.
         */
        public SObject[] fetchByName(String name, Boolean useBindVars) {
            if (useBindVars) {
                return fetchByName(name);
            }
            String query = 'SELECT Id, Name FROM Account WHERE Name=\'' + name + '\' LIMIT 1';
            return super.fetch(query);
        }

        /**
         * @description Update given Account record
         * @param record Account record to update
         * @return `Database.SaveResult` Results of update operation.
         */
        public Database.SaveResult updateRecord(Account record) {
            return super.doUpdate(record);
        }

        /**
         * @description Update given Account records
         * @param records Collection of Account records to update
         * @return `List<Database.SaveResult>` List of Results of update operation, one per input record.
         */
        public List<Database.SaveResult> updateRecords(List<Account> records) {
            return super.doUpdate(records);
        }

        /**
         * @description Upsert given Account record
         * @param record Account record to upsert
         * @return `Database.UpsertResult` Result of upsert operation.
         */
        public Database.UpsertResult upsertRecord(Account record) {
            return super.doUpsert(record);
        }

        /**
         * @description Upsert given Account records
         * @param records Collection of Account records to upsert
         * @return `List<Database.UpsertResult>` List of Results of upsert operation, one per input record.
         */
        public List<Database.UpsertResult> upsertRecords(List<Account> records) {
            return super.doUpsert(records);
        }

        /**
         * @description Create given Account records
         * @param records Collection of Account records to create
         * @return `List<Database.SaveResult>` List of Results of insert operation, one per input record.
         */
        public List<Database.SaveResult> createRecords(List<Account> records) {
            return super.doCreate(records);
        }

        /**
         * @description Create given Account record
         * @param record Account record to create
         * @return `Database.SaveResult` Result of insert operation.
         */
        public Database.SaveResult createRecord(Account record) {
            return super.doCreate(record);
        }

        /**
         * @description Delete given Account record
         * @param record Account record to delete
         * @return `Database.DeleteResult` Result of delete operation.
         */
        public Database.DeleteResult deleteRecord(Account record) {
            return super.doDelete(record);
        }

        /**
         * @description Delete given Account records
         * @param records Collection of Account records to delete
         * @return `List<Database.DeleteResult>` Collection of results from delete operation.
         */
        public List<Database.DeleteResult> deleteRecords(List<Account> records) {
            return super.doDelete(records);
        }

        /**
         * @description Get all Account records with AccountNumber='acctNumber' not using bindVars
         * @param acctNumber String with Account Number to query on
         * @return `List<Account>` Collection of matching Account records.
         */
        public List<Account> fetchByAccountNumberUnsafe(String acctNumber) {
            String query = 'SELECT Id, AccountNumber FROM Account WHERE AccountNumber=\'' + acctNumber + '\'';
            return (List<Account>) fetchUnsafe(query);
        }

        /**
         * @description Get an Account record with Id='acctId' not using bindVars
         * @param acctId Id of Account to query on
         * @return `Account` Matching Account record
         */
        public Account fetchByAccountIdUnsafe(Id acctId) {
            return (Account) this.fetchByIdUnsafe(acctId);
        }

        /**
         * @description Update the Account record - subclass wrapper for protected doUpdateUnsafe method
         * @param account Account record with new values to commit to database
         * @return `Database.SaveResult` Result of DML update operation
         */
        private Database.SaveResult doUpdateAccountUnsafe(Account account) {
            return this.doUpdateUnsafe(account);
        }

        /**
         * @description Update the Account records - subclass wrapper for protected doUpdateUnsafe method
         * @param accounts List of Account records to update
         * @return `List<Database.SaveResult>` Result of DML update operations
         */
        private List<Database.SaveResult> doUpdateAccountUnsafe(List<Account> accounts) {
            return this.doUpdateUnsafe(accounts);
        }

        /**
         * @description Upsert the Account record - subclass wrapper for protected doUpdateUnsafe method
         * @param account Account record to update
         * @return `Database.UpsertResult` Result of DML upsert operation
         */
        private Database.UpsertResult doUpsertAccountUnsafe(Account account) {
            return this.doUpsertUnsafe(account);
        }

        /**
         * @description Upsert the Account records - subclass wrapper for protected doUpdateUnsafe method
         * @param accounts Account records to update
         * @return `List<Database.UpsertResult>` Results of DML upsert operation
         */
        private List<Database.UpsertResult> doUpsertAccountUnsafe(List<Account> accounts) {
            return this.doUpsertUnsafe(accounts);
        }

        /**
         * @description Create the Account record - subclass wrapper for protected doCreateUnsafe method
         * @param account Account record to update
         * @return `Database.SaveResult` Result of DML insert operation
         */
        private Database.SaveResult doCreateAccountUnsafe(Account account) {
            return this.doCreateUnsafe(account);
        }

        /**
         * @description Create the Account records - subclass wrapper for protected doCreateUnsafe method
         * @param accounts Account records to update
         * @return `List<Database.SaveResult>` Results of DML insert operation
         */
        private List<Database.SaveResult> doCreateAccountUnsafe(List<Account> accounts) {
            return this.doCreateUnsafe(accounts);
        }

        /**
         * @description Delete the Account record - subclass wrapper for protected doDeleteUnsafe method
         * @param account Account record to delete
         * @return `Database.DeleteResult` Result of DML delete operation
         */
        private Database.DeleteResult doDeleteAccountUnsafe(Account account) {
            return this.doDeleteUnsafe(account);
        }

        /**
         * @description Delete the Account records - subclass wrapper for protected doDeleteUnsafe method
         * @param accounts Account records to delete
         * @return `List<Database.DeleteResult>` Results of DML delete operation
         */
        private List<Database.DeleteResult> doDeleteAccountUnsafe(List<Account> accounts) {
            return this.doDeleteUnsafe(accounts);
        }
    }

    /********************************************************************************************************
     * Tests for the unsafe/System Mode versions of DML functions
     *
     */

    /**
     * @description Test fetchUnsafe() for success path
     */
    @IsTest
    static void unitFetchUnsafePositive() {
        User testUser = generateStandardTestUser();
        Account testAcct = new Account(Name = 'Fetch Test for Standard User Override', AccountNumber = '000100');
        System.runAs(testUser) {
            insert testAcct;
        }
        MyAccountRepo repo = new MyAccountRepo(true);
        List<Account> results;
        Test.startTest();
        System.runAs(testUser) {
            results = repo.fetchByAccountNumberUnsafe(testAcct.AccountNumber);
        }
        Test.stopTest();
        Assert.areEqual(
            1,
            results.size(),
            'Expected 1 Account to be returned for our given AccountNumber, but instead observed ' +
                results.size() +
                ' being returned'
        );
        Assert.areEqual(
            testAcct.AccountNumber,
            results[0].AccountNumber,
            'Expected fetchUnsafe() to return ' +
                testAcct +
                ' with inaccessible fields when running in unsafe mode but observed return record of ' +
                results[0]
        );
    }

    /**
     * @description Test fetchByIdUnsafe() for success path
     */
    @IsTest
    static void unitFetchByIdUnsafePositive() {
        User testUser = generateStandardTestUser();
        Account testAcct = new Account(Name = 'Fetch Test for Standard User Override', AccountNumber = '000100');
        System.runAs(testUser) {
            insert testAcct;
        }
        MyAccountRepo repo = new MyAccountRepo(true);
        Account fetchedRecord;
        Test.startTest();
        System.runAs(testUser) {
            fetchedRecord = (Account) repo.fetchByAccountIdUnsafe(testAcct.Id);
        }
        Test.stopTest();
        Assert.areEqual(
            testAcct.AccountNumber,
            fetchedRecord.AccountNumber,
            'Expected fetchByIdUnsafe() to return ' +
                testAcct +
                ' with inaccessible fields when running in unsafe mode but observed return record of ' +
                fetchedRecord
        );
    }

    /**
     * @description Test fetchByIdUnsafe() for failure path - using an unknown record id
     */
    @IsTest
    static void unitFetchByIdUnsafeNoRecordsFoundNegative() {
        User testUser = generateStandardTestUser();
        Boolean errorThrown = false;
        MyAccountRepo repo = new MyAccountRepo(true);
        Test.startTest();
        try {
            System.runAs(testUser) {
                repo.fetchByAccountIdUnsafe(IdFactory.get('Account'));
            }
        } catch (ListException error) {
            errorThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(
            errorThrown,
            'Expected fetchByIdUnsafe to throw an error when there are no matching records but observed successful retrieval.'
        );
    }

    /**
     * @description Test fetchByIdUnsafe() for failure path - passing in SOQL with no bind variables (in test subclass)
     */
    @IsTest
    static void unitFetchByIdUnsafeNullParamsNegative() {
        User testUser = generateStandardTestUser();
        MyAccountRepo repo = new MyAccountRepo(true);
        Test.startTest();
        SObject record;
        System.runAs(testUser) {
            try {
                record = repo.fetchByAccountIdUnsafe(null);
                Assert.fail(
                    'Expected IndexOutOfBounds Exception to be returned when null Id was provided but instead observed successful execution.'
                );
            } catch (Exception expectedIndexOOBExc) {
                Assert.isTrue(
                    expectedIndexOOBExc.getMessage().containsIgnoreCase('Index out of bounds'),
                    'Expected IndexOutOfBoundsException to be returned when null Id was provided but instead observed exception ' +
                    expectedIndexOOBExc
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test fetchByIdUnsafe() for failure path - when repo was created WITHOUT allowUnsafe enabled
     */
    @IsTest
    static void unitFetchByIdUnsafeNotAllowedNegative() {
        User testUser = generateStandardTestUser();
        Account testAcct = new Account(Name = 'Fetch Test for Standard User Override', AccountNumber = '000100');
        System.runAs(testUser) {
            insert testAcct;
        }
        MyAccountRepo repo = new MyAccountRepo();
        Account fetchedRecord;
        Test.startTest();
        System.runAs(testUser) {
            try {
                fetchedRecord = (Account) repo.fetchByAccountIdUnsafe(testAcct.Id);
                Assert.fail(
                    'Expected an UnsafeDmlAttemptedException exception to be thrown but instead observed successful execution of an unsafe fetch.'
                );
            } catch (BaseRepo.UnsafeDmlAttemptedException unsafeDmlAttemptedException) {
                Assert.isTrue(
                    unsafeDmlAttemptedException.getMessage().containsIgnoreCase('unsafe query'),
                    'Expected UnsafeDmlAttemptedException exception with message about unsafe query to be returned but instead observed message ' +
                    unsafeDmlAttemptedException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test doUpdateUnsafe() for success path - called from updateRecord in test subclass
     */
    @IsTest
    static void unitTestUpdateRecordUnsafePositive() {
        User testUser = generateStandardTestUser();
        Account testAcct = new Account(Name = 'Test for Standard User Override');
        System.runAs(testUser) {
            insert testAcct;
        }
        MyAccountRepo repo = new MyAccountRepo(true);
        Database.SaveResult result;
        System.runAs(testUser) {
            Test.startTest();
            testAcct.AccountNumber = 'TEST Account #12345';
            result = repo.doUpdateAccountUnsafe(testAcct);
            Test.stopTest();
        }
        Assert.areEqual(
            result.isSuccess(),
            true,
            'Expected updateRecordUnsafe to succeed for a Standard User updating an inaccessible field but DML failed with errors : ' +
            result.getErrors()
        );
        Assert.areEqual(
            testAcct.AccountNumber,
            [SELECT AccountNumber FROM Account WHERE Id = :testAcct.Id].AccountNumber,
            'Expected AccountNumber to change to ' +
                testAcct.AccountNumber +
                ' but observed AccountNumber as ' +
                [SELECT AccountNumber FROM Account WHERE Id = :testAcct.Id]
                .AccountNumber
        );
    }

    /**
     * @description Test doUpdateUnsafe() for success path for multiple records - called from updateRecords in test subclass
     */
    @IsTest
    static void unitTestUpdateRecordsUnsafePositive() {
        delete [SELECT Id FROM Account]; // remove Accounts created as Sys Admin
        User testUser = generateStandardTestUser();
        List<Account> testAccts = new List<Account>();
        for (Integer idx = 0; idx < 5; idx++) {
            testAccts.add(new Account(Name = 'Test for Standard User Override #' + idx));
        }
        System.runAs(testUser) {
            insert testAccts;
        }
        Integer acctNum = 1000;
        for (Account acct : testAccts) {
            acct.AccountNumber = 'Account Number #' + acctNum;
            acctNum += 1000;
        }
        MyAccountRepo repo = new MyAccountRepo(true);
        Test.startTest();
        List<Database.SaveResult> results;
        System.runAs(testUser) {
            results = repo.doUpdateAccountUnsafe(testAccts);
        }
        Test.stopTest();
        Assert.areEqual(results.size(), 5, 'Expected 5 records to be updated but observed ' + results.size());
    }

    /**
     * @description Test doUpsert() for success path for single record - called from upsertRecord in test subclass
     */
    @IsTest
    static void unitTestUpsertRecordUnsafePositive() {
        Account testAcct = [SELECT Id, Name FROM Account LIMIT 1];
        testAcct.Name = 'New Name';
        MyAccountRepo repo = new MyAccountRepo(true);
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            Database.UpsertResult result = repo.doUpsertAccountUnsafe(testAcct);
            Assert.areEqual(result.isSuccess(), true, 'Failed to upsert record successfully.');
        }
        Test.stopTest();
    }

    /**
     * @description Test doUpsert() for success path for multiple records - called from upsertRecords in test subclass
     */
    @IsTest
    static void unitTestUpsertRecordsUnsafePositive() {
        List<Account> testAccts = [SELECT Id, Name FROM Account];
        Integer idx = 1;
        for (Account acct : testAccts) {
            acct.Name = 'Test Name #' + idx;
            idx++;
        }
        MyAccountRepo repo = new MyAccountRepo(true);
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Database.UpsertResult> results = repo.doUpsertAccountUnsafe(testAccts);
            Assert.areEqual(results.size(), 5, 'Failed to return correct # of upsert results successfully.');
        }
        Test.stopTest();
    }

    /**
     * @description Test doCreate() for success path for multiple records - called from createRecords in test subclass
     */
    @IsTest
    static void unitTestCreateRecordsUnsafePositive() {
        Integer initialNumAccts = [SELECT COUNT() FROM Account];
        List<Account> testAccts = new List<Account>();
        for (Integer idx = 0; idx < 5; idx++) {
            Account acct = new Account(Name = 'Test Name #' + idx);
            testAccts.add(acct);
        }
        MyAccountRepo repo = new MyAccountRepo(true);
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            List<Database.SaveResult> results = repo.doCreateAccountUnsafe(testAccts);
            Assert.areEqual(results.size(), 5, 'Failed to create correct # of save results successfully.');
            Integer totalNumAccts = initialNumAccts + testAccts.size();
            Assert.areEqual(
                totalNumAccts,
                [SELECT COUNT() FROM Account],
                'Expected ' +
                    totalNumAccts +
                    ' Accounts to be inserted but observed ' +
                    [SELECT COUNT() FROM Account] +
                    ' Accounts in DB.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test doCreate() for success path for single record - called from createRecord in test subclass
     */
    @IsTest
    static void unitTestCreateRecordUnsafePositive() {
        Account testAcct = new Account(Name = 'Test Name');
        MyAccountRepo repo = new MyAccountRepo(true);
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            Database.SaveResult result = repo.doCreateAccountUnsafe(testAcct);
            Assert.areEqual(result.isSuccess(), true, 'Failed to successfully create a record.');
        }
        Test.stopTest();
    }

    /**
     * @description Test doDelete() for success path for single record - called from deleteRecord in test subclass
     */
    @IsTest
    static void unitTestDeleteRecordUnsafePositive() {
        Account testAcct = [SELECT Id FROM Account LIMIT 1];
        MyAccountRepo repo = new MyAccountRepo(true);
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Database.DeleteResult result = repo.doDeleteAccountUnsafe(testAcct);
            Assert.areEqual(result.isSuccess(), true, 'Failed to successfully delete a record.');
        }
        Test.stopTest();
    }

    /**
     * @description Test doDelete() for success path for multiple records - called from deleteRecords in test subclass
     */
    @IsTest
    static void unitTestDeleteRecordsUnsafePositive() {
        List<Account> testAccts = [SELECT Id FROM Account];
        MyAccountRepo repo = new MyAccountRepo(true);
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Database.DeleteResult> results = repo.doDeleteAccountUnsafe(testAccts);
            Assert.areEqual(results.size(), testAccts.size(), 'Failed to successfully delete list of records.');
        }
        Test.stopTest();
    }

    /**
     * @description Test doUpdateUnsafe() for failure path - did not create repository with unsafe enabled
     */
    @IsTest
    static void unitTestUpdateRecordUnsafeNegative() {
        User testUser = generateStandardTestUser();
        Account testAcct = new Account(Name = 'Test for Standard User Override');
        System.runAs(testUser) {
            insert testAcct;
        }
        MyAccountRepo repo = new MyAccountRepo();
        Database.SaveResult result;
        System.runAs(testUser) {
            Test.startTest();
            testAcct.AccountNumber = 'TEST Account #12345';
            try {
                result = repo.doUpdateAccountUnsafe(testAcct);
                Assert.fail(
                    'Expected doUpdateUnsafe to fail because allowUnsafe operations was not enabled, observed successful update.'
                );
            } catch (Exception unsafeDmlAttemptedException) {
                Assert.isTrue(
                    unsafeDmlAttemptedException instanceof BaseRepo.UnsafeDmlAttemptedException,
                    'Expected doUpdateUnsafe to throw a UnsafeDmlAttemptedException exception when unsafe operation was attempted but had not been enabled, observed different exception : ' +
                    unsafeDmlAttemptedException
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description Test doUpdateUnsafe() for failure path for multiple records- did not create repository with unsafe enabled
     */
    @IsTest
    static void unitTestUpdateRecordsUnsafeNegative() {
        delete [SELECT Id FROM Account]; // remove Accounts created as Sys Admin
        User testUser = generateStandardTestUser();
        List<Account> testAccts = new List<Account>();
        for (Integer idx = 0; idx < 5; idx++) {
            testAccts.add(new Account(Name = 'Test for Standard User Override #' + idx));
        }
        System.runAs(testUser) {
            insert testAccts;
        }
        Integer acctNum = 1000;
        for (Account acct : testAccts) {
            acct.AccountNumber = 'Account Number #' + acctNum;
            acctNum += 1000;
        }
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        List<Database.SaveResult> results;
        System.runAs(testUser) {
            try {
                results = repo.doUpdateAccountUnsafe(testAccts);
                Assert.fail(
                    'Expected doUpdateUnsafe to fail because allowUnsafe operations was not enabled, observed successful update.'
                );
            } catch (Exception unsafeDmlAttemptedException) {
                Assert.isTrue(
                    unsafeDmlAttemptedException instanceof BaseRepo.UnsafeDmlAttemptedException,
                    'Expected doUpdateUnsafe to throw a UnsafeDmlAttemptedException exception when unsafe operation was attempted but had not been enabled, observed different exception : ' +
                    unsafeDmlAttemptedException
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test doUpsert() for failure path for single record- did not create repository with unsafe enabled
     */
    @IsTest
    static void unitTestUpsertRecordUnsafeNegative() {
        Account testAcct = [SELECT Id, Name FROM Account LIMIT 1];
        testAcct.Name = 'New Name';
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            try {
                repo.doUpsertAccountUnsafe(testAcct);
                Assert.fail(
                    'Expected doUpsertUnsafe to fail because allowUnsafe operations was not enabled, observed successful upsert.'
                );
            } catch (Exception unsafeDmlAttemptedException) {
                Assert.isTrue(
                    unsafeDmlAttemptedException instanceof BaseRepo.UnsafeDmlAttemptedException,
                    'Expected doUpdateUnsafe to throw a UnsafeDmlAttemptedException exception when unsafe operation was attempted but had not been enabled, observed different exception : ' +
                    unsafeDmlAttemptedException
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test doUpsert() for failure path for multiple records- did not create repository with unsafe enabled
     */
    @IsTest
    static void unitTestUpsertRecordsUnsafeNegative() {
        List<Account> testAccts = [SELECT Id, Name FROM Account];
        Integer idx = 1;
        for (Account acct : testAccts) {
            acct.Name = 'Test Name #' + idx;
            idx++;
        }
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            try {
                repo.doUpsertAccountUnsafe(testAccts);
                Assert.fail(
                    'Expected doUpsertUnsafe to fail because allowUnsafe operations was not enabled, observed successful upsert.'
                );
            } catch (Exception unsafeDmlAttemptedException) {
                Assert.isTrue(
                    unsafeDmlAttemptedException instanceof BaseRepo.UnsafeDmlAttemptedException,
                    'Expected doUpsertUnsafe to throw a UnsafeDmlAttemptedException exception when unsafe upsert operation was attempted but had not been enabled, observed different exception : ' +
                    unsafeDmlAttemptedException
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test doCreate() for failure path for multiple records- did not create repository with unsafe enabled
     */
    @IsTest
    static void unitTestCreateRecordsUnsafeNegative() {
        List<Account> testAccts = new List<Account>();
        for (Integer idx = 0; idx < 5; idx++) {
            Account acct = new Account(Name = 'Test Name #' + idx);
            testAccts.add(acct);
        }
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            try {
                repo.doCreateAccountUnsafe(testAccts);
                Assert.fail(
                    'Expected doCreateUnsafe to fail because allowUnsafe operations was not enabled, observed successful insert.'
                );
            } catch (Exception unsafeDmlAttemptedException) {
                Assert.isTrue(
                    unsafeDmlAttemptedException instanceof BaseRepo.UnsafeDmlAttemptedException,
                    'Expected doCreateUnsafe to throw a UnsafeDmlAttemptedException exception when unsafe insert operation was attempted but had not been enabled, observed different exception : ' +
                    unsafeDmlAttemptedException
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test doCreate() for failure path for single record- did not create repository with unsafe enabled
     */
    @IsTest
    static void unitTestCreateRecordUnsafeNegative() {
        Account testAcct = new Account(Name = 'Test Name');
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            try {
                repo.doCreateAccountUnsafe(testAcct);
                Assert.fail(
                    'Expected doCreateUnsafe to fail because allowUnsafe operations was not enabled, observed successful insert.'
                );
            } catch (Exception unsafeDmlAttemptedException) {
                Assert.isTrue(
                    unsafeDmlAttemptedException instanceof BaseRepo.UnsafeDmlAttemptedException,
                    'Expected doCreateUnsafe to throw a UnsafeDmlAttemptedException exception when unsafe insert operation was attempted but had not been enabled, observed different exception : ' +
                    unsafeDmlAttemptedException
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test doDelete() for failure path for single record - did not create repository with unsafe enabled
     */
    @IsTest
    static void unitTestDeleteRecordUnsafeNegative() {
        Account testAcct = [SELECT Id FROM Account LIMIT 1];
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            try {
                repo.doDeleteAccountUnsafe(testAcct);
                Assert.fail(
                    'Expected doDeleteUnsafe to fail because allowUnsafe operations was not enabled, observed successful deletion.'
                );
            } catch (Exception unsafeDmlAttemptedException) {
                Assert.isTrue(
                    unsafeDmlAttemptedException instanceof BaseRepo.UnsafeDmlAttemptedException,
                    'Expected doDeleteUnsafe to throw a UnsafeDmlAttemptedException exception when unsafe delete operation was attempted but had not been enabled, observed different exception : ' +
                    unsafeDmlAttemptedException
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test doDelete() for failure path for multiple records - did not create repository with unsafe enabled
     */
    @IsTest
    static void unitTestDeleteRecordsUnsafeNegative() {
        List<Account> testAccts = [SELECT Id FROM Account];
        MyAccountRepo repo = new MyAccountRepo();
        Test.startTest();
        System.runAs(generateStandardTestUser()) {
            try {
                repo.doDeleteAccountUnsafe(testAccts);
                Assert.fail(
                    'Expected doDeleteUnsafe to fail because allowUnsafe operations was not enabled, observed successful deletion.'
                );
            } catch (Exception unsafeDmlAttemptedException) {
                Assert.isTrue(
                    unsafeDmlAttemptedException instanceof BaseRepo.UnsafeDmlAttemptedException,
                    'Expected doDeleteUnsafe to throw a UnsafeDmlAttemptedException exception when unsafe delete operation was attempted but had not been enabled, observed different exception : ' +
                    unsafeDmlAttemptedException
                );
            }
        }
        Test.stopTest();
    }
}
