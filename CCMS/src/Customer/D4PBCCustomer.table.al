namespace D4P.CCMS.Customer;

table 62000 "D4P BC Customer"
{
    Caption = 'D365BC Customer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; "Name"; Text[100])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}