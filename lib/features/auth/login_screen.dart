import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../app/router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      authService.clearError();

      bool success;
      if (_isLoginMode) {
        success = await authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        success = await authService.register(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
      }

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.home);
      }
    }
  }

  void _fillDemoCredentials(bool isAdmin) {
    setState(() {
      if (isAdmin) {
        _emailController.text = 'admin@dramabook.com';
        _passwordController.text = 'admin123';
      } else {
        _emailController.text = 'user@example.com';
        _passwordController.text = 'user123';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withValues(alpha: 0.9),
              theme.primaryColor.withValues(alpha: 0.7),
              theme.colorScheme.secondary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating decorative elements
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 50,
                  left: 30,
                  child: Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Icon(
                      Icons.theater_comedy,
                      size: 60,
                      color: theme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Positioned(
                  bottom: 80,
                  right: 40,
                  child: Transform.translate(
                    offset: Offset(0, -_floatAnimation.value),
                    child: Icon(
                      Icons.star,
                      size: 50,
                      color: theme.colorScheme.secondary.withOpacity(0.2),
                    ),
                  ),
                );
              },
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            offset: Offset(8, 8),
                            blurRadius: 16,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            offset: Offset(-8, -8),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo and Title
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.primaryColor.withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.theater_comedy,
                                size: 48,
                                color: theme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'DramaBook',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              _isLoginMode ? 'Welcome Back!' : 'Join the Stage',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 32),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (!_isLoginMode) ...[
                                    _buildTextField(
                                      controller: _nameController,
                                      label: 'Full Name',
                                      icon: Icons.person,
                                      validator: (value) {
                                        if (!_isLoginMode && (value == null || value.trim().isEmpty)) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    icon: Icons.lock,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: theme.primaryColor.withOpacity(0.7),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (!_isLoginMode && value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 24),

                                  // Error Message
                                  Consumer<AuthService>(
                                    builder: (context, authService, child) {
                                      if (authService.errorMessage != null) {
                                        return Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(12),
                                          margin: EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.red[300]!),
                                          ),
                                          child: Text(
                                            authService.errorMessage!,
                                            style: TextStyle(color: Colors.red[700]),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }
                                      return SizedBox.shrink();
                                    },
                                  ),

                                  // Submit Button
                                  Consumer<AuthService>(
                                    builder: (context, authService, child) {
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: authService.isLoading ? null : _submit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            elevation: 0,
                                            shadowColor: theme.primaryColor.withOpacity(0.4),
                                          ),
                                          child: authService.isLoading
                                              ? CircularProgressIndicator(color: Colors.white)
                                              : Text(
                                            _isLoginMode ? 'Enter Stage' : 'Join DramaBook',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16),

                                  // Toggle Mode Button
                                  TextButton(
                                    onPressed: _toggleMode,
                                    child: Text(
                                      _isLoginMode
                                          ? 'Need an account? Join Now'
                                          : 'Already a member? Sign In',
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  // Demo Credentials
                                  if (_isLoginMode) ...[
                                    SizedBox(height: 24),
                                    Text(
                                      'Try Demo Accounts',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _fillDemoCredentials(false),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: theme.primaryColor.withOpacity(0.5)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              'User Demo',
                                              style: TextStyle(color: theme.primaryColor),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _fillDemoCredentials(true),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: theme.primaryColor.withOpacity(0.5)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              'Admin Demo',
                                              style: TextStyle(color: theme.primaryColor),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(4, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            offset: Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
        validator: validator,
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/auth_service.dart';
// import '../../app/router.dart';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _nameController = TextEditingController();
//
//   bool _isLoginMode = true;
//   bool _obscurePassword = true;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 1000),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _nameController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _toggleMode() {
//     setState(() {
//       _isLoginMode = !_isLoginMode;
//     });
//   }
//
//   Future<void> _submit() async {
//     if (_formKey.currentState!.validate()) {
//       final authService = Provider.of<AuthService>(context, listen: false);
//       authService.clearError();
//
//       bool success;
//       if (_isLoginMode) {
//         success = await authService.login(
//           _emailController.text.trim(),
//           _passwordController.text,
//         );
//       } else {
//         success = await authService.register(
//           _emailController.text.trim(),
//           _passwordController.text,
//           _nameController.text.trim(),
//         );
//       }
//
//       if (success) {
//         Navigator.of(context).pushReplacementNamed(AppRouter.home);
//       }
//     }
//   }
//
//   void _fillDemoCredentials(bool isAdmin) {
//     setState(() {
//       if (isAdmin) {
//         _emailController.text = 'admin@dramabook.com';
//         _passwordController.text = 'admin123';
//       } else {
//         _emailController.text = 'user@example.com';
//         _passwordController.text = 'user123';
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               theme.primaryColor,
//               theme.primaryColor.withOpacity(0.8),
//               theme.colorScheme.secondary,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(24.0),
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: Card(
//                   elevation: 8,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(24.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Logo and Title
//                         Icon(
//                           Icons.theater_comedy,
//                           size: 64,
//                           color: theme.primaryColor,
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'DramaBook',
//                           style: theme.textTheme.headlineMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: theme.primaryColor,
//                           ),
//                         ),
//                         Text(
//                           _isLoginMode ? 'Welcome Back!' : 'Create Account',
//                           style: theme.textTheme.bodyLarge?.copyWith(
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         SizedBox(height: 32),
//
//                         // Form
//                         Form(
//                           key: _formKey,
//                           child: Column(
//                             children: [
//                               if (!_isLoginMode) ...[
//                                 TextFormField(
//                                   controller: _nameController,
//                                   decoration: InputDecoration(
//                                     labelText: 'Full Name',
//                                     prefixIcon: Icon(Icons.person),
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                   validator: (value) {
//                                     if (!_isLoginMode && (value == null || value.trim().isEmpty)) {
//                                       return 'Please enter your name';
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(height: 16),
//                               ],
//
//                               TextFormField(
//                                 controller: _emailController,
//                                 keyboardType: TextInputType.emailAddress,
//                                 decoration: InputDecoration(
//                                   labelText: 'Email',
//                                   prefixIcon: Icon(Icons.email),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 validator: (value) {
//                                   if (value == null || value.trim().isEmpty) {
//                                     return 'Please enter your email';
//                                   }
//                                   if (!value.contains('@')) {
//                                     return 'Please enter a valid email';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               SizedBox(height: 16),
//
//                               TextFormField(
//                                 controller: _passwordController,
//                                 obscureText: _obscurePassword,
//                                 decoration: InputDecoration(
//                                   labelText: 'Password',
//                                   prefixIcon: Icon(Icons.lock),
//                                   suffixIcon: IconButton(
//                                     icon: Icon(
//                                       _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         _obscurePassword = !_obscurePassword;
//                                       });
//                                     },
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter your password';
//                                   }
//                                   if (!_isLoginMode && value.length < 6) {
//                                     return 'Password must be at least 6 characters';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               SizedBox(height: 24),
//
//                               // Error Message
//                               Consumer<AuthService>(
//                                 builder: (context, authService, child) {
//                                   if (authService.errorMessage != null) {
//                                     return Container(
//                                       width: double.infinity,
//                                       padding: EdgeInsets.all(12),
//                                       margin: EdgeInsets.only(bottom: 16),
//                                       decoration: BoxDecoration(
//                                         color: Colors.red[50],
//                                         borderRadius: BorderRadius.circular(8),
//                                         border: Border.all(color: Colors.red[300]!),
//                                       ),
//                                       child: Text(
//                                         authService.errorMessage!,
//                                         style: TextStyle(color: Colors.red[700]),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     );
//                                   }
//                                   return SizedBox.shrink();
//                                 },
//                               ),
//
//                               // Submit Button
//                               Consumer<AuthService>(
//                                 builder: (context, authService, child) {
//                                   return SizedBox(
//                                     width: double.infinity,
//                                     height: 48,
//                                     child: ElevatedButton(
//                                       onPressed: authService.isLoading ? null : _submit,
//                                       style: ElevatedButton.styleFrom(
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(12),
//                                         ),
//                                       ),
//                                       child: authService.isLoading
//                                           ? CircularProgressIndicator(color: Colors.white)
//                                           : Text(
//                                               _isLoginMode ? 'Login' : 'Sign Up',
//                                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                             ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               SizedBox(height: 16),
//
//                               // Toggle Mode Button
//                               TextButton(
//                                 onPressed: _toggleMode,
//                                 child: Text(
//                                   _isLoginMode
//                                       ? 'Don\'t have an account? Sign Up'
//                                       : 'Already have an account? Login',
//                                 ),
//                               ),
//
//                               // Demo Credentials
//                               if (_isLoginMode) ...[
//                                 SizedBox(height: 24),
//                                 Text(
//                                   'Demo Accounts:',
//                                   style: theme.textTheme.bodySmall?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: OutlinedButton(
//                                         onPressed: () => _fillDemoCredentials(false),
//                                         child: Text('User Demo'),
//                                       ),
//                                     ),
//                                     SizedBox(width: 8),
//                                     Expanded(
//                                       child: OutlinedButton(
//                                         onPressed: () => _fillDemoCredentials(true),
//                                         child: Text('Admin Demo'),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }