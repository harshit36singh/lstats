import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}
//https://chatgpt.com/c/690833cf-b8ec-8320-aeb7-ace47b3ced74

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController name=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E0),
      appBar: AppBar(
        title: Text("Create Group",style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Enter Group Name",
          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
          ),
          const SizedBox(height: 10,),
          TextField(
            controller: name,
            decoration: InputDecoration(
              hintText: "e.g. Coders"
              ,border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white
            )
          ),
          const SizedBox(height: 30,),
          ElevatedButton.icon(
            icon:Icon(Icons.check),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 14)
            ),
            onPressed: (){
              final n=name.text.trim();
              if(n.isNotEmpty){
                Navigator.pop(context,n);
              }

            }, label: const Text("Create"))
        ],
      ),
      ),
    );
  }
}