namespace D4P.CCMS.General;

using D4P.CCMS.Customer;
using D4P.CCMS.Tenant;
using System.Visualization;

page 62029 "D4P BC Admin Headline"
{
    PageType = HeadlinePart;
    RefreshOnActivate = true;
    Caption = 'Headline';

    layout
    {
        area(Content)
        {
            group(Control1)
            {
                ShowCaption = false;
                Visible = UserGreetingVisible;
                field(GreetingText; RCHeadlinesPageCommon.GetGreetingText())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Greeting headline';
                    Editable = false;
                }
            }
            group(Control2)
            {
                ShowCaption = false;
                Visible = DefaultFieldsVisible;
                field(DocumentationText; GetDocumentationText())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Documentation headline';
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        HyperLink(GetDocumentationUrlTxt());
                    end;
                }
            }
            group(Statistics)
            {
                ShowCaption = false;
                Visible = true;

                field(CustomersText; GetCustomersText())
                {
                    ApplicationArea = All;
                    Caption = 'Customers';
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"D4P BC Customers List");
                    end;
                }

                field(TenantsText; GetTenantsText())
                {
                    ApplicationArea = All;
                    Caption = 'Tenants';
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"D4P BC Tenant List");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        RCHeadlinesPageCommon.HeadlineOnOpenPage(Page::"D4P BC Admin Headline");
        DefaultFieldsVisible := RCHeadlinesPageCommon.AreDefaultFieldsVisible();
        UserGreetingVisible := RCHeadlinesPageCommon.IsUserGreetingVisible();
    end;

    var
        RCHeadlinesPageCommon: Codeunit "RC Headlines Page Common";

        DefaultFieldsVisible: Boolean;
        UserGreetingVisible: Boolean;

    local procedure GetCustomersText(): Text
    var
        Customer: Record "D4P BC Customer";
        CountTxt: Label 'You have %1 customers.', Comment = '%1 = number of customers';
    begin
        exit(StrSubstNo(CountTxt, Customer.Count()));
    end;

    local procedure GetTenantsText(): Text
    var
        Tenant: Record "D4P BC Tenant";
        CountTxt: Label 'Managing %1 tenants.', Comment = '%1 = number of tenants';
    begin
        exit(StrSubstNo(CountTxt, Tenant.Count()));
    end;

    local procedure GetDocumentationText(): Text
    var
        DocumentationTxt: Label 'Want to learn more about CCMS?';
    begin
        exit(DocumentationTxt);
    end;

    local procedure GetDocumentationUrlTxt(): Text
    var
        DocumentationUrlTxt: Label 'https://directions4partners.github.io/CCMS/', Locked = true;
    begin
        exit(DocumentationUrlTxt);
    end;
}

