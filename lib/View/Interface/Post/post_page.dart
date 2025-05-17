// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:social_media/Controller/input_controllers.dart';
import 'package:social_media/Utils/Components/custom_button.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  //  Instance for Input Controllers
  final InputControllers _inputControllers = InputControllers();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness;
    return Scaffold(
      body: CustomScrollView(
        physics: ScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.of(context).size.height * .4,
              margin: EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [Icon(Iconsax.image), Text("Tap to add a Image")],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.035,
              ),
              child: Column(
                spacing: 15,
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This Field can\'t be Empty!';
                      } else {
                        return null;
                      }
                    },
                    controller: _inputControllers.titleController,
                    style:
                        isDark == Brightness.dark
                            ? TextStyle(color: Colors.white)
                            : TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Enter a Caption",
                      hintText: "Enter a Caption",
                      prefixIcon: Icon(Icons.short_text),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignLabelWithHint: true,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 1,
                  ),
                ],
              ),
            ),
          ),
          //  Submit Button
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.sizeOf(context).height * 0.02,
                horizontal: MediaQuery.sizeOf(context).width * 0.035,
              ),
              child: CustomButton(
                isLoading: _inputControllers.isLoading,
                text: "Post",
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
