// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:univote/auth/authservice.dart';
// import 'package:univote/pages/userelctiondetails.dart';
// import 'package:univote/supabase/electionbase.dart';

// final supabase = Supabase.instance.client;

// class Activeelection extends StatefulWidget {
//   const Activeelection({super.key});

//   @override
//   State<Activeelection> createState() => _ActiveelectionState();
// }

// class _ActiveelectionState extends State<Activeelection> {
//   final electionbase = ElectionBase();
//   final AuthService authService = AuthService();
//   Future<List<Map<String, dynamic>>> getActiveElections() async {
//     final elecs = await supabase
//         .from('elections')
//         .select()
//         .lte('start', DateTime.now().toIso8601String())
//         .gt('end', DateTime.now().toIso8601String())
//         .order('end', ascending: true);

//     return List<Map<String, dynamic>>.from(elecs);
//   }

//   late Map<String, dynamic> profile;

//   // Color scheme
//   final Color primaryColor = const Color(0xFF6C63FF);
//   final Color secondaryColor = const Color(0xFF8A84FF);
//   final Color accentColor = const Color(0xFFFF6584);
//   final Color neutralDark = const Color(0xFF2D3142);
//   final Color neutralLight = const Color(0xFFF8F7FF);
//   final Color activeColor = const Color(0xFF42E2B8);
//   final Color upcomingColor = const Color(0xFFFFC857);
//   final Color pastColor = const Color(0xFF9297C4);

//   String formatDuration(Duration duration) {
//     if (duration.inDays > 0) {
//       return '${duration.inDays} days ${duration.inHours % 24} hours';
//     } else if (duration.inHours > 0) {
//       return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
//     } else {
//       return '${duration.inMinutes} minutes';
//     }
//   }

//   Future<Map<String, dynamic>> getUserProfile() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) {
//       print("No user is logged in.");
//       return {'username': "Invalid User"};
//     }

//     profile =
//         await supabase.from('profiles').select().eq('id', user.id).single();
//     return profile;
//   }

//   @override
//   void initState() {
//     getUserProfile();
//     super.initState();
//   }

//   void _refreshElections() {
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 42),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildSectionHeader('Active Elections', activeColor),
//                   Spacer(),
//                   IconButton(
//                     icon: Icon(
//                       CupertinoIcons.refresh_bold,
//                       color: Color.fromARGB(255, 24, 13, 91),
//                       size: 20,
//                     ),
//                     onPressed: _refreshElections,
//                   ),
//                   SizedBox(width: 10),
//                 ],
//               ),
//               const SizedBox(height: 26),
//               FutureBuilder(
//                 future: getActiveElections(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return SizedBox(
//                       width: MediaQuery.of(context).size.width,
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         itemCount: 5,
//                         itemBuilder:
//                             (context, index) => buildShimmerElectionCard(),
//                       ),
//                     );
//                   }
//                   final elections = snapshot.data;
//                   if (elections == null || elections.isEmpty) {
//                     print("hererre");
//                     return _buildEmptyCard();
//                   }
//                   final now = DateTime.now();
//                   return SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: elections.length,
//                       itemBuilder: (context, index) {
//                         return _buildElectionCard(elections[index], now);
//                       },
//                     ),
//                   );
//                 },
//               ),
//               SizedBox(height: 200),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, Color color) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 24,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             color: neutralDark,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyCard() {
//     String message;
//     Color cardColor;
//     Color iconColor;
//     IconData iconData;

//     message = 'No active elections';
//     cardColor = activeColor.withOpacity(0.15);
//     iconColor = activeColor;
//     iconData = Icons.hourglass_empty_rounded;

//     return Card(
//       elevation: 0,
//       color: cardColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         width: MediaQuery.of(context).size.width - 32,
//         alignment: Alignment.center,
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(iconData, size: 48, color: iconColor),
//             const SizedBox(height: 16),
//             Text(
//               message,
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: neutralDark.withOpacity(0.8),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildElectionCard(Map<String, dynamic> elec, DateTime now) {
//     String statusLabel;
//     Color statusColor;
//     IconData statusIcon;
//     Color cardBgColor;
//     Color borderColor;
//     String timeText;
//     IconData timeIcon;

//     // Active
//     statusLabel = 'Active';
//     statusColor = activeColor;
//     statusIcon = Icons.play_circle_filled;
//     cardBgColor = neutralLight;
//     borderColor = activeColor;
//     timeIcon = Icons.timer;

//     final timeLeft = DateTime.parse(elec['end']).difference(now);
//     timeText = 'Ends in: ${formatDuration(timeLeft)}';

//     return Container(
//       height: 180,
//       margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
//       child: Card(
//         elevation: 2,
//         shadowColor: borderColor.withOpacity(0.4),
//         color: cardBgColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//           side: BorderSide(color: borderColor.withOpacity(0.5), width: 1.5),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Flexible(
//                     child: Text(
//                       elec['name'],
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: neutralDark,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(left: 8),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(statusIcon, size: 14, color: statusColor),
//                         const SizedBox(width: 4),
//                         Text(
//                           statusLabel,
//                           style: GoogleFonts.poppins(
//                             color: statusColor,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Icon(timeIcon, size: 16, color: statusColor.withOpacity(0.8)),
//                   const SizedBox(width: 6),
//                   Text(
//                     timeText,
//                     style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.w500,
//                       fontSize: 14,
//                       color: neutralDark.withOpacity(0.8),
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   OutlinedButton.icon(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (context) => UserElectionDetails(
//                                 elec: elec,
//                                 profile: profile,
//                               ),
//                         ),
//                       );
//                     },
//                     icon: const Icon(Icons.visibility_outlined),
//                     label: const Text('View'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: statusColor,
//                       side: BorderSide(color: statusColor),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// Widget buildShimmerElectionCard() {
//   Color baseColor;
//   Color highlightColor;

//   baseColor = const Color(0xFFE0F2F1);
//   highlightColor = const Color(0xFFF5F5F5);

//   return Container(
//     height: 180,
//     margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
//     child: Shimmer.fromColors(
//       baseColor: baseColor,
//       highlightColor: highlightColor,
//       child: Card(
//         elevation: 2,
//         margin: EdgeInsets.zero,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Title & Status Chip Placeholder
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     width: 180,
//                     height: 22,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                   Container(
//                     width: 80,
//                     height: 28,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Time Remaining Placeholder
//               Container(
//                 width: 200,
//                 height: 18,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//               const SizedBox(height: 30),

//               // Buttons Placeholder
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Container(
//                     width: 90,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     width: 90,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

/*############################################################################################################


###################################################################################################################


####################################################################################################################### */

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:univote/auth/authservice.dart';
// import 'package:univote/pages/userelctiondetails.dart';
// import 'package:univote/supabase/electionbase.dart';
// //import 'package:flutter_svg/flutter_svg.dart';
// import 'package:lottie/lottie.dart';
// import 'package:confetti/confetti.dart';

// final supabase = Supabase.instance.client;

// class Activeelection extends StatefulWidget {
//   const Activeelection({super.key});

//   @override
//   State<Activeelection> createState() => _ActiveelectionState();
// }

// class _ActiveelectionState extends State<Activeelection>
//     with SingleTickerProviderStateMixin {
//   final electionbase = ElectionBase();
//   final AuthService authService = AuthService();
//   late ConfettiController _confettiController;
//   late AnimationController _animationController;
//   bool _isLoading = true;
//   String _errorMessage = '';

//   Future<List<Map<String, dynamic>>> getActiveElections() async {
//     try {
//       final elecs = await supabase
//           .from('elections')
//           .select()
//           .lte('start', DateTime.now().toIso8601String())
//           .gt('end', DateTime.now().toIso8601String())
//           .order('end', ascending: true);

//       return List<Map<String, dynamic>>.from(elecs);
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load elections. Please try again.';
//       });
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
//       print("Error getting profile: $e");
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
//       _isLoading = true;
//       _startLoadingAnimation();
//     });

//     await getUserProfile();

//     setState(() {
//       _isLoading = false;
//       _stopLoadingAnimation();
//     });
//   }

//   Future<void> _refreshElections() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//       _startLoadingAnimation();
//     });

//     await Future.delayed(const Duration(milliseconds: 800));

//     setState(() {
//       _isLoading = false;
//       _stopLoadingAnimation();
//       _playCelebration();
//     });
//   }

//   @override
//   void dispose() {
//     _confettiController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: neutralLight,
//       body: Stack(
//         children: [
//           CustomScrollView(
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               _buildAppBar(),
//               SliverToBoxAdapter(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 16),
//                     _buildHeaderSection(),
//                     const SizedBox(height: 16),
//                     _buildActiveElectionsSection(),
//                     const SizedBox(height: 100), // Extra space at bottom
//                   ],
//                 ),
//               ),
//             ],
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
//           'Active Elections',
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
//       actions: [
//         FutureBuilder(
//           future: getUserProfile(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData && snapshot.data!['avatar_url'] != null) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16),
//                 child: CircleAvatar(
//                   backgroundImage: NetworkImage(snapshot.data!['avatar_url']),
//                   backgroundColor: Colors.white,
//                 ),
//               );
//             } else {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16),
//                 child: CircleAvatar(
//                   backgroundColor: accentColor.withOpacity(0.2),
//                   child: Text(
//                     snapshot.hasData && snapshot.data!['username'] != null
//                         ? snapshot.data!['username']
//                             .substring(0, 1)
//                             .toUpperCase()
//                         : 'U',
//                     style: TextStyle(
//                       color: accentColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               );
//             }
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: cardShadow.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.how_to_vote_rounded,
//                   color: primaryColor,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Cast Your Vote',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: neutralDark,
//                       ),
//                     ),
//                     Text(
//                       'Participate in active elections',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: neutralDark.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: LinearProgressIndicator(
//               value: 0.7,
//               backgroundColor: neutralLight,
//               valueColor: AlwaysStoppedAnimation<Color>(activeColor),
//               minHeight: 8,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Voting participation rate: 70%',
//             style: GoogleFonts.poppins(
//               fontSize: 12,
//               color: neutralDark.withOpacity(0.6),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActiveElectionsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: activeColor,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Active Elections',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: neutralDark,
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: activeColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.access_time_rounded,
//                       size: 14,
//                       color: activeColor,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Live',
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: activeColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         FutureBuilder(
//           future: getActiveElections(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting ||
//                 _isLoading) {
//               return SizedBox(
//                 width: MediaQuery.of(context).size.width,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: 3,
//                   itemBuilder: (context, index) => buildShimmerElectionCard(),
//                 ),
//               );
//             }

//             if (snapshot.hasError) {
//               return _buildErrorCard('Something went wrong. Please try again.');
//             }

//             final elections = snapshot.data;
//             if (elections == null || elections.isEmpty) {
//               return _buildEmptyCard();
//             }

//             final now = DateTime.now();
//             return SizedBox(
//               width: MediaQuery.of(context).size.width,
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: elections.length,
//                 itemBuilder: (context, index) {
//                   return _buildElectionCard(elections[index], now, index);
//                 },
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyCard() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: cardShadow.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: activeColor.withOpacity(0.2), width: 1),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: activeColor.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.how_to_vote_outlined,
//               size: 48,
//               color: activeColor,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No active elections',
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: neutralDark,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Check back later for upcoming elections',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: neutralDark.withOpacity(0.6),
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: _refreshElections,
//             icon: const Icon(Icons.refresh_rounded),
//             label: const Text('Refresh'),
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: primaryColor,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildElectionCard(
//     Map<String, dynamic> elec,
//     DateTime now,
//     int index,
//   ) {
//     final timeLeft = DateTime.parse(elec['end']).difference(now);
//     final percentageTimeLeft =
//         timeLeft.inMinutes /
//         DateTime.parse(
//           elec['end'],
//         ).difference(DateTime.parse(elec['start'])).inMinutes;
//     final progressValue = 1 - percentageTimeLeft.clamp(0.0, 1.0);

//     final bool isUrgent = timeLeft.inHours < 1;

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: cardShadow.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(
//           color:
//               isUrgent
//                   ? accentColor.withOpacity(0.5)
//                   : activeColor.withOpacity(0.2),
//           width: isUrgent ? 2 : 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 8,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors:
//                     isUrgent
//                         ? [accentColor, accentColor.withOpacity(0.7)]
//                         : [activeColor, activeColor.withOpacity(0.7)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Flexible(
//                       child: Text(
//                         elec['name'],
//                         style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: neutralDark,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Container(
//                       margin: const EdgeInsets.only(left: 8),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isUrgent
//                                 ? accentColor.withOpacity(0.15)
//                                 : activeColor.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             isUrgent
//                                 ? Icons.timer_outlined
//                                 : Icons.play_circle_filled,
//                             size: 14,
//                             color: isUrgent ? accentColor : activeColor,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             isUrgent ? 'Urgent' : 'Active',
//                             style: GoogleFonts.poppins(
//                               color: isUrgent ? accentColor : activeColor,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: neutralLight,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         isUrgent
//                             ? Icons.timer_outlined
//                             : Icons.hourglass_top_outlined,
//                         size: 20,
//                         color: isUrgent ? accentColor : primaryColor,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               isUrgent
//                                   ? 'Hurry! Time is running out'
//                                   : 'Election in progress',
//                               style: GoogleFonts.poppins(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14,
//                                 color: isUrgent ? accentColor : primaryColor,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Ends in: ${formatDuration(timeLeft)}',
//                               style: GoogleFonts.poppins(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 12,
//                                 color: neutralDark.withOpacity(0.7),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(4),
//                               child: LinearProgressIndicator(
//                                 value: progressValue,
//                                 backgroundColor: neutralLight.withOpacity(0.5),
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   isUrgent ? accentColor : activeColor,
//                                 ),
//                                 minHeight: 4,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => UserElectionDetails(
//                                   elec: elec,
//                                   profile: profile,
//                                 ),
//                           ),
//                         );
//                       },
//                       icon: const Icon(Icons.how_to_vote_rounded),
//                       label: const Text('Vote Now'),
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: isUrgent ? accentColor : primaryColor,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 10,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorCard(String message) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: cardShadow.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.error_outline_rounded, size: 40, color: accentColor),
//           const SizedBox(height: 16),
//           Text(
//             'Something went wrong',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: neutralDark,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             message,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: neutralDark.withOpacity(0.7),
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: _refreshElections,
//             icon: const Icon(Icons.refresh_rounded),
//             label: const Text('Try Again'),
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: primaryColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
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
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/pages/userelctiondetails.dart';
import 'package:univote/supabase/electionbase.dart';
//import 'package:flutter_svg/flutter_svg.dart';
//import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final supabase = Supabase.instance.client;

class Activeelection extends StatefulWidget {
  const Activeelection({super.key});

  @override
  State<Activeelection> createState() => _ActiveelectionState();
}

class _ActiveelectionState extends State<Activeelection>
    with SingleTickerProviderStateMixin {
  final electionbase = ElectionBase();
  final AuthService authService = AuthService();
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  bool _isLoading = true;
  String _errorMessage = '';

  // Add RefreshController
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  Future<List<Map<String, dynamic>>> getActiveElections() async {
    try {
      final elecs = await supabase
          .from('elections')
          .select()
          .lte('start', DateTime.now().toIso8601String())
          .gt('end', DateTime.now().toIso8601String())
          .order('end', ascending: true);

      return List<Map<String, dynamic>>.from(elecs);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load elections. Please try again.';
      });
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
      _isLoading = true;
      _startLoadingAnimation();
    });

    await getUserProfile();

    setState(() {
      _isLoading = false;
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
    await getActiveElections();

    setState(() {
      _stopLoadingAnimation();
      _playCelebration();
    });

    // Important: tell the RefreshController that refresh is done
    _refreshController.refreshCompleted();
  }

  Future<void> _refreshElections() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _startLoadingAnimation();
    });

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
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
                      _buildHeaderSection(),
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
          'Active Elections',
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

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardShadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.how_to_vote_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cast Your Vote',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: neutralDark,
                      ),
                    ),
                    Text(
                      'Participate in active elections',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: neutralDark.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: 0.7,
              backgroundColor: neutralLight,
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Voting participation rate: 70%',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: neutralDark.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveElectionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Active Elections',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: neutralDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: activeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: activeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder(
          future: getActiveElections(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                _isLoading) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) => buildShimmerElectionCard(),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorCard('Something went wrong. Please try again.');
            }

            final elections = snapshot.data;
            if (elections == null || elections.isEmpty) {
              return _buildEmptyCard();
            }

            final now = DateTime.now();
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: elections.length,
                itemBuilder: (context, index) {
                  return _buildElectionCard(elections[index], now, index);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: activeColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.how_to_vote_outlined,
              size: 48,
              color: activeColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No active elections',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: neutralDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for upcoming elections',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: neutralDark.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshElections,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColor,
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

  Widget _buildElectionCard(
    Map<String, dynamic> elec,
    DateTime now,
    int index,
  ) {
    final timeLeft = DateTime.parse(elec['end']).difference(now);
    final percentageTimeLeft =
        timeLeft.inMinutes /
        DateTime.parse(
          elec['end'],
        ).difference(DateTime.parse(elec['start'])).inMinutes;
    final progressValue = 1 - percentageTimeLeft.clamp(0.0, 1.0);

    final bool isUrgent = timeLeft.inHours < 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color:
              isUrgent
                  ? accentColor.withOpacity(0.5)
                  : activeColor.withOpacity(0.2),
          width: isUrgent ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isUrgent
                        ? [accentColor, accentColor.withOpacity(0.7)]
                        : [activeColor, activeColor.withOpacity(0.7)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
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
                    Flexible(
                      child: Text(
                        elec['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: neutralDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isUrgent
                                ? accentColor.withOpacity(0.15)
                                : activeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUrgent
                                ? Icons.timer_outlined
                                : Icons.play_circle_filled,
                            size: 14,
                            color: isUrgent ? accentColor : activeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUrgent ? 'Urgent' : 'Active',
                            style: GoogleFonts.poppins(
                              color: isUrgent ? accentColor : activeColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
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
                  child: Row(
                    children: [
                      Icon(
                        isUrgent
                            ? Icons.timer_outlined
                            : Icons.hourglass_top_outlined,
                        size: 20,
                        color: isUrgent ? accentColor : primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUrgent
                                  ? 'Hurry! Time is running out'
                                  : 'Election in progress',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isUrgent ? accentColor : primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ends in: ${formatDuration(timeLeft)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: neutralDark.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                backgroundColor: neutralLight.withOpacity(0.5),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isUrgent ? accentColor : activeColor,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => UserElectionDetails(
                                  elec: elec,
                                  profile: profile,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.how_to_vote_rounded),
                      label: const Text('Vote Now'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: isUrgent ? accentColor : primaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Widget _buildErrorCard(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 40, color: accentColor),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: neutralDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: neutralDark.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshElections,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColor,
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
