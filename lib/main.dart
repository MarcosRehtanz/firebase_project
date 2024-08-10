import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(title: 'Flutter Demo Home Page'),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.title});
  final String title;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String _logged = 'signed out!';
  UserCredential? _credential;

  void onSignInWithCredential() async {
    var userCredential =
        await FirebaseAuth.instance.signInWithCredential(_credential as AuthCredential );
    final user = userCredential.user;
    print(user?.uid);
  }

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          _logged = 'Signed out!';
        });
        print('User is currently signed out!');
      } else {
        setState(() {
          _logged = 'Signed in!';
        });
        print('User is signed in!');
      }
    });
    super.initState();
  }

  void onRegistered(String emailAddress, String password) async {
    try {
      // print('hello, world!');
      var credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      print(credential);
      setState(() {
        _credential = credential;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  void onSignIn(String emailAddress, String password) async {
    try {
      var credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      print(credential);
      setState(() {
        _credential = credential;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Register(onRegistered: onRegistered),
              Login(
                onSignIn: onSignIn,
              ),
              ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  iconAlignment: IconAlignment.start,
                  child: const Text('Sign Out')),
              Text(
                _logged,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }
}

class Register extends StatefulWidget {
  const Register({super.key, required this.onRegistered});
  final Function onRegistered;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String emailAddress = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Email'),
          onChanged: (email) {
            setState(() {
              emailAddress = email;
            });
          },
        ),
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Password'),
          onChanged: (pass) {
            setState(() {
              password = pass;
            });
          },
        ),
        IconButton(
            onPressed: () {
              widget.onRegistered(emailAddress, password);
            },
            icon: const Icon(Icons.app_registration))
      ],
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key, required this.onSignIn});
  final Function onSignIn;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String emailAddress = '';
  String password = '';
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Email'),
          onChanged: (text) {
            setState(() {
              emailAddress = text;
            });
          },
        ),
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Password'),
          onChanged: (text) {
            setState(() {
              password = text;
            });
          },
        ),
        TextButton(
            onPressed: () {
              widget.onSignIn(emailAddress, password);
            },
            child: const Text('Loggin'))
      ],
    );
  }
}
