namespace D4P.CCMS.Customer;

using D4P.CCMS.Environment;
using D4P.CCMS.Setup;
using D4P.CCMS.Tenant;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.NoSeries;
using System.EMail;

table 62000 "D4P BC Customer"
{
    Caption = 'D365BC Customer';
    DataCaptionFields = "No.", Name;
    DataClassification = CustomerContent;
    DrillDownPageId = "D4P BC Customers List";
    LookupPageId = "D4P BC Customers List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestNoSeries();
            end;
        }
        field(2; "Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(4; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(5; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;

            trigger OnLookup()
            begin
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
            end;
        }
        field(6; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Country/Region Code" = const('')) "Post Code"
            else
            if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;

            trigger OnLookup()
            begin
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
            end;
        }
        field(7; County; Text[30])
        {
            Caption = 'County';
            CaptionClass = '5,1,' + "Country/Region Code";
            DataClassification = CustomerContent;
        }
        field(8; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                PostCode.CheckClearPostCodeCityCounty(City, "Post Code", County, "Country/Region Code", xRec."Country/Region Code");
            end;
        }
        field(9; "Contact Person Name"; Text[100])
        {
            Caption = 'Contact Person Name';
            DataClassification = CustomerContent;
        }
        field(10; "Contact Person Email"; Text[80])
        {
            Caption = 'Contact Person Email';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
            trigger OnValidate()
            begin
                ValidateContactEmail();
            end;
        }
        field(11; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(20; Tenants; Integer)
        {
            CalcFormula = count("D4P BC Tenant" where("Customer No." = field("No.")));
            Caption = 'Tenants';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of tenants for this customer';
        }
        field(21; "All Active Environments"; Integer)
        {
            CalcFormula = count("D4P BC Environment" where("Customer No." = field("No."),
                                                              State = const('Active')));
            Caption = 'All Active Environments';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of active environments for this customer';
        }
        field(22; "Active Prod. Environments"; Integer)
        {
            CalcFormula = count("D4P BC Environment" where("Customer No." = field("No."),
                                                              State = const('Active'),
                                                              Type = const('Production')));
            Caption = 'Active Production Environments';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of active production environments for this customer';
        }
        field(23; "Active Sand. Environments"; Integer)
        {
            CalcFormula = count("D4P BC Environment" where("Customer No." = field("No."),
                                                              State = const('Active'),
                                                              Type = const('Sandbox')));
            Caption = 'Active Sandbox Environments';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of active sandbox environments for this customer';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "No." = '' then begin
            CCMSSetup.Get();
            CCMSSetup.TestField("Customer Nos.");
            "No. Series" := CCMSSetup."Customer Nos.";
            if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeries.GetNextNo("No. Series");
        end;
    end;

    var
        CCMSSetup: Record "D4P BC Setup";
        PostCode: Record "Post Code";
        NoSeries: Codeunit "No. Series";

    procedure AssistEdit(OldCustomer: Record "D4P BC Customer"): Boolean
    var
        D4PBCCustomer: Record "D4P BC Customer";
    begin
        D4PBCCustomer := Rec;
        CCMSSetup.Get();
        CCMSSetup.TestField("Customer Nos.");
        if NoSeries.LookupRelatedNoSeries(CCMSSetup."Customer Nos.", OldCustomer."No. Series", D4PBCCustomer."No. Series") then begin
            "No." := NoSeries.GetNextNo(D4PBCCustomer."No. Series");
            Rec := D4PBCCustomer;
            exit(true);
        end;
    end;

    local procedure TestNoSeries()
    var
        D4PBCCustomer: Record "D4P BC Customer";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestNoSeries(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if "No." <> xRec."No." then
            if not D4PBCCustomer.Get(Rec."No.") then begin
                CCMSSetup.Get();
                NoSeries.TestManual(CCMSSetup."Customer Nos.");
                "No. Series" := '';
            end;
    end;

    local procedure ValidateContactEmail()
    var
        MailManagement: Codeunit "Mail Management";
    begin
        if "Contact Person Email" = '' then
            exit;
        MailManagement.CheckValidEmailAddresses("Contact Person Email");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoSeries(var D4PBCCustomer: Record "D4P BC Customer"; xD4PBCCustomer: Record "D4P BC Customer"; var IsHandled: Boolean)
    begin
    end;
}