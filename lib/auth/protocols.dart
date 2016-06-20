part of aqueduct;

/// An interface for implementing [TokenType] for an [AuthenticationServer].
///
/// In order to use authentication tokens, an [AuthenticationServer] requires
/// that its [TokenType] implement this interface. You will likely use
/// this interface in defining a [Model] that represents the concrete implementation of a authentication
/// token in your application.
abstract class Tokenizable {
  /// The value to be passed as a Bearer Authorization header.
  String accessToken;

  /// The value to be passed for refreshing an expired (or not yet expired) token.
  String refreshToken;

  /// The timestamp this token was issued on.
  DateTime issueDate;

  /// When this token expires.
  DateTime expirationDate;

  /// The type of token, currently only 'bearer' is valid.
  String type;

  /// The identifier of the resource owner.
  ///
  /// Tokens are owned by a resource owner, typically a User, Profile or Account
  /// in an application. This value is the primary key or identifiying value of those
  /// instances.
  dynamic resourceOwnerIdentifier;

  /// The clientID this token was issued under.
  String clientID;
}

/// A representation of authentication information to be attached to a [Request].
///
/// When a [Request] passes through an [Authenticator] and is validated,
/// the [Authenticator] attaches an instance of [Permission] to its [permission]
/// property to carry the authentication information to the next [RequestHandler]s.
class Permission {
  /// Creates an instance of a [Permission].
  const Permission(this.clientID, this.resourceOwnerIdentifier, this.grantingServer);

  /// The client ID the permission was granted under.
  final String clientID;

  /// The identifier for the owner of the resource.
  ///
  /// If a [Request] has a Bearer token, this will be the primary key value of the [Model]
  /// for which the Bearer token was associated with. If the [Request] was signed with
  /// a Client ID and secret, this value will be [null].
  final dynamic resourceOwnerIdentifier;

  /// The [AuthenticationServer] that granted this permission.
  final AuthenticationServer grantingServer;
}

/// An interface for implementing a resource owner.
///
/// In order for an [AuthenticationServer] to authenticate a resource owner - like a User, Profile or Account in your application -
/// that resource owner class must implement this interface. An [Authenticatable] doesn't necessarily have to have these properties explicitly.
/// For example, if the 'username' of a user is their email, they may define the [username] property to access the email property.
abstract class Authenticatable {
  /// The username of the authenticatable resource.
  ///
  /// This value is often an email address. The storage of an [Authenticatable] need not define a [username] property,
  /// and so the implementation may simply proxy property to the underlying identifying attribute - like email.
  String username;

  /// The hashed password of the resource owner.
  String hashedPassword;

  /// The salt the [hashedPassword] was hashed with.
  String salt;

  /// The unique identifier of the [Authenticatable].
  dynamic id;
}

/// An interface for implementing storage of an [AuthenticationServer].
///
/// This interface is responsible for persisting information generated and requested by an [AuthenticationServer].
/// The [ResourceOwner] often represents a user, and must implement [Authenticatable]. The [TokenType]
/// is a concrete instance of [Tokenizable].
abstract class AuthenticationServerDelegate<ResourceOwner extends Authenticatable, TokenType extends Tokenizable> {
  /// Returns a [TokenType] for an [accessToken].
  ///
  /// This method returns an instance of [TokenType] if one exists for [accessToken], and [null] otherwise.
  /// [server] is the [AuthenticationServer] requesting the [TokenType].
  Future<TokenType> tokenForAccessToken(AuthenticationServer server, String accessToken);

  /// Returns a [TokenType] for an [refreshToken].
  ///
  /// This method returns an instance of [TokenType] if one exists for [refreshToken], and [null] otherwise.
  /// [server] is the [AuthenticationServer] requesting the [TokenType].
  Future<TokenType> tokenForRefreshToken(AuthenticationServer server, String refreshToken);

  /// Returns a [ResourceOwner] for an [username].
  ///
  /// This method returns an instance of [ResourceOwner] if one exists for [username], and [null] otherwise.
  /// [server] is the [AuthenticationServer] requesting the [ResourceOwner].
  Future<ResourceOwner> authenticatableForUsername(AuthenticationServer server, String username);

  /// Returns a [ResourceOwner] for an [username].
  ///
  /// This method returns an instance of [ResourceOwner] if one exists for [id], and [null] otherwise.
  /// [server] is the [AuthenticationServer] requesting the [ResourceOwner].
  Future<ResourceOwner> authenticatableForID(AuthenticationServer server, dynamic id);

  /// Returns a [Client] for a client id.
  ///
  /// This method returns an instance of [Client] if one exists for [id], and [null] otherwise.
  /// [server] is the [AuthenticationServer] requesting the [Client].
  Future<Client> clientForID(AuthenticationServer server, String id);

  /// Deletes a [TokenType] for [accessToken].
  ///
  /// If the [server] wishes to delete an authentication token, it will invoke this method. The
  /// concrete instance must delete that token from its persistent storage.
  Future deleteTokenForAccessToken(AuthenticationServer server, String accessToken);

  /// Asks this instance to store a [TokenType] for [server].
  ///
  /// The implementing class must persistent the token [t].
  Future storeToken(AuthenticationServer server, TokenType t);
}
