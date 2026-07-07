namespace D4P.CCMS.Connector.RestClientOAuth;
table 62010 "D4P Entra Secret"
{
    Caption = 'Secret';
    DataPerCompany = false;
    ReplicateData = false;
    Access = Internal;

    fields
    {
        field(1; "Application Code"; Code[20])
        {
            Caption = 'Application Code';
            DataClassification = SystemMetadata;
        }
        field(2; Id; Text[36])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Guid: Guid;
            begin
                if Rec.Id = '' then
                    exit;
                Evaluate(Guid, Rec.Id);
                Rec.Id := Format(Guid, 0, 4).ToLower();
            end;
        }
        field(3; "Isolated Storage Id"; Guid)
        {
            Access = Local;
            DataClassification = SystemMetadata;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Start Date/Time"; DateTime)
        {
            Caption = 'Start Date/Time';
            DataClassification = CustomerContent;
        }
        field(12; "End Date/Time"; DateTime)
        {
            Caption = 'End Date/Time';
            DataClassification = CustomerContent;
        }
        field(13; Hint; Text[3])
        {
            Caption = 'Hint';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Application Code", Id) { Clustered = true; }
    }

    trigger OnDelete()
    begin
        RemoveSecretText();
    end;

    procedure GetSecretText() ReturnValue: SecretText
    begin
        if IsolatedStorage.Contains("Isolated Storage Id", DataScope::Module) then
            IsolatedStorage.Get("Isolated Storage Id", DataScope::Module, ReturnValue);
    end;

    procedure SetSecretText(SecretText: SecretText)
    begin
        RemoveSecretText();

        Rec."Isolated Storage Id" := CreateGuid();
        Rec.Modify();

        if EncryptionEnabled() then
            IsolatedStorage.SetEncrypted("Isolated Storage Id", SecretText, DataScope::Module)
        else
            IsolatedStorage.Set("Isolated Storage Id", SecretText, DataScope::Module);
    end;

    procedure RemoveSecretText()
    begin
        if IsolatedStorage.Contains("Isolated Storage Id", DataScope::Module) then
            IsolatedStorage.Delete("Isolated Storage Id", DataScope::Module);
    end;
}