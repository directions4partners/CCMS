namespace D4P.CCMS.Features;

using D4P.CCMS.Customer;

table 62013 "D4P BC Environment Feature"
{
    Caption = 'D365BC Environment Feature';
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
            ToolTip = 'Specifies the name of the feature.';
        }
        field(20; "Feature Key"; Text[100])
        {
            Caption = 'Feature Key';
            ToolTip = 'Specifies the unique key of the feature.';
        }
        field(25; "Is Enabled"; Text[50])
        {
            Caption = 'Enabled Status';
            ToolTip = 'Specifies the enabled status (All Users, None, etc.).';
            // Values: "All Users", "None", etc.
        }
        field(30; "Learn More Link"; Text[250])
        {
            Caption = 'Learn More Link';
            ToolTip = 'Specifies the link to learn more about the feature.';
        }
        field(35; "Mandatory By"; Text[100])
        {
            Caption = 'Mandatory By';
            ToolTip = 'Specifies when the feature becomes mandatory.';
        }
        field(40; "Mandatory By Version"; Text[30])
        {
            Caption = 'Mandatory By Version';
            ToolTip = 'Specifies the BC version when the feature becomes mandatory.';
        }
        field(45; "Can Try"; Boolean)
        {
            Caption = 'Can Try';
            ToolTip = 'Specifies whether the feature can be tried.';
        }
        field(50; "Is One Way"; Boolean)
        {
            Caption = 'Is One Way';
            ToolTip = 'Specifies whether the feature change is one-way.';
        }
        field(55; "Feature Description"; Text[250])
        {
            Caption = 'Feature Description';
            ToolTip = 'Specifies the description of the feature.';
        }
        field(60; "Description In English"; Text[250])
        {
            Caption = 'Description In English';
        }
        field(65; "Data Update Required"; Boolean)
        {
            Caption = 'Data Update Required';
            ToolTip = 'Specifies whether enabling the feature requires data update.';
        }
        field(70; "Last Modified"; DateTime)
        {
            Caption = 'Last Modified';
            ToolTip = 'Specifies when the feature was last retrieved.';
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