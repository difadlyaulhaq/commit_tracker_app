import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';

// Auth Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String githubUsername;
  final String githubToken;

  RegisterRequested({
    required this.email,
    required this.password,
    required this.githubUsername,
    required this.githubToken,
  });

  @override
  List<Object> get props => [email, password, githubUsername, githubToken];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String githubUsername;
  final String githubToken;

  LoginRequested({
    required this.email,
    required this.password,
    required this.githubUsername,
    required this.githubToken,
  });

  @override
  List<Object> get props => [email, password, githubUsername, githubToken];
}

class LogoutRequested extends AuthEvent {}

// Auth States
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// Auth Bloc dengan Firestore-based Authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // Hash password untuk keamanan
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final userModel = UserModel.fromMap(doc.data()!);
          emit(AuthAuthenticated(userModel));
        } else {
          // User ada di Firebase Auth tapi tidak ada di Firestore, logout
          await _firebaseAuth.signOut();
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        await _firebaseAuth.signOut();
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final email = event.email.trim().toLowerCase();
      final hashedPassword = _hashPassword(event.password);

      // Cari user di Firestore berdasarkan email dan password
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        emit(AuthError('Email tidak ditemukan. Silakan daftar terlebih dahulu.'));
        return;
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      
      // Verifikasi password
      if (userData['hashedPassword'] != hashedPassword) {
        emit(AuthError('Password salah. Silakan coba lagi.'));
        return;
      }

      // Buat UserModel dari data Firestore
      final userModel = UserModel.fromMap(userData);

      // Update GitHub credentials jika diberikan
      if (event.githubUsername.isNotEmpty || event.githubToken.isNotEmpty) {
        final updatedUserModel = UserModel(
          uid: userModel.uid,
          email: userModel.email,
          githubUsername: event.githubUsername.isNotEmpty ? event.githubUsername : userModel.githubUsername,
          githubToken: event.githubToken.isNotEmpty ? event.githubToken : userModel.githubToken,
        );
        
        // Update di Firestore
        await _firestore.collection('users').doc(userModel.uid).update({
          'githubUsername': updatedUserModel.githubUsername,
          'githubToken': updatedUserModel.githubToken,
        });
        
        emit(AuthAuthenticated(updatedUserModel));
      } else {
        emit(AuthAuthenticated(userModel));
      }

      // Sign in ke Firebase Auth secara silent (untuk konsistensi)
      try {
        // Coba sign in dengan Firebase Auth, tapi jangan gagalkan jika error
        await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: event.password,
        );
      } catch (e) {
        // Jika Firebase Auth gagal, tetap lanjutkan karena sudah verify dengan Firestore
        print('Firebase Auth sign in failed, but Firestore auth succeeded: $e');
      }

    } catch (e) {
      emit(AuthError('Login gagal: ${e.toString()}'));
    }
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final email = event.email.trim().toLowerCase();
      final hashedPassword = _hashPassword(event.password);

      // Cek apakah email sudah terdaftar di Firestore
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        emit(AuthError('Email sudah terdaftar. Silakan gunakan email lain atau login.'));
        return;
      }

      // Cek apakah GitHub username sudah digunakan
      if (event.githubUsername.isNotEmpty) {
        final existingGithubUser = await _firestore
            .collection('users')
            .where('githubUsername', isEqualTo: event.githubUsername)
            .limit(1)
            .get();

        if (existingGithubUser.docs.isNotEmpty) {
          emit(AuthError('GitHub username sudah digunakan. Silakan gunakan username lain.'));
          return;
        }
      }

      // Generate UID untuk user baru
      String uid;
      try {
        // Coba daftar ke Firebase Auth dulu
        final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: event.password,
        );
        uid = credential.user!.uid;
      } catch (e) {
        // Jika Firebase Auth gagal, generate UID sendiri
        uid = _firestore.collection('users').doc().id;
      }

      // Buat user model
      final userModel = UserModel(
        uid: uid,
        email: email,
        githubUsername: event.githubUsername,
        githubToken: event.githubToken,
      );

      // Simpan ke Firestore dengan password hash
      await _firestore.collection('users').doc(uid).set({
        ...userModel.toMap(),
        'hashedPassword': hashedPassword,
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(AuthAuthenticated(userModel));

    } catch (e) {
      emit(AuthError('Registrasi gagal: ${e.toString()}'));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      // Ignore Firebase Auth errors during logout
    }
    emit(AuthUnauthenticated());
  }
}