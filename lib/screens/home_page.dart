import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_blog/constants/constants.dart';
import 'package:news_blog/constants/shared_preferences.dart';
import 'package:news_blog/screens/news_home.dart';
import 'package:news_blog/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import '../constants/theme_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  int currentIndex = 0;
  bool isLoading = false;
  bool isLoggedIn = false;
  String? myPhotoUrl = '';
  String? myName = '';
  bool? isAdmin = false;

  final DateTime timestamp =
      DateTime.now(); // To get the date user created the account

  final usersRef = firebaseFirestore.collection(
      'users'); //To make a reference to Users collection in firestore

  final GoogleSignInAccount? googleAccount = googleSignIn.currentUser;

  @override
  void initState() {
    signInSlently();
    getDataFromSharedPreference();
    super.initState();
  }

  void changePage(int? index) {
    setState(() {
      currentIndex = index!;
    });
  }

//Method to Sign in
  signIn() async {
    setState(() {
      isLoading = true;
    });

    await googleSignIn.signIn().then((googleAccount) async {
      //To get the Google account id from firestore
      DocumentSnapshot userId =
          await usersRef.doc(googleAccount!.id).get().catchError((e) {});

      //if user doesn't exist before, do this
      if (userId.exists == false) {
        usersRef.doc(googleAccount.id).set({
          "id": googleAccount.id,
          "photoUrl": googleAccount.photoUrl,
          "displayName": googleAccount.displayName,
          "isAdmin": false
        });

        await MySharedPreferences.setId(googleAccount.id);
        await MySharedPreferences.setPhotoUrl(googleAccount.photoUrl!);
        await MySharedPreferences.setDisplayName(googleAccount.displayName!);
        await MySharedPreferences.setIsAdmin(false);

        getDataFromSharedPreference();

        setState(() {
          isLoggedIn = true;
          isLoading = false;
        });

        Get.snackbar("Sign in successful", "",
            snackPosition: SnackPosition.BOTTOM);
      } else if (userId.exists == true) {
        getAdminValue();
        await MySharedPreferences.setId(googleAccount.id);
        await MySharedPreferences.setPhotoUrl(googleAccount.photoUrl!);
        await MySharedPreferences.setDisplayName(googleAccount.displayName!);

        getDataFromSharedPreference();

        setState(() {
          isLoggedIn = true;
          isLoading = false;
          isAdmin = true;
        });

        Get.snackbar("Sign in successful", "Welcome back",
            snackPosition: SnackPosition.BOTTOM);
      }
    }).catchError((e) {
      Get.snackbar("Something went wrong", "Please try again",
          snackPosition: SnackPosition.BOTTOM);
      setState(() {
        isLoading = false;
      });
    });
  }

  getAdminValue() {
    firebaseFirestore
        .collection('users')
        .doc(googleSignIn.currentUser!.id)
        .get()
        .then((value) {
      bool data = value.data()!['isAdmin'];

      if (data == true) {
        setState(() async {
          isAdmin = true;
          await MySharedPreferences.setIsAdmin(true);
        });
      } else if (data == false || data == null) {
        setState(() async {
          isAdmin = false;
          await MySharedPreferences.setIsAdmin(false);
        });
      }
    });
  }

//To sign out
  signOut() async {
    setState(() {
      isLoading = true;
    });

    await googleSignIn.signOut().then((value) async {
      setState(() {
        isLoading = false;
        isLoggedIn = false;
        isAdmin = false;
      });

      Get.snackbar("You Signed out successfully", "",
          snackPosition: SnackPosition.BOTTOM);
      await MySharedPreferences.setIsAdmin(false);
    }).catchError((e) {
      Get.snackbar("Something went wrong", "Try again",
          snackPosition: SnackPosition.BOTTOM);
    });
  }

//This runs when someone just opens the app
//It is called in init state
  signInSlently() {
    googleSignIn.signInSilently(suppressErrors: false).then(
      (googleAccount) {
        getAdminValue();
        setState(() {
          isLoggedIn = true;
        });
      },
    );
  }

  getDataFromSharedPreference() async {
    String? initialPhotoUrl = await MySharedPreferences().getPhotoUrl();
//Checking if photoUrl from sharedpreference is null
    if (initialPhotoUrl == null) {
      myPhotoUrl = '';
    } else {
      myPhotoUrl = initialPhotoUrl;
    }

    String? initialName = await MySharedPreferences().getDisplayName();
//Checking if name from sharedpreference is null

    if (initialName == null) {
      myName = '';
    } else {
      myName = initialName;
    }

    bool? initialIsAdmin = await MySharedPreferences().getIsAdmin();
//Checking if admin status from sharedpreference is null

    if (initialIsAdmin == null) {
      isAdmin = false;
    } else {
      isAdmin = initialIsAdmin;
    }
  }

//To toggle theme
  themeToggle(context, provider) {
    return showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return SimpleDialog(
              contentPadding: EdgeInsets.only(left: 10.w, bottom: 20.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.8.sp),
                ),
              ),
              title: const Text(
                'Change Theme',
                textAlign: TextAlign.center,
              ),
              children: [
                Row(children: [
                  Checkbox(
                      value: provider.isLightMode,
                      onChanged: (bool? value) {
                        Navigator.pop(context);
                        setState(() {
                          provider.toogleLightTheme(value!);
                        });
                      }),
                  Text(
                    'Light',
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ]),
                Row(children: [
                  Checkbox(
                      value: provider.isDarkMode,
                      onChanged: (bool? value) {
                        Navigator.pop(context);
                        setState(() {
                          provider.toogleDarkTheme(value!);
                        });
                      }),
                  Text(
                    'Dark',
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ]),
              ],
            );
          });
        });
  }

  //Main Screen

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgress()
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              leading: Builder(builder: (context) {
                //Drawer Menu icon
                return GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Icon(
                      Icons.menu,
                      size: 25.2.sp,
                      color: Theme.of(context).cardColor,
                    ),
                  ),
                );
              }),
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                myName: myName!,
                                myPhotoUrl: myPhotoUrl!,
                                isAdmin: isAdmin!,
                                isLoggedIn: isLoggedIn,
                              ),
                            ));
                      },

                      //Rounded profile icon at the top right
                      child: isLoggedIn
                          ? CircleAvatar(
                              foregroundImage:
                                  CachedNetworkImageProvider(myPhotoUrl!),
                            )
                          : const CircleAvatar(
                              backgroundImage: AssetImage('images/blank.png'),
                            )),
                ),
              ],
            ),

            //Drawer
            drawer: Drawer(
              child: Column(
                children: [
                  SizedBox(
                    height: 30.h,
                  ),

                  //1st item
                  DrawerHeader(
                    child: SizedBox(
                      height: 140.h,
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset('images/news.png'),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),

                  // 2nd item
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              isAdmin: isAdmin!,
                              myName: myName!,
                              myPhotoUrl: myPhotoUrl!,
                              isLoggedIn: isLoggedIn,
                            ),
                          ));
                    },
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),

                  //Light and dark theme
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      final provider =
                          Provider.of<ThemeProvider>(context, listen: false);
                      themeToggle(context, provider);
                    },
                    child: Text(
                      'Light/Dark mode',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),

                  //SignIn and SignOut
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);

                      isLoggedIn ? signOut() : signIn();
                    },
                    child: Text(
                      isLoggedIn ? 'Sign out' : 'Sign In',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),

                  //That last arrow at the bottom
                  Material(
                    borderRadius: BorderRadius.circular(500),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(500),
                      splashColor: Colors.black45,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        radius: 16.8.sp,
                        backgroundColor: Colors.black,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            //The body of the screen
            body: NewsHome(isLoggedin: isLoggedIn, isAdmin: isAdmin!),
          );
  }
}

class CircularProgress extends StatelessWidget {
  const CircularProgress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(
      children: [
       const SizedBox(
          width: 130,
          height: 130,
          child:  CircularProgressIndicator(
            backgroundColor: Color(0xFFE3319D),
            valueColor: AlwaysStoppedAnimation(Colors.lightBlue),
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: 130,
          height: 130,
          child: Text(
            'Please wait...',
            style: TextStyle(
              decoration: TextDecoration.overline,
              decorationThickness: 0.4,
              fontSize: 15.1.sp,
              fontFamily: 'Castoro',
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue,
            ),
          ),
        ),
      ],
    ));
  }
}
