namespace D4P.CCMS.General;

using D4P.CCMS.Capacity;
using D4P.CCMS.Customer;
using D4P.CCMS.Environment;
using D4P.CCMS.Extension;
using D4P.CCMS.Tenant;

page 62034 "D4P BC Admin Center Cues"
{
    ApplicationArea = All;
    Caption = 'BC Admin Center';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "D4P BC Admin Center Cue";

    layout
    {
        area(Content)
        {
            cuegroup(Overview)
            {
                Caption = 'Overview';

                field("Customers Count"; Rec."Customers Count")
                {
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"D4P BC Customers List");
                    end;
                }
            }
            cuegroup(Tenants)
            {
                Caption = 'Tenants';

                field("Tenants Count"; Rec."Tenants Count")
                {
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"D4P BC Tenant List");
                    end;
                }

                field("Tenants >90% Capacity"; Rec."Tenants >90% Capacity")
                {
                    trigger OnDrillDown()
                    var
                        BCCapacityHeader: Record "D4P BC Capacity Header";
                    begin
                        BCCapacityHeader.SetFilter("Usage %", '>%1', 90);
                        Page.Run(Page::"D4P BC Capacity List", BCCapacityHeader);
                    end;
                }
            }
            cuegroup(Environments)
            {
                Caption = 'Environments';
                field("Active Environments"; Rec."Active Environments")
                {
                    trigger OnDrillDown()
                    var
                        BCEnvironment: Record "D4P BC Environment";
                    begin
                        BCEnvironment.SetRange(State, 'Active');
                        Page.Run(Page::"D4P BC Environment List", BCEnvironment);
                    end;
                }

                field("Active Production Environ."; Rec."Active Production Environ.")
                {
                    trigger OnDrillDown()
                    var
                        BCEnvironment: Record "D4P BC Environment";
                    begin
                        BCEnvironment.SetRange(State, 'Active');
                        BCEnvironment.SetRange(Type, 'Production');
                        Page.Run(Page::"D4P BC Environment List", BCEnvironment);
                    end;
                }
                field("Act. Prod Env. No Telemetry"; Rec."Act. Prod Env. No Telemetry")
                {
                    trigger OnDrillDown()
                    var
                        BCEnvironment: Record "D4P BC Environment";
                    begin
                        BCEnvironment.SetRange(State, 'Active');
                        BCEnvironment.SetRange(Type, 'Production');
                        BCEnvironment.SetFilter("Application Insights String", '%1', '');
                        Page.Run(Page::"D4P BC Environment List", BCEnvironment);
                    end;
                }

                field("Active Sandbox Environ."; Rec."Active Sandbox Environ.")
                {
                    trigger OnDrillDown()
                    var
                        BCEnvironment: Record "D4P BC Environment";
                    begin
                        BCEnvironment.SetRange(State, 'Active');
                        BCEnvironment.SetRange(Type, 'Sandbox');
                        Page.Run(Page::"D4P BC Environment List", BCEnvironment);
                    end;
                }
                field("Act. Sandbox Env. No Telemetry"; Rec."Act. Sandbox Env. No Telemetry")
                {
                    trigger OnDrillDown()
                    var
                        BCEnvironment: Record "D4P BC Environment";
                    begin
                        BCEnvironment.SetRange(State, 'Active');
                        BCEnvironment.SetRange(Type, 'Sandbox');
                        BCEnvironment.SetFilter("Application Insights String", '%1', '');
                        Page.Run(Page::"D4P BC Environment List", BCEnvironment);
                    end;
                }

                field("Updates (7 Days)"; Updates7Days)
                {
                    Caption = 'Updates (7 Days)';
                    ToolTip = 'Environments scheduled to update within the next 7 days';

                    trigger OnDrillDown()
                    var
                        BCEnvironment: Record "D4P BC Environment";
                    begin
                        FilterForUpdatesInDays(BCEnvironment, 7);
                        Page.Run(Page::"D4P BC Environment List", BCEnvironment);
                    end;
                }

                field("Updates (14 Days)"; Updates14Days)
                {
                    Caption = 'Updates (14 Days)';
                    ToolTip = 'Environments scheduled to update within the next 14 days';

                    trigger OnDrillDown()
                    var
                        BCEnvironment: Record "D4P BC Environment";
                    begin
                        FilterForUpdatesInDays(BCEnvironment, 14);
                        Page.Run(Page::"D4P BC Environment List", BCEnvironment);
                    end;
                }
            }
            cuegroup("Apps & Capacity")
            {
                Caption = 'Applications';

                field("Apps with Available Update"; Rec."Apps with Available Update")
                {
                    trigger OnDrillDown()
                    var
                        BCInstalledApp: Record "D4P BC Installed App";
                    begin
                        BCInstalledApp.SetFilter("Available Update Version", '<>%1', '');
                        Page.Run(Page::"D4P BC Installed Apps List", BCInstalledApp);
                    end;
                }
                field("Apps w. Av. upd. No Microsoft"; Rec."Apps w. Av. upd. No Microsoft")
                {
                    trigger OnDrillDown()
                    var
                        BCInstalledApp: Record "D4P BC Installed App";
                    begin
                        BCInstalledApp.SetFilter("Available Update Version", '<>%1', '');
                        BCInstalledApp.SetFilter("App Publisher", '<>%1', 'Microsoft');
                        Page.Run(Page::"D4P BC Installed Apps List", BCInstalledApp);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("Tenants >90% Capacity", "Act. Prod Env. No Telemetry", "Act. Sandbox Env. No Telemetry", "Apps with Available Update",
        "Tenants Count", "Customers Count", "Active Environments", "Active Production Environ.", "Active Sandbox Environ.");
        Updates7Days := Rec.GetNumberOfEnvironmentsForUpdates(7);
        Updates14Days := Rec.GetNumberOfEnvironmentsForUpdates(14);
    end;

    local procedure FilterForUpdatesInDays(var BCEnvironment: Record "D4P BC Environment"; NoOfDays: Integer)
    var
        EndDate: DateTime;
    begin
        EndDate := CreateDateTime(CalcDate(StrSubstNo('<%1D>', NoOfDays), Today()), 235959T);
        BCEnvironment.SetRange(Available, true);
        BCEnvironment.SetFilter("Selected DateTime", '%1..%2', CreateDateTime(Today, 0T), EndDate);
    end;

    var
        Updates7Days, Updates14Days : Integer;
}
