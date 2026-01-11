namespace D4P.CCMS.Telemetry;

using System.Utilities;

page 62041 "D4P KQL Query Preview"
{
    PageType = CardPart;
    SourceTable = "D4P KQL Query Store";
    Caption = 'Query Preview';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;

                field(QueryAsText; GetQueryText())
                {
                    MultiLine = true;
                    Caption = 'Query';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UploadQuery)
            {
                Caption = 'Upload Query';
                Image = Import;
                ToolTip = 'Upload a KQL query from a text file';

                trigger OnAction()
                begin
                    UploadQueryFromFile();
                end;
            }
            action(DownloadQuery)
            {
                Caption = 'Download Query';
                Image = Export;
                ToolTip = 'Download the KQL query to a text file';

                trigger OnAction()
                begin
                    DownloadQueryToFile();
                end;
            }
        }
    }

    local procedure UploadQueryFromFile()
    var
        InStr: InStream;
        FileIsEmptyMsg: Label 'The selected file is empty.';
        QueryUploadedMsg: Label 'Query uploaded successfully from file: %1';
        OutStr: OutStream;
        FileName: Text;
        Line: Text;
        QueryText: Text;
    begin
        if Rec.Code = '' then begin
            Message('Please select a query record first.');
            exit;
        end;

        if not UploadIntoStream('Select KQL Query File', '', 'Text Files (*.txt)|*.txt|KQL Files (*.kql)|*.kql', FileName, InStr) then
            exit;

        // Read entire file content
        while not InStr.EOS() do begin
            InStr.ReadText(Line);
            if QueryText = '' then
                QueryText := Line
            else
                QueryText += '\n' + Line;
        end;

        if QueryText = '' then begin
            Message(FileIsEmptyMsg);
            exit;
        end;

        Rec.Query.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(QueryText);
        Rec.Modify(true);

        Message(QueryUploadedMsg, FileName);
        CurrPage.Update(false);
    end;

    local procedure DownloadQueryToFile()
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        NoQueryContentMsg: Label 'No query content to download.';
        PleaseSelectRecordMsg: Label 'Please select a query record first.';
        OutStr: OutStream;
        FileName: Text;
        QueryText: Text;
    begin
        if Rec.Code = '' then begin
            Message(PleaseSelectRecordMsg);
            exit;
        end;

        if not Rec.Query.HasValue() then begin
            Message(NoQueryContentMsg);
            exit;
        end;

        QueryText := GetQueryText();
        FileName := Rec.Code + '_Query.txt';

        TempBlob.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(QueryText);
        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);

        DownloadFromStream(InStr, 'Download KQL Query', '', 'Text Files (*.txt)|*.txt', FileName);
    end;

    local procedure GetQueryText(): Text
    var
        InStr: InStream;
        Line: Text;
        Txt: Text;
    begin
        if Rec.Query.HasValue() then begin
            Rec.CalcFields(Query);
            Rec.Query.CreateInStream(InStr, TEXTENCODING::UTF8);
            while not InStr.EOS() do begin
                InStr.ReadText(Line);
                if Txt = '' then
                    Txt := Line
                else
                    Txt += '\n' + Line;
            end;
            exit(Txt);
        end;
        exit('');
    end;
}
