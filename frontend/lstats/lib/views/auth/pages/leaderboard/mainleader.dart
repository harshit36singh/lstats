import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lstats/views/auth/pages/leaderboard/CollegeLeaderboard.dart';
import 'package:lstats/views/auth/pages/leaderboard/groups/create_group_list.dart';
import 'package:lstats/views/auth/pages/leaderboard/leaderboard.dart';
import 'package:iconsax/iconsax.dart';

class MainLeader extends StatefulWidget {
  const MainLeader({super.key});

  @override
  State<MainLeader> createState() => _MainLeaderState();
}

class _MainLeaderState extends State<MainLeader> {
  int _selectedIndex = 0;
    Future<void> fetchLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://lstatsbackend-production.up.railway.app/leaderboard/global',
        ),
      );

      if (response.statusCode == 200) {
      
       
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
      
    }
  }
  Future<void> _refreshData() async {
    try {
      await http.post(
        Uri.parse(
          'https://lstatsbackend-production.up.railway.app/leaderboard/refresh',
        ),
      );
      await fetchLeaderboard();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leaderboard refreshed!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error refreshing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to refresh'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  List<String> tabs = ["Global", "College"];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(
          0xFF2EDF75,
        ), // Same base green as Homescreen
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    
                    Expanded(
                      child:  Row(
                  children: [
                    const Icon(Icons.emoji_events, size: 32, color: Colors.black),
                    const SizedBox(width: 12),
                    const Text(
                      'LEADERBOARD',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _refreshData,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.amberAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      for (int i = 0; i < tabs.length; i++)
                        Expanded(child: _buildTab(tabs[i], i)),
                      GestureDetector(
                        onTap: () async {
                          final newGroupName = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateGroupPage(),
                            ),
                          );
                          if(newGroupName!=null && newGroupName is String){
                            setState(() {
                              tabs.add(newGroupName);
                              _selectedIndex=tabs.length-1;
                            });
                          }
                        },
                        child: Container(
                         
                          width: 60,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          child: const Icon(Iconsax.add,),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Container(
              //   color: Colors.amberAccent,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 20,
              //       vertical: 16,
              //     ),
              //     child: Container(
              //       height: 46,
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         border: Border.all(color: Colors.black, width: 1),
              //       ),
              //       child: Row(
              //         children: [
              //           Expanded(child: _buildTab("Global", 0)),
              //           Expanded(child: _buildTab("College", 1)),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTab(String text, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
  Widget _buildTabContent(){
    if(_selectedIndex==0){
      return _buildBentoWrapper(const Leaderboard(), Colors.white);

    }
    else if(_selectedIndex==1){
      return _buildBentoWrapper(const CollegeLeaderboard(),  const Color(0xFFFFB84D));


    }
    else{
      String groupname=tabs[_selectedIndex];
      return _buildBentoWrapper(Center(
        child: Text("$groupname",style: 
        const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
      ), const Color(0xFFB4E7B0),);
    }
  }
  Widget _buildBentoWrapper(Widget child, Color color) {
    return Container(
      key: ValueKey<int>(_selectedIndex),
      width: double.infinity,
     color: color,
      child: child
    );
  }
}
