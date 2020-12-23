// Generated using Sourcery 0.11.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest
@testable import ChatServerTests
@testable import Vapor2ChatServerTests

extension ActivateUserTests {
  static var allTests = [
    ("testJustActivate", testJustActivate),
    ("testActivateAndAddPermissions", testActivateAndAddPermissions),
  ]
}

extension AttachmentsNewTests {
  static var allTests = [
    ("testCreateAttachments", testCreateAttachments),
    ("testTooManyAttachments", testTooManyAttachments),
  ]
}

extension AuthorizationHeaderParserTests {
  static var allTests = [
    ("testGoodHeader", testGoodHeader),
    ("testExtraKeyValuePart", testExtraKeyValuePart),
    ("testWrongVersion", testWrongVersion),
    ("testMissingLoginKey", testMissingLoginKey),
    ("testMissingSignature", testMissingSignature),
    ("testNoKeyValuePart", testNoKeyValuePart),
  ]
}

extension BlobRoutesTests {
  static var allTests = [
    ("testGetNonexistentBlob", testGetNonexistentBlob),
    ("testAddAndGetBlob", testAddAndGetBlob),
    ("testDuplicateKey", testDuplicateKey),
  ]
}

extension ConversationJoinTests {
  static var allTests = [
    ("testJoinNonexistentConversation", testJoinNonexistentConversation),
    ("testJoinConversation", testJoinConversation),
  ]
}

extension ConversationLeaveTests {
  static var allTests = [
    ("testLeaveNonexistentConversation", testLeaveNonexistentConversation),
    ("testLeaveConversation", testLeaveConversation),
  ]
}

extension ConversationPermissionGetTests {
  static var allTests = [
    ("testGetPermissionWithBadConversationKeyID", testGetPermissionWithBadConversationKeyID),
    ("testGetPermission", testGetPermission),
  ]
}

extension ConversationsRoutesTests {
  static var allTests = [
    ("testCreateRequiresAuth", testCreateRequiresAuth),
    ("testCreate", testCreate),
    ("testNewPermissionsRequiresAuth", testNewPermissionsRequiresAuth),
    ("testNewPermissions", testNewPermissions),
    ("testListRequiresAuth", testListRequiresAuth),
    ("testList", testList),
    ("testMessagesRequiresAuth", testMessagesRequiresAuth),
    ("testMessagesInvalidConversation", testMessagesInvalidConversation),
    ("testEmptyMessagesList", testEmptyMessagesList),
  ]
}

extension ConversationsRoutesTestsWithMessages {
  static var allTests = [
    ("testMessagesList", testMessagesList),
  ]
}

extension CryptoUtilTests {
  static var allTests = [
    ("testEncryptSymmetricallyWithWrongKeyLength", testEncryptSymmetricallyWithWrongKeyLength),
    ("testEncryptSymmetricallyWithWrongNonceLength", testEncryptSymmetricallyWithWrongNonceLength),
    ("testEncryptEmptyStringSymmetrically", testEncryptEmptyStringSymmetrically),
    ("testEncryptNonEmptyStringSymmetrically", testEncryptNonEmptyStringSymmetrically),
  ]
}

extension DeviceAuthTests {
  static var allTests = [
    ("testAuthWorksWithActiveDevice", testAuthWorksWithActiveDevice),
    ("testDeviceMustBeActiveForAuth", testDeviceMustBeActiveForAuth),
  ]
}

extension DeviceGetTests {
  static var allTests = [
    ("testGetNonexistentDevice", testGetNonexistentDevice),
    ("testGetDevice", testGetDevice),
  ]
}

extension DevicesRoutesTests {
  static var allTests = [
    ("testRegisterWithNonJSONBody", testRegisterWithNonJSONBody),
    ("testRegisterWithBrokenJSONBody", testRegisterWithBrokenJSONBody),
    ("testRegisterWithBadEmail", testRegisterWithBadEmail),
    ("testRegisterWithWrongPassword", testRegisterWithWrongPassword),
    ("testRegisterDeviceWithConflictingID", testRegisterDeviceWithConflictingID),
    ("testRegisterDeviceWithWrongOwnerID", testRegisterDeviceWithWrongOwnerID),
    ("testRegisterDeviceWithWrongState", testRegisterDeviceWithWrongState),
    ("testRegisterDeviceWithBlockTime", testRegisterDeviceWithBlockTime),
    ("testRegisterDevice", testRegisterDevice),
    ("testGetDevicesRequiresAuth", testGetDevicesRequiresAuth),
    ("testGetDevices", testGetDevices),
    ("testGetPendingDevices", testGetPendingDevices),
    ("testPatchDeviceRequiresAuth", testPatchDeviceRequiresAuth),
    ("testSetStateToPendingFails", testSetStateToPendingFails),
    ("testActivateNonPendingFails", testActivateNonPendingFails),
    ("testActivate", testActivate),
    ("testActivateByAdminUser", testActivateByAdminUser),
    ("testBlockDeviceRequiresAuthAsOwnerOfDevice", testBlockDeviceRequiresAuthAsOwnerOfDevice),
    ("testBlockNonexistingDevice", testBlockNonexistingDevice),
    ("testBlockDeviceRequiresBlockTime", testBlockDeviceRequiresBlockTime),
    ("testBlockDevice", testBlockDevice),
  ]
}

extension DummyUserTests {
  static var allTests = [
    ("testMakeDummyUser", testMakeDummyUser),
  ]
}

extension FluentUsersServiceTests {
  static var allTests = [
    ("testGetAllUsers", testGetAllUsers),
    ("testUserWithID", testUserWithID),
    ("testUserWithEmail", testUserWithEmail),
    ("testUpdateConflict", testUpdateConflict),
  ]
}

extension JSONDiffTests {
  static var allTests = [
    ("testNull", testNull),
    ("testNumber", testNumber),
    ("testString", testString),
    ("testArray", testArray),
    ("testObject", testObject),
  ]
}

extension LogServiceTests {
  static var allTests = [
    ("testInfo", testInfo),
    ("testWarning", testWarning),
    ("testError", testError),
    ("testFatal", testFatal),
  ]
}

extension MessageNewTests {
  static var allTests = [
    ("testUnparsableMessage", testUnparsableMessage),
    ("testMalformedNewMessageRequest", testMalformedNewMessageRequest),
    ("testNewMessageRequest", testNewMessageRequest),
  ]
}

extension NewConversationPermissionsTests {
  static var allTests = [
    ("testNewPermissions", testNewPermissions),
    ("testNewPermissionsForNonexistentConversation", testNewPermissionsForNonexistentConversation),
    ("testNewPermissionsWithUnauthenticatedCreator", testNewPermissionsWithUnauthenticatedCreator),
    ("testNewPermissionsWithNonexistentOwner", testNewPermissionsWithNonexistentOwner),
    ("testNewPermissionsWithConflictingConversationKeyID", testNewPermissionsWithConflictingConversationKeyID),
  ]
}

extension NewConversationTests {
  static var allTests = [
    ("testNewGroup", testNewGroup),
    ("testNewGroupWithConflictingID", testNewGroupWithConflictingID),
    ("testNewGroupWithConflictingParticipants", testNewGroupWithConflictingParticipants),
    ("testNewChannel", testNewChannel),
    ("testNewChannelWithConflictingName", testNewChannelWithConflictingName),
    ("testNewChannelWithNonexistentParticipant", testNewChannelWithNonexistentParticipant),
  ]
}

extension NewDeviceTests {
  static var allTests = [
    ("testAddFirstDevice", testAddFirstDevice),
  ]
}

extension NewMessageTests {
  static var allTests = [
    ("testNewMessageWithBadPreviousMessage", testNewMessageWithBadPreviousMessage),
    ("testNewMessageWithNonexistentConversationKey", testNewMessageWithNonexistentConversationKey),
    ("testNewMessageWithObsoleteConversationKey", testNewMessageWithObsoleteConversationKey),
    ("testNewMessageWithUnownedDevice", testNewMessageWithUnownedDevice),
    ("testNewMessage", testNewMessage),
    ("testNewMessageWithBadParentMessage", testNewMessageWithBadParentMessage),
    ("testNewMessageWithParent", testNewMessageWithParent),
  ]
}

extension UserAuthTests {
  static var allTests = [
    ("testAuthWorksWithActiveUser", testAuthWorksWithActiveUser),
    ("testUserMustBeActiveForAuth", testUserMustBeActiveForAuth),
  ]
}

extension UserGetTests {
  static var allTests = [
    ("testGetNonexistentUser", testGetNonexistentUser),
    ("testGetUser", testGetUser),
  ]
}

extension UsersRoutesTests {
  static var allTests = [
    ("testRegisterWithDuplicateEmailAddress", testRegisterWithDuplicateEmailAddress),
    ("testRegister", testRegister),
    ("testGetAllRequiresAuth", testGetAllRequiresAuth),
    ("testGetAll", testGetAll),
    ("testGetMeWithBadEmail", testGetMeWithBadEmail),
    ("testGetMeWithWrongPVK", testGetMeWithWrongPVK),
    ("testGetMe", testGetMe),
  ]
}

extension UsersRoutesTestsWithPendingUser {
  static var allTests = [
    ("testGetPending", testGetPending),
    ("testUpdateRequiresAuth", testUpdateRequiresAuth),
    ("testUpdateState", testUpdateState),
    ("testUpdateProfile", testUpdateProfile),
  ]
}

extension UsersRoutesTestsWithoutUsers {
  static var allTests = [
    ("testFirstUserIsInitiallyActive", testFirstUserIsInitiallyActive),
  ]
}

extension WebSocketRequestTests {
  static var allTests = [
    ("testInvalidType", testInvalidType),
  ]
}

extension WebSocketRoutesTests {
  static var allTests = [
    ("testMakeURLRequiresAuth", testMakeURLRequiresAuth),
    ("testMakeURL", testMakeURL),
    ("testConnectToURLWithoutToken", testConnectToURLWithoutToken),
    ("testConnectToURLWithBadToken", testConnectToURLWithBadToken),
    ("testConnectToURL", testConnectToURL),
  ]
}


XCTMain([
  testCase(ActivateUserTests.allTests),
  testCase(AttachmentsNewTests.allTests),
  testCase(AuthorizationHeaderParserTests.allTests),
  testCase(BlobRoutesTests.allTests),
  testCase(ConversationJoinTests.allTests),
  testCase(ConversationLeaveTests.allTests),
  testCase(ConversationPermissionGetTests.allTests),
  testCase(ConversationsRoutesTests.allTests),
  testCase(ConversationsRoutesTestsWithMessages.allTests),
  testCase(CryptoUtilTests.allTests),
  testCase(DeviceAuthTests.allTests),
  testCase(DeviceGetTests.allTests),
  testCase(DevicesRoutesTests.allTests),
  testCase(DummyUserTests.allTests),
  testCase(FluentUsersServiceTests.allTests),
  testCase(JSONDiffTests.allTests),
  testCase(LogServiceTests.allTests),
  testCase(MessageNewTests.allTests),
  testCase(NewConversationPermissionsTests.allTests),
  testCase(NewConversationTests.allTests),
  testCase(NewDeviceTests.allTests),
  testCase(NewMessageTests.allTests),
  testCase(UserAuthTests.allTests),
  testCase(UserGetTests.allTests),
  testCase(UsersRoutesTests.allTests),
  testCase(UsersRoutesTestsWithPendingUser.allTests),
  testCase(UsersRoutesTestsWithoutUsers.allTests),
  testCase(WebSocketRequestTests.allTests),
  testCase(WebSocketRoutesTests.allTests),
])
