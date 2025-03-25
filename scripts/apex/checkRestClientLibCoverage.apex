// Script to check code coverage for RestClientLib
ApexCodeCoverageAggregate[] coverage = [
    SELECT ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered
    FROM ApexCodeCoverageAggregate
    WHERE ApexClassOrTrigger.Name = 'RestClientLib'
];

if (coverage.size() > 0) {
    ApexCodeCoverageAggregate restLibCoverage = coverage[0];
    Integer totalLines = restLibCoverage.NumLinesCovered + restLibCoverage.NumLinesUncovered;
    Decimal coveragePercent = (restLibCoverage.NumLinesCovered * 100.0) / totalLines;
    
    System.debug('RestClientLib coverage stats:');
    System.debug('Lines covered: ' + restLibCoverage.NumLinesCovered);
    System.debug('Lines not covered: ' + restLibCoverage.NumLinesUncovered);
    System.debug('Total lines: ' + totalLines);
    System.debug('Coverage percentage: ' + coveragePercent.setScale(2) + '%');
    
    // Identify any methods with low coverage
    System.debug('Note: Check execution logs from the test runs for any methods that still need coverage');
} else {
    System.debug('No coverage information found for RestClientLib');
}