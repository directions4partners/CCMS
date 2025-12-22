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
                field("AppInsights Connection String"; Rec."AppInsights Connection String")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Application Insights connection string.';
                    ShowMandatory = true;
                    MaskType = Concealed;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description for this connection.';
                }
            }
            group(TelemetryDetails)
            {
                Caption = 'Telemetry Details';
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