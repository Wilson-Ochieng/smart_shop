import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class OrdersWidgetFree extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrdersWidgetFree({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Get products from Firestore order
    final List<Map<String, dynamic>> products =
        List<Map<String, dynamic>>.from(orderData['products']);

    final firstProduct = products.isNotEmpty ? products.first : {};
    final imageUrl = firstProduct['image'] ?? '';
    final title = firstProduct['title'] ?? 'Unknown Product';
    final price = firstProduct['price'] ?? '0.0';
    final qty = firstProduct['quantity'] ?? 1;

    final totalAmount = orderData['totalAmount'].toString();
    final status = orderData['status'] ?? 'pending';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FancyShimmerImage(
                height: size.width * 0.25,
                width: size.width * 0.25,
                boxFit: BoxFit.cover,
                imageUrl: imageUrl.isNotEmpty ? imageUrl : "https://via.placeholder.com/150",
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TitlesTextWidget(
                            label: title,
                            maxLines: 2,
                            fontSize: 15,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // optional: cancel order or remove item
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ],
                    ),

                    // Price
                    Row(
                      children: [
                        const TitlesTextWidget(
                          label: 'Price: ',
                          fontSize: 15,
                        ),
                        Flexible(
                          child: SubtitleTextWidget(
                            label: "$price Ksh",
                            fontSize: 15,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Quantity
                    SubtitleTextWidget(
                      label: "Qty: $qty",
                      fontSize: 15,
                    ),

                    const SizedBox(height: 5),

                    // Order info
                    SubtitleTextWidget(
                      label: "Total: Ksh $totalAmount",
                      fontSize: 14,
                      color: Colors.green,
                    ),
                    SubtitleTextWidget(
                      label: "Status: $status",
                      fontSize: 14,
                      color: status == "pending"
                          ? Colors.orange
                          : status == "delivered"
                              ? Colors.green
                              : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
