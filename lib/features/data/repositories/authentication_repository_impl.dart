import "package:windenergy/features/data/services/db_service.dart";
import "package:windenergy/features/domain/repositories/authentication_repository.dart";
import "package:windenergy/utils/exceptions.dart";
import "package:windenergy/utils/result.dart";

class AuthenticationRepositoryImpl extends AuthenticationRepository {
  final DbService dbService;
  AuthenticationRepositoryImpl({required this.dbService});
  @override
  FutureResult<dynamic> signIn({String email = "", String password = ""}) async {
    try{
      return await dbService.signIn(email: email, password: password);
    } on ServerException catch(e){
      return Error(reason: e.reason);
    }
  }

  @override
  FutureResult<dynamic> signOut() async {
    try{
      return await dbService.signOut();
    } on ServerException catch(e){
      return Error(reason: e.reason);
    }
  }

  @override
  FutureResult<dynamic> signUp({String fullname = "", String email = "", String password = ""}) async {
    try{
      return await dbService.signUp(fullname: fullname, email: email, password: password);
    } on ServerException catch(e){
      return Error(reason: e.reason);
    }
  }
}