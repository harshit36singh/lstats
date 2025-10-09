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
  Future<List<String>> fetchclg(String query) async {
    final uri = Uri.parse(
      "https://lstatsbackend-production.up.railway.app/auth/collges?query=$query",
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
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      controller: widget.con,
       hideOnEmpty: true,
  hideOnLoading: false,
  hideOnSelect: true,
  hideKeyboardOnDrag: false, // Keep keyboard available when scrolling
  
  // Add this to keep suggestions visible
  autoFlipDirection: true,
      debounceDuration: const Duration(milliseconds: 200),

      suggestionsCallback: (search) async {
        return await fetchclg(search);
      },

      builder: (context, controller, focusNode) {
        return TextField(
          cursorColor: const Color(0xFFFFA116), // Orange cursor to match theme
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFEFEFEF), // Light text color
          ),
          decoration: InputDecoration(
        
            hintText: "College name or enter 'Other'",
            labelStyle: const TextStyle(
              color: Color(0xFF6B6B6B), // Gray label
              fontWeight: FontWeight.w400,
            ),
            floatingLabelStyle: const TextStyle(
              color: Color(0xFFFFA116), // Orange when focused
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: const Icon(
              Icons.school_outlined,
              color: Color(0xFFFFA116), // Orange icon
              size: 22,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFFFA116), // Orange border when focused
                width: 2,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFF2D2D2D), // Dark background
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        );
      },

      itemBuilder: (context, suggestion) {
        return ListTile(title: Text(suggestion),
        splashColor: Colors.amberAccent,
        tileColor: Colors.black,
        textColor: Colors.white,
        
        );
      },

      onSelected: (suggestion) {
        widget.con.text = suggestion;
      },

      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("No college found..."),
      ),
    );
  }
}
