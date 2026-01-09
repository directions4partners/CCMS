namespace D4P.CCMS.Operations;

using D4P.CCMS.Environment;

page 62028 "D4P BC Environment Operations"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "D4P BC Environment Operation";
    Caption = 'D365BC Environment Operations';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Customer No."; Rec."Customer No.")
                {
                }
                field("Environment Name"; Rec."Environment Name")
                {
                }
                field("Environment Type"; Rec."Environment Type")
                {
                }
                field("Operation Type"; Rec."Operation Type")
                {
                }
                field(Status; Rec.Status)
                {
                    StyleExpr = StatusStyle;
                }
                field("Created On"; Rec."Created On")
                {
                }
                field("Started On"; Rec."Started On")
                {
                }
                field("Completed On"; Rec."Completed On")
                {
                }
                field("Created By"; Rec."Created By")
                {
                }
                field("Error Message"; Rec."Error Message")
                {
                }
                field("Operation ID"; Rec."Operation ID")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetOperations)
            {
                ApplicationArea = All;
                Caption = 'Get Operations';
                Image = Refresh;
                ToolTip = 'Get the list of operations for this environment.';

                trigger OnAction()
                var
                    OperationsHelper: Codeunit "D4P BC Operations Helper";
                    EnvironmentContextMissingMsg: Label 'No environment context set.';
                begin
                    if CurrentEnvironment.Name <> '' then
                        OperationsHelper.GetEnvironmentOperations(CurrentEnvironment."Customer No.", CurrentEnvironment."Tenant ID", CurrentEnvironment.Name)
                    else
                        Message(EnvironmentContextMissingMsg);
                    CurrPage.Update(false);
                end;
            }
            action(ViewParameters)
            {
                ApplicationArea = All;
                Caption = 'View Parameters';
                Image = ViewDetails;
                ToolTip = 'View the operation parameters.';

                trigger OnAction()
                var
                    InStream: InStream;
                    ParametersText: Text;
                    FormattedText: Text;
                    NoParametersMsg: Label 'No parameters available.';
                begin
                    if Rec.Parameters.HasValue then begin
                        Rec.CalcFields(Parameters);
                        Rec.Parameters.CreateInStream(InStream, TextEncoding::UTF8);
                        InStream.ReadText(ParametersText);
                        FormattedText := FormatJsonParameters(ParametersText);
                        Message(FormattedText);
                    end else
                        Message(NoParametersMsg);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(GetOperations_Promoted; GetOperations)
                {
                }
                actionref(ViewParameters_Promoted; ViewParameters)
                {
                }
            }
        }
    }

    var
        CurrentEnvironment: Record "D4P BC Environment";
        StatusStyle: Text;


    local procedure FormatJsonParameters(JsonText: Text): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
        Keys: List of [Text];
        KeyText: Text;
        Result: Text;
        ValueText: Text;
    begin
        if JsonText = '' then
            exit('');

        if not JObject.ReadFrom(JsonText) then
            exit(JsonText);

        Keys := JObject.Keys();

        foreach KeyText in Keys do
            if JObject.Get(KeyText, JToken) then begin
                JToken.WriteTo(ValueText);
                if Result <> '' then
                    Result += '\';
                Result += KeyText + ' : ' + ValueText;
            end;

        exit(Result);
    end;

    procedure SetEnvironmentContext(Environment: Record "D4P BC Environment")
    var
        TenantIdGuid: Guid;
    begin
        CurrentEnvironment := Environment;
        TenantIdGuid := Environment."Tenant ID";
        Rec.SetRange("Customer No.", Environment."Customer No.");
        Rec.SetRange("Tenant ID", Format(TenantIdGuid));
        Rec.SetRange("Environment Name", Environment.Name);
        CurrPage.Update(false);
    end;

    trigger OnAfterGetRecord()
    begin
        case LowerCase(Rec.Status) of
            'succeeded':
                StatusStyle := Format(PageStyle::Favorable);
            'failed':
                StatusStyle := Format(PageStyle::Unfavorable);
            'running':
                StatusStyle := Format(PageStyle::Ambiguous);
            else
                StatusStyle := Format(PageStyle::Standard);
        end;
    end;
}
