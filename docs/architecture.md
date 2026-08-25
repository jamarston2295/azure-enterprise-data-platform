# Architecture

## 1. Overview

The Azure Enterprise Data Platform is a cloud-based data platform designed to ingest data from multiple source systems, retain raw historical data, transform and validate datasets, and provide curated data for analytical consumption.

The platform uses Azure Data Factory for ingestion and orchestration, Azure Data Lake Storage Gen2 as the central data lake, Azure Databricks for transformation and data quality processing, and Azure SQL Database as a relational serving layer.

Supporting Azure services provide security, monitoring and secrets management, while GitHub, GitHub Actions and Bicep provide source control, CI/CD and infrastructure as code.

## 2. High-Level Architecture

```text
                         ┌─────────────────────┐
                         │     Data Sources    │
                         │                     │
                         │ REST APIs           │
                         │ CSV Files           │
                         │ SQL Database        │
                         │ Reference Data      │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │  Azure Data Factory │
                         │                     │
                         │ Ingestion           │
                         │ Orchestration       │
                         │ Scheduling          │
                         └──────────┬──────────┘
                                    │
                                    ▼
                 ┌─────────────────────────────────┐
                 │       ADLS Gen2 — Bronze        │
                 │                                 │
                 │          Raw Data               │
                 └───────────────┬─────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │      Azure Databricks  │
                    │                        │
                    │ PySpark                │
                    │ Data Quality           │
                    │ Transformations        │
                    └────────────┬───────────┘
                                 │
                                 ▼
                 ┌─────────────────────────────────┐
                 │        ADLS Gen2 — Silver       │
                 │                                 │
                 │       Clean Delta Tables        │
                 └───────────────┬─────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │      Azure Databricks  │
                    │                        │
                    │Business Transformations│
                    └────────────┬───────────┘
                                 │
                                 ▼
                 ┌─────────────────────────────────┐
                 │         ADLS Gen2 — Gold        │
                 │                                 │
                 │       Curated Data Products     │
                 └───────────────┬─────────────────┘
                                 │
                         ┌───────┴────────┐
                         ▼                ▼
                 ┌─────────────┐   ┌─────────────┐
                 │ Azure SQL   │   │   Power BI  │
                 │   Serving   │   │  Reporting  │
                 └─────────────┘   └─────────────┘


        ┌─────────────────────────────────────────────────┐
        │              Supporting Services                │
        │                                                 │
        │ Key Vault │ Entra ID │ RBAC │ Monitor           │
        │ Log Analytics                                   │
        └─────────────────────────────────────────────────┘


                    GitHub / GitHub Actions
                              │
                              ▼
                            Bicep
                              │
                              ▼
                     Azure Infrastructure
```
## 3. Data Flow
### 3.1 Ingestion

Source systems provide data through APIs, files and relational databases.

Azure Data Factory is responsible for orchestrating ingestion from these sources.

Data is initially written to the Bronze layer of Azure Data Lake Storage Gen2.

The Bronze layer retains source data in its original form wherever possible, providing a historical record of what was received from each source.

### 3.2 Transformation

Azure Databricks reads data from the Bronze layer and performs cleaning, standardisation and validation using PySpark.

The resulting datasets are written to the Silver layer using Delta Lake.

Data quality checks are performed during this stage and invalid or problematic records should be identifiable rather than silently discarded.

### 3.3 Curated Data

Further transformations are performed against the Silver datasets to create business-ready Gold datasets.

Gold datasets are designed around analytical requirements rather than the structure of the original source systems.

### 3.4 Data Consumption

Selected curated datasets will be made available through Azure SQL Database for relational consumption.

Power BI will be used to demonstrate analytical consumption of the curated data.

The final implementation will determine which datasets are best suited to each consumption method.

## 4. Architecture Components
### Azure Data Lake Storage Gen2

ADLS Gen2 provides the central storage layer for the platform.

The data lake is organised using a Bronze, Silver and Gold architecture.

- Bronze — raw source data
- Silver — cleaned and validated Delta datasets
- Gold — curated analytical datasets

ADLS provides scalable storage while allowing the platform to retain historical source data independently of downstream processing.

### Azure Data Factory

Azure Data Factory provides orchestration and data integration.

It is responsible for:

- Triggering ingestion pipelines
- Connecting to source systems
- Moving data into the Bronze layer
- Managing pipeline dependencies
- Supporting scheduled execution
- Supporting incremental ingestion
- Providing pipeline execution information

### Azure Databricks

Azure Databricks provides the transformation and processing environment.

PySpark will be used to:

- Clean data
- Standardise schemas
- Apply business rules
- Perform joins
- Validate data
- Create Delta tables
- Perform incremental processing

### Azure SQL Database

Azure SQL Database provides a relational serving layer for selected curated datasets.

It allows consumers that require a traditional SQL interface to query curated information.

### Power BI

Power BI provides the analytical and reporting layer.

It will consume appropriate curated datasets and demonstrate how the platform can support business reporting.

### Azure Key Vault

Azure Key Vault will provide secure storage and management of secrets required by the platform.

Where possible, managed identities will be used instead of storing credentials.

### Microsoft Entra ID and RBAC

Microsoft Entra ID will provide identity management and Azure role-based access control will be used to apply least-privilege access to platform resources.

### Azure Monitor and Log Analytics

Azure Monitor and Log Analytics will provide operational monitoring.

The platform should expose information such as:

- Pipeline execution status
- Pipeline duration
- Failed activities
- Processing volumes
- Data quality failures

### Bicep

Bicep will be used to define Azure infrastructure as code.

This allows the environment to be recreated consistently and reduces reliance on manual configuration through the Azure Portal.

### GitHub and GitHub Actions

GitHub provides source control.

GitHub Actions will provide automated validation and deployment processes.

## 5. Data Lake Structure

The initial data lake structure will follow the pattern below:

```text
/
├── bronze/
│   ├── transport/
│   ├── weather/
│   ├── maintenance/
│   └── reference/
│
├── silver/
│   ├── transport/
│   ├── weather/
│   ├── maintenance/
│   └── reference/
│
└── gold/
    ├── assets/
    ├── maintenance/
    └── operational_metrics/
```

The exact datasets and partitioning strategy will be determined during implementation.

## 6. Security Architecture

Security will be implemented using Azure-native identity and access controls.

The platform will aim to:

- Use managed identities where supported.
- Store secrets in Azure Key Vault.
- Avoid hard-coded credentials.
- Apply least-privilege RBAC.
- Separate development, test and production environments.
- Prevent secrets from being committed to source control.

Security decisions will be documented as the platform is implemented.

## 7. Infrastructure and Deployment

Azure resources will be deployed using Bicep rather than relying exclusively on manual portal configuration.

The intended deployment flow is:

```text
Developer
    │
    ▼
GitHub
    │
    ▼
GitHub Actions
    │
    ├── Validate
    ├── Test
    └── Deploy
          │
          ▼
        Bicep
          │
          ▼
     Azure Resources
```

This allows infrastructure changes to be version controlled, reviewed and reproduced.

## 8. Architectural Decisions

This section will record significant architectural decisions made during implementation.

### 8.1 Why ADLS Gen2?

ADLS Gen2 provides scalable cloud storage suitable for retaining raw source data and supporting a layered data lake architecture.

It also provides the underlying storage required for the Bronze, Silver and Gold approach.

### 8.2 Why Azure Data Factory?

ADF provides managed data integration and orchestration capabilities and can connect to a wide range of data sources.

It will therefore be responsible primarily for moving and orchestrating data rather than performing complex transformations.

### 8.3 Why Azure Databricks?

Databricks provides a scalable Spark-based processing environment and allows the project to demonstrate PySpark, Delta Lake and incremental data processing.

This makes it appropriate for the transformation and data quality layer.

### 8.4 Why Delta Lake?

Delta Lake provides transactional capabilities and supports operations such as updates and merges.

This will allow the project to demonstrate reliable incremental processing rather than simply writing independent Parquet files.

### 8.5 Why Azure SQL?

Azure SQL provides a relational serving layer for consumers that require SQL-based access to curated datasets.

Not every dataset will necessarily be loaded into Azure SQL. The final serving architecture will depend on the analytical requirements.

### 8.6 Why Bicep?

Bicep allows Azure infrastructure to be represented as version-controlled code.

This makes deployments reproducible and provides experience with Infrastructure as Code, which is an important part of production Azure environments.

## 9. Design Principles

The platform will follow these principles:

### Automation

Manual data processing should be minimised.

### Reproducibility

Infrastructure and processing logic should be reproducible from source control.

### Security by design

Credentials and permissions should be managed securely from the beginning.

### Incremental processing

The platform should avoid unnecessarily reprocessing historical data.

### Data quality

Invalid or unexpected data should be identified rather than silently propagated.

### Observability

Pipeline execution and data processing should be observable.

### Separation of concerns

Ingestion, transformation, serving and reporting should have clearly defined responsibilities.

### Scalability

The platform should be capable of handling increasing data volumes without fundamental architectural changes.