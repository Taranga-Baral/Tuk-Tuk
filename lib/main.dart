// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:final_menu/login_screen/sign_up_page.dart';

// Future<void> main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//    if(kIsWeb){
//       WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: const FirebaseOptions(apiKey: 'AIzaSyCrHL5E_oHQjng6ApZza8TGqx1CxxKH7vM',

//   authDomain: 'menu-app-8cced.firebaseapp.com',

//   projectId: 'menu-app-8cced',

//   storageBucket: 'menu-app-8cced.appspot.com',

//   messagingSenderId: '387296614571',

//   appId: '1:387296614571:web:f19599ed85e2d017b73fee'
// ));
//    }else{
//      await  Firebase.initializeApp();
//    }
//   runApp( MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: RegistrationPage(),
//   ));
// }


import 'package:final_menu/homepage1.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_menu/login_screen/sign_up_page.dart';
import 'package:final_menu/homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCrHL5E_oHQjng6ApZza8TGqx1CxxKH7vM',
        authDomain: 'menu-app-8cced.firebaseapp.com',
        projectId: 'menu-app-8cced',
        storageBucket: 'menu-app-8cced.appspot.com',
        messagingSenderId: '387296614571',
        appId: '1:387296614571:web:f19599ed85e2d017b73fee',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), // Wrap your pages with AuthWrapper
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    // If the user is signed in, navigate to the homepage, otherwise, show the RegistrationPage
    if (user != null) {
      return HomePage1();
    } else {
      return RegistrationPage();
    }
  }
}
