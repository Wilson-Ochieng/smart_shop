import 'package:flutter/material.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class CartBottomSheetWidget extends StatelessWidget {
  const CartBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(width: 1, color: Colors.grey)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: kBottomNavigationBarHeight + 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    FittedBox(
                      child: TitlesTextWidget(
                        label: "Total (6 products/9 items)",
                      ),
                    ),
                    SubtitleTextWidget(label: "16.0\$", color: Colors.blue),
                  ],
                ),
              ),
              ElevatedButton(onPressed: () {}, child: const Text("Checkout")),
            ],
          ),
        ),
      ),
    );
  }
}
