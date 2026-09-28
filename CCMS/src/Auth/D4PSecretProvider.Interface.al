namespace D4P.CCMS.Auth;

/// <summary>
/// Supplies app registration client secrets from a store outside of this extension, for example a
/// central Azure Key Vault. Subscribe to OnGetSecretProvider on table "D4P BC App Registration" to
/// hand an implementation of this interface to CCMS.
/// </summary>
interface "D4P Secret Provider"
{
    /// <summary>
    /// Retrieves the client secret of an app registration.
    /// </summary>
    /// <param name="ClientId">The app registration client id to retrieve the client secret for.</param>
    /// <returns>SecretText containing the client secret, or an empty SecretText if the provider has none.</returns>
    procedure GetClientSecret(ClientId: Guid) ClientSecret: SecretText

    /// <summary>
    /// Tests whether this provider is responsible for the client id and expects to be able to supply a
    /// secret for it. Implementations should answer from their own configuration rather than by calling
    /// the external secret store, because this is evaluated while records are displayed.
    /// </summary>
    /// <param name="ClientId">The app registration client id to test.</param>
    /// <returns>Boolean indicating whether this provider can supply a client secret for the client id.</returns>
    procedure HasClientSecret(ClientId: Guid) SecretExists: Boolean
}
