import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/models/address_model.dart';
import 'package:shop_smart/providers/address_provider.dart';
import 'package:shop_smart/widgets/app_name_text.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';
import 'package:uuid/uuid.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';

class AddressFormScreen extends StatefulWidget {
  static const routName = "/AddressFormScreen";
  final AddressModel? existingAddress;
  const AddressFormScreen({super.key, this.existingAddress});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final uuid = const Uuid();

  String? _firstName;
  String? _lastName;
  String? _phoneNumber;
  String? _additionalPhoneNumber;
  String? _additionalInfo;
  String? _region; // corresponds to "state" in picker
  String? _city;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );

    // If editing existing address, pre-fill all
    if (widget.existingAddress != null) {
      final a = widget.existingAddress!;
      _firstName = a.firstName;
      _lastName = a.lastName;
      _phoneNumber = a.phoneNumber;
      _additionalPhoneNumber = a.additionalPhoneNumber;
      _additionalInfo = a.additionalInfo;
      _region = a.region;
      _city = a.city;
      _isDefault = a.isDefault;
    } else {
      // Otherwise fetch addresses and auto-populate first three fields
      addressProvider.fetchAddresses().then((_) {
        if (addressProvider.addresses.isNotEmpty) {
          final last = addressProvider.addresses.last;
          setState(() {
            _firstName = last.firstName;
            _lastName = last.lastName;
            _phoneNumber = last.phoneNumber;
          });
        }
      });
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final provider = Provider.of<AddressProvider>(context, listen: false);

    if (widget.existingAddress != null) {
      // Update existing
      final updated = widget.existingAddress!.copyWith(
        firstName: _firstName,
        lastName: _lastName,
        phoneNumber: _phoneNumber,
        additionalPhoneNumber: _additionalPhoneNumber ?? "",
        additionalInfo: _additionalInfo ?? "",
        region: _region ?? "",
        city: _city ?? "",
        isDefault: _isDefault,
      );

      await provider.updateAddress(updated);

      Fluttertoast.showToast(
        msg: "Address updated successfully ✅",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      // Add new
      final newAddress = AddressModel(
        id: "", // let Firestore assign ID
        firstName: _firstName!,
        lastName: _lastName!,
        phoneNumber: _phoneNumber!,
        additionalPhoneNumber: _additionalPhoneNumber ?? "",
        additionalInfo: _additionalInfo ?? "",
        region: _region ?? "",
        city: _city ?? "",
        isDefault: _isDefault,
      );

      await provider.addAddress(newAddress);
      await provider.fetchAddresses();

      Fluttertoast.showToast(
        msg: "Address saved successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppNameTextWidget(fontSize: 20)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              const TitlesTextWidget(label: "Add Address"),
              const SizedBox(height: 20),

              // First Name
              TextFormField(
                initialValue: _firstName,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Required" : null,
                onSaved: (val) => _firstName = val?.trim(),
              ),

              const SizedBox(height: 10),

              // Last Name
              TextFormField(
                initialValue: _lastName,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Required" : null,
                onSaved: (val) => _lastName = val?.trim(),
              ),

              const SizedBox(height: 10),

              // Phone Number
              TextFormField(
                initialValue: _phoneNumber,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Required" : null,
                onSaved: (val) => _phoneNumber = val?.trim(),
              ),

              const SizedBox(height: 10),

              // Additional Phone
              TextFormField(
                initialValue: _additionalPhoneNumber,
                decoration: const InputDecoration(
                  labelText: "Additional Phone",
                ),
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val != null &&
                      val.trim().isNotEmpty &&
                      !val.trim().startsWith("254")) {
                    return "Must start with 254";
                  }
                  return null;
                },
                onSaved: (val) => _additionalPhoneNumber = val?.trim(),
              ),

              const SizedBox(height: 10),

              // Additional Info
              TextFormField(
                initialValue: _additionalInfo,
                decoration: const InputDecoration(labelText: "Additional Info"),
                maxLines: 2,
                onSaved: (val) => _additionalInfo = val?.trim(),
              ),

              const SizedBox(height: 20),

              // Use CSCPickerPlus
              CSCPickerPlus(
                defaultCountry: CscCountry.Kenya,
                disableCountry: true,
                showStates: true,
                showCities: true,
                countryStateLanguage: CountryStateLanguage.englishOrNative,
                cityLanguage: CityLanguage.native,
                flagState: CountryFlag.DISABLE,
                onCountryChanged: (country) {
                  // Not used; country locked
                },
                onStateChanged: (state) {
                  setState(() {
                    _region = state;
                    // reset city when region changes
                    _city = null;
                  });
                },
                onCityChanged: (city) {
                  setState(() {
                    _city = city;
                  });
                },
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                disabledDropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade200,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (val) {
                      setState(() => _isDefault = val ?? false);
                    },
                  ),
                  const SubtitleTextWidget(label: "Set as Default Address"),
                ],
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveForm,
                child: Text(
                  widget.existingAddress != null
                      ? "Update Address"
                      : "Save Address",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
