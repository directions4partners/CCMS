namespace D4P.CCMS.Telemetry;

page 62048 "D4P AppInsights Conn Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "D4P AppInsights Connection";
    Caption = 'Application Insights Connection Setup Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Information';
                field("Connection String"; Rec."Connection String")
                {
                    ShowMandatory = true;
                    MaskType = Concealed;
                }
                field("Description"; Rec."Description")
                {
                }
            }
            group(TelemetryDetails)
            {
                Caption = 'Telemetry Details';
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
            action(TestConnection)
            {
                ApplicationArea = All;
                Caption = 'Test Connection';
                Image = TestDatabase;
                ToolTip = 'Test the Application Insights connection with the specified parameters.';

                trigger OnAction()
                var
                    ConnectionTestMsg: Label 'Connection test functionality will be implemented in future versions.';
                begin
                    Message(ConnectionTestMsg);
                end;
            }
        }
        area(Promoted)
        {
            group(ActionsGroup)
            {
                Caption = 'Actions';
                actionref(TestConnectionPromoted; TestConnection)
                {
                }
            }
        }
    }
}