namespace D4P.CCMS.Extension;

/// <summary>
/// Update status of an installed app, mirroring the "Update" column on the Manage Apps page of the Business Central admin center.
/// </summary>
enum 62012 "D4P App Update Status"
{
    Extensible = true;

    value(0; "N/A")
    {
        Caption = 'N/A';
    }
    value(1; "Update Available")
    {
        Caption = 'Update Available';
    }
    value(2; "Action Required")
    {
        Caption = 'Action Required';
    }
    value(3; "Update Scheduled")
    {
        Caption = 'Update is Scheduled';
    }
    value(4; Updating)
    {
        Caption = 'Updating';
    }
    value(5; "Update Failed")
    {
        Caption = 'Update Failed';
    }
}
