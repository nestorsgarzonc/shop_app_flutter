import 'package:flutter/material.dart';
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
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImage);
    super.initState();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImage);
    super.dispose();
  }

  void _updateImage() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() {
    _formKey.currentState.save();
    print(_editedProduct.id);
    print(_editedProduct.title);
    print(_editedProduct.description);
    print(_editedProduct.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit product'),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.save_alt), onPressed: _saveForm)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'Title'),
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_priceFocusNode),
                onChanged: (value) => _editedProduct = Product(
                  id: _editedProduct.id,
                  description: _editedProduct.description,
                  imageUrl: _editedProduct.imageUrl,
                  price: _editedProduct.price,
                  title: value,
                ),
              ),
              TextFormField(
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_descriptionFocusNode),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'Price'),
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
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_imageUrlFocusNode),
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                focusNode: _descriptionFocusNode,
                onChanged: (value) => _editedProduct = Product(
                  id: _editedProduct.id,
                  description: value,
                  imageUrl: _editedProduct.imageUrl,
                  price: _editedProduct.price,
                  title: _editedProduct.title,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
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
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) => _saveForm(),
                      onChanged: (value) => _editedProduct = Product(
                        id: _editedProduct.id,
                        description: _editedProduct.description,
                        imageUrl: value,
                        price: _editedProduct.price,
                        title: _editedProduct.title,
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
