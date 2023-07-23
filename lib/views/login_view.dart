import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Enter your email"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,

            decoration: const InputDecoration(hintText: "Enter your password"),
          ),
          TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;

                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  final user = FirebaseAuth.instance.currentUser;
                  if(user?.emailVerified ?? false){
                    // user's email is verified
                    if (!mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                  }else{
                    // user's email is not verified
                    if (!mounted) return;
                    await showErrorDialog(context, 'User email not verified');
                    await user?.sendEmailVerification();
                    if(!mounted) return;
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  }
                  
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    await showErrorDialog(context,'User not found');
                  } else if (e.code == 'wrong-password') {
                    await showErrorDialog(context,'Password incorrect');
                  } else{
                    await showErrorDialog(
                      context,
                      'Error: ${e.code}',
                    );
                  }
                }
                catch (e){
                  await showErrorDialog(
                      context,
                      'Error: ${e.toString()}',
                    );
                }
              },
              child: const Text("Login")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text('Not registered yet? Register here!'))
        ],
      ),
    );
  }
}

