# Azure Enterprise Data Platform — Requirements

## 1. Project Overview

The purpose of this project is to design and implement a cloud-based data platform on Microsoft Azure for a fictional UK infrastructure organisation.

The platform will ingest data from multiple source systems, store the data in a scalable data lake, transform and validate the data, and provide curated datasets for analysis and reporting.

The project is intended to demonstrate the design and implementation of a production-style Azure data engineering solution, including data ingestion, transformation, orchestration, security, monitoring, testing, infrastructure-as-code and CI/CD.

## 2. Business Objective

The organisation currently receives data from a number of different systems and sources. The data is difficult to combine and requires manual processing before it can be used for analysis.

The organisation requires a centralised data platform that will:

- Consolidate data from multiple sources.
- Retain historical data.
- Automate data ingestion and processing.
- Provide reliable and trusted datasets for analysts.
- Reduce manual data processing.
- Support incremental data processing.
- Provide visibility of pipeline execution and failures.
- Apply appropriate security controls.
- Provide a scalable foundation for future data sources.

## 3. Data Sources

The platform will initially integrate several different types of data source to demonstrate different ingestion patterns.

### 3.1 REST API

The platform will ingest data from a publicly available REST API.

Requirements:

- The API must be accessed programmatically.
- API responses must be captured in the raw data layer.
- The ingestion process must support historical data where available.
- API failures must be handled appropriately.
- The ingestion process must be capable of being scheduled.

### 3.2 CSV Files

The platform will ingest CSV files representing an asset register.

Requirements:

- Files must be ingested without modifying the original source data.
- Multiple files must be supported.
- The ingestion process must record when files were received.
- The platform must be able to process new files without requiring the pipeline to be redesigned.

### 3.3 Relational Database

The platform will ingest maintenance records from a relational database.

Requirements:

- Data must be extracted without manually exporting the database.
- The ingestion process must support incremental extraction.
- New and changed records should be identifiable.
- Database credentials must not be hard-coded in source code or pipeline definitions.

### 3.4 Reference Data

Reference datasets such as regions, asset types and categories will also be incorporated.

These datasets will support joins and enrichment during the transformation process.

## 4. Data Lake Requirements

Azure Data Lake Storage Gen2 will provide the central storage layer for the platform.

The data lake will use a medallion-style architecture:

```text
Bronze
  ↓
Silver
  ↓
Gold
```

### Bronze Layer

The Bronze layer will contain raw source data.

Requirements:

- Raw data must be retained.
- Source data must not be modified during ingestion.
- Data must be organised by source and ingestion date.
- Historical data must be retained.
- File naming and folder structures must be consistent.

Example:

```text
bronze/
├── transport/
│   └── 2026/08/24/
├── weather/
│   └── 2026/08/24/
└── maintenance/
    └── 2026/08/24/
```
### Silver Layer

The Silver layer will contain cleaned and standardised data.

Requirements:

- Data types must be standardised.
- Invalid records must be identified.
- Duplicate records should be handled.
- Data quality checks must be performed.
- Data should be stored using Delta Lake.
- Transformations must be reproducible.

### Gold Layer

The Gold layer will contain business-ready datasets.

Requirements:

- Data should be structured around analytical requirements.
- Complex transformations should be performed before data reaches the Gold layer.
- Gold datasets should be suitable for consumption by reporting and analytical tools.
- Data should be optimised for querying.

## 5. Data Ingestion Requirements

Azure Data Factory will be used as the primary orchestration and data integration service.

The ingestion framework should:

- Support multiple data sources.
- Support parameterised pipelines.
- Support scheduled execution.
- Support incremental ingestion.
- Allow new datasets to be added without duplicating large amounts of pipeline logic.
- Record pipeline execution information.
- Handle failures appropriately.
- Prevent duplicate ingestion where possible.

The platform should use metadata-driven ingestion where appropriate, allowing source configuration to control how datasets are ingested rather than requiring a separate hard-coded pipeline for every source.

## 6. Data Transformation Requirements

Azure Databricks and PySpark will be used for large-scale transformation and processing.

The transformation layer must:

- Clean incoming data.
- Standardise schemas.
- Apply business rules.
- Remove or appropriately handle duplicate records.
- Handle missing and invalid values.
- Perform joins between datasets.
- Produce Delta Lake tables.
- Support incremental processing.
- Maintain historical records where required.

Transformations should be modular and maintainable.

## 7. Incremental Processing

The platform must support incremental processing rather than requiring the complete dataset to be processed on every pipeline execution.

Where appropriate, the platform should:

- Identify new or modified source records.
- Ingest only the required data.
- Transform the new data.
- Merge the results into existing Delta tables.
- Maintain appropriate historical information.

The implementation should demonstrate the difference between full loading and incremental loading.

## 8. Data Quality

The platform must implement automated data quality checks.

Checks should include, where appropriate:

- Required fields are populated.
- Expected data types are present.
- Duplicate records are identified.
- Values fall within expected ranges.
- Referential integrity is maintained.
- Unexpected schema changes are detected.
- Record counts are monitored.

Data quality failures should be identifiable and should not silently pass through the platform.

## 9. Serving Layer

Azure SQL Database will provide a relational serving layer for selected curated datasets.

Requirements:

- Curated data must be accessible through SQL.
- Tables should use appropriate data types.
- The database should be structured for analytical querying.
- Loading should support incremental updates where appropriate.
- Access should use secure authentication.
- Credentials must not be stored in source code.

## 10. Security

Security must be considered throughout the platform.

The solution should:

- Use Microsoft Entra ID where supported.
- Use managed identities instead of storing credentials wherever possible.
- Apply least-privilege access.
- Separate access to different Azure resources.
- Store secrets in Azure Key Vault.
- Prevent credentials and secrets from being committed to Git.
- Use role-based access control (RBAC).
- Maintain appropriate separation between development and production resources.

Azure Data Factory supports managed identity authentication for services such as ADLS Gen2, and Microsoft recommends managed identities as a way to avoid managing credentials directly.

## 11. Monitoring and Alerting

The platform must provide visibility of pipeline operation.

Monitoring should include:

- Pipeline execution status.
- Pipeline duration.
- Number of records processed.
- Failed activities.
- Data quality failures.
- Ingestion failures.
- Transformation failures.

Azure Monitor and Log Analytics will be considered for centralised operational monitoring.

Where appropriate, failures should generate an alert so that operational issues can be investigated promptly.

## 12. Infrastructure as Code

Azure infrastructure should be deployed using Infrastructure as Code.

The project will use Bicep to define Azure resources.

Infrastructure code should define resources such as:

- Resource groups
- ADLS Gen2
- Azure Data Factory
- Azure Databricks
- Azure SQL
- Azure Key Vault
- Monitoring resources

Infrastructure should be reproducible so that the environment can be recreated without manually configuring each resource through the Azure Portal.

## 13. CI/CD

The project must use GitHub Actions to automate software quality checks and deployment processes.

The CI/CD process should:

- Validate Python code.
- Run unit tests.
- Validate infrastructure code.
- Prevent broken code from being deployed.
- Support deployment of infrastructure.
- Support deployment of data engineering code where practical.

The repository will use Git for version control.

## 14. Environment Separation

The platform should support separate environments for:

```text
Development
     ↓
Test
     ↓
Production
```

The implementation should demonstrate how configuration and infrastructure can differ between environments without duplicating the entire codebase.

## 15. Reliability and Error Handling

The platform should be designed to handle expected operational failures.

This should include:

- API failures.
- Temporary network failures.
- Invalid input data.
- Missing files.
- Schema changes.
- Database connection failures.
- Transformation failures.

Where appropriate, pipelines should support retries and failed records should be identifiable for investigation.

## 16. Performance and Scalability

The platform should be designed so that data volumes can increase without requiring fundamental redesign.

Considerations should include:

- Partitioning.
- File formats.
- Delta Lake optimisation.
- Appropriate Spark processing.
- Incremental processing.
- Query performance.
- Pipeline parallelisation where appropriate.

The solution should avoid processing the entire historical dataset unnecessarily when only new data has arrived.

## 17. Testing

Automated testing should be incorporated throughout the project.

Tests should cover, where appropriate:

- Python transformation logic.
- Data quality rules.
- Schema validation.
- Incremental processing logic.
- Configuration.
- Infrastructure validation.

External Azure services should be mocked where appropriate so that unit tests can run without requiring live cloud resources.

## 18. Documentation

The project must include documentation covering:

- Business requirements.
- Architecture.
- Azure resources.
- Data flows.
- Data model.
- Security approach.
- Deployment process.
- Testing strategy.
- Monitoring approach.
- Key architectural decisions.

The README should provide a concise overview of the completed platform, with more detailed documentation maintained under docs/.

## 19. Key Success Criteria

The project will be considered successful when:

- Multiple source types can be ingested automatically.
- Raw data is retained in ADLS Gen2.
- Data is transformed into validated Silver datasets.
- Curated Gold datasets are produced.
- Delta Lake is used for appropriate datasets.
- Incremental processing is demonstrated.
- Data quality checks are automated.
- Curated data can be queried through Azure SQL.
- Data Factory orchestrates the platform.
- Azure resources are defined using Bicep.
- Secrets are securely managed.
- Managed identities are used where appropriate.
- Pipeline execution can be monitored.
- Automated tests pass.
- CI/CD successfully validates and deploys the solution.
- The platform can be reproduced from source control.
