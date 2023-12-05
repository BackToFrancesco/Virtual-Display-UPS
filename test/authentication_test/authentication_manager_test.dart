import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_display/repositories/authentication_repository/models/authentication_manager/authentication_manager.dart';
import '../authentication_helper.dart';

void main() async {
  
  List<String> user = MockUser.user;
  List<String> emptyUser = [];
  MockGlobalPreferences mockGlobalPreferences = MockGlobalPreferences();
  Map<String, Object> values = {
    'user': user,
  };
  Map<String, Object> emptyValues = {
    'user': emptyUser,
  };
  
  test('init() initialize the AuthenticationManager with the expected values',
      () async {
    AuthenticationManager authenticationManager = AuthenticationManager();
    await mockGlobalPreferences.setGlobalPreferences(values);
    authenticationManager.init();
    expect(authenticationManager.user?.id, int.parse(user[0]));
    expect(authenticationManager.user?.name, user[1]);
    expect(authenticationManager.user?.surname, user[2]);
    expect(authenticationManager.user?.email, user[3]);
    expect(authenticationManager.user?.phoneNumber, user[4]);
    authenticationManager.dispose();
  });

  test('if credential are not saved, no user is logged to AuthenticationManager', () async{
    AuthenticationManager authenticationManager = AuthenticationManager();
    await mockGlobalPreferences.setGlobalPreferences(emptyValues);
    authenticationManager.init();
    expect(authenticationManager.logged, false);
    authenticationManager.dispose();
  });

  test('logIn() logged the user correctly in AuthenticationManager', () async {
    AuthenticationManager authenticationManager = AuthenticationManager();
    await mockGlobalPreferences.setGlobalPreferences(emptyValues);
    authenticationManager.init();
    expect(authenticationManager.logged, false);
    MockServer mockServer = MockServer();
    mockServer.startServer();
    await authenticationManager.logIn(email: MockUser.user[3], password: "password", url: MockServer.url);
    expect(authenticationManager.user?.id, int.parse(MockUser.user[0]));
    expect(authenticationManager.user?.name, MockUser.user[1]);
    expect(authenticationManager.user?.surname, MockUser.user[2]);
    expect(authenticationManager.user?.email, MockUser.user[3]);
    expect(authenticationManager.user?.phoneNumber, MockUser.user[4]);
    expect(authenticationManager.logged, true);
    await mockServer.dispose();
    authenticationManager.dispose();
  });

  test('logout() logged out the user and the credential are deleted from AuthenticationManager', () async{
    AuthenticationManager authenticationManager = AuthenticationManager();
    await mockGlobalPreferences.setGlobalPreferences(values);
    authenticationManager.init();
    expect(authenticationManager.logged, true);
    authenticationManager.logOut();
    expect(authenticationManager.logged, false);
    expect(authenticationManager.user, isNull);
  });
}
