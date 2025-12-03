namespace D4P.CCMS.Telemetry;

page 62047 "D4P AppInsights Conn List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "D4P AppInsights Connection";
    Caption = 'Application Insights Connection Setup';
    CardPageId = "D4P AppInsights Conn Card";
    Editable = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("AppInsights Connection String"; Rec."AppInsights Connection String")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Application Insights connection string.';
                    MaskType = Concealed;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description for this connection.';
                }
                field("Telemetry Application Id"; Rec."Telemetry Application Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Application ID for telemetry data access.';
                }
                field("Telemetry API Key"; Rec."Telemetry API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API key for telemetry data access.';
                    ExtendedDatatype = Masked;
                }
                field("Tenant Id"; Rec."Tenant Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Tenant ID for telemetry data access.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(New)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                RunObject = Page "D4P AppInsights Conn Card";
                RunPageMode = Create;
                ToolTip = 'Create a new Application Insights connection setup.';
            }
            action(Edit)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                Image = Edit;
                RunObject = Page "D4P AppInsights Conn Card";
                RunPageLink = "AppInsights Connection String" = field("AppInsights Connection String");
                ToolTip = 'Edit the selected Application Insights connection setup.';
            }
        }
        area(Promoted)
        {
            group(Management)
            {
                Caption = 'Management';
                actionref(NewPromoted; New)
                {
                }
                actionref(EditPromoted; Edit)
                {
                }
            }
        }
    }
}