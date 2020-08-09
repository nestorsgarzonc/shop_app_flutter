import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_flutter/providers/products_provider.dart';
import '../providers/product_model.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'EditProductScreen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _editedProduct = Product(id: null, description: '', imageUrl: ' ', price: 0, title: '');
  bool isInit = true;
  bool isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final String productId = ModalRoute.of(context).settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<ProductProvider>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': _editedProduct.imageUrl,
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode?.dispose();
    _descriptionFocusNode?.dispose();
    _imageUrlController?.dispose();
    _imageUrlFocusNode?.dispose();
    _imageUrlFocusNode?.removeListener(_updateImage);
    super.dispose();
  }

  void _updateImage() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _saveForm() async {
      setState(() => isLoading = true);
      final isValid = _formKey.currentState.validate();
      final prov = Provider.of<ProductProvider>(context, listen: false);
      if (!isValid) {
        return;
      }
      if (_editedProduct.id != null) {
      } else {
        prov.updateProduct(_editedProduct.id, _editedProduct);
        setState(() => isLoading = false);
        Navigator.of(context).pop();
      }
      _formKey.currentState.save();
      await  prov.addProduct(_editedProduct).catchError((e) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('An error ocurred'),
            content: Text(e.toString()),
            actions: [
              FlatButton(
                child: Text('Okay'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }).then((value) {
        setState(() => isLoading = false);
        Navigator.of(context).pop();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit product'),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.save_alt), onPressed: _saveForm)],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                autovalidate: true,
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Provide a value';
                        } else {
                          return null;
                        }
                      },
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_priceFocusNode),
                      onChanged: (value) => _editedProduct = Product(
                        id: _editedProduct.id,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                        price: _editedProduct.price,
                        title: value,
                      ),
                    ),
                    TextFormField(
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_descriptionFocusNode),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Provide a price';
                        } else if (double.tryParse(value) < 0) {
                          return 'Price is greater than zero';
                        } else if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        } else {
                          return null;
                        }
                      },
                      focusNode: _priceFocusNode,
                      onChanged: (value) => _editedProduct = Product(
                        id: _editedProduct.id,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        price: double.parse(value),
                        title: _editedProduct.title,
                      ),
                    ),
                    TextFormField(
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_imageUrlFocusNode),
                      keyboardType: TextInputType.multiline,
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter a description';
                        } else if (value.length < 10) {
                          return 'Should be grater than 10 caracters';
                        } else {
                          return null;
                        }
                      },
                      focusNode: _descriptionFocusNode,
                      onChanged: (value) => _editedProduct = Product(
                        id: _editedProduct.id,
                        description: value,
                        imageUrl: _editedProduct.imageUrl,
                        price: _editedProduct.price,
                        title: _editedProduct.title,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration:
                              BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL', textAlign: TextAlign.center)
                              : FittedBox(
                                  child: Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            focusNode: _imageUrlFocusNode,
                            controller: _imageUrlController,
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            //initialValue: _initValues['imageUrl'],
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter a image URL';
                              } else if (!value.startsWith('http') && !value.startsWith('https')) {
                                return 'Invalid url';
                              } else {
                                return null;
                              }
                            },
                            onFieldSubmitted: (value) => _saveForm(),
                            onChanged: (value) => _editedProduct = Product(
                              id: _editedProduct.id,
                              description: _editedProduct.description,
                              imageUrl: value,
                              price: _editedProduct.price,
                              title: _editedProduct.title,
                              isFavorite: _editedProduct.isFavorite,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
