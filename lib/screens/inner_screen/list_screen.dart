import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/providers/address_provider.dart';
import 'package:shop_smart/screens/inner_screen/address.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TitlesTextWidget(label: "My Addresses")),
      body: Consumer<AddressProvider>(
        builder: (ctx, addressProvider, _) {
          if (addressProvider.addresses.isEmpty) {
            return const Center(
              child: SubtitleTextWidget(label: "No addresses yet"),
            );
          }

          return ListView.builder(
            itemCount: addressProvider.addresses.length,
            itemBuilder: (ctx, i) {
              final addr = addressProvider.addresses[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text("${addr.firstName} ${addr.lastName}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📞 ${addr.phoneNumber}"),
                      if (addr.additionalPhoneNumber.isNotEmpty)
                        Text("📞 (Alt) ${addr.additionalPhoneNumber}"),
                      Text("📍 ${addr.city}, ${addr.region}"),
                      if (addr.additionalInfo.isNotEmpty)
                        Text("ℹ️ ${addr.additionalInfo}"),
                      if (addr.isDefault)
                        const Text("⭐ Default Address",
                            style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddressFormScreen(
                                existingAddress: addr,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Delete Address"),
                              content: const Text(
                                  "Are you sure you want to delete this address?"),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete")),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await addressProvider.deleteAddress(addr.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddressFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
