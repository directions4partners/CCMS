namespace D4P.CCMS.Environment;

using D4P.CCMS.Connector;
using D4P.CCMS.Tenant;
using System.Security.AccessControl;

codeunit 62050 "D4P BC Environment Access"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AdminAPIClient: Codeunit D4PBCAdminAPIClient;

    /// <summary>
    /// Raises an error unless the current user is a member of the security group assigned to the environment.
    /// The group is read from the Admin API on every call. Environments without a group are blocked.
    /// </summary>
    procedure CheckCanManage(BCTenant: Record "D4P BC Tenant"; EnvironmentName: Text)
    var
        GroupId: Text;
        GroupName: Text;
        GroupLookupFailedErr: Label 'Could not verify the security group of environment %1. The operation was blocked.', Comment = '%1 = Environment Name';
        NoGroupErr: Label 'Environment %1 has no security group assigned. Assign a group to the environment in the Business Central admin center to manage it from CCMS.', Comment = '%1 = Environment Name';
        NotMemberErr: Label 'You are not a member of the security group %2 assigned to environment %1, so you cannot manage it.', Comment = '%1 = Environment Name, %2 = Security Group Name';
    begin
        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.GetSecurityGroup(EnvironmentName, GroupId, GroupName) then begin
            LogDenied(EnvironmentName, 'LookupFailed');
            Error(GroupLookupFailedErr, EnvironmentName);
        end;

        if GroupId = '' then begin
            LogDenied(EnvironmentName, 'NoGroup');
            Error(NoGroupErr, EnvironmentName);
        end;

        if not IsCurrentUserMember(GroupId) then begin
            LogDenied(EnvironmentName, 'NotMember');
            if GroupName = '' then
                GroupName := GroupId;
            Error(NotMemberErr, EnvironmentName, GroupName);
        end;
    end;

    procedure CheckCanManage(BCEnvironment: Record "D4P BC Environment")
    var
        BCTenant: Record "D4P BC Tenant";
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");
        CheckCanManage(BCTenant, BCEnvironment.Name);
    end;

    local procedure IsCurrentUserMember(GroupId: Text): Boolean
    var
        TempMemberBuffer: Record "Security Group Member Buffer" temporary;
        SecurityGroup: Codeunit "Security Group";
        FailedGroups: List of [Code[20]];
        GroupCode: Code[20];
    begin
        // The group must be registered as a security group in this environment, otherwise nobody matches.
        if not SecurityGroup.GetCode(CopyStr(GroupId, 1, 250), GroupCode) then
            if not SecurityGroup.GetCode(CopyStr(LowerCase(GroupId), 1, 250), GroupCode) then
                exit(false);

        FailedGroups := SecurityGroup.GetMembers(TempMemberBuffer);
        if FailedGroups.Contains(GroupCode) then
            exit(false);

        TempMemberBuffer.SetRange("Security Group Code", GroupCode);
        TempMemberBuffer.SetRange("User Security ID", UserSecurityId());
        exit(not TempMemberBuffer.IsEmpty());
    end;

    local procedure LogDenied(EnvironmentName: Text; Reason: Text)
    var
        CategoryTok: Label 'CCMS Environment Access', Locked = true;
        DeniedTok: Label 'Environment management denied. Environment: %1, Reason: %2', Locked = true;
    begin
        Session.LogMessage('D4P0050', StrSubstNo(DeniedTok, EnvironmentName, Reason), Verbosity::Warning,
            DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;
}
