import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Groupleaderboard extends StatefulWidget {
  final int groupid;
  final String groupname;
  const Groupleaderboard({
    super.key,
    required this.groupid,
    required this.groupname,
  });

  @override
  State<Groupleaderboard> createState() => _GroupleaderboardState();
}

class _GroupleaderboardState extends State<Groupleaderboard> {
  List<dynamic> l = [];
  bool isLoading = true;

  Future<void> fetchgroupleaderboard() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://lstats-railway-backend-production.up.railway.app/leaderboard/group/${widget.groupid}',
        ),
      );

     if(res.statusCode==200){
      setState(() {
        l=jsonDecode(res.body);
        isLoading=false;
      });
     }
     else{
      print("failed to load leaderboard : ${res.body}");
     } 
    } catch (e) {

      print("$e");
    }
  }


@override
  void initState() {
    super.initState();
    fetchgroupleaderboard();
  }
  @override
  Widget build(BuildContext context) {


    if(isLoading){
      return const Center(child: Text("No members in this group."),);
    }

    if(l.isEmpty){
      return const Center(child: Text("No members in this group"),);
    }
    return  Column(
      children: [
        Container(
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          width: double.infinity,
          child: Text(
            widget.groupname.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: l.length,
            itemBuilder: (context, i) {
              final user = l[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['avatar'] != null &&
                          user['avatar'].toString().isNotEmpty
                      ? NetworkImage(user['avatar'])
                      : null,
                  backgroundColor: Colors.black12,
                  child: Text(
                    '${user['rank']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(user['username']),
                subtitle: Text(user['clg'] ?? ''),
                trailing: Text(
                  "${user['points']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
