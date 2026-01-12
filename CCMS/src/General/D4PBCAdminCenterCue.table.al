namespace D4P.CCMS.General;

using D4P.CCMS.Customer;
using D4P.CCMS.Tenant;
using D4P.CCMS.Environment;
using D4P.CCMS.Extension;
using D4P.CCMS.Capacity;

table 62047 "D4P BC Admin Center Cue"
{
    Caption = 'BC Admin Center Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            ToolTip = 'Primary key for the cue record.';
        }
        field(2; "Customers Count"; Integer)
        {
            CalcFormula = count("D4P BC Customer");
            Caption = 'Customers';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of D365 BC customers';
        }
        field(3; "Tenants Count"; Integer)
        {
            CalcFormula = count("D4P BC Tenant");
            Caption = 'Tenants';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of Entra ID tenants';
        }
        field(4; "Active Environments"; Integer)
        {
            CalcFormula = count("D4P BC Environment" where(State = const('Active')));
            Caption = 'Active';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of active D365 BC environments';
        }
        field(5; "Active Production Environ."; Integer)
        {
            CalcFormula = count("D4P BC Environment" where(State = const('Active'),
                                                              Type = const('Production')));
            Caption = 'Active Production';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of active production environments';
        }
        field(6; "Active Sandbox Environ."; Integer)
        {
            CalcFormula = count("D4P BC Environment" where(State = const('Active'),
                                                              Type = const('Sandbox')));
            Caption = 'Active Sandbox';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of active sandbox environments';
        }
        field(7; "Apps with Available Update"; Integer)
        {
            CalcFormula = count("D4P BC Installed App" where("Available Update Version" = filter(<> '')));
            Caption = 'Available Updates';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of apps with available updates';
        }
        field(8; "Tenants >90% Capacity"; Integer)
        {
            CalcFormula = count("D4P BC Capacity Header" where("Usage %" = filter(> 90)));
            Caption = 'Tenants >90% Capacity';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of tenants with storage usage over 90%';
        }
        field(9; "Act. Prod Env. No Telemetry"; Integer)
        {
            CalcFormula = count("D4P BC Environment" where(State = const('Active'),
                                                              Type = const('Production'),
                                                              "Application Insights String" = filter('')));
            Caption = 'Act. Production without Telemetry';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of active production environments without telemetry enabled';
        }
        field(10; "Act. Sandbox Env. No Telemetry"; Integer)
        {
            CalcFormula = count("D4P BC Environment" where(State = const('Active'),
                                                              Type = const('Sandbox'),
                                                              "Application Insights String" = filter('')));
            Caption = 'Act. Sandbox without Telemetry';
            FieldClass = FlowField;
            ToolTip = 'Number of active sandbox environments without telemetry enabled';
        }
        field(11; "Apps w. Av. upd. No Microsoft"; Integer)
        {
            CalcFormula = count("D4P BC Installed App" where("Available Update Version" = filter(<> ''),
                                                              "App Publisher" = filter(<> 'Microsoft')));
            Caption = 'Available Updates (non-Microsoft)';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of apps with available updates';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetNumberOfEnvironmentsForUpdates(NoOfDays: Integer): Integer
    var
        BCEnvironment: Record "D4P BC Environment";
        EndDate: DateTime;
    begin
        EndDate := CreateDateTime(CalcDate(StrSubstNo('<%1D>', NoOfDays), Today()), 235959T);
        BCEnvironment.SetRange(Available, true);
        BCEnvironment.SetFilter("Selected DateTime", '%1..%2', CreateDateTime(Today, 0T), EndDate);
        exit(BCEnvironment.Count());
    end;
}
