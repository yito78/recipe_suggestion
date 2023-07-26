import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final currentUser = Provider<User>((ref) => throw UnimplementedError());

final userProvider = StreamProvider<User?>((ref) async* {
  final auth = FirebaseAuth.instance;
  final userStream = auth.authStateChanges();
  await for (final user in userStream) {
    debugPrint("-------------user: $user");
    yield user;
  }
});
