import "package:equatable/equatable.dart";

class Profile extends Equatable {
  final String id;
  final String email;
  final String fullname;
  final DateTime? createdAt;

  const Profile({this.id="", this.email="", this.fullname="", this.createdAt});

  @override
  List<Object?> get props => [id];
}