namespace D4P.CCMS.Telemetry;

page 62047 "D4P AppInsights Conn List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "D4P AppInsights Connection";
    Caption = 'D365BC Application Insights';
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
                field("Connection String"; Rec."Connection String")
                {
                    MaskType = Concealed;
                }
                field("Description"; Rec."Description")
                {
                }
                field("Telemetry Application Id"; Rec."Telemetry Application Id")
                {
                }
                field("Telemetry API Key"; Rec."Telemetry API Key")
                {
                    ExtendedDatatype = Masked;
                }
                field("Tenant Id"; Rec."Tenant Id")
                {
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
                RunObject = page "D4P AppInsights Conn Card";
                RunPageMode = Create;
                ToolTip = 'Create a new Application Insights connection setup.';
            }
            action(Edit)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                Image = Edit;
                RunObject = page "D4P AppInsights Conn Card";
                RunPageLink = "Connection String" = field("Connection String");
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