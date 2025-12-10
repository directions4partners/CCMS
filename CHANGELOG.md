# Changelog

All notable changes to the Cloud Customer Management System (CCMS) project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-12-10

### Added

#### Core Management
- **Customer Management**: Customer records with tenant associations
  - Customer List page (62000)
  - Customer Card page (62001)
  - Navigate to BC Tenants action
  
- **Tenant Management**: Azure AD tenant configuration and credentials
  - Tenant List page (62002)
  - Tenant Card page (62011)
  - Tenant FactBox (62012)
  - Client ID/Secret management with expiration tracking
  - Backup SAS token configuration with expiration alerts
  - Visual expiration indicators for Client Secret and SAS Token
  - New and Delete actions
  - Setup and Test Debug Mode actions
  
- **Environment Management**: Complete CRUD operations via Admin API v2.28
  - Environment List page (62003)
  - Environment Card page (62004)
  - New Environment Dialog (62005)
  - Copy Environment Dialog (62006)
  - Rename Environment Dialog (62007)
  - Update Selection Dialog (62025)
  - Available Update table (62024)
  - Environment Type enum (62000)
  - Tenant Migration Dialog (62017)
  - Create, Copy, Rename, Delete environment operations
  - Update scheduling and version management
  - Application Insights connection string configuration
  - App/Extension update management
  - Get Environment data actions (Environments, Updates, App Updates, Scheduled Updates)

#### Advanced Features
- **Telemetry System**: KQL-based Application Insights integration
  - KQL Query Store table for managing queries
  - KQL Query Selection page (62039)
  - KQL Queries management page (62040)
  - KQL Query Preview page (62041)
  - Extension Lifecycle tracking page (62042)
  - Page Executions analytics page (62043)
  - Report Executions analytics page (62044)
  - Slow AL Methods detection page (62045)
  - AppInsights Connection List (62047)
  - AppInsights Connection Card (62048)
  - Pre-built KQL query templates
  - Custom query builder
  - Load Data report (62032)
  
- **Backup System**: Database export operations
  - Environment Backup table and list page (62014)
  - Start Database Export action
  - Get Export Metrics action
  - Get Export History action
  - Point-in-Time restore functionality
  
- **Session Management**: Active session monitoring and termination
  - Environment Sessions table and list page (62016)
  - Environment Session Card page (62019)
  - Get Sessions action
  - Get Session Details action
  - Terminate Session action
  
- **Capacity Monitoring**: Storage quotas and environment limits
  - Capacity Worksheet page (62021)
  - Capacity Subform page (62022)
  - Capacity Card page (62023)
  - Get Quotas action
  - Get Storage per Environment action
  
- **Feature Management**: Environment feature toggles via Automation API
  - Environment Features list page (62013)
  - Get Features action
  - Update Feature action
  - Activate/Deactivate feature operations

#### Infrastructure
- **Centralized API Helper** (D4PBCAPIHelper - Codeunit 62049)
  - Single point for all HTTP/OAuth operations
  - Admin API integration (v2.28)
  - Automation API integration (v2.0)
  - Automatic token management
  - Debug logging support
  - Eliminated ~1,150+ lines of duplicate HTTP/OAuth code
  
- **Namespace Organization**: All objects organized with D4P.CCMS.{Area} pattern
  - D4P.CCMS.Customer
  - D4P.CCMS.Tenant
  - D4P.CCMS.Environment
  - D4P.CCMS.Extension
  - D4P.CCMS.Backup
  - D4P.CCMS.Session
  - D4P.CCMS.Capacity
  - D4P.CCMS.Features
  - D4P.CCMS.Telemetry
  - D4P.CCMS.Setup
  - D4P.CCMS.General
  - D4P.CCMS.Permissions
  
- **Configurable API Endpoints**
  - Admin API base URL configuration in Setup (default: v2.28)
  - Automation API base URL configuration in Setup (default: v2.0)
  - Restore Defaults action
  
- **Permission Sets**: Role-based access control
  - D4P BC ADMIN (62000): Full admin access - all operations
  - D4P BC ADMIN READ (62001): Read-only access to all data
  - D4P BC SETUP (62002): Setup configuration only
  - D4P BC TELEMETRY (62003): Telemetry data access

#### User Interface
- **Role Center**: D4P BC Admin Role Center (62049)
- **Profile**: D4P BC Admin profile
- **Cues**: Cloud Customer Management System Cues (62034)
- **Setup Page**: D4P BC Setup (62010) with Debug Mode toggle

#### Extension Management
- Installed Apps table and list page (62008)
- PTE Object Range table (62004) and list page (62009)
- App State enum (62002)
- App Type enum (62005)
- Update Attempt Result enum (62003)
- Uninstall Attempt Result enum (62004)
- Get Available Updates action
- Update App action

### Changed
- Refactored all 5 helper codeunits to use centralized API methods:
  - D4PBCBackupHelper: 1 procedure refactored
  - D4PBCEnvironmentMgt: 11 procedures refactored
  - D4PBCSessionHelper: 3 procedures refactored
  - D4PBCCapacityHelper: 2 procedures refactored
  - D4PBCFeaturesHelper: 5 procedures refactored
- Upgraded Admin API from v2.24 to v2.28 for full endpoint support
- Updated Tenant List page caption from "D365BC Tenants" to "D365BC Entra Tenants"

### Fixed
- GetEnvironmentUpdates endpoint: Fixed missing `applicationFamily` parameter
- Admin API version: Upgraded to v2.28 for GET /updates support
- Duplicate HTTP code: Centralized in APIHelper

### Technical Details
- **Platform**: Business Central 27.0 (Runtime 16.0)
- **Publisher**: Directions for partners
- **Object ID Ranges**: 62000-62049
- **API Integrations**: 
  - Microsoft Business Central Admin Center API v2.28
  - Automation API v2.0
  - Application Insights REST API
- **Authentication**: Azure AD OAuth2 with Client Credentials flow

### Architecture
- Centralized API pattern through D4PBCAPIHelper
- Organized folder structure with logical separation:
  - Customer/
  - Tenant/
  - Environment/
  - Extension/
  - Backup/
  - Session/
  - Capacity/
  - Features/
  - Telemetry/
  - Setup/
  - General/
  - Permissions/

### Known Limitations
- Requires Azure AD App Registration with proper API permissions
- Requires Microsoft Business Central Admin Center API access
- Tenant-to-Tenant Migration feature structure created but implementation pending

---

[0.0.1]: https://github.com/directions4partners/CCMS/releases/tag/v0.0.1
