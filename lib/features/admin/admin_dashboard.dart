import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/drama.dart';
import '../../services/auth_service.dart';
import '../../services/local_database_service.dart';
import '../../utils/responsive.dart';
import '../../app/theme.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

  class _AdminDashboardState extends State<AdminDashboard>
      with TickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _genreController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _posterController = TextEditingController();
    final _showTimesController = TextEditingController();
    final _priceController = TextEditingController();
    final _durationController = TextEditingController();
    StreamSubscription<List<Drama>>? _dramaSubscription;
    List<Drama> _dramas = [];
    bool _isLoading = false;
    File? _selectedImage;
    final ImagePicker _imagePicker = ImagePicker();
    late AnimationController _animationController;
    late AnimationController _formAnimationController;
    late Animation<double> _fadeAnimation;
    late Animation<double> _slideAnimation;
    late Animation<double> _formAnimation;

    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );
      _formAnimationController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
      );
      _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _formAnimationController, curve: Curves.elasticOut),
      );
      _loadDramas();
      _animationController.forward();
    }

    void _loadDramas() {
      final databaseService = Provider.of<LocalDatabaseService>(context, listen: false);
      try {
        final dramasStream = databaseService.getDramasStream();
        _dramaSubscription = dramasStream.listen((dramas) {
          if (mounted) {
            setState(() {
              _dramas = dramas;
            });
          }
        });
      } catch (e) {
        print('Error loading dramas: $e');
      }
    }

    @override
    Widget build(BuildContext context) {
      final auth = Provider.of<AuthService>(context);

      // Role check - redirect if not admin
      if (auth.user?.role != 'admin') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/home');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Access denied. Admin privileges required.')),
          );
        });
        return Scaffold(
          appBar: AppBar(title: Text('Access Denied')),
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: Responsive.isMobile(context) ? 120 : 150,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: Text(
                                      'Admin Dashboard',
                                      style: TextStyle(
                                        fontSize: Responsive.getFontSize(context, 24),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: _fadeAnimation.value,
                                        child: _buildActionButton(
                                          Icons.refresh,
                                          _loadDramas,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Transform.scale(
                                        scale: _fadeAnimation.value,
                                        child: _buildActionButton(
                                          Icons.logout,
                                          () async {
                                            await auth.signOut();
                                            Navigator.pushReplacementNamed(context, '/login');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Text(
                                    'Manage your drama collection',
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(context, 16),
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
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

            // Add Drama Form
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Padding(
                        padding: Responsive.getPadding(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.add_circle_outline,
                                        color: AppTheme.primaryColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Add New Drama',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: Responsive.getFontSize(context, 20),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _titleController,
                                        decoration: InputDecoration(
                                          labelText: 'Drama Title',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Please enter title';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: _genreController,
                                        decoration: InputDecoration(
                                          labelText: 'Genre',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Please enter genre';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: _descriptionController,
                                        decoration: InputDecoration(
                                          labelText: 'Description',
                                          border: OutlineInputBorder(),
                                        ),
                                        maxLines: 3,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Please enter description';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      // Image Upload Section
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            if (_selectedImage != null) ...[
                                              Container(
                                                height: 200,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                                  child: Image.file(
                                                    _selectedImage!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Poster Image Selected',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _selectedImage = null;
                                                          _posterController.clear();
                                                        });
                                                      },
                                                      child: Text('Remove'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ] else ...[
                                              InkWell(
                                                onTap: _pickImage,
                                                child: Container(
                                                  height: 120,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[50],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.cloud_upload_outlined,
                                                        size: 48,
                                                        color: AppTheme.primaryColor,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'Upload Drama Poster',
                                                        style: TextStyle(
                                                          color: AppTheme.primaryColor,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        'Tap to select image',
                                                        style: TextStyle(
                                                          color: Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Or enter poster URL manually:',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: _posterController,
                                        decoration: InputDecoration(
                                          labelText: 'Poster URL (Optional)',
                                          border: OutlineInputBorder(),
                                          hintText: 'https://example.com/poster.jpg',
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: _showTimesController,
                                        decoration: InputDecoration(
                                          labelText: 'Show Times (comma separated)',
                                          border: OutlineInputBorder(),
                                          hintText: '7:00 PM, 9:00 PM',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Please enter show times';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: _priceController,
                                        decoration: InputDecoration(
                                          labelText: 'Price',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Please enter price';
                                          }
                                          if (double.tryParse(value) == null) {
                                            return 'Please enter valid price';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: _durationController,
                                        decoration: InputDecoration(
                                          labelText: 'Duration (minutes)',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Please enter duration';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Please enter valid duration';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          onPressed: _isLoading ? null : _addDrama,
                                          icon: _isLoading
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            : Icon(Icons.add),
                                          label: Text(_isLoading ? 'Adding...' : 'Add Drama'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Existing Dramas List
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.getPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    Text(
                      'Manage Existing Dramas',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    if (_dramas.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.theater_comedy, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No dramas found'),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _dramas.length,
                        itemBuilder: (context, index) {
                          Drama drama = _dramas[index];
                          return Card(
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  child: drama.poster.startsWith('http')
                                      ? Image.network(
                                          drama.poster,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: Icon(Icons.theater_comedy, color: Colors.grey[600]),
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          drama.poster,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: Icon(Icons.theater_comedy, color: Colors.grey[600]),
                                            );
                                          },
                                        ),
                                ),
                              ),
                              title: Text(drama.title),
                              subtitle: Text('${drama.genre} • \$${drama.price.toStringAsFixed(0)}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDrama(drama.id),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Future<void> _addDrama() async {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final databaseService = Provider.of<LocalDatabaseService>(context, listen: false);
        
        final showTimes = _showTimesController.text
            .split(',')
            .map((time) => time.trim())
            .where((time) => time.isNotEmpty)
            .toList();

        if (showTimes.isEmpty) {
          throw Exception('Please enter at least one show time');
        }

        // Determine poster path - use selected image or URL
        String posterPath;
        if (_selectedImage != null) {
          // For demo purposes, we'll use a placeholder path
          // In a real app, you'd upload the image to a server or save it locally
          posterPath = 'assets/images/uploaded_${DateTime.now().millisecondsSinceEpoch}.jpg';
        } else if (_posterController.text.trim().isNotEmpty) {
          posterPath = _posterController.text.trim();
        } else {
          throw Exception('Please select an image or enter a poster URL');
        }

        final drama = Drama(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          genre: _genreController.text.trim(),
          description: _descriptionController.text.trim(),
          poster: posterPath,
          showTimes: showTimes,
          price: double.tryParse(_priceController.text.trim()) ?? 0.0,
          duration: _durationController.text.trim(),
        );

        await databaseService.initDatabase(); // Ensure database is initialized
        await databaseService.addDrama(drama);
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Drama added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding drama: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    Future<void> _deleteDrama(String dramaId) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this drama?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final databaseService = Provider.of<LocalDatabaseService>(context, listen: false);
        try {
          await databaseService.deleteDrama(dramaId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drama deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting drama: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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

    Future<void> _pickImage() async {
      try {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        
        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
            // Clear URL field when image is selected
            _posterController.clear();
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    void _clearForm() {
      _titleController.clear();
      _genreController.clear();
      _descriptionController.clear();
      _posterController.clear();
      _showTimesController.clear();
      _priceController.clear();
      _durationController.clear();
      _selectedImage = null;
      _formKey.currentState?.reset();
    }

    @override
    void dispose() {
      _dramaSubscription?.cancel();
      _titleController.dispose();
      _genreController.dispose();
      _descriptionController.dispose();
      _posterController.dispose();
      _showTimesController.dispose();
      _priceController.dispose();
      _durationController.dispose();
      _animationController.dispose();
      _formAnimationController.dispose();
      super.dispose();
    }
  }