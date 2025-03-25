# ShipStation Salesforce Integration - Dev Guide

## Commands

- **Lint:** `npm run lint` (ESLint for JS files)
- **Format:** `npm run prettier` (all files) | `npm run prettier:verify` (check only)
- **Test LWC:** `npm run test` | `npm run test:unit:watch` (watch mode) | `npm run test:unit:debug` (debug)
- **Test Apex:** `sf force apex test run` (all tests) | `sf force apex test run -n TestClassName` (single)
- **Test Apex with Coverage:** `sf apex run test -c -w 5 -n TestClassName` (test with coverage)
- **Deploy:** `sf project deploy start -p force-app/` | `sf project deploy start -m ApexClass:ClassName`
- **PMD:** `pmd check -d force-app/main/default/classes -f csv -R pmd/ruleset.xml -t 8 --cache .pmdcache`

## Code Style

- **Formatting:** 120 char line limit, 4 space indentation
- **Naming:** camelCase for variables, methods, parameters (start lowercase)
- **Variables:** start with a lower case letter, camelCase, minimum three characters in length
- **Constants:** UPPER_SNAKE_CASE
- **Classes:** Start with uppercase, follow noun convention
- **Apex Tests:** Must use Assert._ methods instead of System.assert_ (deprecated)
    - **Assert.areEqual(expected, actual, msg)** - Asserts that the first two arguments are the same
    - **Assert.areNotEqual(notExpected, actual, msg)** - Asserts that the first two arguments aren't the same
    - **Assert.fail(msg)** - Immediately return a fatal error that causes code execution to halt
    - **Assert.isFalse(condition, msg)** - Asserts that the specified condition is false
    - **Assert.isInstanceOfType(instance, expectedType, msg)** - Asserts that the instance is of the specified type
    - **Assert.isNotInstanceOfType(instance, notExpectedType, msg)** - Asserts that the instance isn't of the specified type
    - **Assert.isNotNull(value, msg)** - Asserts that the value isn't null
    - **Assert.isNull(value, msg)** - Asserts that the value is null
    - **Assert.isTrue(condition, msg)** - Asserts that the specified condition is true
- **Security:** No hardcoded credentials, follow CRUD/FLS best practices
- **Documentation:** Required ApexDoc for public/protected methods and properties
- **Error Handling:** Check for null before isEmpty(), avoid triggers with logic

# Requirements

- **API Version:** All \*-meta.xml files must use API version 63.0
- All unit tests MUST include a system.runAs call, even for basic unit tests that don't interact with permissions.
- The runAs user should be appropriate for the context of the test.
- Each test method should start with system.runAs before any test assertions.
- Where possible, please use the Stub class and builder interface found in force-app/main/default/classes/ApexKit/Stub.cls for building mocks.
- The Stub class uses a fluent API style with a builder pattern. Example usage:
    ```apex
    StubObject fooStub = new Stub.Builder('foo.class')
      .mockingMethodCall('someMethodName', List<Object> Params)
      .withParameterTypes()
      .returning() || .throwingException() || .throwingException(ExceptionObj)
      .mockingMethodCall('secondMethodName', ...)
      .withParameterTypes()
      .returning() || .throwingException() || .throwingException(ExceptionObj)
      .createStub()
    ```
- Each test method should be named according to the formula <type><UnitUnderTest><Positive/Negative> where Type is either Unit or Functional. Unit tests are not allowed to make actual DML, and must use mocks. Functional Tests can make DML calls through Repo classes.
- All DML (insert, update, upsert, delete, and queries) must take place in Repo classes that extend the BaseRepo class. Each sObject has it's own Repo class named <Sobject>Repo minus any '**c' suffix. For Instance AccountRepo or ContactRepo or for a custom object Foo**c it would be FooRepo.
- All code should throw no new PMD errors or warnings.
