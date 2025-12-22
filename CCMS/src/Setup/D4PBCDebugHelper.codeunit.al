namespace D4P.CCMS.Setup;

using D4P.CCMS.Environment;

codeunit 62001 "D4P BC Debug Helper"
{
    procedure TestDebugMode()
    var
        BCSetup: Record "D4P BC Setup";
        EnvironmentMgt: Codeunit "D4P BC Environment Mgt";
        TestResponse: Text;
        TestMsg: Label 'Debug Mode is %1. Setup record exists: %2';
        DebugModeDisabledMsg: Label 'Debug Mode is currently disabled. Enable it in Setup to see debug messages.';
    begin
        BCSetup := BCSetup.GetSetup();
        TestResponse := '{"test": "This is a test API response", "status": "success"}';

        Message(TestMsg, BCSetup."Debug Mode", true);

        if BCSetup."Debug Mode" then
            EnvironmentMgt.ShowDebugMessagePublic(TestResponse, 'TestDebugMode')
        else
            Message(DebugModeDisabledMsg);
    end;
}