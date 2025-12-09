namespace D4P.CCMS.Features;

using D4P.CCMS.Customer;

table 62013 "D4P BC Environment Features"
{
    Caption = 'D365BC Environment Features';
    DataClassification = SystemMetadata;
    DrillDownPageId = "D4P BC Environment Features";
    LookupPageId = "D4P BC Environment Features";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer"."No.";
        }
        field(5; "Tenant ID"; Text[50])
        {
            Caption = 'Tenant ID';
        }
        field(10; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
        }
        field(15; "Feature Name"; Text[100])
        {
            Caption = 'Feature Name';
        }
        field(20; "Feature Key"; Text[100])
        {
            Caption = 'Feature Key';
        }
        field(25; "Is Enabled"; Text[50])
        {
            Caption = 'Enabled Status';
            // Values: "All Users", "None", etc.
        }
        field(30; "Learn More Link"; Text[250])
        {
            Caption = 'Learn More Link';
        }
        field(35; "Mandatory By"; Text[100])
        {
            Caption = 'Mandatory By';
        }
        field(40; "Mandatory By Version"; Text[30])
        {
            Caption = 'Mandatory By Version';
        }
        field(45; "Can Try"; Boolean)
        {
            Caption = 'Can Try';
        }
        field(50; "Is One Way"; Boolean)
        {
            Caption = 'Is One Way';
        }
        field(55; "Feature Description"; Text[250])
        {
            Caption = 'Feature Description';
        }
        field(60; "Description In English"; Text[250])
        {
            Caption = 'Description In English';
        }
        field(65; "Data Update Required"; Boolean)
        {
            Caption = 'Data Update Required';
        }
        field(70; "Last Modified"; DateTime)
        {
            Caption = 'Last Modified';
        }
    }

    keys
    {
        key(PK; "Customer No.", "Tenant ID", "Environment Name", "Feature Key")
        {
            Clustered = true;
        }
        key(FeatureName; "Feature Name")
        {
        }
    }
}