import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/drama.dart';
import '../../services/fake_api_service.dart';
import '../../services/auth_service.dart';
import '../../services/local_database_service.dart';
import '../drama_details/drama_details_screen.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard.dart';
import '../../utils/responsive.dart';
import '../../utils/animations.dart';
import '../../app/theme.dart';
import '../../app/router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Drama> _dramas = [];
  List<Drama> _filteredDramas = [];
  bool _isLoading = true;
  String _selectedGenre = 'All';
  final List<String> _genres = ['All', 'Romance', 'Tragedy', 'Comedy', 'Drama', 'Musical', 'Thriller', 'Fantasy'];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _loadDramas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: Responsive.isMobile(context) ? 200 : 250,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGradient,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: Responsive.getPadding(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with user actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Text(
                                    'DramaBook',
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(context, 28),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (user != null) ...[
                                      Transform.scale(
                                        scale: _fadeAnimation.value,
                                        child: _buildActionButton(
                                          Icons.person,
                                          () => Navigator.push(
                                            context,
                                            SlidePageRoute(child: ProfileScreen()),
                                          ),
                                        ),
                                      ),
                                      if (user.isAdmin) ...[
                                        const SizedBox(width: 8),
                                        Transform.scale(
                                          scale: _fadeAnimation.value,
                                          child: _buildActionButton(
                                            Icons.admin_panel_settings,
                                            () => Navigator.push(
                                              context,
                                              SlidePageRoute(child: AdminDashboard()),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ] else
                                      Transform.scale(
                                        scale: _fadeAnimation.value,
                                        child: _buildActionButton(
                                          Icons.login,
                                          () => Navigator.push(
                                            context,
                                            SlidePageRoute(child: LoginScreen()),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Welcome message
                            Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user != null ? 'Welcome back, ${user.name}!' : 'Discover Amazing Dramas',
                                      style: TextStyle(
                                        fontSize: Responsive.getFontSize(context, 20),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Find your next favorite performance',
                                      style: TextStyle(
                                        fontSize: Responsive.getFontSize(context, 16),
                                        color: Colors.white.withValues(alpha: 0.9),
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
                  );
                },
              ),
            ),
          ),
          
          // Search and Filter Section
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 0.5),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Padding(
                      padding: Responsive.getPadding(context),
                      child: Column(
                        children: [
                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _filterDramas,
                              decoration: InputDecoration(
                                hintText: 'Search dramas...',
                                prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                                        onPressed: () {
                                          _searchController.clear();
                                          _filterDramas('');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Genre Filter
                          SizedBox(
                            height: 50,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _genres
                                  .map((genre) => Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: FilterChip(
                                          label: Text(genre),
                                          selected: _selectedGenre == genre,
                                          onSelected: (selected) {
                                            setState(() {
                                              _selectedGenre = genre;
                                            });
                                            _filterDramas(_searchController.text);
                                          },
                                          backgroundColor: Theme.of(context).cardColor,
                                          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                                          checkmarkColor: AppTheme.primaryColor,
                                          labelStyle: TextStyle(
                                            color: _selectedGenre == genre
                                                ? AppTheme.primaryColor
                                                : AppTheme.textSecondary,
                                            fontWeight: _selectedGenre == genre
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Drama Grid
          _isLoading
              ? SliverToBoxAdapter(
                  child: Container(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading amazing dramas...',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : _filteredDramas.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.theater_comedy,
                                size: 64,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No dramas found',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Responsive.isMobile(context)
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return AnimatedCard(
                                delay: Duration(milliseconds: index * 100),
                                child: _buildDramaCard(_filteredDramas[index], context),
                              );
                            },
                            childCount: _filteredDramas.length,
                          ),
                        )
                      : SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: Responsive.isDesktop(context) ? 3 : 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: Responsive.isDesktop(context) ? 20 : 16,
                            mainAxisSpacing: Responsive.isDesktop(context) ? 20 : 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return AnimatedCard(
                                delay: Duration(milliseconds: index * 100),
                                child: _buildDramaCard(_filteredDramas[index], context),
                              );
                            },
                            childCount: _filteredDramas.length,
                          ),
                        ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDramaCard(Drama drama, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlidePageRoute(
            child: DramaDetailsScreen(drama: drama),
            direction: AxisDirection.left,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Responsive.isMobile(context) ? 16 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: Responsive.isMobile(context) ? 200 : 300,
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
            ),
            child: Stack(
              children: [
                // Drama poster image
                Positioned.fill(
                  child: drama.poster.startsWith('http')
                      ? Image.network(
                          drama.poster,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.cardGradient,
                              ),
                              child: Icon(
                                Icons.theater_comedy,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          drama.poster,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.cardGradient,
                              ),
                              child: Icon(
                                Icons.theater_comedy,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            );
                          },
                        ),
                ),
                
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Content
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          drama.title,
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, 18),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                drama.genre,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$${drama.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Favorite button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Consumer<LocalDatabaseService>(
                    builder: (context, dbService, _) {
                      final auth = Provider.of<AuthService>(context, listen: false);
                      final isLiked = auth.user != null 
                          ? dbService.isDramaLiked(auth.user!.id, drama.id)
                          : false;
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.white,
                            size: 20,
                          ),
                          onPressed: () async {
                            if (auth.user != null) {
                              if (isLiked) {
                                await dbService.unlikeDrama(auth.user!.id, drama.id);
                              } else {
                                await dbService.likeDrama(auth.user!.id, drama.id);
                              }
                            } else {
                              Navigator.pushNamed(context, AppRouter.login);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadDramas() async {
    try {
      final apiService = Provider.of<FakeApiService>(context, listen: false);
      final dramas = await apiService.getDramas();
      setState(() {
        _dramas = dramas;
        _filteredDramas = dramas;
        _isLoading = false; // Set loading to false when data loads successfully
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading dramas: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _filterDramas(String query) async {
    final databaseService = Provider.of<LocalDatabaseService>(context, listen: false);
    final filteredDramas = await databaseService.searchDramas(
      query, 
      genreFilter: _selectedGenre
    );
    
    setState(() {
      _filteredDramas = filteredDramas;
    });
  }


}