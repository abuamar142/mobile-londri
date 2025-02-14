import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/auth.dart';
import '../../domain/usecases/auth_login.dart';
import '../../domain/usecases/auth_logout.dart';
import '../../domain/usecases/auth_register.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthLogin authLogin;
  final AuthRegister authRegister;
  final AuthLogout authLogout;

  AuthBloc({
    required this.authLogin,
    required this.authRegister,
    required this.authLogout,
  }) : super(AuthStateInitial()) {
    on<AuthEventLogin>((event, emit) async {
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthStateFailure(
          message: 'Email and password are required',
        ));
        emit(AuthStateInitial());
        return;
      } else {
        emit(AuthStateLoading());

        Either<Failure, Auth> result = await authLogin.call(
          event.email,
          event.password,
        );

        result.fold((left) {
          emit(AuthStateFailure(
            message: left.message.toString(),
          ));
        }, (right) {
          emit(AuthStateSuccessLogin(
            auth: right,
          ));
        });
      }
    });

    on<AuthEventRegister>((event, emit) async {
      if (event.name.isEmpty ||
          event.email.isEmpty ||
          event.password.isEmpty ||
          event.passwordAgain.isEmpty) {
        emit(const AuthStateFailure(
          message: 'All fields are required',
        ));
        emit(AuthStateInitial());
        return;
      } else if (event.password != event.passwordAgain) {
        emit(const AuthStateFailure(
          message: 'Passwords do not match',
        ));
        emit(AuthStateInitial());
        return;
      } else {
        emit(AuthStateLoading());

        Either<Failure, Auth> result = await authRegister.call(
          event.email,
          event.password,
          event.name,
        );

        result.fold((left) {
          emit(AuthStateFailure(
            message: left.message.toString(),
          ));
        }, (right) {
          emit(AuthStateSuccessRegister(
            auth: right,
          ));
        });
      }
    });

    on<AuthEventLogout>((event, emit) async {
      emit(AuthStateLoading());
      Either<Failure, void> result = await authLogout.call();

      result.fold((left) {
        emit(AuthStateFailure(
          message: left.message,
        ));
      }, (_) {
        emit(AuthStateSuccessLogout());
      });
    });
  }
}
