import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../models/category_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'auth_screen.dart';

class CreateListingScreen extends StatefulWidget {
  final VoidCallback onListingCreated;

  const CreateListingScreen({super.key, required this.onListingCreated});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _campusLocationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  String _selectedCondition = 'GOOD';
  UserModel? _currentUser;

  XFile? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  bool _isLoadingCategories = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<Map<String, String>> _conditionOptions = [
    {'value': 'NEW', 'label': 'Brand New'},
    {'value': 'LIKE_NEW', 'label': 'Like New'},
    {'value': 'GOOD', 'label': 'Good Condition'},
    {'value': 'FAIR', 'label': 'Fair / Functional'},
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    _currentUser = await StorageService.getUser();
    if (_currentUser != null) {
      if (_currentUser!.phoneNumber != null) {
        _phoneController.text = _currentUser!.phoneNumber!;
      }
      if (_currentUser!.whatsappNumber != null) {
        _whatsappController.text = _currentUser!.whatsappNumber!;
      }
    }

    final fetched = await _apiService.getCategories();
    _categories = fetched.isNotEmpty ? fetched : CategoryModel.defaultCategories;
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }

    if (mounted) {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1440,
        maxHeight: 1440,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() {
        _selectedImage = file;
        _isUploadingImage = true;
        _errorMessage = null;
      });

      final uploadedUrl = await _apiService.uploadImage(file);

      if (mounted) {
        if (uploadedUrl != null) {
          setState(() {
            _uploadedImageUrl = uploadedUrl;
            _isUploadingImage = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product photo uploaded successfully!'),
              backgroundColor: AppColors.secondary,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            _isUploadingImage = false;
            _errorMessage = 'Failed to upload photo to server. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _errorMessage = 'Error picking photo: $e';
        });
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _uploadedImageUrl = null;
      _imageUrlController.clear();
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Add Product Photo',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Capture photo directly with your camera', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Select photo from your phone album', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.link_rounded, color: AppColors.tertiary),
                ),
                title: const Text('Paste Image URL', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Use a direct web link to an image', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showUrlInputDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUrlInputDialog() {
    final tempController = TextEditingController(text: _imageUrlController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Image Web Link'),
        content: TextField(
          controller: tempController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _imageUrlController.text = tempController.text.trim();
                _selectedImage = null;
                _uploadedImageUrl = null;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_currentUser == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuthScreen(
            onLoginSuccess: () {
              Navigator.pop(context);
              _initData();
            },
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() => _errorMessage = 'Please select a category');
      return;
    }

    if (_isUploadingImage) {
      setState(() => _errorMessage = 'Please wait for photo upload to finish');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final price = double.parse(_priceController.text.trim());
      final originalPrice = _originalPriceController.text.trim().isNotEmpty
          ? double.tryParse(_originalPriceController.text.trim())
          : null;

      final finalImageUrl = _uploadedImageUrl ??
          (_imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null);

      await _apiService.createProduct(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        originalPrice: originalPrice,
        conditionGrade: _selectedCondition,
        campusLocation: _campusLocationController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        contactWhatsapp: _whatsappController.text.trim().isNotEmpty
            ? _whatsappController.text.trim()
            : _phoneController.text.trim(),
        imageUrl: finalImageUrl,
        categoryId: _selectedCategory!.id,
      );

      if (mounted) {
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _originalPriceController.clear();
        setState(() {
          _selectedImage = null;
          _uploadedImageUrl = null;
          _imageUrlController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing published successfully!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        widget.onListingCreated();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildPhotoAttachmentSection() {
    final hasImage = _selectedImage != null || _imageUrlController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Product Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            if (hasImage)
              TextButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.edit, size: 14, color: AppColors.primary),
                label: const Text('Change', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (!hasImage)
          InkWell(
            onTap: _isUploadingImage ? null : _showImageSourceDialog,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, size: 28, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Attach Product Photo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Take picture with camera or upload from gallery',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: _selectedImage != null
                      ? (kIsWeb
                          ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                          : Image.file(File(_selectedImage!.path), fit: BoxFit.cover))
                      : Image.network(
                          _imageUrlController.text.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surfaceContainer,
                            child: const Center(child: Icon(Icons.broken_image_rounded, size: 36, color: AppColors.textMuted)),
                          ),
                        ),
                ),
              ),
              if (_isUploadingImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          SizedBox(height: 10),
                          Text(
                            'Uploading photo to server...',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Photo Attached', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    onPressed: _removeImage,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCategories) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post an Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],

              // Photo Attachment Section (Amazon / OLX style)
              _buildPhotoAttachmentSection(),
              const SizedBox(height: 20),

              // Item Title
              const Text('Item Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 16),

              // Category Picker Dropdown
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CategoryModel>(
                    isExpanded: true,
                    value: _selectedCategory,
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Row(
                                children: [
                                  Icon(c.iconData, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(c.name, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price & Original Price
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price (Your Asking)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Required';
                            if (double.tryParse(val) == null) return 'Invalid number';
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Original / Retail (Opt)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _originalPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Condition Grade
              const Text('Item Condition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _conditionOptions.map((opt) {
                  final isSelected = _selectedCondition == opt['value'];
                  return ChoiceChip(
                    label: Text(opt['label']!),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCondition = opt['value']!);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Description
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (val) => val == null || val.trim().length < 10 ? 'At least 10 characters required' : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 16),

              // Campus Pickup Location
              const Text('Campus Pickup Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _campusLocationController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Pickup location is required' : null,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 16),

              // Contact Phone & WhatsApp
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.textMuted, size: 18),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('WhatsApp (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _whatsappController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.chat_rounded, color: AppColors.textMuted, size: 18),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSubmit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.add_shopping_cart_rounded),
                label: const Text('Publish Listing', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
