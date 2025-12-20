namespace D4P.CCMS.Features;

page 62013 "D4P BC Environment Features"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "D4P BC Environment Features";
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the feature.';
                }
                field("Feature Key"; Rec."Feature Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique key of the feature.';
                }
                field("Is Enabled"; Rec."Is Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the enabled status (All Users, None, etc.).';
                    StyleExpr = EnabledStatusStyle;

                    trigger OnDrillDown()
                    begin
                    end;
                }
                field("Feature Description"; Rec."Feature Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the feature.';
                }
                field("Mandatory By"; Rec."Mandatory By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the feature becomes mandatory.';
                }
                field("Mandatory By Version"; Rec."Mandatory By Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the BC version when the feature becomes mandatory.';
                }
                field("Can Try"; Rec."Can Try")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the feature can be tried.';
                }
                field("Is One Way"; Rec."Is One Way")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the feature change is one-way.';
                }
                field("Data Update Required"; Rec."Data Update Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether enabling the feature requires data update.';
                }
                field("Learn More Link"; Rec."Learn More Link")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the link to learn more about the feature.';
                    ExtendedDatatype = URL;
                }
                field("Last Modified"; Rec."Last Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the feature was last retrieved.';
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
                ApplicationArea = All;
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
                ApplicationArea = All;
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
                ApplicationArea = All;
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
                ApplicationArea = All;
                Caption = 'Delete All';
                Image = Delete;
                ToolTip = 'Delete all fetched feature records.';
                trigger OnAction()
                var
                    Feature: Record "D4P BC Environment Features";
                    DeleteMsg: Label 'Are you sure you want to delete all %1 fetched feature records?';
                    DeletedSuccessMsg: Label '%1 feature records deleted.';
                    RecordCount: Integer;
                begin
                    Feature.CopyFilters(Rec);
                    RecordCount := Feature.Count;
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
            EnabledStatusStyle := 'Favorable'
        else
            EnabledStatusStyle := 'Standard';
    end;
}
