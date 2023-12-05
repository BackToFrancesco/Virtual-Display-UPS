import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_display/repositories/authentication_repository/authentication_repository.dart';

import '../authentication_helper.dart';

void main() {
  List<String> user = MockUser.user;
  List<String> emptyUser = [];
  MockGlobalPreferences mockGlobalPreferences = MockGlobalPreferences();
  Map<String, Object> values = {
    'user': user,
  };
  Map<String, Object> emptyValues = {
    'user': emptyUser,
  };

  test('init() initialize the AuthenticationManager with the expected values', () async{
    AuthenticationRepository authenticationRepository = AuthenticationRepository();
    await mockGlobalPreferences.setGlobalPreferences(values);
    authenticationRepository.init();
    expect(authenticationRepository.user?.id, int.parse(user[0]));
    expect(authenticationRepository.user?.name, user[1]);
    expect(authenticationRepository.user?.surname, user[2]);
    expect(authenticationRepository.user?.email, user[3]);
    expect(authenticationRepository.user?.phoneNumber, user[4]);
    authenticationRepository.dispose();
  });

  test('if credential are not saved, no user is logged to AuthenticationRepository', () async{
    AuthenticationRepository authenticationRepository = AuthenticationRepository();
    await mockGlobalPreferences.setGlobalPreferences(emptyValues);
    authenticationRepository.init();
    expect(authenticationRepository.logged, false);
    authenticationRepository.dispose();
  });

  test('logIn() logged the user correctly in AuthenticationRepository', () async{
    AuthenticationRepository authenticationRepository = AuthenticationRepository();
    await mockGlobalPreferences.setGlobalPreferences(emptyValues);
    authenticationRepository.init();
    expect(authenticationRepository.logged, false);
    MockServer mockServer = MockServer();
    mockServer.startServer();
    await authenticationRepository.logIn(email: MockUser.user[3], password: "password", url: MockServer.url);
    expect(authenticationRepository.user?.id, int.parse(MockUser.user[0]));
    expect(authenticationRepository.user?.name, MockUser.user[1]);
    expect(authenticationRepository.user?.surname, MockUser.user[2]);
    expect(authenticationRepository.user?.email, MockUser.user[3]);
    expect(authenticationRepository.user?.phoneNumber, MockUser.user[4]);
    expect(authenticationRepository.logged, true);
    await mockServer.dispose();
    authenticationRepository.dispose();
  });

  test('logout() logged out the user and the credential are deleted from AuthenticationRepository', () async{
    AuthenticationRepository authenticationRepository = AuthenticationRepository();
    await mockGlobalPreferences.setGlobalPreferences(values);
    authenticationRepository.init();
    expect(authenticationRepository.logged, true);
    authenticationRepository.logOut();
    expect(authenticationRepository.logged, false);
    expect(authenticationRepository.user, isNull);
  });
}