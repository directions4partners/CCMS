namespace D4P.CCMS.Telemetry;

using D4P.CCMS.Environment;

page 62040 "D4P KQL Queries"
{
    PageType = List;
    SourceTable = "D4P KQL Query Store";
    Caption = 'KQL Queries';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(EnvironmentInfo)
            {
                Caption = 'Environment Context';
                Visible = ShowEnvironmentContext;
                field(CurrentEnvironmentName; CurrentEnvironment.Name)
                {
                    Caption = 'Environment';
                    Editable = false;
                    ToolTip = 'Specifies the environment that will be used for telemetry queries.';
                }
                field(CurrentEnvironmentTelemetryDescription; CurrentEnvironment."Telemetry Description")
                {
                    Caption = 'Telemetry Connection';
                    Editable = false;
                    ToolTip = 'Specifies the telemetry connection description for the current environment.';
                }
                field(TelemetryStatus; TelemetryStatusText)
                {
                    Caption = 'Status';
                    Editable = false;
                    StyleExpr = TelemetryStatusStyle;
                    ToolTip = 'Specifies whether telemetry is properly configured for this environment.';
                }
            }
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                }
                field(Name; Rec.Name)
                {
                }
                field(Description; Rec.Description)
                {
                    Width = 40;
                }
                field(ResultTableID; Rec."Result Table ID")
                {
                    ToolTip = 'Table ID where results will be stored. Leave blank for generic processing.';
                }
            }
        }

        area(FactBoxes)
        {
            part(Preview; "D4P KQL Query Preview")
            {
                SubPageLink = Code = field(Code);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunQuery)
            {
                Caption = 'Run Query';
                ApplicationArea = All;
                Image = Start;
                trigger OnAction()
                var
                    AIConnectionSetup: Record "D4P AppInsights Connection";
                    LoadData: Report "D4P Load Data";
                    NoConnectionStringErr: Label 'The environment "%1" does not have an Application Insights connection string configured. Please configure telemetry first.';
                    NoEnvironmentContextErr: Label 'No environment context is set. Please open KQL Queries from the Environment Card to use the environment context directly.';
                    SetupNotFoundErr: Label 'Application Insights connection setup not found for environment "%1". Please verify telemetry configuration.';
                begin
                    // Check if we have environment context set
                    if not ShowEnvironmentContext then
                        Error(NoEnvironmentContextErr);

                    // Verify environment has telemetry configuration
                    if CurrentEnvironment."Application Insights String" = '' then
                        Error(NoConnectionStringErr, CurrentEnvironment.Name);

                    if not AIConnectionSetup.Get(CurrentEnvironment."Application Insights String") then
                        Error(SetupNotFoundErr, CurrentEnvironment.Name);

                    // Run the selected query directly with current environment's context
                    LoadData.InitRequestFromEnvironment(CurrentEnvironment, Rec.Code);
                    LoadData.Run();
                end;
            }
            action(InitializeQueries)
            {
                Caption = 'Initialize Default Queries';
                ApplicationArea = All;
                Image = Setup;
                trigger OnAction()
                var
                    Init: Codeunit "D4P KQL Query Store Init";
                    InitializedMsg: Label 'Default KQL queries have been initialized.';
                begin
                    Init.InitializeKQLQueries();
                    Message(InitializedMsg);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        CurrentEnvironment: Record "D4P BC Environment";
        ShowEnvironmentContext: Boolean;
        TelemetryStatusStyle: Text[20];
        TelemetryStatusText: Text[50];

    /// <summary>
    /// Sets the current environment context for telemetry queries
    /// </summary>
    /// <param name="Environment">The environment record to use for telemetry queries</param>
    procedure SetEnvironmentContext(Environment: Record "D4P BC Environment")
    begin
        // Store the environment record
        CurrentEnvironment := Environment;
        ShowEnvironmentContext := true;

        // Calculate telemetry flowfields for display
        if CurrentEnvironment."Application Insights String" <> '' then
            CurrentEnvironment.CalcFields("Telemetry API Key", "Telemetry Application ID", "Telemetry Tenant ID", "Telemetry Description");

        // Update page caption and status
        CurrPage.Caption := 'KQL Queries - ' + Environment.Name;
        UpdateTelemetryStatus();

        // Force page update to reflect changes
        CurrPage.Update(false);
    end;

    /// <summary>
    /// Clears the environment context (fallback to environment selection)
    /// </summary>
    procedure ClearEnvironmentContext()
    begin
        Clear(CurrentEnvironment);
        ShowEnvironmentContext := false;
        TelemetryStatusText := '';
        TelemetryStatusStyle := '';
        CurrPage.Caption := 'KQL Queries';
        CurrPage.Update();
    end;

    local procedure UpdateTelemetryStatus()
    var
        AIConnectionSetup: Record "D4P AppInsights Connection";
    begin
        if not ShowEnvironmentContext then begin
            TelemetryStatusText := '';
            TelemetryStatusStyle := '';
            exit;
        end;

        if CurrentEnvironment."Application Insights String" = '' then begin
            TelemetryStatusText := 'Not Configured';
            TelemetryStatusStyle := Format(PageStyle::Unfavorable);
        end else
            if AIConnectionSetup.Get(CurrentEnvironment."Application Insights String") then begin
                if (AIConnectionSetup."Telemetry Application Id" <> '') and
                   (AIConnectionSetup."Telemetry API Key" <> '') then begin
                    TelemetryStatusText := 'Ready';
                    TelemetryStatusStyle := Format(PageStyle::Favorable);
                end else begin
                    TelemetryStatusText := 'Incomplete Setup';
                    TelemetryStatusStyle := Format(PageStyle::Ambiguous);
                end;
            end else begin
                TelemetryStatusText := 'Setup Not Found';
                TelemetryStatusStyle := Format(PageStyle::Unfavorable);
            end;
    end;

    trigger OnOpenPage()
    begin
        // Initialize visibility - this will be updated by SetEnvironmentContext if called
        ShowEnvironmentContext := false;
    end;

    trigger OnAfterGetRecord()
    begin
        // Update telemetry status when records change, if environment context is set
        if ShowEnvironmentContext then
            UpdateTelemetryStatus();
    end;
}
