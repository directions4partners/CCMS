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
        }
        field(2; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(4; "Application Family"; Text[50])
        {
            Caption = 'Application Family';
        }
        field(5; Type; Text[50])
        {
            Caption = 'Type';
        }
        field(6; State; Text[50])
        {
            Caption = 'State';
        }
        field(7; "Country/Region"; Text[50])
        {
            Caption = 'Country/Region';
        }
        field(8; "Current Version"; Text[100])
        {
            Caption = 'Current Version';
        }
        field(9; "Target Version"; Text[100])
        {
            Caption = 'Target Version';
        }
        field(10; "Selected DateTime"; DateTime)
        {
            Caption = 'Selected Date Time';
        }
        field(11; "Application Insights String"; Text[1024])
        {
            Caption = 'Application Insights Connection String';
            TableRelation = "D4P AppInsights Connection"."AppInsights Connection String";
        }
        field(12; "Friendly Name"; Text[100])
        {
            Caption = 'Friendly Name';
        }
        field(13; "AAD Tenant ID"; Guid)
        {
            Caption = 'AAD Tenant ID';
        }
        field(14; "Web Client Login URL"; Text[250])
        {
            Caption = 'Web Client Login URL';
        }
        field(15; "Web Service URL"; Text[250])
        {
            Caption = 'Web Service URL';
        }
        field(16; "Location Name"; Text[100])
        {
            Caption = 'Location Name';
        }
        field(17; "Geo Name"; Text[100])
        {
            Caption = 'Geo Name';
        }
        field(18; "Ring Name"; Text[50])
        {
            Caption = 'Ring Name';
        }
        field(20; "Soft Deleted On"; DateTime)
        {
            Caption = 'Soft Deleted On';
        }
        field(21; "Hard Delete Pending On"; DateTime)
        {
            Caption = 'Hard Delete Pending On';
        }
        field(22; "Delete Reason"; Text[250])
        {
            Caption = 'Delete Reason';
        }
        field(23; "AppSource Apps Update Cadence"; Text[50])
        {
            Caption = 'AppSource Apps Update Cadence';
        }
        field(24; "Latest Selectable Date"; DateTime)
        {
            Caption = 'Latest Selectable Date';
        }
        field(33; "Ignore Update Window"; Boolean)
        {
            Caption = 'Ignore Update Window';
        }
        field(34; "Rollout Status"; Text[50])
        {
            Caption = 'Rollout Status';
        }
        field(35; "Target Version Type"; Text[20])
        {
            Caption = 'Target Version Type';
        }
        field(36; "Expected Availability"; Text[20])
        {
            Caption = 'Expected Availability';
        }
        field(37; "Available"; Boolean)
        {
            Caption = 'Available';
        }
        field(25; "Grace Period Start Date"; DateTime)
        {
            Caption = 'Grace Period Start Date';
        }
        field(26; "Enforced Update Period Start"; DateTime)
        {
            Caption = 'Enforced Update Period Start Date';
        }
        field(27; "Platform Version"; Text[50])
        {
            Caption = 'Platform Version';
        }
        field(28; "Linked PowerPlatform Env ID"; Text[100])
        {
            Caption = 'Linked Power Platform Environment ID';
        }
        field(29; "Telemetry API Key"; Text[50])
        {
            Caption = 'Telemetry API Key';
            FieldClass = FlowField;
            CalcFormula = lookup("D4P AppInsights Connection"."Telemetry API Key" where("AppInsights Connection String" = field("Application Insights String")));
            Editable = false;
        }
        field(30; "Telemetry Application ID"; Text[50])
        {
            Caption = 'Telemetry Application ID';
            FieldClass = FlowField;
            CalcFormula = lookup("D4P AppInsights Connection"."Telemetry Application Id" where("AppInsights Connection String" = field("Application Insights String")));
            Editable = false;
        }
        field(31; "Telemetry Tenant ID"; Text[50])
        {
            Caption = 'Telemetry Tenant ID';
            FieldClass = FlowField;
            CalcFormula = lookup("D4P AppInsights Connection"."Tenant Id" where("AppInsights Connection String" = field("Application Insights String")));
            Editable = false;
        }
        field(32; "Telemetry Description"; Text[50])
        {
            Caption = 'Telemetry Description';
            FieldClass = FlowField;
            CalcFormula = lookup("D4P AppInsights Connection"."Description" where("AppInsights Connection String" = field("Application Insights String")));
            Editable = false;
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