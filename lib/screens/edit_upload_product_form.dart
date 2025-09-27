import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_smart/helpers/cloudinary_upload.dart';
import 'package:shop_smart/models/product_model.dart';
import 'package:shop_smart/services/my_app_functions.dart';

class EditOrUploadProductScreen extends StatefulWidget {

    static const routName = "/EditOrUploadProductScreen";
  const EditOrUploadProductScreen({Key? key}) : super(key: key);

  @override
  State<EditOrUploadProductScreen> createState() => _EditOrUploadProductScreenState();
}

class _EditOrUploadProductScreenState extends State<EditOrUploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();

  String? _categoryValue;
  XFile? _pickedImage;

  bool _isLoading = false;

  /// Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  /// Upload product
  Future<void> _uploadProduct() async {
    if (_pickedImage == null) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: "Please pick up an image",
        fct: () {},
      );
      return;
    }

    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      // 1. Use product title as Firestore doc ID
      final String productId = _titleController.text.trim().toLowerCase();

      // 2. Check if product already exists
      final existingDoc = await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .get();

      if (existingDoc.exists) {
        setState(() => _isLoading = false);
        MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: "Product with this title already exists!",
          fct: () {},
        );
        return;
      }

      // 3. Upload image to Cloudinary
      final imageUrl =
          await CloudinaryService.uploadImage(File(_pickedImage!.path));
      if (imageUrl == null) throw "Image upload failed";

      // 4. Create product model
      final product = ProductModel(
        productId: productId,
        productTitle: _titleController.text.trim(),
        productPrice: _priceController.text.trim(),
        productCategory: _categoryValue ?? "Uncategorized",
        productDescription: _descriptionController.text.trim(),
        productImage: imageUrl,
        productQuantity: _quantityController.text.trim(),
      );

      // 5. Save to Firestore
      await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .set({
        "productId": product.productId,
        "productTitle": product.productTitle,
        "productPrice": product.productPrice,
        "productCategory": product.productCategory,
        "productDescription": product.productDescription,
        "productImage": product.productImage,
        "productQuantity": product.productQuantity,
        "createdAt": Timestamp.now(),
      });

      // 6. Clear form after success
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Product uploaded successfully!")),
      );
    } catch (e) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: e.toString(),
        fct: () {},
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Clear form fields
  void _clearForm() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    _categoryValue = null;
    _pickedImage = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// Product Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Product Title"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter title" : null,
              ),

              /// Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter price" : null,
              ),

              /// Quantity
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter quantity" : null,
              ),

              /// Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? "Enter description"
                    : null,
              ),

              const SizedBox(height: 12),

              /// Category Dropdown
              DropdownButtonFormField<String>(
                value: _categoryValue,
                hint: const Text("Select Category"),
                items: ["Electronics", "Clothing", "Books", "Uncategorized"]
                    .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _categoryValue = val),
              ),

              const SizedBox(height: 12),

              /// Pick Image Button
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("Pick Image"),
                  ),
                  const SizedBox(width: 10),
                  _pickedImage != null
                      ? Image.file(
                          File(_pickedImage!.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : const Text("No image selected"),
                ],
              ),

              const SizedBox(height: 20),

              /// Upload Button (Disabled while loading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadProduct,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Upload Product"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
