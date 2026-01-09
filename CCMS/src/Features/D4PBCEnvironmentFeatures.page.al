namespace D4P.CCMS.Features;

page 62013 "D4P BC Environment Features"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "D4P BC Environment Feature";
    Caption = 'D365BC Environment Features';
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Feature Name"; Rec."Feature Name")
                {
                }
                field("Feature Key"; Rec."Feature Key")
                {
                }
                field("Is Enabled"; Rec."Is Enabled")
                {
                    StyleExpr = EnabledStatusStyle;

                }
                field("Feature Description"; Rec."Feature Description")
                {
                }
                field("Mandatory By"; Rec."Mandatory By")
                {
                }
                field("Mandatory By Version"; Rec."Mandatory By Version")
                {
                }
                field("Can Try"; Rec."Can Try")
                {
                }
                field("Is One Way"; Rec."Is One Way")
                {
                }
                field("Data Update Required"; Rec."Data Update Required")
                {
                }
                field("Learn More Link"; Rec."Learn More Link")
                {
                    ExtendedDatatype = URL;
                }
                field("Last Modified"; Rec."Last Modified")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetFeatures)
            {
                Caption = 'Get Features';
                Image = GetEntries;
                ToolTip = 'Retrieve the list of available features for this environment.';

                trigger OnAction()
                var
                    FeaturesHelper: Codeunit "D4P BC Features Helper";
                    SuccessMsg: Label 'Features retrieved successfully.';
                begin
                    FeaturesHelper.GetFeatures(Rec);
                    Message(SuccessMsg);
                    CurrPage.Update(false);
                end;
            }
            action(ActivateFeature)
            {
                Caption = 'Activate Feature';
                Image = Action;
                ToolTip = 'Activate the selected feature.';

                trigger OnAction()
                var
                    FeaturesHelper: Codeunit "D4P BC Features Helper";
                    UpdateInBackground: Boolean;
                    StartDateTime: DateTime;
                    ConfirmMsg: Label 'Do you want to activate feature "%1"?';
                begin
                    if not Confirm(ConfirmMsg, false, Rec."Feature Name") then
                        exit;

                    UpdateInBackground := true;
                    StartDateTime := CurrentDateTime();

                    FeaturesHelper.ActivateFeature(Rec, UpdateInBackground, StartDateTime);
                    CurrPage.Update(false);
                end;
            }
            action(DeactivateFeature)
            {
                Caption = 'Deactivate Feature';
                Image = Cancel;
                ToolTip = 'Deactivate the selected feature.';

                trigger OnAction()
                var
                    FeaturesHelper: Codeunit "D4P BC Features Helper";
                    ConfirmMsg: Label 'Do you want to deactivate feature "%1"?';
                begin
                    if not Confirm(ConfirmMsg, false, Rec."Feature Name") then
                        exit;

                    FeaturesHelper.DeactivateFeature(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(DeleteAll)
            {
                Caption = 'Delete All';
                Image = Delete;
                ToolTip = 'Delete all fetched feature records.';
                trigger OnAction()
                var
                    Feature: Record "D4P BC Environment Feature";
                    RecordCount: Integer;
                    DeletedSuccessMsg: Label '%1 feature records deleted.';
                    DeleteMsg: Label 'Are you sure you want to delete all %1 fetched feature records?';
                begin
                    Feature.CopyFilters(Rec);
                    RecordCount := Feature.Count();
                    if RecordCount = 0 then
                        exit;

                    if Confirm(DeleteMsg, false, RecordCount) then begin
                        Feature.DeleteAll();
                        CurrPage.Update(false);
                        Message(DeletedSuccessMsg, RecordCount);
                    end;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Features)
            {
                Caption = 'Features';
                actionref(GetFeaturesPromoted; GetFeatures)
                {
                }
                actionref(ActivateFeaturePromoted; ActivateFeature)
                {
                }
                actionref(DeactivateFeaturePromoted; DeactivateFeature)
                {
                }
                actionref(DeleteAllPromoted; DeleteAll)
                {
                }
            }
        }
    }

    var
        EnabledStatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;

    local procedure SetStatusStyle()
    begin
        if Rec."Is Enabled" = 'All Users' then
            EnabledStatusStyle := Format(PageStyle::Favorable)
        else
            EnabledStatusStyle := Format(PageStyle::Standard);
    end;
}
