import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _bgController;
  late AnimationController _cardController;
  late AnimationController _logoController;
  late AnimationController _glowController;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<double> _glow;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeIn),
    );

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    ));

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotate = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _glow = Tween<double>(begin: 0.15, end: 0.4).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgController.dispose();
    _cardController.dispose();
    _logoController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(email, password);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/');
    } else if (mounted) {
      _showSnackBar(auth.errorMessage);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFFEA5863),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                  -0.5 + _bgController.value * 0.3,
                  -0.5 + _bgController.value * 0.2,
                ),
                end: Alignment(
                  0.5 - _bgController.value * 0.3,
                  0.5 - _bgController.value * 0.2,
                ),
                colors: const [
                  Color(0xFF27C7D4),
                  Color(0xFF1A9EAA),
                  Color(0xFFFE9063),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            // Animated background particles
            _buildParticles(),
            // Main content - NO SCROLL, single screen
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Animated Logo - FIXE
                    ScaleTransition(
                      scale: _logoScale,
                      child: RotationTransition(
                        turns: _logoRotate,
                        child: AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF27C7D4)
                                        .withOpacity(_glow.value),
                                    blurRadius: 30,
                                    spreadRadius: 6,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFE9063)
                                        .withOpacity(_glow.value * 0.5),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'assets/images/logo.jpg',
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // UniSy text with shimmer
                    ScaleTransition(
                      scale: _logoScale,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment(_shimmer.value - 1, 0),
                            end: Alignment(_shimmer.value, 0),
                            colors: const [
                              Colors.white,
                              Color(0xFFFE9063),
                              Color(0xFF27C7D4),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.35, 0.65, 1.0],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'UniSy',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Tagline
                    FadeTransition(
                      opacity: _cardFade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFE9063).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFE9063).withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Smart Campus Companion',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login Card - COMPACT
                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF0E7).withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1A1A2E).withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: const Color(0xFF27C7D4).withOpacity(0.1),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF27C7D4),
                                          Color(0xFF1A9EAA),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF27C7D4).withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.school_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome Back',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      Text(
                                        'Sign in to continue',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                label: 'University Email',
                                hint: 'firstname.lastname@unisy.dz',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF27C7D4),
                                    size: 18,
                                  ),
                                  onPressed: () => setState(
                                          () => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Consumer<AuthProvider>(
                                builder: (context, auth, child) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 46,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF27C7D4),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 0,
                                        shadowColor: const Color(0xFF27C7D4).withOpacity(0.5),
                                      ),
                                      onPressed:
                                      auth.state == AuthState.loading
                                          ? null
                                          : _handleLogin,
                                      child: auth.state == AuthState.loading
                                          ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                          : const Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login_rounded,
                                              size: 18),
                                          SizedBox(width: 6),
                                          Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              // Compact divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey[300], height: 8)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      'or',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey[300], height: 8)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Compact biometric button
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF27C7D4),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () async {
                                    final success = await context
                                        .read<AuthProvider>()
                                        .loginWithBiometrics();
                                    if (success && mounted) {
                                      Navigator.pushReplacementNamed(context, '/');
                                    } else if (mounted) {
                                      _showSnackBar('Biometric authentication failed');
                                    }
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.fingerprint,
                                        color: Color(0xFF27C7D4),
                                        size: 20,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Sign in with Biometrics',
                                        style: TextStyle(
                                          color: Color(0xFF27C7D4),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Footer - ORIGINAL
                    FadeTransition(
                      opacity: _cardFade,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security_rounded,
                              size: 12, color: Colors.white.withOpacity(0.6)),
                          const SizedBox(width: 5),
                          Text(
                            'Secured with encrypted storage',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Background floating particles
  Widget _buildParticles() {
    return IgnorePointer(
      child: Stack(
        children: [
          _Particle(
            color: const Color(0xFFFE9063).withOpacity(0.12),
            size: 8,
            duration: const Duration(seconds: 6),
            begin: const Offset(0.1, 0.8),
            end: const Offset(0.3, 0.2),
          ),
          _Particle(
            color: const Color(0xFF27C7D4).withOpacity(0.1),
            size: 6,
            duration: const Duration(seconds: 8),
            begin: const Offset(0.8, 0.9),
            end: const Offset(0.5, 0.1),
          ),
          _Particle(
            color: const Color(0xFFEA5863).withOpacity(0.08),
            size: 7,
            duration: const Duration(seconds: 7),
            begin: const Offset(0.9, 0.3),
            end: const Offset(0.2, 0.7),
          ),
          _Particle(
            color: const Color(0xFFFDF0E7).withOpacity(0.06),
            size: 10,
            duration: const Duration(seconds: 10),
            begin: const Offset(0.5, 0.95),
            end: const Offset(0.7, 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF555555),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[300], fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF27C7D4), size: 18),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFF27C7D4), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFB),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }
}

// Animated floating particle widget
class _Particle extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  final Offset begin;
  final Offset end;

  const _Particle({
    required this.color,
    required this.size,
    required this.duration,
    required this.begin,
    required this.end,
  });

  @override
  State<_Particle> createState() => _ParticleState();
}

class _ParticleState extends State<_Particle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * _animation.value.dx,
          top: MediaQuery.of(context).size.height * _animation.value.dy,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.5),
                  blurRadius: widget.size * 2,
                  spreadRadius: widget.size * 0.5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}