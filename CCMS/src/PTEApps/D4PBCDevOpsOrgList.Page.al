namespace D4P.CCMS.PTEApps;

page 62030 "D4P BC DevOps Org. List"
{
    ApplicationArea = All;
    Caption = 'D365BC DevOps Organization List';
    PageType = List;
    SourceTable = "D4P BC DevOps Organization";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                }
                field(Name; Rec.Name)
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportToken)
            {
                Caption = 'Import Token';
                ApplicationArea = All;
                Image = CodesList;
                trigger OnAction()
                var
                    InputToken: Page "D4P BC Input Token";
                begin
                    if InputToken.RunModal() = Action::OK then
                        IsolatedStorage.Set(Rec.ID, InputToken.GetToken());
                end;
            }
        }
    }
}