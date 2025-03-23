// import 'package:flutter/material.dart';

// class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
//   const TopNavBar({super.key});

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       elevation: 0,
//       automaticallyImplyLeading: false,
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF0F193F), Color(0xFF1E2A58)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//       ),
//       title: const Text(
//         'CFD Platform',
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 1.2,
//         ),
//       ),
//       actions: [
//         _navButton(context, 'Home', '/'),
//         _navButton(context, 'Projects', '/projects'),
//         _navButton(context, 'Community', '/community'),
//         _navButton(context, 'Connect', '/connect'),
//         const SizedBox(width: 12),
//       ],
//     );
//   }

//  Widget _navButton(BuildContext context, String label, String route) {
//     return TextButton(
//       style: ButtonStyle(
//         overlayColor: MaterialStateProperty.resolveWith<Color?>(
//           (states) {
//             if (states.contains(MaterialState.hovered)) {
//               return Colors.white.withOpacity(0.1); // custom hover color
//             }
//             return null;
//           },
//         ),
//       ),
//       onPressed: () => Navigator.pushNamed(context, route),
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w500,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }

// }

import 'package:blockercrafter/config/app_colors.dart';
import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,

      // flexibleSpace: Container(
      //   // decoration: const BoxDecoration(
      //   //   gradient: LinearGradient(
      //   //     colors: AppColors.yellow, A],
      //   //     begin: Alignment.topLeft,
      //   //     end: Alignment.bottomRight,
      //   //   ),
      //   // ),
      // ),
      title: const Text(
        'CFD Platform',
        style: TextStyle(
          color: AppColors.yellow,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        _navButton(context, 'Home', '/'),
        _navButton(context, 'Projects', '/projects'),
        _navButton(context, 'Community', '/community'),
        _navButton(context, 'Connect', '/connect'),
        const SizedBox(width: 12),
      ],
    );
  }

 Widget _navButton(BuildContext context, String label, String route) {
    return TextButton(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(MaterialState.hovered)) {
              return AppColors.orange.withOpacity(0.1); // custom hover color
            }
            return null;
          },
        ),
      ),
      onPressed: () => Navigator.pushNamed(context, route),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.lightBlue,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

}

