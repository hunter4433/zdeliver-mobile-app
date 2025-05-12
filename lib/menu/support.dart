import 'package:flutter/material.dart';
import 'package:mrsgorilla/api/firebase.dart';
import 'package:flutter/material.dart';
import 'package:mrsgorilla/api/firebase.dart';
// Add these imports
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ✅ Top Section with Full-Screen Background Image
          Stack(
            children: [
              /// ✅ Background Image Covering SafeArea + AppBar
              Container(
                height: 370,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/supportblue.png'),  // ✅ Use your blue curved image here
                    fit: BoxFit.cover,
                  ),
                ),
              ),


              /// ✅ SafeArea + Back Button + Text
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ✅ Floating Back Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white,size: 30,),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white,size: 30,),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),


                      /// ✅ Page Title and Subtitle
                      const Text(
                        'Support',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'New to mrs.Gorilla?\nLet us answer your questions',
                        style: TextStyle(fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Use the public method instead
                          NotificationService().showTestNotification();
                        },
                        child: Text('Test Local Notification'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),


          const SizedBox(height: 20),


          /// ✅ Card 1 - Chat with us
          _buildSupportOption(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Chat with us',
            subtitle: 'Chat with our customer support',
            onTap: () {
              // TODO: Navigate to Chat Screen
            },
          ),
          const SizedBox(height: 10),


          /// ✅ Card 2 - Guide to mrs.Gorilla
          _buildSupportOption(
            context,
            icon: Icons.help_outline,
            title: 'Guide to mrs.Gorilla',
            subtitle: 'How to use the app',
            onTap: () {
              // TODO: Navigate to Guide Page
            },
          ),
          const SizedBox(height: 10),


          /// ✅ Card 3 - Check out FAQs
          _buildSupportOption(
            context,
            icon: Icons.question_answer_outlined,
            title: 'Check out FAQs',
            subtitle: 'Frequently asked questions',
            onTap: () {
              // TODO: Navigate to FAQ Page
            },
          ),
        ],
      ),
    );
  }


  /// ✅ Reusable Support Option Card
  Widget _buildSupportOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// ✅ Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.deepPurple,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),


            /// ✅ Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
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

