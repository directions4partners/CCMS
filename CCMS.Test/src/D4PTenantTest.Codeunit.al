namespace D4P.CCMS.Test;

using D4P.CCMS.Customer;
using D4P.CCMS.Tenant;

codeunit 62902 "D4P Tenant Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "D4P Test Assert";

    [Test]
    procedure InsertWithoutTenantIdFails()
    var
        Tenant: Record "D4P BC Tenant";
    begin
        // [GIVEN] A tenant with a customer but an empty Tenant ID
        Tenant.Init();
        Tenant."Customer No." := CreateCustomer();

        // [WHEN] The tenant is inserted
        asserterror Tenant.Insert(true);

        // [THEN] An error names the missing Tenant ID and nothing is inserted
        Assert.ExpectedError(Tenant.FieldCaption("Tenant ID"));
        Assert.IsFalse(TenantExists(Tenant."Customer No."), 'Tenant must not be inserted');
    end;

    [Test]
    procedure InsertWithoutCustomerFails()
    var
        Tenant: Record "D4P BC Tenant";
    begin
        // [GIVEN] A tenant with a Tenant ID but no customer
        Tenant.Init();
        Tenant."Tenant ID" := CreateGuid();

        // [WHEN] The tenant is inserted
        asserterror Tenant.Insert(true);

        // [THEN] The customer is required
        Assert.ExpectedErrorCode('TestField');
    end;

    [Test]
    procedure InsertWithCustomerAndTenantIdSucceeds()
    var
        Tenant: Record "D4P BC Tenant";
        TenantId: Guid;
    begin
        // [GIVEN] A complete primary key
        TenantId := CreateGuid();
        Tenant.Init();
        Tenant."Customer No." := CreateCustomer();
        Tenant."Tenant ID" := TenantId;

        // [WHEN] The tenant is inserted
        Tenant.Insert(true);

        // [THEN] The tenant exists
        Assert.IsTrue(Tenant.Get(Tenant."Customer No.", TenantId), 'Tenant must exist');
    end;

    [Test]
    procedure CardDoesNotInsertBeforeTenantIdIsSet()
    var
        Tenant: Record "D4P BC Tenant";
        TenantCard: TestPage "D4P BC Tenant Card";
        CustomerNo: Code[20];
    begin
        // [GIVEN] A new tenant on the card
        CustomerNo := CreateCustomer();
        TenantCard.OpenNew();

        // [WHEN] Only the customer is entered and the user moves on to the next field
        TenantCard."Customer No.".SetValue(CustomerNo);
        TenantCard."Tenant Name".SetValue('Test Tenant');

        // [THEN] No tenant with an empty Tenant ID has been inserted (this used to force a rename later)
        Assert.IsFalse(TenantExists(CustomerNo), 'Tenant must not be inserted without Tenant ID');

        // [THEN] Closing the card without a Tenant ID is refused with a clear message
        asserterror TenantCard.Close();
        Assert.ExpectedError(Tenant.FieldCaption("Tenant ID"));
    end;

    [Test]
    procedure CardInsertsTenantWithTenantIdEnteredLater()
    var
        Tenant: Record "D4P BC Tenant";
        TenantCard: TestPage "D4P BC Tenant Card";
        CustomerNo: Code[20];
        TenantId: Guid;
    begin
        // [GIVEN] A new tenant on the card
        CustomerNo := CreateCustomer();
        TenantId := CreateGuid();
        TenantCard.OpenNew();

        // [WHEN] The customer is entered, other fields are filled and the Tenant ID is entered afterwards
        TenantCard."Customer No.".SetValue(CustomerNo);
        TenantCard."Tenant Name".SetValue('Test Tenant');
        TenantCard."Tenant ID".SetValue(TenantId);
        TenantCard.Close();

        // [THEN] The tenant is inserted with the entered Tenant ID, no rename error occurred
        Assert.IsTrue(Tenant.Get(CustomerNo, TenantId), 'Tenant must be inserted with the entered Tenant ID');
        Assert.AreEqual('Test Tenant', Tenant."Tenant Name", 'Tenant Name');
        Assert.IsFalse(Tenant.Get(CustomerNo, EmptyGuid()), 'No tenant with an empty Tenant ID');
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record "D4P BC Customer";
    begin
        Customer.Init();
        Customer."No." := CopyStr('T' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(Customer."No."));
        Customer.Name := 'Test Customer';
        Customer.Insert(true);
        exit(Customer."No.");
    end;

    local procedure TenantExists(CustomerNo: Code[20]): Boolean
    var
        Tenant: Record "D4P BC Tenant";
    begin
        Tenant.SetRange("Customer No.", CustomerNo);
        exit(not Tenant.IsEmpty());
    end;

    local procedure EmptyGuid(): Guid
    var
        NullGuid: Guid;
    begin
        exit(NullGuid);
    end;
}
