import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_flutter/providers/orders_provider.dart';
import '../widgets/cart_item.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  static const routeName = 'cart_screen';

  @override
  Widget build(BuildContext context) {
    final totalProvider = Provider.of<CartProvider>(context);
    final items = totalProvider.items.values.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:', style: TextStyle(fontSize: 20)),
                  Spacer(flex: 10),
                  Chip(
                    label: Text('\$${totalProvider.getTotalAMount}'),
                    labelStyle: TextStyle(color: Colors.white),
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                  Spacer(flex: 1),
                  FlatButton(
                    onPressed: () {
                      Provider.of<OredersProvider>(context, listen: false).addOrder(
                        items,
                        totalProvider.getTotalAMount,
                      );
                      totalProvider.clear();
                    },
                    child: Text(
                      'Order Now',
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: totalProvider.items.length,
              itemBuilder: (context, index) => CartItemWidget(
                productId: totalProvider.items.keys.toList()[index],
                id: items[index].id,
                price: items[index].price,
                quantity: items[index].quantity,
                title: items[index].title,
              ),
            ),
          )
        ],
      ),
    );
  }
}
