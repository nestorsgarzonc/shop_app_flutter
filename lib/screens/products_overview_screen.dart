import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import './cart_screen.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';

enum FilterOptions { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  static const routeName = 'product_overview';

  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  @override
  void initState() {
    Provider.of<ProductProvider>(context, listen: false).fetchAndSetProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final providerProducts = Provider.of<ProductProvider>(context, listen: false);
    final providerCart = Provider.of<CartProvider>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('NW shop'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions value) {
              switch (value) {
                case FilterOptions.All:
                  providerProducts.favoritesOnly = false;
                  break;
                case FilterOptions.Favorites:
                  providerProducts.favoritesOnly = true;
                  break;
                default:
              }
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('Only Favorites'), value: FilterOptions.Favorites),
              PopupMenuItem(
                child: Text('Show all'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Badge(
            color: Colors.redAccent,
            value: '${providerCart.itemCount}',
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () => Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
          )
        ],
      ),
      body: ProductsGrid(),
    );
  }
}
