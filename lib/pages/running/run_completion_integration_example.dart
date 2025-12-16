// /// Example integration of RunShareScreen with RunCompletionScreen
// ///
// /// This file shows how to add a "Share" button to RunCompletionScreen
// /// that navigates to RunShareScreen with the session data.
// ///
// /// DO NOT USE THIS FILE DIRECTLY - it's just an example.
// /// Copy the relevant parts to your actual RunCompletionScreen.

// import 'package:flutter/material.dart';
// import 'package:turun/data/model/running/run_session_model.dart';
// import 'package:turun/pages/running/run_share_screen.dart';

// /// Example of how to add Share button to RunCompletionScreen
// class RunCompletionIntegrationExample extends StatelessWidget {
//   final RunSession session;

//   const RunCompletionIntegrationExample({
//     super.key,
//     required this.session,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           // ... existing RunCompletionScreen content ...

//           // Add this section near the bottom, alongside other action buttons
//           _buildActionButtons(context),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           // Existing button (e.g., View Leaderboard)
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () {
//                 // Navigate to leaderboard
//               },
//               child: const Text('View Leaderboard'),
//             ),
//           ),

//           const SizedBox(width: 12),

//           // NEW: Share button
//           Expanded(
//             child: OutlinedButton.icon(
//               onPressed: () => _navigateToShareScreen(context),
//               icon: const Icon(Icons.share),
//               label: const Text('Share'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 side: const BorderSide(color: Colors.white),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Navigate to share screen with session data
//   void _navigateToShareScreen(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RunShareScreen(
//           // Convert RunSession data to share screen format
//           distance: session.formattedDistance,
//           pace: session.formattedPace,
//           duration: session.formattedDuration,
//           territoryConquered: session.territoryConquered,
//           territoryName: session.territoryId, // atau dari territory join data
//           // mapImagePath: null, // TODO: implement map screenshot
//         ),
//       ),
//     );
//   }
// }

// /// Alternative: Add as FloatingActionButton
// class RunCompletionWithFABExample extends StatelessWidget {
//   final RunSession session;

//   const RunCompletionWithFABExample({
//     super.key,
//     required this.session,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // ... existing RunCompletionScreen content ...

//       // Add FloatingActionButton for share
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _navigateToShareScreen(context),
//         icon: const Icon(Icons.share),
//         label: const Text('Share Run'),
//         backgroundColor: Colors.orange,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }

//   void _navigateToShareScreen(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RunShareScreen(
//           distance: session.formattedDistance,
//           pace: session.formattedPace,
//           duration: session.formattedDuration,
//           territoryConquered: session.territoryConquered,
//           territoryName: session.territoryId,
//         ),
//       ),
//     );
//   }
// }

// /// How to format duration in Indonesian style (2j 9m)
// ///
// /// If RunSession.formattedDuration doesn't match the style you want,
// /// use this helper function:
// String formatDurationIndonesian(int durationSeconds) {
//   final hours = durationSeconds ~/ 3600;
//   final minutes = (durationSeconds % 3600) ~/ 60;
//   final seconds = durationSeconds % 60;

//   if (hours > 0) {
//     return '${hours}j ${minutes}m';
//   } else if (minutes > 0) {
//     return '${minutes}m ${seconds}s';
//   } else {
//     return '${seconds}s';
//   }
// }

// /// Example with custom formatting
// void navigateToShareScreenCustomFormat(
//   BuildContext context,
//   RunSession session,
// ) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => RunShareScreen(
//         distance: session.formattedDistance,
//         pace: session.formattedPace,
//         duration: formatDurationIndonesian(session.durationSeconds),
//         territoryConquered: session.territoryConquered,
//         territoryName: session.territoryId,
//       ),
//     ),
//   );
// }
