import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

class AutoCompleteField extends StatefulWidget {
  final TextEditingController con;
  const AutoCompleteField({super.key, required this.con});

  @override
  State<AutoCompleteField> createState() => _AutoCompleteFieldState();
}

class _AutoCompleteFieldState extends State<AutoCompleteField> {
  final FocusNode _focusNode = FocusNode();

  Future<List<String>> fetchclg(String query) async {
    final uri = Uri.parse(
      "https://lstats-backend.onrender.com/auth/collges?query=$query",
    );
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => e.toString()).toList();
    } else {
      return [];
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      controller: widget.con,
      focusNode: _focusNode,
      hideOnEmpty: true,
      hideOnLoading: false,
      hideOnSelect: true,

    
    hideWithKeyboard: false, 
      hideOnUnfocus: true, 
      hideKeyboardOnDrag: false, 
      autoFlipDirection: true,
      debounceDuration: const Duration(milliseconds: 200),

      suggestionsCallback: (search) async {
        return await fetchclg(search);
      },

      builder: (context, controller, focusNode) {
        return TextField(
          cursorColor: Colors.black,
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: "College name or enter 'Other'",
           hintStyle: TextStyle(color: const Color(0xFFCCCCCC)),
            border: InputBorder.none,
            filled: true,
            fillColor: const Color.fromARGB(255, 254, 254, 254),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        );
      },

      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
          splashColor: const Color.fromARGB(255, 169, 166, 154),
          tileColor: Colors.white,
          textColor: Colors.black,
        );
      },

      onSelected: (suggestion) {
        widget.con.text = suggestion;
        // Optionally keep list open after selection:
        Future.delayed(const Duration(milliseconds: 100), () {
          _focusNode.requestFocus();
        });
      },

      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("No college found..."),
      ),
    );
  }
}
