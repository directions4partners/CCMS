namespace D4P.CCMS.Environment;

using D4P.CCMS.Customer;
using D4P.CCMS.Telemetry;

table 62002 "D4P BC Environment"
{
    Caption = 'D365BC Environment';
    DataClassification = CustomerContent;
    LookupPageId = "D4P BC Environment List";
    DrillDownPageId = "D4P BC Environment List";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer";
            ToolTip = 'Specifies the customer number associated with this environment.';
        }
        field(2; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            ToolTip = 'Specifies the tenant ID of the environment.';
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the environment.';
        }
        field(4; "Application Family"; Text[50])
        {
            Caption = 'Application Family';
            ToolTip = 'Specifies the application family of the environment.';
        }
        field(5; Type; Text[50])
        {
            Caption = 'Type';
            ToolTip = 'Specifies the type of the environment.';
        }
        field(6; State; Text[50])
        {
            Caption = 'State';
            ToolTip = 'Specifies the current state of the environment.';
        }
        field(7; "Country/Region"; Text[50])
        {
            Caption = 'Country/Region';
            ToolTip = 'Specifies the country/region of the environment.';
        }
        field(8; "Current Version"; Text[100])
        {
            Caption = 'Current Version';
            ToolTip = 'Specifies the current version of Business Central.';
        }
        field(9; "Target Version"; Text[100])
        {
            Caption = 'Target Version';
            ToolTip = 'Specifies the target version of Business Central update.';
        }
        field(10; "Selected DateTime"; DateTime)
        {
            Caption = 'Selected Date Time';
            ToolTip = 'Indicates the datetime for which the update to the target version has been scheduled.';
        }
        field(11; "Application Insights String"; Text[1024])
        {
            Caption = 'Application Insights Connection String';
            TableRelation = "D4P AppInsights Connection"."AppInsights Connection String";
            ToolTip = 'Specifies the connection string for Application Insights. Use the lookup to select from existing configurations or type directly to create new entries.';
        }
        field(12; "Friendly Name"; Text[100])
        {
            Caption = 'Friendly Name';
            ToolTip = 'Specifies the friendly/display name of the environment.';
        }
        field(13; "AAD Tenant ID"; Guid)
        {
            Caption = 'AAD Tenant ID';
        }
        field(14; "Web Client Login URL"; Text[250])
        {
            Caption = 'Web Client Login URL';
            ToolTip = 'Specifies the URL to log into the environment.';
        }
        field(15; "Web Service URL"; Text[250])
        {
            Caption = 'Web Service URL';
            ToolTip = 'Specifies the URL to access the environment service API.';
        }
        field(16; "Location Name"; Text[100])
        {
            Caption = 'Location Name';
            ToolTip = 'Specifies the Azure Region where the environment database is stored.';
        }
        field(17; "Geo Name"; Text[100])
        {
            Caption = 'Geo Name';
            ToolTip = 'Specifies the Azure Geo where the environment database is stored.';
        }
        field(18; "Ring Name"; Text[50])
        {
            Caption = 'Ring Name';
            ToolTip = 'Specifies the update ring name (e.g., Prod, Preview).';
        }
        field(20; "Soft Deleted On"; DateTime)
        {
            Caption = 'Soft Deleted On';
            ToolTip = 'Specifies when the environment was soft deleted.';
        }
        field(21; "Hard Delete Pending On"; DateTime)
        {
            Caption = 'Hard Delete Pending On';
            ToolTip = 'Specifies when the environment will be permanently deleted.';
        }
        field(22; "Delete Reason"; Text[250])
        {
            Caption = 'Delete Reason';
            ToolTip = 'Specifies the reason why the environment was deleted.';
        }
        field(23; "AppSource Apps Update Cadence"; Text[50])
        {
            Caption = 'AppSource Apps Update Cadence';
            ToolTip = 'Specifies the cadence for automatic AppSource apps updates.';
        }
        field(24; "Latest Selectable Date"; DateTime)
        {
            Caption = 'Latest Selectable Date';
            ToolTip = 'Indicates the last date for which the update to this target version can be scheduled.';
        }
        field(25; "Grace Period Start Date"; DateTime)
        {
            Caption = 'Grace Period Start Date';
            ToolTip = 'Specifies the grace period start date for the current major version.';
        }
        field(26; "Enforced Update Period Start"; DateTime)
        {
            Caption = 'Enforced Update Period Start Date';
            ToolTip = 'Specifies the enforced update period start date for the current major version.';
        }
        field(27; "Platform Version"; Text[50])
        {
            Caption = 'Platform Version';
            ToolTip = 'Specifies the platform version of the environment.';
        }
        field(28; "Linked PowerPlatform Env ID"; Text[100])
        {
            Caption = 'Linked Power Platform Environment ID';
            ToolTip = 'Specifies the linked Power Platform environment ID.';
        }
        field(29; "Telemetry API Key"; Text[50])
        {
            Caption = 'Telemetry API Key';
            FieldClass = FlowField;
            CalcFormula = lookup("D4P AppInsights Connection"."Telemetry API Key" where("AppInsights Connection String" = field("Application Insights String")));
            Editable = false;
            ToolTip = 'Specifies the API key for telemetry data access (automatically retrieved from AppInsights Connection Setup).';
        }
        field(30; "Telemetry Application ID"; Text[50])
        {
            Caption = 'Telemetry Application ID';
            FieldClass = FlowField;
            CalcFormula = lookup("D4P AppInsights Connection"."Telemetry Application Id" where("AppInsights Connection String" = field("Application Insights String")));
            Editable = false;
            ToolTip = 'Specifies the Application ID for telemetry data access (automatically retrieved from AppInsights Connection Setup).';
        }
        field(31; "Telemetry Tenant ID"; Text[50])
        {
            Caption = 'Telemetry Tenant ID';
            FieldClass = FlowField;
            CalcFormula = lookup("D4P AppInsights Connection"."Tenant Id" where("AppInsights Connection String" = field("Application Insights String")));
            Editable = false;
            ToolTip = 'Specifies the Tenant ID for telemetry data access (automatically retrieved from Application Insights Connection Setup).';
        }
        field(32; "Telemetry Description"; Text[50])
        {
            Caption = 'Telemetry Description';
            FieldClass = FlowField;
            CalcFormula = lookup("D4P AppInsights Connection"."Description" where("AppInsights Connection String" = field("Application Insights String")));
            Editable = false;
            ToolTip = 'Specifies the description for the telemetry connection (automatically retrieved from Application Insights Connection Setup).';
        }
        field(33; "Ignore Update Window"; Boolean)
        {
            Caption = 'Ignore Update Window';
            ToolTip = 'Indicates whether the update window for the environment may be ignored.';
        }
        field(34; "Rollout Status"; Text[50])
        {
            Caption = 'Rollout Status';
            ToolTip = 'Indicates the rollout status of updates to this target version.';
        }
        field(35; "Target Version Type"; Text[20])
        {
            Caption = 'Target Version Type';
            ToolTip = 'Indicates the type of the target version (GA or Preview).';
        }
        field(36; "Expected Availability"; Text[20])
        {
            Caption = 'Expected Availability';
            ToolTip = 'Expected availability month/year for unreleased versions.';
        }
        field(37; "Available"; Boolean)
        {
            Caption = 'Available';
            ToolTip = 'Indicates whether the target version has been released.';
        }
        field(38; "Customer Name"; Text[100])
        {
            CalcFormula = lookup("D4P BC Customer".Name where("No." = field("Customer No.")));
            Caption = 'Customer Name';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the name of the customer associated with this environment.';
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Tenant ID", Name)
        {
            Clustered = true;
        }
    }
}