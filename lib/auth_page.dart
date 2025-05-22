import 'package:flutter/material.dart';
import 'otp_number.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mrsgorilla/gohome.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import flutter_secure_storage

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool isButtonEnabled = false; // Track button state
  bool isLoading = false;
  String fcmToken = ''; // Store the FCM token
  final storage = const FlutterSecureStorage(); // Create storage instance

  @override
  void initState() {
    super.initState();
    _loadFcmToken(); // Load FCM token when screen initializes
  }

  // Function to load FCM token from storage
  Future<void> _loadFcmToken() async {
    try {
      final token = await storage.read(key: 'fcmToken');
      setState(() {
        fcmToken = token ?? 'Token not found';
      });
      print('FCM Token: $fcmToken');
    } catch (e) {
      print('Error reading FCM token: $e');
      setState(() {
        fcmToken = 'Error loading token';
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<bool> sendOtp(String phoneNumber) async {
    final String baseUrl = 'http://3.111.39.222/auth';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'), // Adjust the endpoint to match your backend route
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'fcm_token':fcmToken
        }),
      );
      print(response.body);

      if (response.statusCode == 200) {
        return true; // Successfully sent OTP
      } else {
        // Parse error message from response if available
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      print('Error sending OTP: $e');
      return false; // Failed to send OTP
    }
  }

  void _validatePhoneNumber(String value) {
    if (value.length == 10 && !isButtonEnabled) {
      setState(() {
        isButtonEnabled = true;
      });
    } else if (value.length != 10 && isButtonEnabled) {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main Image with Skip Login button
            Stack(
              children: [
                // Main image
                Image.asset(
                  'assets/images/DALL·E 2025-03-02 11.57.04 - A realistic vector-style illustration of an e-vehicle vegetable cart positioned closer to the camera in the center of a modern Mumbai or Pune society.webp',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: double.infinity,
                ),

                // Gradient overlay at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 200, // Adjust the height of the gradient as needed
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.6),
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // Logo (positioned above the gradient)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/newlogo.png',
                        fit: BoxFit.cover,
                        height: 105,
                        width: 311,
                      ),
                    ),
                  ),
                ),

                // Skip login button
                Positioned(
                  top: 50,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePageWithMap(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white.withOpacity(0.75), // Semi-transparent background
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    child: const Text(
                      'Skip Login',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Tagline
            Text(
              'We bring the market to you!',
              style: GoogleFonts.leagueSpartan(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 5),

            // Login or Signup text
            Text(
              'Login or Signup',
              style: GoogleFonts.leagueSpartan(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            // // FCM Token display
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            //   margin: const EdgeInsets.symmetric(horizontal: 20),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[100],
            //     borderRadius: BorderRadius.circular(10),
            //     border: Border.all(color: Colors.grey[300]!),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'FCM Token:',
            //         style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           fontSize: 12,
            //           color: Colors.grey[700],
            //         ),
            //       ),
            //       const SizedBox(height: 4),
            //       Text(
            //         fcmToken,
            //         style: TextStyle(
            //           fontSize: 12,
            //           color: Colors.grey[800],
            //         ),
            //         maxLines: 3,
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 10),

            // Phone number input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10, // Restrict to 10 digits
                onChanged: _validatePhoneNumber, // Call function on input change
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter mobile number',
                  counterText: "", // Hide character count
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefix: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
                    margin: const EdgeInsets.only(right: 10),
                    child: const Text(
                      '+91',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Continue button (turns green when valid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: isButtonEnabled
                    ? () async {
                  // Show loading indicator
                  setState(() {
                    isLoading = true;
                  });

                  bool success = await sendOtp(_phoneController.text);

                  // Hide loading indicator
                  setState(() {
                    isLoading = false;
                  });

                  if (success) {
                    // Navigate to OTP verification screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpVerificationScreen(
                          phoneNumber: _phoneController.text,
                        ),
                      ),
                    );
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to send OTP. Please try again.')),
                    );
                  }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled ? Color(0xFF49C71F) : Colors.grey[400],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
            Divider(),

            // Terms text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'By continuing you agree to our',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.1, // Even tighter line height
                    ),
                  ),
                  SizedBox(height: 0), // Removes extra spacing between lines
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TermsOfServiceScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero, // Ensures no extra space
                          padding: EdgeInsets.zero, // Removes padding inside button
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrinks tap area
                        ),
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        ' & ',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Terms of Service Screen
class TermsOfServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms of Service")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            "Add your Terms of Service text here...",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            "Add your Privacy Policy text here...",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}