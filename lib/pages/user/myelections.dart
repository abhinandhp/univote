import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/models/model.dart';
import 'package:univote/pages/user/manifestouploadpage.dart';
import 'package:univote/pages/userelctiondetails.dart';
import 'package:univote/supabase/electionbase.dart';
import 'package:confetti/confetti.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final supabase = Supabase.instance.client;

class MyElections extends StatefulWidget {
  const MyElections({super.key});

  @override
  State<MyElections> createState() => _MyElectionsState();
}

class _MyElectionsState extends State<MyElections>
    with SingleTickerProviderStateMixin {
  final electionbase = ElectionBase();
  final AuthService authService = AuthService();
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  String _errorMessage = '';

  // Add RefreshController
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  Future<List<Map<String, dynamic>>> getmyElections() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("No user is logged in.");
        return [];
      }

      final data = await supabase
          .from('candidates')
          .select('*, elections(*)')
          .eq('uid', user.id)
          .eq('approved', true);

      final now = DateTime.now();

      final elecs =
          data
              .map((e) => e['elections'])
              .where(
                (e) =>
                    e != null &&
                    DateTime.tryParse(e['end'].toString())?.isAfter(now) ==
                        true,
              )
              .toList()
            ..sort(
              (a, b) => DateTime.parse(
                b['start'],
              ).compareTo(DateTime.parse(a['start'])),
            );

      return List<Map<String, dynamic>>.from(elecs);
    } catch (e) {
      print(e);
      return [];
    }
  }

  late Map<String, dynamic> profile = {};

  // Enhanced color scheme
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color secondaryColor = const Color(0xFF8A84FF);
  final Color accentColor = const Color(0xFFFF6584);
  final Color neutralDark = const Color(0xFF2D3142);
  final Color neutralLight = const Color(0xFFF8F7FF);
  final Color activeColor = const Color(0xFF42E2B8);
  final Color upcomingColor = const Color(0xFFFFC857);
  final Color pastColor = const Color(0xFF9297C4);
  final Color cardShadow = const Color(0xFFE0E0E0);

  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print("No user is logged in.");
      return {'username': "Invalid User"};
    }

    try {
      profile =
          await supabase.from('profiles').select().eq('id', user.id).single();
      return profile;
    } catch (e) {
      //print("Error getting profile: $e");
      return {'username': "Error Loading Profile"};
    }
  }

  void _startLoadingAnimation() {
    _animationController.repeat();
  }

  void _stopLoadingAnimation() {
    _animationController.stop();
  }

  void _playCelebration() {
    _confettiController.play();
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
    
      _startLoadingAnimation();
    });

    await getUserProfile();

    setState(() {

      _stopLoadingAnimation();
    });
  }

  // Implement onRefresh callback for pull to refresh
  void _onRefresh() async {
    setState(() {
      _errorMessage = '';
      _startLoadingAnimation();
    });

    await Future.delayed(const Duration(milliseconds: 800));
    await getUserProfile();
    await getmyElections();

    setState(() {
      _stopLoadingAnimation();
      _playCelebration();
    });

    // Important: tell the RefreshController that refresh is done
    _refreshController.refreshCompleted();
  }

  Future<void> _refreshElections() async {
    setState(() {
      _errorMessage = '';
      _startLoadingAnimation();
    });

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _stopLoadingAnimation();
      _playCelebration();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    _refreshController.dispose(); // Dispose the RefreshController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralLight,
      body: Stack(
        children: [
          // Replace CustomScrollView with SmartRefresher
          SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              waterDropColor: primaryColor,
              complete: Icon(Icons.check, color: activeColor),
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildActiveElectionsSection(),
                      const SizedBox(height: 100), // Extra space at bottom
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: [
                primaryColor,
                secondaryColor,
                accentColor,
                activeColor,
                upcomingColor,
              ],
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildErrorBanner(),
            ),
        ],
      ),
      floatingActionButton: _buildFloatingRefreshButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'My Elections',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, secondaryColor],
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -20,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -50,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
      actions: [
        FutureBuilder(
          future: getUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!['avatar_url'] != null) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(snapshot.data!['avatar_url']),
                  backgroundColor: Colors.white,
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundColor: accentColor.withOpacity(0.2),
                  child: Text(
                    snapshot.hasData && snapshot.data!['username'] != null
                        ? snapshot.data!['username']
                            .substring(0, 1)
                            .toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildActiveElectionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: getmyElections(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(child: Text("No upcoming elections found."));
            }

            final elections = snapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: elections.length,
              itemBuilder: (context, index) {
                final election = elections[index];
                final start = DateTime.parse(election['start']);
                final end = DateTime.parse(election['end']);

                return Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        election['name'] ?? 'Unnamed Election',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Start: ${DateFormat.yMMMd().add_jm().format(start)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        "End: ${DateFormat.yMMMd().add_jm().format(end)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                withNavBar: false,
                                screen: ManifestoUploadPage(

                                  profile: profile,
                                  elec:election,
                                ),
                              );
                            },
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Add Manifesto"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: accentColor.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _errorMessage = '';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingRefreshButton() {
    return FloatingActionButton(
      onPressed: _refreshElections,
      backgroundColor: primaryColor,
      elevation: 4,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animationController.value * 2 * 3.14159,
            child: Icon(Icons.refresh_rounded, color: Colors.white),
          );
        },
      ),
    );
  }
}

// Add SmartRefresher and RefreshController import and class

Widget buildShimmerElectionCard() {
  final baseColor = const Color(0xFFE0F2F1);
  final highlightColor = const Color(0xFFF5F5F5);

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 180,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 100,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
