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
            DataClassification = CustomerContent;
            TableRelation = "D4P BC Customer";
        }
        field(2; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(4; "Application Family"; Text[50])
        {
            Caption = 'Application Family';
            DataClassification = CustomerContent;
        }
        field(5; Type; Text[50])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(6; State; Text[50])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(7; "Country/Region"; Text[50])
        {
            Caption = 'Country/Region';
            DataClassification = CustomerContent;
        }
        field(8; "Current Version"; Text[100])
        {
            Caption = 'Current Version';
            DataClassification = CustomerContent;
        }
        field(9; "Target Version"; Text[100])
        {
            Caption = 'Target Version';
            DataClassification = CustomerContent;
        }
        field(10; "Selected DateTime"; DateTime)
        {
            Caption = 'Selected Date Time';
            DataClassification = CustomerContent;
        }
        field(11; "Application Insights String"; Text[1024])
        {
            Caption = 'Application Insights Connection String';
            DataClassification = CustomerContent;
            TableRelation = "D4P AppInsights Connection"."AppInsights Connection String";
        }
        field(12; "Friendly Name"; Text[100])
        {
            Caption = 'Friendly Name';
            DataClassification = CustomerContent;
        }
        field(13; "AAD Tenant ID"; Guid)
        {
            Caption = 'AAD Tenant ID';
            DataClassification = CustomerContent;
        }
        field(14; "Web Client Login URL"; Text[250])
        {
            Caption = 'Web Client Login URL';
            DataClassification = CustomerContent;
        }
        field(15; "Web Service URL"; Text[250])
        {
            Caption = 'Web Service URL';
            DataClassification = CustomerContent;
        }
        field(16; "Location Name"; Text[100])
        {
            Caption = 'Location Name';
            DataClassification = CustomerContent;
        }
        field(17; "Geo Name"; Text[100])
        {
            Caption = 'Geo Name';
            DataClassification = CustomerContent;
        }
        field(18; "Ring Name"; Text[50])
        {
            Caption = 'Ring Name';
            DataClassification = CustomerContent;
        }
        field(20; "Soft Deleted On"; DateTime)
        {
            Caption = 'Soft Deleted On';
            DataClassification = CustomerContent;
        }
        field(21; "Hard Delete Pending On"; DateTime)
        {
            Caption = 'Hard Delete Pending On';
            DataClassification = CustomerContent;
        }
        field(22; "Delete Reason"; Text[250])
        {
            Caption = 'Delete Reason';
            DataClassification = CustomerContent;
        }
        field(23; "AppSource Apps Update Cadence"; Text[50])
        {
            Caption = 'AppSource Apps Update Cadence';
            DataClassification = CustomerContent;
        }
        field(24; "Latest Selectable Date"; DateTime)
        {
            Caption = 'Latest Selectable Date';
            DataClassification = CustomerContent;
        }
        field(33; "Ignore Update Window"; Boolean)
        {
            Caption = 'Ignore Update Window';
            DataClassification = CustomerContent;
        }
        field(34; "Rollout Status"; Text[50])
        {
            Caption = 'Rollout Status';
            DataClassification = CustomerContent;
        }
        field(35; "Target Version Type"; Text[20])
        {
            Caption = 'Target Version Type';
            DataClassification = CustomerContent;
        }
        field(36; "Expected Availability"; Text[20])
        {
            Caption = 'Expected Availability';
            DataClassification = CustomerContent;
        }
        field(37; "Available"; Boolean)
        {
            Caption = 'Available';
            DataClassification = CustomerContent;
        }
        field(25; "Grace Period Start Date"; DateTime)
        {
            Caption = 'Grace Period Start Date';
            DataClassification = CustomerContent;
        }
        field(26; "Enforced Update Period Start"; DateTime)
        {
            Caption = 'Enforced Update Period Start Date';
            DataClassification = CustomerContent;
        }
        field(27; "Platform Version"; Text[50])
        {
            Caption = 'Platform Version';
            DataClassification = CustomerContent;
        }
        field(28; "Linked PowerPlatform Env ID"; Text[100])
        {
            Caption = 'Linked Power Platform Environment ID';
            DataClassification = CustomerContent;
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