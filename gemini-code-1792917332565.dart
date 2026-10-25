// lib/main_client.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';

// --- YOUR CUSTOM FIREBASE & PREMIUM COMPONENTS ---
import 'shared/firebase_config.dart';
import 'controllers/advanced_player_controller.dart';
import 'components/premium_paywall_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await Firebase.initializeApp(options: SharedFirebase.options);
  } catch (e) {
    debugPrint("Firebase Init Warning: $e");
  }

  runApp(const SudarXConsumerApp());
}

/// Recursively sanitizes Firestore data (Timestamps, etc.) so jsonEncode won't crash.
Map<String, dynamic> sanitizeFirestoreData(Map<String, dynamic> data) {
  Map<String, dynamic> sanitized = {};
  data.forEach((key, value) {
    if (value is Timestamp) {
      sanitized[key] = value.toDate().toIso8601String();
    } else if (value is Map<String, dynamic>) {
      sanitized[key] = sanitizeFirestoreData(value);
    } else {
      sanitized[key] = value;
    }
  });
  return sanitized;
}

class SudarXConsumerApp extends StatelessWidget {
  const SudarXConsumerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SudarX Entertainment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF09090C),
        primaryColor: const Color(0xFFE50914),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          surface: Color(0xFF14141F),
        ),
      ),
      home: const SudarXSafeSplashScreen(),
    );
  }
}

// =========================================================
// 0. SAFE SPLASH SCREEN (WITH INTRO VIDEO & SAFE FALLBACK)
// =========================================================
class SudarXSafeSplashScreen extends StatefulWidget {
  const SudarXSafeSplashScreen({super.key});

  @override
  State<SudarXSafeSplashScreen> createState() => _SudarXSafeSplashScreenState();
}

class _SudarXSafeSplashScreenState extends State<SudarXSafeSplashScreen> {
  VideoPlayerController? _introController;
  bool _isVideoInitialized = false;
  bool _hasNavigated = false;
  Timer? _safetyFallbackTimer;

  // =========================================================================
  // INTRO VIDEO CONFIGURATION:
  // 1. For a local file: Put your video at 'assets/videos/intro.mp4', add it
  //    to pubspec.yaml under assets, and keep _useNetworkIntro = false.
  // 2. For a web/Firebase URL: Set _useNetworkIntro = true and paste your URL.
  // =========================================================================
  static const bool _useNetworkIntro = false;
  static const String _localIntroAsset = 'assets/videos/intro.mp4';
  static const String _networkIntroUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';

  @override
  void initState() {
    super.initState();
    _initializeIntroVideo();

    // Safety Fallback: If video fails to load or takes longer than 6 seconds,
    // automatically transition to the app so the user is never stuck.
    _safetyFallbackTimer = Timer(const Duration(seconds: 6), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _initializeIntroVideo() async {
    try {
      if (_useNetworkIntro) {
        _introController = VideoPlayerController.networkUrl(
          Uri.parse(_networkIntroUrl),
        );
      } else {
        _introController = VideoPlayerController.asset(_localIntroAsset);
      }

      await _introController!.initialize();

      if (!mounted) return;

      setState(() {
        _isVideoInitialized = true;
      });

      _introController!.setLooping(false);
      await _introController!.play();

      // Listen for when the intro video finishes playing
      _introController!.addListener(_videoListener);
    } catch (e) {
      debugPrint(
        "Intro Video Warning: Could not load intro video ($e). "
        "Falling back to standard splash screen.",
      );
      // If asset is missing or fails, wait 2.5 seconds showing the logo, then proceed
      Future.delayed(const Duration(milliseconds: 2500), _navigateToNextScreen);
    }
  }

  void _videoListener() {
    if (_introController == null || !mounted) return;
    final value = _introController!.value;
    if (value.isInitialized &&
        !value.isPlaying &&
        value.position >= value.duration) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _safetyFallbackTimer?.cancel();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ConsumerAuthCheck(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _safetyFallbackTimer?.cancel();
    _introController?.removeListener(_videoListener);
    _introController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Show Intro Video if loaded, otherwise show fallback logo
          if (_isVideoInitialized && _introController != null)
            Center(
              child: AspectRatio(
                aspectRatio: _introController!.value.aspectRatio,
                child: VideoPlayer(_introController!),
              ),
            )
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "SudarX",
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE50914),
                      letterSpacing: -2,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: Color(0xFFE50914)),
                ],
              ),
            ),

          // 2. Skip Intro Button (if video is playing)
          if (_isVideoInitialized)
            Positioned(
              bottom: 40,
              right: 24,
              child: SafeArea(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: _navigateToNextScreen,
                  child: const Text(
                    "Skip Intro",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- AUTHENTICATION ROUTER ---
class ConsumerAuthCheck extends StatelessWidget {
  const ConsumerAuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            ),
          );
        }
        if (snapshot.hasData) {
          return const ConsumerMainShell();
        }
        return const ConsumerLoginScreen();
      },
    );
  }
}

// --- LOGIN / SIGN UP SCREEN ---
class ConsumerLoginScreen extends StatefulWidget {
  const ConsumerLoginScreen({super.key});

  @override
  State<ConsumerLoginScreen> createState() => _ConsumerLoginScreenState();
}

class _ConsumerLoginScreenState extends State<ConsumerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginTab = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isLoginTab) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        UserCredential cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        if (cred.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(cred.user!.uid)
              .set({
                'email': _emailController.text.trim(),
                'subscription_tier': 'Basic',
                'created_at': FieldValue.serverTimestamp(),
              });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Auth Failed: ${e.toString().split(']').last.trim()}",
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email to reset password."),
        ),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset link sent to your email!"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString().split(']').last.trim()}"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1A0000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "SudarX",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE50914),
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isLoginTab = true),
                        child: Column(
                          children: [
                            Text(
                              "SIGN IN",
                              style: TextStyle(
                                color: _isLoginTab
                                    ? Colors.white
                                    : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_isLoginTab)
                              Container(
                                height: 2,
                                width: 40,
                                color: const Color(0xFFE50914),
                              )
                            else
                              const SizedBox(height: 2),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTap: () => setState(() => _isLoginTab = false),
                        child: Column(
                          children: [
                            Text(
                              "SIGN UP",
                              style: TextStyle(
                                color: !_isLoginTab
                                    ? Colors.white
                                    : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (!_isLoginTab)
                              Container(
                                height: 2,
                                width: 40,
                                color: const Color(0xFFE50914),
                              )
                            else
                              const SizedBox(height: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email address",
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _authenticate,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isLoginTab ? "Sign In" : "Create Account",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoginTab)
                    TextButton(
                      onPressed: _resetPassword,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- MAIN NAVIGATION SHELL ---
class ConsumerMainShell extends StatefulWidget {
  const ConsumerMainShell({super.key});

  @override
  State<ConsumerMainShell> createState() => _ConsumerMainShellState();
}

class _ConsumerMainShellState extends State<ConsumerMainShell> {
  int _currentIndex = 0;
  final GlobalKey<_ConsumerDownloadsScreenState> _downloadsKey =
      GlobalKey<_ConsumerDownloadsScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ConsumerHomeScreen(),
      const ConsumerSearchScreen(),
      ConsumerDownloadsScreen(key: _downloadsKey),
      const ConsumerProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF09090C),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Refresh downloads list automatically when switching to the Downloads tab
          if (index == 2) {
            _downloadsKey.currentState?.loadDownloads();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.saved_search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_for_offline_outlined),
            activeIcon: Icon(Icons.download),
            label: "Downloads",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

// --- 1. HOME SCREEN ---
class ConsumerHomeScreen extends StatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  State<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends State<ConsumerHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _launchCastSettings() async {
    try {
      await launchUrl(
        Uri.parse("intent://#Intent;action=android.settings.CAST_SETTINGS;end"),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Searching for wireless displays...")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            double offset = _scrollController.hasClients
                ? _scrollController.offset
                : 0.0;
            return AppBar(
              backgroundColor: Colors.black.withValues(
                alpha: (offset / 350).clamp(0.0, 1.0),
              ),
              elevation: 0,
              title: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "SudarX\n",
                      style: TextStyle(
                        color: Color(0xFFE50914),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: "ENTERTAINMENT",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.cast),
                  onPressed: _launchCastSettings,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConsumerProfileScreen(),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBillboard(),
            const SizedBox(height: 20),
            _buildHorizontalStorefrontShelf(
              'trending',
              'Trending Now',
              isPremiumRow: true,
            ),
            const SizedBox(height: 10),
            _buildHorizontalStorefrontShelf(
              'originals',
              'SudarX Originals',
              isPremiumRow: false,
            ),
            const SizedBox(height: 10),
            _buildHorizontalStorefrontShelf(
              'movies',
              'Blockbuster Movies',
              isPremiumRow: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBillboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hero_banners')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            height: 550,
            color: const Color(0xFF101016),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            ),
          );
        }

        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        String coverUrl =
            data['image_url'] ??
            "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200";
        String tag = data['network_tag'] ?? "EXCLUSIVE";

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 550,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(coverUrl),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Container(
              height: 550,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xFF09090C),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_movies,
                        color: Color(0xFFE50914),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tag.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      data['title'] ?? "Untitled",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow, size: 28),
                        label: const Text(
                          "Inspect Title",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ContentDetailsScreen(
                              movieData: data,
                              isPremiumRow: true,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHorizontalStorefrontShelf(
    String collection,
    String shelfTitle, {
    required bool isPremiumRow,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                shelfTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              if (isPremiumRow) ...[
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.amber, size: 16),
              ],
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(collection)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Data Sync Error",
                    style: TextStyle(color: Colors.white30),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE50914)),
                );
              }

              var docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Titles arriving soon...",
                    style: TextStyle(color: Colors.white30),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var item = docs[index].data() as Map<String, dynamic>;
                  String coverUrl = item['image_url'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ContentDetailsScreen(
                          movieData: item,
                          isPremiumRow: isPremiumRow,
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: coverUrl.isNotEmpty
                            ? Image.network(
                                coverUrl,
                                fit: BoxFit.cover,
                                cacheWidth: 250,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.broken_image,
                                      color: Colors.white30,
                                    ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.movie_creation_outlined,
                                  color: Colors.white24,
                                  size: 30,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- 2. SEARCH SCREEN ---
class ConsumerSearchScreen extends StatefulWidget {
  const ConsumerSearchScreen({super.key});

  @override
  State<ConsumerSearchScreen> createState() => _ConsumerSearchScreenState();
}

class _ConsumerSearchScreenState extends State<ConsumerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090C),
        elevation: 0,
        title: TextField(
          controller: _searchController,
          onChanged: (value) =>
              setState(() => _searchQuery = value.toLowerCase()),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search for a movie, show, or genre...",
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white10,
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    },
                  )
                : null,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('movies').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            );
          }

          var docs = snapshot.data!.docs;
          var filteredDocs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var title = (data['title'] ?? '').toString().toLowerCase();
            var genre = (data['genre'] ?? '').toString().toLowerCase();
            return title.contains(_searchQuery) || genre.contains(_searchQuery);
          }).toList();

          if (filteredDocs.isEmpty && _searchQuery.isNotEmpty) {
            return const Center(
              child: Text(
                "No titles matched your search.",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _searchQuery.isEmpty ? "Top Suggestions" : "Results",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2 / 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var data =
                          filteredDocs[index].data() as Map<String, dynamic>;
                      String imgUrl = data['image_url'] ?? '';
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ContentDetailsScreen(
                              movieData: data,
                              isPremiumRow: false,
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: imgUrl.isNotEmpty
                              ? Image.network(
                                  imgUrl,
                                  fit: BoxFit.cover,
                                  cacheWidth: 350,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.white10,
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.white24,
                                        ),
                                      ),
                                )
                              : Container(
                                  color: Colors.white10,
                                  child: const Icon(
                                    Icons.movie,
                                    color: Colors.white24,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- 3. DOWNLOADS SCREEN ---
class ConsumerDownloadsScreen extends StatefulWidget {
  const ConsumerDownloadsScreen({super.key});

  @override
  State<ConsumerDownloadsScreen> createState() =>
      _ConsumerDownloadsScreenState();
}

class _ConsumerDownloadsScreenState extends State<ConsumerDownloadsScreen> {
  List<Map<String, dynamic>> _downloadedMovies = [];

  @override
  void initState() {
    super.initState();
    loadDownloads();
  }

  Future<void> loadDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('downloads_data') ?? [];
    if (mounted) {
      setState(() {
        _downloadedMovies = list
            .map((item) => jsonDecode(item) as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _removeDownload(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('downloads_data') ?? [];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await prefs.setStringList('downloads_data', list);
      loadDownloads();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Downloads",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF09090C),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: loadDownloads,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFE50914),
        onRefresh: loadDownloads,
        child: _downloadedMovies.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          color: Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.download_rounded,
                          size: 80,
                          color: Colors.white24,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "Never be without SudarX",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Download shows and movies so you'll never be without something to watch — even when you're offline.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _downloadedMovies.length,
                itemBuilder: (context, index) {
                  final movie = _downloadedMovies[index];
                  final imgUrl = movie['image_url'] ?? '';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 60,
                      height: 80,
                      color: Colors.white10,
                      child: imgUrl.isNotEmpty
                          ? Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                              cacheWidth: 150,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.movie,
                                    color: Colors.white24,
                                  ),
                            )
                          : const Icon(Icons.movie, color: Colors.white24),
                    ),
                    title: Text(
                      movie['title'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: const Text(
                      "Downloaded | 1080p HD",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white54,
                      ),
                      onPressed: () => _removeDownload(index),
                    ),
                    onTap: () {
                      String streamUrl = movie['stream_url'] ?? '';
                      if (streamUrl.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SudarXPlayerScreen(
                              videoUrl: streamUrl,
                              title: movie['title'],
                              userTier: 'Premium',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Stream URL missing for this title."),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}

// --- 4. PROFILE SCREEN ---
class ConsumerProfileScreen extends StatelessWidget {
  const ConsumerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Member';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF09090C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user != null)
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String currentTier = 'Basic';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          if (data != null &&
                              data.containsKey('subscription_tier')) {
                            currentTier = data['subscription_tier'];
                          }
                        }

                        Color tierColor = currentTier == 'Premium'
                            ? Colors.amber
                            : (currentTier == 'Pro'
                                  ? Colors.purpleAccent
                                  : Colors.grey);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tierColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: tierColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            "$currentTier Tier",
                            style: TextStyle(
                              color: tierColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildProfileListTile(
              context,
              Icons.check_rounded,
              "My List",
              const MyListScreen(),
            ),
            _buildProfileListTile(
              context,
              Icons.settings,
              "App Settings",
              const AppSettingsScreen(),
            ),
            _buildProfileListTile(
              context,
              Icons.account_box,
              "Account",
              const AccountScreen(),
            ),
            _buildProfileListTile(
              context,
              Icons.help_outline,
              "Help",
              const HelpScreen(),
            ),
            const Divider(color: Colors.white10, height: 40),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              title: const Text(
                "Sign Out",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
              ),
              trailing: const Icon(Icons.exit_to_app, color: Colors.white54),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
            const SizedBox(height: 40),
            const Text(
              "SudarX Entertainment v2.0.0",
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileListTile(
    BuildContext context,
    IconData icon,
    String title,
    Widget destinationPage,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Icon(icon, color: Colors.white70, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white24,
        size: 16,
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destinationPage),
      ),
    );
  }
}

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  List<Map<String, dynamic>> _myListMovies = [];

  @override
  void initState() {
    super.initState();
    _loadMyList();
  }

  Future<void> _loadMyList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('mylist_data') ?? [];
    if (mounted) {
      setState(() {
        _myListMovies = list
            .map((item) => jsonDecode(item) as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _removeFromList(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('mylist_data') ?? [];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await prefs.setStringList('mylist_data', list);
      _loadMyList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF09090C),
        elevation: 0,
      ),
      body: _myListMovies.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 80,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Your list is empty.",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Add shows and movies to your list\nso you can easily find them later.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _myListMovies.length,
              itemBuilder: (context, index) {
                final movie = _myListMovies[index];
                final imgUrl = movie['image_url'] ?? '';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 60,
                    height: 80,
                    color: Colors.white10,
                    child: imgUrl.isNotEmpty
                        ? Image.network(
                            imgUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 150,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.movie, color: Colors.white24),
                          )
                        : const Icon(Icons.movie, color: Colors.white24),
                  ),
                  title: Text(
                    movie['title'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.white54,
                    ),
                    onPressed: () => _removeFromList(index),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ContentDetailsScreen(
                        movieData: movie,
                        isPremiumRow: false,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});
  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _wifiOnly = true;
  bool _smartDownloads = true;
  String _cellularDataUsage = "Automatic";
  String _downloadQuality = "Standard";

  void _showSelectionMenu(
    String title,
    List<String> options,
    String current,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14141F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ...options.map(
              (opt) => ListTile(
                title: Text(
                  opt,
                  style: TextStyle(
                    color: opt == current ? Colors.white : Colors.white70,
                  ),
                ),
                trailing: opt == current
                    ? const Icon(Icons.check, color: Color(0xFFE50914))
                    : null,
                onTap: () {
                  onSelect(opt);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        backgroundColor: const Color(0xFF09090C),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "VIDEO PLAYBACK",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            title: const Text("Cellular Data Usage"),
            subtitle: Text(
              _cellularDataUsage,
              style: const TextStyle(color: Colors.greenAccent),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white24,
            ),
            onTap: () => _showSelectionMenu(
              "Cellular Data",
              ["Automatic", "Wi-Fi Only", "Save Data", "Maximum Data"],
              _cellularDataUsage,
              (v) => setState(() => _cellularDataUsage = v),
            ),
          ),
          const Divider(color: Colors.white10),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "DOWNLOADS",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text("Wi-Fi Only"),
            activeColor: const Color(0xFFE50914),
            value: _wifiOnly,
            onChanged: (val) => setState(() => _wifiOnly = val),
          ),
          SwitchListTile(
            title: const Text("Smart Downloads"),
            subtitle: const Text(
              "Auto-delete finished episodes",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: const Color(0xFFE50914),
            value: _smartDownloads,
            onChanged: (val) => setState(() => _smartDownloads = val),
          ),
          ListTile(
            title: const Text("Download Video Quality"),
            subtitle: Text(
              _downloadQuality,
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white24,
            ),
            onTap: () => _showSelectionMenu(
              "Video Quality",
              ["Standard", "High"],
              _downloadQuality,
              (v) => setState(() => _downloadQuality = v),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        backgroundColor: const Color(0xFF09090C),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.email ?? "User",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () async {
                    if (user?.email != null) {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: user!.email!,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Password reset email sent!"),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    "Change Password",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () async {
                try {
                  await user?.delete();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please sign in again before deleting your account.",
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        backgroundColor: const Color(0xFF09090C),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Find answers to top questions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Card(
            color: Colors.white10,
            child: ExpansionTile(
              title: Text("How do I change my password?"),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Go to Account screen and tap Change Password."),
                ),
              ],
            ),
          ),
          const Card(
            color: Colors.white10,
            child: ExpansionTile(
              title: Text("How can I download titles?"),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Tap the download icon on the movie popup."),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            label: const Text(
              "Email Support",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: () => launchUrl(
              Uri.parse("mailto:support@sudarx.com.au?subject=App%20Support"),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.call_outlined, color: Colors.white),
            label: const Text(
              "Call Us",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: () => launchUrl(Uri.parse("tel:+61200000000")),
          ),
        ],
      ),
    );
  }
}

// --- GATEKEEPER CONTENT DETAILS OVERLAY ---
class ContentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> movieData;
  final bool isPremiumRow;

  const ContentDetailsScreen({
    super.key,
    required this.movieData,
    required this.isPremiumRow,
  });

  Future<void> _addToDownloads(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('downloads_data') ?? [];
    String movieJson = jsonEncode(sanitizeFirestoreData(movieData));
    bool exists = list.any(
      (item) => jsonDecode(item)['title'] == movieData['title'],
    );
    if (!exists) {
      list.add(movieJson);
      await prefs.setStringList('downloads_data', list);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to Downloads List")),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Already in Downloads")));
      }
    }
  }

  Future<void> _addToMyList(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('mylist_data') ?? [];
    String movieJson = jsonEncode(sanitizeFirestoreData(movieData));
    bool exists = list.any(
      (item) => jsonDecode(item)['title'] == movieData['title'],
    );
    if (!exists) {
      list.add(movieJson);
      await prefs.setStringList('mylist_data', list);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Saved to My List!")));
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Already in My List")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = movieData['title'] ?? 'Unknown Title';
    String year = (movieData['year'] ?? '2026').toString();
    String duration = (movieData['duration'] ?? 'N/A').toString();
    String desc =
        movieData['subtitle'] ?? 'No description available for this title.';
    String imgUrl = movieData['image_url'] ?? '';
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF14141F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              height: 220,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (imgUrl.isNotEmpty)
                    Image.network(
                      imgUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      opacity: const AlwaysStoppedAnimation(0.4),
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  const Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        year,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          "HD",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        duration,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (currentUser != null)
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        String userTier = 'Basic';
                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          final data =
                              userSnapshot.data!.data()
                                  as Map<String, dynamic>?;
                          if (data != null &&
                              data.containsKey('subscription_tier')) {
                            userTier = data['subscription_tier'];
                          }
                        }

                        // FIXED LOGIC: Only Premium or VIP can watch Premium Row content
                        bool accessDenied =
                            isPremiumRow &&
                            (userTier != 'Premium' && userTier != 'VIP');

                        if (accessDenied) {
                          return SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              icon: const Icon(
                                Icons.lock_outline,
                                color: Colors.black,
                              ),
                              label: const Text(
                                "Upgrade to Premium to Unlock",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please upgrade your account to Premium to watch this title.",
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }

                        return SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE50914),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Stream Now",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              String streamUrl = movieData['stream_url'] ?? '';
                              if (streamUrl.isNotEmpty) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SudarXPlayerScreen(
                                      videoUrl: streamUrl,
                                      title: title,
                                      userTier: userTier,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Stream URL is not available for this title yet.",
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () => _addToDownloads(context),
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text(
                          "Download",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _addToMyList(context),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "My List",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- FULLSCREEN CINEMATIC PLAYER ---
class SudarXPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final String userTier;

  const SudarXPlayerScreen({
    super.key,
    required this.videoUrl,
    this.title,
    required this.userTier,
  });

  @override
  State<SudarXPlayerScreen> createState() => _SudarXPlayerScreenState();
}

class _SudarXPlayerScreenState extends State<SudarXPlayerScreen> {
  bool _isYouTube = false;
  bool _isPlayerReady = false;
  String _activeSessionId = '';

  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _mp4Controller;
  Timer? _hideControlsTimer;

  bool _showControls = true;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
    ]);

    _checkVideoTypeAndInitialize();
    _registerActiveSession();
  }

  void _checkVideoTypeAndInitialize() {
    String url = widget.videoUrl.toLowerCase();
    _isYouTube = url.contains('youtube.com') || url.contains('youtu.be');

    if (_isYouTube) {
      _initYouTubePlayer();
    } else {
      _initMp4Player();
    }
  }

  void _initYouTubePlayer() {
    String? videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl);
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId ?? '',
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        showVideoAnnotations: false,
        loop: false,
      ),
    );
    setState(() {
      _isPlayerReady = true;
    });
  }

  void _initMp4Player() {
    _mp4Controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _mp4Controller!
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _isPlayerReady = true;
            });
            _mp4Controller!.play();
            _hideControlsWithDelay();
          }
        })
        .catchError((error) {
          debugPrint("MP4 Render Error: $error");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Video playback failed."),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        });

    _mp4Controller!.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _hideControlsWithDelay() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted &&
          _mp4Controller != null &&
          _mp4Controller!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Future<void> _registerActiveSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var doc = await FirebaseFirestore.instance
            .collection('active_sessions')
            .add({
              'email': user.email,
              'title': widget.title ?? 'Unknown Stream',
              'tier': widget.userTier,
              'started_at': FieldValue.serverTimestamp(),
            });
        _activeSessionId = doc.id;
      }
    } catch (e) {
      debugPrint("Session accounting logging skipped.");
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    if (_activeSessionId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('active_sessions')
          .doc(_activeSessionId)
          .delete()
          .catchError((_) {});
    }
    _youtubeController?.close();
    _mp4Controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) return '${duration.inHours}:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14141F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.speed, color: Colors.white),
                title: const Text("Playback Speed"),
                trailing: Text(
                  "${_playbackSpeed}x",
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showSpeedMenu();
                },
              ),
              ListTile(
                leading: const Icon(Icons.high_quality, color: Colors.white),
                title: const Text("Video Quality"),
                trailing: const Text(
                  "Auto (Raw)",
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Quality switching requires HLS (.m3u8) server transcoding. Playing raw MP4 default.",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSpeedMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14141F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Playback Speed",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map(
                (speed) => ListTile(
                  title: Text(
                    "${speed}x",
                    style: TextStyle(
                      color: _playbackSpeed == speed
                          ? const Color(0xFFE50914)
                          : Colors.white,
                    ),
                  ),
                  trailing: _playbackSpeed == speed
                      ? const Icon(Icons.check, color: Color(0xFFE50914))
                      : null,
                  onTap: () {
                    setState(() {
                      _playbackSpeed = speed;
                    });
                    _mp4Controller?.setPlaybackSpeed(speed);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCinematicMp4Player() {
    if (_mp4Controller == null || !_mp4Controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return MouseRegion(
      onHover: (_) {
        setState(() {
          _showControls = true;
          _hideControlsWithDelay();
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
            if (_showControls) _hideControlsWithDelay();
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Layer
            FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _mp4Controller!.value.size.width,
                height: _mp4Controller!.value.size.height,
                child: VideoPlayer(_mp4Controller!),
              ),
            ),

            // Interactive UI Layer
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black87,
                    ],
                    stops: [0.0, 0.2, 0.8, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.title ?? "Now Playing",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.replay_10_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                          onPressed: !_showControls
                              ? null
                              : () {
                                  _mp4Controller!.seekTo(
                                    _mp4Controller!.value.position -
                                        const Duration(seconds: 10),
                                  );
                                },
                        ),
                        const SizedBox(width: 48),
                        GestureDetector(
                          onTap: !_showControls
                              ? null
                              : () {
                                  setState(() {
                                    _mp4Controller!.value.isPlaying
                                        ? _mp4Controller!.pause()
                                        : _mp4Controller!.play();
                                    if (_mp4Controller!.value.isPlaying) {
                                      _hideControlsWithDelay();
                                    }
                                  });
                                },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE50914),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _mp4Controller!.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                        IconButton(
                          icon: const Icon(
                            Icons.forward_10_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                          onPressed: !_showControls
                              ? null
                              : () {
                                  _mp4Controller!.seekTo(
                                    _mp4Controller!.value.position +
                                        const Duration(seconds: 10),
                                  );
                                },
                        ),
                      ],
                    ),

                    // Bottom Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Text(
                            _formatDuration(_mp4Controller!.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: VideoProgressIndicator(
                              _mp4Controller!,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: Color(0xFFE50914),
                                bufferedColor: Colors.white24,
                                backgroundColor: Colors.white10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            _formatDuration(_mp4Controller!.value.duration),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            onPressed: !_showControls
                                ? null
                                : _showSettingsMenu,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PremiumPaywallGate(
        userSubscriptionTier: widget.userTier,
        requiredTiers: const ['Basic', 'Pro', 'Premium', 'VIP'],
        premiumContent: _isPlayerReady
            ? (_isYouTube
                  ? SafeArea(
                      child: Center(
                        child: YoutubePlayer(
                          controller: _youtubeController!,
                          aspectRatio: 16 / 9,
                        ),
                      ),
                    )
                  : _buildCinematicMp4Player())
            : const Center(
                child: CircularProgressIndicator(color: Color(0xFFE50914)),
              ),
      ),
    );
  }
}