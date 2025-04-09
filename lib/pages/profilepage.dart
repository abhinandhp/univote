import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/pages/user/myelections.dart';

final supabase = Supabase.instance.client;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService authService = AuthService();
  bool _isLoading = true;
  Map<String, dynamic> _userProfile = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await getUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    final profile =
        await supabase.from('profiles').select().eq('id', user.id).single();
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 109, 105, 235),
                    Color.fromARGB(255, 102, 98, 210), // PrimaryColor (purple)
                    Color(0xFF837EFF), // SecondaryColor (lavender)
                  ],
                ),
              ),
            ),

            // Top-right soft circle
            Positioned(
              right: -30,
              top: 30,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),

            // Bottom-left soft circle
            Positioned(
              left: -20,
              bottom: 30,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),

            // Top-right 'J' avatar

            // Bottom-left title text
            Positioned(
              left: 20,
              bottom: 20,
              child: Text(
                'My Profile',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // Profile Avatar
                    Padding(
                      padding: const EdgeInsets.only(right: 240),
                      child: Stack(
                        children: [
                          Container(
                            width: 70,
                            height: 75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              child:
                                  _userProfile['avatar_url'] != null
                                      ? Image.network(
                                        _userProfile['avatar_url'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Center(
                                            child: Text(
                                              _userProfile['username']?[0]
                                                      ?.toUpperCase() ??
                                                  'U',
                                              style: GoogleFonts.outfit(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                      : Center(
                                        child: Text(
                                          _userProfile['username']?[0]
                                                  ?.toUpperCase() ??
                                              'U',
                                          style: GoogleFonts.outfit(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 20),
                    // Username
                    Transform.translate(
                      offset: const Offset(-30, -65), // move upward by 6 pixels
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userProfile['username'] ?? 'Username',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: const Color.fromARGB(255, 66, 65, 82),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _userProfile['role'] ?? 'Student',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Personal Information Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 20,
                            left: 20,
                            bottom: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Information',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 66, 65, 82),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildInfoRow(
                                'Username',
                                _userProfile['username'] ?? 'Not set',
                                Icons.person,
                              ),
                              const Divider(height: 30),
                              _buildInfoRow(
                                'Roll Number',
                                _userProfile['rollno'] ?? 'Not set',
                                Icons.numbers,
                              ),
                              const Divider(height: 30),
                              _buildInfoRow(
                                'Joined On',
                                supabase.auth.currentUser?.createdAt != null
                                    ? _formatDate(
                                      supabase.auth.currentUser!.createdAt,
                                    )
                                    : 'Unknown',
                                Icons.calendar_today,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Container(
                      width: 315, // Adjust width as needed
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A5AE0), Color(0xFF8D7BE5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            withNavBar: false,
                            screen: MyElections(),
                          );
                        },
                        child: Text(
                          "My Elections",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Account Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 66, 65, 82),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildInfoRow(
                                'Email',
                                supabase.auth.currentUser?.email ?? 'No email',
                                Icons.email,
                              ),
                              const Divider(height: 30),
                              InkWell(
                                onTap: () async {
                                  try {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Logout Confirmation",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Are you sure you want to logout?",
              style: GoogleFonts.outfit(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.outfit(color: Colors.grey.shade700),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Logout", style: GoogleFonts.outfit()),
              ),
            ],
          );
        },
      );

      if (confirm) {
        await authService.signOut();
      }
    } catch (e) {
      print(e);
    }
                                },
                                child: Text(
                                  'Logout',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
    IconData icon, {
    bool isAction = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isAction
                    ? const Color.fromARGB(255, 244, 67, 54).withOpacity(0.1)
                    : Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color:
                isAction
                    ? const Color.fromARGB(255, 244, 67, 54)
                    : Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      isAction
                          ? const Color.fromARGB(255, 244, 67, 54)
                          : const Color.fromARGB(255, 66, 65, 82),
                ),
              ),
            ],
          ),
        ),
        if (isAction)
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color.fromARGB(255, 244, 67, 54),
          ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
