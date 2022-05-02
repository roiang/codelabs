//many errors wtf is this  whare are my commits? in this proyect can they readme?

import 'package:firebase_auth/firebase_auth.dart'; //new
import 'package:firebase_core/firebase_core.dart'; //new
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart'; //new

// import 'firebase_options.dart';              // new
import 'src/authentication.dart';            // new
import 'src/widgets.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Meetup',
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
              highlightColor: Colors.deepPurple,
            ),
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}  

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Meetup'),
      ),
      body: ListView(
        children: <Widget>[
          Image.asset('assets/codelab.png'),
          const SizedBox(height: 8),
          const IconAndDetail(Icons.calendar_today, 'October 30'),
          const IconAndDetail(Icons.location_city, 'San Francisco'),
          //aplicaremos el Consumer applicationState , crearemos el authentication widget 
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Authentication(
              email: appState.email,
              loginState: appState.loginState,
              startLoginFlow: appState.startLoginFlow,
              verifyEmail: appState.verifyEmail,
              signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
              cancelRegistration: appState.cancelRegistration,
              registerAccount: appState.registerAccount,
              signOut: appState.signOut,
            ),
          ),
          const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          const Header("What we'll be doing"),
          const Paragraph(
            'Join us for a day full of Firebase Workshops and Pizza!',
          ),
        ],
      ),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  
  ApplicationState(){
     init();
  }
  Future<void> init() async {
    await Firebase.initializeApp(
      options: Firebase.apps.first.options,
    );


    FirebaseAuth.instance.userChanges().listen((user) { //aqui se actualiza el usuario 
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
      } else {
        _loginState = ApplicationLoginState.loggedOut;
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;
  String? _email;
  String? get email => _email;
  void startLoginFlow() {
      _loginState = ApplicationLoginState.emailAddress;
      notifyListeners(); 
      }

  Future<void> verifyEmail( //verificacion de correo
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email); //metodo de verificacion de el email
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password; //se autentifica la contraseña 
      } else {
        _loginState = ApplicationLoginState.register; //re registra el usuario
          //esto es importante porque esta es la manera en como esta configurada de manera austera la verificacion por el proceso de un paso a otro cuando es evidente que se puede hacer de otra mnera esto esta hecho para que del poner el correo y no esta inscrito se registre como nuevo y crea un nuevo usuario en la base de datos
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> signInWithEmailAndPassword( //Ingreso de Ususario
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword( //metodo de login
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e); //aqui el usuario puede intentar registrarse o ingresar nuevamente 
    }
  }

  void cancelRegistration() { //cancela el registro 
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }


    Future<void> registerAccount( //registra el usuario creacion del usuario
      String email,
      String displayName,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }


  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}