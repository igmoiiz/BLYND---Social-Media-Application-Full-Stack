import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/Controller/Services/Authentication/auth_services.dart';
import 'package:social_media/Model/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchCurrentUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUser() async {
    final authService = Provider.of<AuthServices>(context, listen: false);

    try {
      // In a real app, you would have a method to get the current user
      // For now, we'll just simulate a delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Get current Firebase user
      final currentUser = authService.auth.currentUser;

      if (currentUser != null) {
        // Fetch user data from Firestore
        final userDoc =
            await authService.fireStore
                .collection('users')
                .doc(currentUser.uid)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _currentUser = UserModel.fromJson(userData);
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.secondary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BLYND',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colorScheme.primary),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: colorScheme.primary,
            ),
            onPressed: () {
              // Notifications
            },
          ),
        ],
        elevation: 0,
        backgroundColor: colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.secondary,
          labelColor: colorScheme.secondary,
          unselectedLabelColor: colorScheme.primary.withOpacity(0.6),
          tabs: const [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.explore)),
            Tab(icon: Icon(Icons.message)),
            Tab(icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(),
          _buildExploreTab(),
          _buildMessagesTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new post
        },
        backgroundColor: colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFeedTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 5, // Sample posts
      itemBuilder: (context, index) {
        return _buildPostCard(index);
      },
    );
  }

  Widget _buildExploreTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey[300],
          child: Center(child: Icon(Icons.image, color: Colors.grey[600])),
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Messages Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect with friends to start chatting',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Profile image
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: colorScheme.secondary.withOpacity(0.2),
                      backgroundImage:
                          _currentUser?.profileImage != null &&
                                  _currentUser!.profileImage!.isNotEmpty
                              ? NetworkImage(_currentUser!.profileImage!)
                              : null,
                      child:
                          _currentUser?.profileImage == null ||
                                  _currentUser!.profileImage!.isEmpty
                              ? Icon(
                                Icons.person,
                                size: 40,
                                color: colorScheme.secondary,
                              )
                              : null,
                    ),
                    const SizedBox(width: 16),
                    // User info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.name ?? 'User',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${_currentUser?.userName ?? 'username'}',
                            style: TextStyle(
                              color: colorScheme.primary.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Age: ${_currentUser?.age ?? ''}',
                            style: TextStyle(
                              color: colorScheme.primary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Posts', '0'),
                    _buildStatColumn('Followers', '0'),
                    _buildStatColumn('Following', '0'),
                  ],
                ),
                const SizedBox(height: 16),
                // Edit profile button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Edit profile
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.secondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      // Show confirmation dialog
                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        final authService = Provider.of<AuthServices>(
                          context,
                          listen: false,
                        );

                        // Sign out
                        await authService.auth.signOut();

                        // Navigate to login screen
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // My Posts header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'My Posts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),

          // No posts placeholder
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.post_add,
                    size: 64,
                    color: colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Posts Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your posts will appear here',
                    style: TextStyle(
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String count) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: colorScheme.primary.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildPostCard(int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondary.withOpacity(0.2),
              child: Icon(Icons.person, color: colorScheme.secondary),
            ),
            title: Text(
              'Sample User',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            subtitle: Text(
              '2 hours ago',
              style: TextStyle(
                color: colorScheme.primary.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: colorScheme.primary.withOpacity(0.7),
              ),
              onPressed: () {},
            ),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'This is a sample post #${index + 1}. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
              style: TextStyle(color: colorScheme.primary.withOpacity(0.8)),
            ),
          ),

          // Post image (placeholder)
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(Icons.image, size: 48, color: Colors.grey[600]),
            ),
          ),

          // Post actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                  onPressed: () {},
                ),
                Text(
                  '0',
                  style: TextStyle(color: colorScheme.primary.withOpacity(0.7)),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                  onPressed: () {},
                ),
                Text(
                  '0',
                  style: TextStyle(color: colorScheme.primary.withOpacity(0.7)),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:social_media/Controller/Services/Authentication/auth_services.dart';
// import 'package:social_media/Model/user_model.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   UserModel? _currentUser;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _fetchCurrentUser();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchCurrentUser() async {
//     final authService = Provider.of<AuthServices>(context, listen: false);
    
//     try {
//       // In a real app, you would have a method to get the current user
//       // For now, we'll just simulate a delay
//       await Future.delayed(const Duration(milliseconds: 500));
      
//       // Get current Firebase user
//       final currentUser = authService.auth.currentUser;
      
//       if (currentUser != null) {
//         // Fetch user data from Firestore
//         final userDoc = await authService._fireStore
//             .collection('users')
//             .doc(currentUser.uid)
//             .get();
        
//         if (userDoc.exists) {
//           final userData = userDoc.data() as Map<String, dynamic>;
//           setState(() {
//             _currentUser = UserModel.fromJson(userData);
//             _isLoading = false;
//           });
//           return;
//         }
//       }
      
//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
    
//     if (_isLoading) {
//       return Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(
//             color: colorScheme.secondary,
//           ),
//         ),
//       );
//     }
    
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'BLYND',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: colorScheme.primary,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: colorScheme.primary),
//             onPressed: () {
//               // Search functionality
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.notifications_outlined, color: colorScheme.primary),
//             onPressed: () {
//               // Notifications
//             },
//           ),
//         ],
//         elevation: 0,
//         backgroundColor: colorScheme.surface,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: colorScheme.secondary,
//           labelColor: colorScheme.secondary,
//           unselectedLabelColor: colorScheme.primary.withOpacity(0.6),
//           tabs: const [
//             Tab(icon: Icon(Icons.home)),
//             Tab(icon: Icon(Icons.explore)),
//             Tab(icon: Icon(Icons.message)),
//             Tab(icon: Icon(Icons.person)),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildFeedTab(),
//           _buildExploreTab(),
//           _buildMessagesTab(),
//           _buildProfileTab(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Create new post
//         },
//         backgroundColor: colorScheme.secondary,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildFeedTab() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: 5, // Sample posts
//       itemBuilder: (context, index) {
//         return _buildPostCard(index);
//       },
//     );
//   }

//   Widget _buildExploreTab() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(8),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 4,
//         mainAxisSpacing: 4,
//       ),
//       itemCount: 30,
//       itemBuilder: (context, index) {
//         return Container(
//           color: Colors.grey[300],
//           child: Center(
//             child: Icon(
//               Icons.image,
//               color: Colors.grey[600],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMessagesTab() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.message_outlined,
//             size: 80,
//             color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No Messages Yet',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Connect with friends to start chatting',
//             style: TextStyle(
//               color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileTab() {
//     final colorScheme = Theme.of(context).colorScheme;
    
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Profile header
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: colorScheme.surface,
//               boxShadow: [
//                 BoxShadow(
//                   color: colorScheme.primary.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     // Profile image
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundColor: colorScheme.secondary.withOpacity(0.2),
//                       backgroundImage: _currentUser?.profileImage != null && 
//                                       _currentUser!.profileImage!.isNotEmpty
//                           ? NetworkImage(_currentUser!.profileImage!)
//                           : null,
//                       child: _currentUser?.profileImage == null || 
//                              _currentUser!.profileImage!.isEmpty
//                           ? Icon(
//                               Icons.person,
//                               size: 40,
//                               color: colorScheme.secondary,
//                             )
//                           : null,
//                     ),
//                     const SizedBox(width: 16),
//                     // User info
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             _currentUser?.name ?? 'User',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: colorScheme.primary,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             '@${_currentUser?.userName ?? 'username'}',
//                             style: TextStyle(
//                               color: colorScheme.primary.withOpacity(0.7),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Age: ${_currentUser?.age ?? ''}',
//                             style: TextStyle(
//                               color: colorScheme.primary.withOpacity(0.7),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Stats row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildStatColumn('Posts', '0'),
//                     _buildStatColumn('Followers', '0'),
//                     _buildStatColumn('Following', '0'),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Edit profile button
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       // Edit profile
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: colorScheme.secondary),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       'Edit Profile',
//                       style: TextStyle(color: colorScheme.secondary),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 // Logout button
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () async {
//                       // Show confirmation dialog
//                       final bool? confirm = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: const Text('Logout'),
//                           content: const Text('Are you sure you want to logout?'),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, false),
//                               child: Text(
//                                 'Cancel',
//                                 style: TextStyle(color: colorScheme.primary),
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, true),
//                               child: Text(
//                                 'Logout',
//                                 style: TextStyle(color: colorScheme.error),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
                      
//                       if (confirm == true) {
//                         final authService = Provider.of<AuthServices>(
//                           context, 
//                           listen: false
//                         );
                        
//                         // Sign out
//                         await authService.auth.signOut();
                        
//                         // Navigate to login screen
//                         Navigator.pushNamedAndRemoveUntil(
//                           context, 
//                           '/login', 
//                           (route) => false
//                         );
//                       }
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: colorScheme.error),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       'Logout',
//                       style: TextStyle(color: colorScheme.error),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // My Posts header
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               'My Posts',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: colorScheme.primary,
//               ),
//             ),
//           ),
          
//           // No posts placeholder
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.all(32.0),
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.post_add,
//                     size: 64,
//                     color: colorScheme.primary.withOpacity(0.3),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No Posts Yet',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: colorScheme.primary.withOpacity(0.7),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Your posts will appear here',
//                     style: TextStyle(
//                       color: colorScheme.primary.withOpacity(0.5),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatColumn(String title, String count) {
//     final colorScheme = Theme.of(context).colorScheme;
    
//     return Column(
//       children: [
//         Text(
//           count,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: colorScheme.primary,
//           ),
//         ),
//         Text(
//           title,
//           style: TextStyle(
//             color: colorScheme.primary.withOpacity(0.7),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPostCard(int index) {
//     final colorScheme = Theme.of(context).colorScheme;
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(
//           color: colorScheme.primary.withOpacity(0.1),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Post header
//           ListTile(
//             leading: CircleAvatar(
//               backgroundColor: colorScheme.secondary.withOpacity(0.2),
//               child: Icon(
//                 Icons.person,
//                 color: colorScheme.secondary,
//               ),
//             ),
//             title: Text(
//               'Sample User',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: colorScheme.primary,
//               ),
//             ),
//             subtitle: Text(
//               '2 hours ago',
//               style: TextStyle(
//                 color: colorScheme.primary.withOpacity(0.6),
//                 fontSize: 12,
//               ),
//             ),
//             trailing: IconButton(
//               icon: Icon(
//                 Icons.more_vert,
//                 color: colorScheme.primary.withOpacity(0.7),
//               ),
//               onPressed: () {},
//             ),
//           ),
          
//           // Post content
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               'This is a sample post #${index + 1}. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
//               style: TextStyle(
//                 color: colorScheme.primary.withOpacity(0.8),
//               ),
//             ),
//           ),
          
//           // Post image (placeholder)
//           Container(
//             height: 200,
//             margin: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Center(
//               child: Icon(
//                 Icons.image,
//                 size: 48,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
          
//           // Post actions
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     Icons.favorite_border,
//                     color: colorScheme.primary.withOpacity(0.7),
//                   ),
//                   onPressed: () {},
//                 ),
//                 Text(
//                   '0',
//                   style: TextStyle(
//                     color: colorScheme.primary.withOpacity(0.7),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 IconButton(
//                   icon: Icon(
//                     Icons.chat_bubble_outline,
//                     color: colorScheme.primary.withOpacity(0.7),
//                   ),
//                   onPressed: () {},
//                 ),
//                 Text(
//                   '0',
//                   style: TextStyle(
//                     color: colorScheme.primary.withOpacity(0.7),
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: Icon(
//                     Icons.share_outlined,
//                     color: colorScheme.primary.withOpacity(0.7),
//                   ),
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   }