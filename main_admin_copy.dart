// lib/main_admin.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import 'shared/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: SharedFirebase.options);
  } catch (e) {
    debugPrint("Firebase Init Warning: $e");
  }

  runApp(const SudarXAdminApp());
}

class SudarXAdminApp extends StatelessWidget {
  const SudarXAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SudarX Console',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF09090D),
        primaryColor: const Color(0xFFE50914),
      ),
      home: const AdminAuthWrapper(),
    );
  }
}

class AdminAuthWrapper extends StatefulWidget {
  const AdminAuthWrapper({super.key});

  @override
  State<AdminAuthWrapper> createState() => _AdminAuthWrapperState();
}

class _AdminAuthWrapperState extends State<AdminAuthWrapper> {
  User? _authenticatedUser;
  bool _isCheckingAuth = true;
  bool _isAuthorizedAdmin = false;

  final List<String> _approvedAdmins = [
    'admin@sudarx.com',
    'biyas.123kc@gmail.com',
  ];

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && _approvedAdmins.contains(user.email)) {
        setState(() {
          _authenticatedUser = user;
          _isAuthorizedAdmin = true;
          _isCheckingAuth = false;
        });
      } else {
        setState(() {
          _authenticatedUser = null;
          _isAuthorizedAdmin = false;
          _isCheckingAuth = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE50914)),
        ),
      );
    }
    if (_authenticatedUser != null && _isAuthorizedAdmin) {
      return const AdminDashboardDeck();
    }
    return const AdminLoginGate();
  }
}

class AdminLoginGate extends StatefulWidget {
  const AdminLoginGate({super.key});

  @override
  State<AdminLoginGate> createState() => _AdminLoginGateState();
}

class _AdminLoginGateState extends State<AdminLoginGate> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = "";

  Future<void> _handleAdminLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your administrative credentials.";
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "Authentication failed.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07070A),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SudarX',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE50914),
                  letterSpacing: -1,
                ),
              ),
              const Text(
                'DISTRIBUTOR CONTROL CENTER',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const Text(
                "Admin Email",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "admin@sudarx.com",
                  hintStyle: const TextStyle(
                    color: Colors.white24,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Secure Password",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "••••••••",
                  hintStyle: const TextStyle(
                    color: Colors.white24,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleAdminLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Access Dashboard",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminDashboardDeck extends StatefulWidget {
  const AdminDashboardDeck({super.key});

  @override
  State<AdminDashboardDeck> createState() => _AdminDashboardDeckState();
}

class _AdminDashboardDeckState extends State<AdminDashboardDeck> {
  String _activeAdminTab = "Content Ingestion";

  // Core Metadata Controllers
  String? _editingDocId;
  bool _isEditing = false;
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _streamController = TextEditingController();
  final _durationController = TextEditingController();
  final _yearController = TextEditingController();
  final _genreController = TextEditingController();

  // ADVANCED: Granular Metadata Controllers
  final _directorController = TextEditingController();
  final _castController = TextEditingController();
  final _studioController = TextEditingController();

  // ADVANCED: Release Scheduling
  DateTime? _scheduledReleaseDate;

  // Video Upload Tracking States
  String _uploadedMp4Url = "";
  bool _isVideoUploading = false;
  double _videoUploadProgress = 0.0;

  final _heroTitleController = TextEditingController();
  final _heroTaglineController = TextEditingController();
  final _heroNetworkTagController = TextEditingController();
  final _heroStreamUrlController = TextEditingController();

  String _uploadedMovieImageUrl = "";
  String _uploadedHeroImageUrl = "";
  bool _isStreamUrlValid = false;
  bool _isHeroUrlValid = false;
  String _targetRowCollection = "trending";
  bool _isUploading = false;
  bool _isHeroUploading = false;
  bool _isFilePicking = false;

  final List<String> _shelves = [
    'trending',
    'originals',
    'movies',
    'hero_banners',
  ];

  @override
  void initState() {
    super.initState();
    _streamController.addListener(_onStreamUrlChanged);
    _heroStreamUrlController.addListener(_onHeroStreamUrlChanged);
  }

  @override
  void dispose() {
    _streamController.removeListener(_onStreamUrlChanged);
    _heroStreamUrlController.removeListener(_onHeroStreamUrlChanged);
    _titleController.dispose();
    _subtitleController.dispose();
    _streamController.dispose();
    _durationController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _directorController.dispose();
    _castController.dispose();
    _studioController.dispose();
    _heroTitleController.dispose();
    _heroTaglineController.dispose();
    _heroNetworkTagController.dispose();
    _heroStreamUrlController.dispose();
    super.dispose();
  }

  void _onStreamUrlChanged() {
    // If we have a direct MP4 upload, consider it valid automatically
    if (_uploadedMp4Url.isNotEmpty &&
        _streamController.text == _uploadedMp4Url) {
      setState(() => _isStreamUrlValid = true);
      return;
    }
    String currentText = _streamController.text.trim();
    _validateAndExtractUrl(currentText, isHero: false);
  }

  void _onHeroStreamUrlChanged() {
    String currentText = _heroStreamUrlController.text.trim();
    _validateAndExtractUrl(currentText, isHero: true);
  }

  void _validateAndExtractUrl(String url, {required bool isHero}) {
    if (url.isEmpty) {
      setState(() {
        isHero ? _isHeroUrlValid = false : _isStreamUrlValid = false;
      });
      return;
    }
    RegExp regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|shorts\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
    );
    Match? match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 2) {
      String? videoId = match.group(2);
      if (videoId != null && videoId.length == 11) {
        setState(() {
          String highResArtwork =
              "https://img.youtube.com/vi/$videoId/maxresdefault.jpg";
          if (isHero) {
            _isHeroUrlValid = true;
            _uploadedHeroImageUrl = highResArtwork;
          } else {
            _isStreamUrlValid = true;
            _uploadedMovieImageUrl = highResArtwork;
          }
        });
        return;
      }
    }
    setState(() {
      isHero ? _isHeroUrlValid = false : _isStreamUrlValid = false;
    });
  }

  Future<void> _pickScheduleDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE50914),
              onPrimary: Colors.white,
              surface: Color(0xFF14141F),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _scheduledReleaseDate = picked;
      });
    }
  }

  // --- NEW: DIRECT MP4 UPLOAD LOGIC ---
  Future<void> _uploadDirectMp4Video() async {
    setState(() {
      _isVideoUploading = true;
      _videoUploadProgress = 0.0;
    });

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        Uint8List? fileBytes = file.bytes;

        if (fileBytes == null || fileBytes.isEmpty) {
          throw Exception("File reading failed. Try running on Chrome.");
        }

        String fileName =
            "${DateTime.now().millisecondsSinceEpoch}_${file.name}";
        Reference storageRef = FirebaseStorage.instance.ref().child(
          'videos/$fileName',
        );

        SettableMetadata metadata = SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {
            'origin': 'SudarX Admin Console',
            'cache_control': 'public,max-age=31536000',
          },
        );

        UploadTask uploadTask = storageRef.putData(fileBytes, metadata);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          setState(() {
            _videoUploadProgress = progress;
          });
        });

        TaskSnapshot completedSnapshot = await uploadTask;
        String downloadUrl = await completedSnapshot.ref.getDownloadURL();

        setState(() {
          _uploadedMp4Url = downloadUrl;
          _streamController.text =
              downloadUrl; // Automatically populates the stream URL field
          _isStreamUrlValid = true; // Bypasses YouTube validation check
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video uploaded successfully to Storage!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video Upload Failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isVideoUploading = false;
      });
    }
  }

  Future<String?> _uploadCoverToStorage(String destinationFolder) async {
    setState(() => _isFilePicking = true);
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: kIsWeb,
      );
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        Uint8List? fileBytes = file.bytes;
        if (fileBytes == null || fileBytes.isEmpty)
          throw Exception("Browser sandbox denied array mapping.");

        String fileName =
            "${DateTime.now().millisecondsSinceEpoch}_${file.name}";
        Reference storageRef = FirebaseStorage.instance.ref().child(
          '$destinationFolder/$fileName',
        );

        // ADVANCED: CDN Optimizer Flags injected into metadata
        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/${file.extension ?? "jpeg"}',
          customMetadata: {
            'origin': 'SudarX Web Console',
            'auto_compress_webp': 'true',
            'cache_control': 'public,max-age=31536000',
          },
        );

        UploadTask uploadTask = storageRef.putData(fileBytes, metadata);
        TaskSnapshot snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Storage Engine Blocked: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isFilePicking = false);
    }
    return null;
  }

  void _pushMovieToDatabase() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deployment Halted: Please supply a title entry.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    setState(() => _isUploading = true);

    // ADVANCED: Enhanced Metadata Map
    final data = {
      'title': _titleController.text.trim(),
      'subtitle': _subtitleController.text.trim().isEmpty
          ? 'Premium Feature'
          : _subtitleController.text.trim(),
      'stream_url': _streamController.text.trim(),
      'image_url': _uploadedMovieImageUrl.isEmpty
          ? "https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=500"
          : _uploadedMovieImageUrl,
      'duration': _durationController.text.trim().isEmpty
          ? 'N/A'
          : _durationController.text.trim(),
      'year': _yearController.text.trim().isEmpty
          ? '2026'
          : _yearController.text.trim(),
      'genre': _genreController.text.trim().isEmpty
          ? 'General'
          : _genreController.text.trim(),

      // Granular Attributes
      'director': _directorController.text.trim(),
      'cast': _castController.text.trim(),
      'studio': _studioController.text.trim(),

      // Release Logic
      'is_published': _scheduledReleaseDate == null,
      'release_date': _scheduledReleaseDate != null
          ? Timestamp.fromDate(_scheduledReleaseDate!)
          : FieldValue.serverTimestamp(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      if (_isEditing && _editingDocId != null) {
        await FirebaseFirestore.instance
            .collection(_targetRowCollection)
            .doc(_editingDocId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Success: Catalog Document Updated!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await FirebaseFirestore.instance
            .collection(_targetRowCollection)
            .add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _scheduledReleaseDate == null
                  ? 'Success: Content live!'
                  : 'Success: Release Queued in Temporal Engine!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      _resetIngestionForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database rejection payload: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _resetIngestionForm() {
    _titleController.clear();
    _subtitleController.clear();
    _streamController.clear();
    _durationController.clear();
    _yearController.clear();
    _genreController.clear();
    _directorController.clear();
    _castController.clear();
    _studioController.clear();
    setState(() {
      _isEditing = false;
      _editingDocId = null;
      _uploadedMovieImageUrl = "";
      _uploadedMp4Url = "";
      _videoUploadProgress = 0.0;
      _isStreamUrlValid = false;
      _scheduledReleaseDate = null;
    });
  }

  void _pushHeroBannerToDatabase() async {
    if (_heroTitleController.text.trim().isEmpty) return;
    setState(() => _isHeroUploading = true);
    try {
      await FirebaseFirestore.instance.collection('hero_banners').add({
        'title': _heroTitleController.text.trim(),
        'tagline': _heroTaglineController.text.trim().isEmpty
            ? 'Now Streaming'
            : _heroTaglineController.text.trim(),
        'network_tag': _heroNetworkTagController.text.trim().isEmpty
            ? "EXCLUSIVE"
            : _heroNetworkTagController.text.trim().toUpperCase(),
        'stream_url': _heroStreamUrlController.text.trim(),
        'image_url': _uploadedHeroImageUrl.isEmpty
            ? "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200"
            : _uploadedHeroImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _heroTitleController.clear();
      _heroTaglineController.clear();
      _heroNetworkTagController.clear();
      _heroStreamUrlController.clear();
      setState(() {
        _uploadedHeroImageUrl = "";
        _isHeroUrlValid = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Success: Billboard live!'),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hero sync error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isHeroUploading = false);
    }
  }

  Future<void> _deleteMovieFromDatabase(String collection, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .delete();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 300,
            color: const Color(0xFF0E0E13),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SudarX',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE50914),
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  'ADMIN CONSOLE',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "CORE OPTIONS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white30,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSidebarButton(
                  Icons.cloud_upload_rounded,
                  "Content Ingestion",
                ),
                _buildSidebarButton(
                  Icons.movie_filter_outlined,
                  "Catalog Manager",
                ),
                _buildSidebarButton(
                  Icons.insert_chart_outlined_rounded,
                  "Analytics Data",
                ),
                _buildSidebarButton(Icons.people_outline, "User Management"),
                const Spacer(),
                const Divider(color: Colors.white10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_circle, color: Colors.grey),
                  title: const Text(
                    "Authorized Admin",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Sign Out",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFE50914),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => FirebaseAuth.instance.signOut(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(56.0),
              child: _buildSelectedWorkspaceBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarButton(IconData icon, String tabName) {
    bool isActive = _activeAdminTab == tabName;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFFE50914) : Colors.white60,
        ),
        title: Text(
          tabName,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white60,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isActive,
        selectedTileColor: Colors.white.withOpacity(0.05),
        onTap: () => setState(() => _activeAdminTab = tabName),
      ),
    );
  }

  Widget _buildSelectedWorkspaceBody() {
    switch (_activeAdminTab) {
      case "Catalog Manager":
        return _buildCatalogManagerWorkspaceView();
      case "Content Ingestion":
      default:
        return _buildIngestionWorkspaceView();
    }
  }

  Widget _buildIngestionWorkspaceView() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? "Modify Catalog Item Meta"
                      : "Ingest New Media Title",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  _isEditing
                      ? "Updating document context ID: $_editingDocId directly."
                      : "Broadcast new titles directly into your storefront rows.",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // ROW 1: Source
                _buildFormInputField(
                  "Video Stream Deployment Destination URL (YouTube Links Auto-Generate Thumbnails)",
                  _streamController,
                  "https://www.youtube.com/watch?v=...",
                  isValidatedField: true,
                  isValid: _isStreamUrlValid,
                ),
                const SizedBox(height: 12),

                // MP4 UPLOAD BUTTON & PROGRESS
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _uploadedMp4Url.isNotEmpty
                            ? Colors.green.shade800
                            : const Color(0xFF1C1C24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white10),
                        ),
                      ),
                      icon: _isVideoUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.video_file_rounded,
                              color: Colors.white70,
                            ),
                      label: Text(
                        _uploadedMp4Url.isNotEmpty
                            ? "MP4 Uploaded!"
                            : "Or Upload Direct MP4 File",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: _isVideoUploading
                          ? null
                          : _uploadDirectMp4Video,
                    ),
                    if (_isVideoUploading) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _videoUploadProgress,
                              color: const Color(0xFFE50914),
                              backgroundColor: Colors.white10,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Uploading: ${(_videoUploadProgress * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // ROW 2: Primary Meta
                Row(
                  children: [
                    Expanded(
                      child: _buildFormInputField(
                        "Movie Title",
                        _titleController,
                        "e.g., Chori: The Battle of Life",
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildFormInputField(
                        "Brief Description / Tagline",
                        _subtitleController,
                        "e.g., A profound journey",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ROW 3: Secondary Meta
                Row(
                  children: [
                    Expanded(
                      child: _buildFormInputField(
                        "Runtime Duration",
                        _durationController,
                        "e.g., 2h 15m",
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildFormInputField(
                        "Release Year",
                        _yearController,
                        "e.g., 2026",
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildFormInputField(
                        "Genre Track Tag",
                        _genreController,
                        "e.g., Rap / Hip-Hop",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ADVANCED ROW 4: Creator Attribution Matrix
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                const Text(
                  "Creator & Attribution Metadata",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormInputField(
                        "Director",
                        _directorController,
                        "e.g., Bachan Karki",
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildFormInputField(
                        "Primary Cast",
                        _castController,
                        "e.g., Actor A, Actor B",
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildFormInputField(
                        "Production Studio",
                        _studioController,
                        "e.g., BRR Technology Solutions",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ADVANCED ROW 5: Temporal Scheduling & Images
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Cover Artwork Override (Optional)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C1C24),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Colors.white10),
                              ),
                            ),
                            icon: _isFilePicking
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.image_search_rounded,
                                    color: Colors.white70,
                                  ),
                            label: const Text(
                              "Select Custom Cover Image",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: _isFilePicking
                                ? null
                                : () async {
                                    String? url = await _uploadCoverToStorage(
                                      'posters',
                                    );
                                    if (url != null)
                                      setState(
                                        () => _uploadedMovieImageUrl = url,
                                      );
                                  },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Release Scheduling Engine",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _scheduledReleaseDate == null
                                  ? const Color(0xFF1C1C24)
                                  : Colors.indigo.shade800,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Colors.white10),
                              ),
                            ),
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white70,
                            ),
                            label: Text(
                              _scheduledReleaseDate == null
                                  ? "Publish Immediately"
                                  : "Queued: ${DateFormat('MMM dd, yyyy').format(_scheduledReleaseDate!)}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            onPressed: _pickScheduleDate,
                          ),
                        ],
                      ),
                    ),
                    if (_scheduledReleaseDate != null)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () =>
                            setState(() => _scheduledReleaseDate = null),
                      ),
                  ],
                ),

                const SizedBox(height: 32),
                if (!_isEditing) ...[
                  const Text(
                    "Select Storefront Shelf Section Placement",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildRowSegmentSelector("trending", "Trending Row"),
                      const SizedBox(width: 12),
                      _buildRowSegmentSelector("originals", "SudarX Originals"),
                      const SizedBox(width: 12),
                      _buildRowSegmentSelector("movies", "Blockbusters Block"),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  children: [
                    SizedBox(
                      width: 240,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: _isUploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.bolt, color: Colors.white),
                        label: Text(
                          _isUploading
                              ? "Deploying Data..."
                              : (_isEditing
                                    ? "Save Changes"
                                    : "Push to Distribution"),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: _isUploading ? null : _pushMovieToDatabase,
                      ),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: _resetIngestionForm,
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.redAccent,
                        ),
                        label: const Text(
                          "Abort Edit",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),

          // SIDEBAR MONITOR
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF101016),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "LIVE ASSET MONITOR",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 320,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                      image: _uploadedMovieImageUrl.isNotEmpty
                          ? DecorationImage(
                              image: Image.network(
                                _uploadedMovieImageUrl,
                              ).image,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _uploadedMovieImageUrl.isEmpty
                        ? const Center(
                            child: Text(
                              "Awaiting Data...",
                              style: TextStyle(
                                color: Colors.white12,
                                fontSize: 11,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 24),
                  if (_scheduledReleaseDate != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.indigo.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            color: Colors.indigoAccent,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Asset is Queued in Temporal Pipeline. Will automatically publish to clients on scheduled date.",
                              style: TextStyle(
                                color: Colors.indigoAccent,
                                fontSize: 11,
                              ),
                            ),
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
    );
  }

  Widget _buildFormInputField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isValidatedField = false,
    bool isValid = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF14141F),
            suffixIcon: isValidatedField
                ? Icon(
                    isValid ? Icons.check_circle : Icons.error_outline,
                    color: isValid ? Colors.greenAccent : Colors.white24,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRowSegmentSelector(String collection, String description) {
    bool isSelected = _targetRowCollection == collection;
    return ChoiceChip(
      label: Text(description),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _targetRowCollection = collection);
      },
    );
  }

  Widget _buildCatalogManagerWorkspaceView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Storefront Catalog Manager",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const Text(
          "Review and manage active streaming documents across your server clusters live.",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
            itemCount: _shelves.length,
            itemBuilder: (context, shelfIdx) {
              String currentShelf = _shelves[shelfIdx];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Text(
                      "${currentShelf.toUpperCase()} CHANNEL DISTRIBUTOR ROW",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: currentShelf == 'hero_banners'
                            ? Colors.teal
                            : const Color(0xFFE50914),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111116),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(currentShelf)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: LinearProgressIndicator(
                              color: Color(0xFFE50914),
                            ),
                          );
                        var docs = snapshot.data!.docs;
                        if (docs.isEmpty)
                          return const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              "Shelf is perfectly empty.",
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          );

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: Colors.white10, height: 1),
                          itemBuilder: (context, index) {
                            var itemData =
                                docs[index].data() as Map<String, dynamic>;
                            String docId = docs[index].id;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 50,
                                height: 50,
                                color: Colors.black38,
                                child: Image.network(
                                  itemData['image_url'] ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.movie,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              title: Text(
                                itemData['title'] ?? 'Untitled Production',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                itemData['director'] != null &&
                                        itemData['director']
                                            .toString()
                                            .isNotEmpty
                                    ? "Dir: ${itemData['director']}"
                                    : (itemData['subtitle'] ?? ''),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_note_outlined,
                                      color: Colors.blueAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = true;
                                        _editingDocId = docId;
                                        _targetRowCollection = currentShelf;
                                        _titleController.text =
                                            itemData['title'] ?? '';
                                        _subtitleController.text =
                                            itemData['subtitle'] ?? '';
                                        _streamController.text =
                                            itemData['stream_url'] ?? '';
                                        _durationController.text =
                                            itemData['duration'] ?? '';
                                        _yearController.text =
                                            itemData['year'] ?? '';
                                        _genreController.text =
                                            itemData['genre'] ?? '';
                                        _directorController.text =
                                            itemData['director'] ?? '';
                                        _castController.text =
                                            itemData['cast'] ?? '';
                                        _studioController.text =
                                            itemData['studio'] ?? '';
                                        _uploadedMovieImageUrl =
                                            itemData['image_url'] ?? '';
                                        _activeAdminTab = "Content Ingestion";
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => _deleteMovieFromDatabase(
                                      currentShelf,
                                      docId,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
