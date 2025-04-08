// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:univote/auth/authservice.dart';
// import 'package:univote/pages/user/manifestouploadpage.dart';
// import 'package:univote/supabase/electionbase.dart';
// import 'package:confetti/confetti.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

// final supabase = Supabase.instance.client;

// class MyElections extends StatefulWidget {
//   const MyElections({super.key});

//   @override
//   State<MyElections> createState() => _MyElectionsState();
// }

// class _MyElectionsState extends State<MyElections>
//     with SingleTickerProviderStateMixin {
//   final electionbase = ElectionBase();
//   final AuthService authService = AuthService();
//   late ConfettiController _confettiController;
//   late AnimationController _animationController;
//   String _errorMessage = '';

//   // Add RefreshController
//   final RefreshController _refreshController = RefreshController(
//     initialRefresh: false,
//   );

//   Future<List<Map<String, dynamic>>> getmyElections() async {
//     try {
//       final user = supabase.auth.currentUser;
//       if (user == null) {
//         print("No user is logged in.");
//         return [];
//       }

//       final data = await supabase
//           .from('candidates')
//           .select('*, elections(*)')
//           .eq('uid', user.id)
//           .eq('approved', true);

//       final now = DateTime.now();

//       final elecs =
//           data
//               .map((e) => e['elections'])
//               .where(
//                 (e) =>
//                     e != null &&
//                     DateTime.tryParse(e['end'].toString())?.isAfter(now) ==
//                         true,
//               )
//               .toList()
//             ..sort(
//               (a, b) => DateTime.parse(
//                 b['start'],
//               ).compareTo(DateTime.parse(a['start'])),
//             );

//       return List<Map<String, dynamic>>.from(elecs);
//     } catch (e) {
//       print(e);
//       return [];
//     }
//   }

//   late Map<String, dynamic> profile = {};

//   // Enhanced color scheme
//   final Color primaryColor = const Color(0xFF6C63FF);
//   final Color secondaryColor = const Color(0xFF8A84FF);
//   final Color accentColor = const Color(0xFFFF6584);
//   final Color neutralDark = const Color(0xFF2D3142);
//   final Color neutralLight = const Color(0xFFF8F7FF);
//   final Color activeColor = const Color(0xFF42E2B8);
//   final Color upcomingColor = const Color(0xFFFFC857);
//   final Color pastColor = const Color(0xFF9297C4);
//   final Color cardShadow = const Color(0xFFE0E0E0);

//   String formatDuration(Duration duration) {
//     if (duration.inDays > 0) {
//       return '${duration.inDays}d ${duration.inHours % 24}h';
//     } else if (duration.inHours > 0) {
//       return '${duration.inHours}h ${duration.inMinutes % 60}m';
//     } else {
//       return '${duration.inMinutes}m';
//     }
//   }

//   Future<Map<String, dynamic>> getUserProfile() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) {
//       print("No user is logged in.");
//       return {'username': "Invalid User"};
//     }

//     try {
//       profile =
//           await supabase.from('profiles').select().eq('id', user.id).single();
//       return profile;
//     } catch (e) {
//       //print("Error getting profile: $e");
//       return {'username': "Error Loading Profile"};
//     }
//   }

//   void _startLoadingAnimation() {
//     _animationController.repeat();
//   }

//   void _stopLoadingAnimation() {
//     _animationController.stop();
//   }

//   void _playCelebration() {
//     _confettiController.play();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _confettiController = ConfettiController(
//       duration: const Duration(seconds: 1),
//     );
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() {
//       _startLoadingAnimation();
//     });

//     await getUserProfile();

//     setState(() {
//       _stopLoadingAnimation();
//     });
//   }

//   // Implement onRefresh callback for pull to refresh
//   void _onRefresh() async {
//     setState(() {
//       _errorMessage = '';
//       _startLoadingAnimation();
//     });

//     await Future.delayed(const Duration(milliseconds: 800));
//     await getUserProfile();
//     await getmyElections();

//     setState(() {
//       _stopLoadingAnimation();
//       _playCelebration();
//     });

//     // Important: tell the RefreshController that refresh is done
//     _refreshController.refreshCompleted();
//   }

//   Future<void> _refreshElections() async {
//     setState(() {
//       _errorMessage = '';
//       _startLoadingAnimation();
//     });

//     await Future.delayed(const Duration(milliseconds: 800));

//     setState(() {
//       _stopLoadingAnimation();
//       _playCelebration();
//     });
//   }

//   @override
//   void dispose() {
//     _confettiController.dispose();
//     _animationController.dispose();
//     _refreshController.dispose(); // Dispose the RefreshController
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: neutralLight,
//       body: Stack(
//         children: [
//           // Replace CustomScrollView with SmartRefresher
//           SmartRefresher(
//             enablePullDown: true,
//             header: WaterDropHeader(
//               waterDropColor: primaryColor,
//               complete: Icon(Icons.check, color: activeColor),
//             ),
//             controller: _refreshController,
//             onRefresh: _onRefresh,
//             child: CustomScrollView(
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 _buildAppBar(),
//                 SliverToBoxAdapter(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 16),
//                       _buildActiveElectionsSection(),
//                       const SizedBox(height: 100), // Extra space at bottom
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.topCenter,
//             child: ConfettiWidget(
//               confettiController: _confettiController,
//               blastDirectionality: BlastDirectionality.explosive,
//               particleDrag: 0.05,
//               emissionFrequency: 0.05,
//               numberOfParticles: 20,
//               gravity: 0.1,
//               colors: [
//                 primaryColor,
//                 secondaryColor,
//                 accentColor,
//                 activeColor,
//                 upcomingColor,
//               ],
//             ),
//           ),
//           if (_errorMessage.isNotEmpty)
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: _buildErrorBanner(),
//             ),
//         ],
//       ),
//       floatingActionButton: _buildFloatingRefreshButton(),
//     );
//   }

//   Widget _buildAppBar() {
//     return SliverAppBar(
//       expandedHeight: 120,
//       floating: true,
//       pinned: true,
//       elevation: 0,
//       backgroundColor: primaryColor,
//       flexibleSpace: FlexibleSpaceBar(
//         titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
//         title: Text(
//           'My Elections',
//           style: GoogleFonts.poppins(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         background: Stack(
//           fit: StackFit.expand,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [primaryColor, secondaryColor],
//                 ),
//               ),
//             ),
//             Positioned(
//               right: -30,
//               top: -20,
//               child: CircleAvatar(
//                 radius: 80,
//                 backgroundColor: Colors.white.withOpacity(0.1),
//               ),
//             ),
//             Positioned(
//               left: -20,
//               bottom: -50,
//               child: CircleAvatar(
//                 radius: 60,
//                 backgroundColor: Colors.white.withOpacity(0.1),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActiveElectionsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 16),
//         FutureBuilder<List<Map<String, dynamic>>>(
//           future: getmyElections(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (snapshot.hasError ||
//                 !snapshot.hasData ||
//                 snapshot.data!.isEmpty) {
//               return const Center(child: Text("No upcoming elections found."));
//             }

//             final elections = snapshot.data!;

//             return ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: elections.length,
//               itemBuilder: (context, index) {
//                 final election = elections[index];
//                 final start = DateTime.parse(election['start']);
//                 final end = DateTime.parse(election['end']);

//                 return Container(
//                   margin: const EdgeInsets.all(12),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.2),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         election['name'] ?? 'Unnamed Election',
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.deepPurple,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         "Start: ${DateFormat.yMMMd().add_jm().format(start)}",
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       Text(
//                         "End: ${DateFormat.yMMMd().add_jm().format(end)}",
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       const SizedBox(height: 12),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             PersistentNavBarNavigator.pushNewScreen(
//                               context,
//                               withNavBar: false,
//                               screen: ManifestoUploadPage(
//                                 profile: profile,
//                                 elec: election,
//                               ),
//                             );
//                           },
//                           icon: const Icon(Icons.upload_file),
//                           label: const Text("Add Manifesto"),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.deepPurple,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildErrorBanner() {
//     return Material(
//       elevation: 4,
//       borderRadius: BorderRadius.circular(12),
//       color: accentColor.withOpacity(0.9),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 _errorMessage,
//                 style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
//               ),
//             ),
//             IconButton(
//               icon: Icon(Icons.close, color: Colors.white),
//               onPressed: () {
//                 setState(() {
//                   _errorMessage = '';
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingRefreshButton() {
//     return FloatingActionButton(
//       onPressed: _refreshElections,
//       backgroundColor: primaryColor,
//       elevation: 4,
//       child: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) {
//           return Transform.rotate(
//             angle: _animationController.value * 2 * 3.14159,
//             child: Icon(Icons.refresh_rounded, color: Colors.white),
//           );
//         },
//       ),
//     );
//   }
// }

// // Add SmartRefresher and RefreshController import and class

// Widget buildShimmerElectionCard() {
//   final baseColor = const Color(0xFFE0F2F1);
//   final highlightColor = const Color(0xFFF5F5F5);

//   return Container(
//     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     child: Shimmer.fromColors(
//       baseColor: baseColor,
//       highlightColor: highlightColor,
//       child: Container(
//         height: 190,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Container(
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           width: 180,
//                           height: 24,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                         Container(
//                           width: 80,
//                           height: 28,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Container(
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           width: 100,
//                           height: 32,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         Container(
//                           width: 100,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/pages/user/manifestouploadpage.dart';
import 'package:univote/supabase/electionbase.dart';
import 'package:confetti/confetti.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

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
  bool _isLoading = false;

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

  String getRemainingTime(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    return formatDuration(difference);
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
    setState(() {
      _isLoading = true;
    });
  }

  void _stopLoadingAnimation() {
    _animationController.stop();
    setState(() {
      _isLoading = false;
    });
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
    await getmyElections();

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
                      _buildProfileCard(),
                      // _buildStatisticsCard(),
                      _buildSectionHeader('My Elections'),
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
      expandedHeight: 140,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'My Elections',
          style: GoogleFonts.poppins(
            fontSize: 24,
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
            // Decorative elements
            Positioned(
              right: 20,
              bottom: 40,
              child: Icon(
                Icons.how_to_vote_rounded,
                size: 35,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [secondaryColor.withOpacity(0.9), primaryColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadow.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              profile['username']?.substring(0, 1).toUpperCase() ?? 'U',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile['username'] ?? 'Loading...',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  profile['email'] ?? 'Loading email...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Candidate',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getmyElections(),
      builder: (context, snapshot) {
        int electionCount = snapshot.hasData ? snapshot.data!.length : 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cardShadow.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Election Statistics',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: neutralDark,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.how_to_vote,
                    value: electionCount.toString(),
                    label: 'Active Elections',
                    color: activeColor,
                  ),
                  _buildStatItem(
                    icon: Icons.description_outlined,
                    value: profile['manifesto_count']?.toString() ?? '0',
                    label: 'Manifestos',
                    color: upcomingColor,
                  ),
                  _buildStatItem(
                    icon: Icons.people_outline,
                    value: profile['vote_count']?.toString() ?? '0',
                    label: 'Votes Received',
                    color: accentColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: neutralDark,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: neutralDark.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: neutralDark,
            ),
          ),
          if (_isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveElectionsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getmyElections(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: List.generate(2, (index) => buildShimmerElectionCard()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
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
            final now = DateTime.now();
            final isActive = now.isAfter(start) && now.isBefore(end);
            final isUpcoming = now.isBefore(start);

            return _buildElectionCard(
              election,
              start,
              end,
              isActive,
              isUpcoming,
            );
          },
        );
      },
    );
  }

  Widget _buildElectionCard(
    Map<String, dynamic> election,
    DateTime start,
    DateTime end,
    bool isActive,
    bool isUpcoming,
  ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isActive) {
      statusColor = activeColor;
      statusText = 'Active';
      statusIcon = Icons.event_available;
    } else if (isUpcoming) {
      statusColor = upcomingColor;
      statusText = 'Upcoming';
      statusIcon = Icons.event_note;
    } else {
      statusColor = pastColor;
      statusText = 'Ended';
      statusIcon = Icons.event_busy;
    }

    final remainingTime = getRemainingTime(end);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadow.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
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
                    Expanded(
                      child: Text(
                        election['name'] ?? 'Unnamed Election',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: neutralLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildTimelineItem(
                        icon: Icons.play_circle_outline,
                        title: 'Starts',
                        datetime: start,
                        color: isActive ? activeColor : upcomingColor,
                      ),
                      const SizedBox(height: 8),
                      _buildTimelineItem(
                        icon: Icons.stop_circle_outlined,
                        title: 'Ends',
                        datetime: end,
                        color: pastColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Remaining: $remainingTime',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          withNavBar: false,
                          screen: ManifestoUploadPage(
                            profile: profile,
                            elec: election,
                          ),
                        );
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Add Manifesto"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required DateTime datetime,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: neutralDark.withOpacity(0.7),
                ),
              ),
              Text(
                DateFormat.yMMMd().add_jm().format(datetime),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: neutralDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.ballot_outlined,
            size: 80,
            color: primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No Active Elections",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: neutralDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You don't have any upcoming elections as a candidate. Check back later or contact your election officer.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: neutralDark.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshElections,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
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
