import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_data_manager.dart';

class CommunityTipsForum extends StatefulWidget {
  const CommunityTipsForum({super.key});

  @override
  State<CommunityTipsForum> createState() => _CommunityTipsForumState();
}

class _CommunityTipsForumState
    extends State<CommunityTipsForum> {
  @override
  void initState() {
    super.initState();
    loadTips();
  }

  Future<void> loadTips() async {
    try {

      final snapshot =
      await FirebaseFirestore.instance
          .collection('community_tips')
          .orderBy(
        'datePosted',
        descending: true,
      )
          .get();

      _pastTips.clear();

      for (var doc in snapshot.docs) {

        final data = doc.data();

        final likedUsers =
        data.containsKey('likedUsers')
            ? List<String>.from(
          data['likedUsers'],
        )
            : <String>[];

        final dislikedUsers =
        data.containsKey('dislikedUsers')
            ? List<String>.from(
          data['dislikedUsers'],
        )
            : <String>[];

        final userId =
            FirebaseAuth.instance
                .currentUser
                ?.uid;

        _pastTips.add({
          'id': doc.id,
          'postedBy': doc['postedBy'],
          'title': doc['title'],
          'summary': doc['summary'],
          'datePosted':
          (doc['datePosted'] as Timestamp)
              .toDate(),
          'likes': doc['likes'],
          'dislikes': doc['dislikes'],
          'comments':
          List<String>.from(
              doc['comments']),
          'likedUsers': likedUsers,

          'dislikedUsers': dislikedUsers,

          'isLiked':
          likedUsers.contains(
            userId,
          ),

          'isDisliked':
          dislikedUsers.contains(
            userId,
          ),
        });
      }

      if (!mounted) return;

      setState(() {});

    } catch (e) {

      debugPrint(
        'Error loading tips: $e',
      );
    }
  }
  String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hour ago";
    } else {
      return "${difference.inDays} day ago";
    }
  }

  String searchText = '';
  final List<Map<String, dynamic>> _pastTips = [];

  Future<void> _handleLike(int index) async {

    final userId =
        FirebaseAuth.instance
            .currentUser
            ?.uid;

    if (userId == null) return;

    setState(() {
      if (_pastTips[index]['isLiked']) {

        _pastTips[index]['likes']--;
        _pastTips[index]['isLiked'] = false;

        _pastTips[index]['likedUsers']
            .remove(userId);
      } else {

        _pastTips[index]['likes']++;
        _pastTips[index]['isLiked'] = true;

        _pastTips[index]['likedUsers']
            .add(userId);

        if (_pastTips[index]['isDisliked']) {

          _pastTips[index]['dislikes']--;
          _pastTips[index]['isDisliked'] = false;

          _pastTips[index]['dislikedUsers']
              .remove(userId);
        }
      }
    });

    try {

      await FirebaseFirestore.instance
          .collection('community_tips')
          .doc(_pastTips[index]['id'])
          .update({
        'likes':
        _pastTips[index]['likes'],

        'dislikes':
        _pastTips[index]['dislikes'],

        'likedUsers':
        _pastTips[index]
        ['likedUsers'],

        'dislikedUsers':
        _pastTips[index]
        ['dislikedUsers'],
      });

    } catch (e) {

      debugPrint(
        'Error saving like: $e',
      );
    }
  }

  Future<void> _handleDislike(int index) async {
    final userId =
        FirebaseAuth.instance
            .currentUser
            ?.uid;

    if (userId == null) return;

    setState(() {

      if (_pastTips[index]['isDisliked']) {

        _pastTips[index]['dislikes']--;
        _pastTips[index]['isDisliked'] = false;

        _pastTips[index]['dislikedUsers']
            .remove(userId);

      } else {

        _pastTips[index]['dislikes']++;
        _pastTips[index]['isDisliked'] = true;

        _pastTips[index]['dislikedUsers']
            .add(userId);

        if (_pastTips[index]['isLiked']) {

          _pastTips[index]['likes']--;
          _pastTips[index]['isLiked'] = false;

          _pastTips[index]['likedUsers']
              .remove(userId);
        }
      }
    });

    try {

      await FirebaseFirestore.instance
          .collection('community_tips')
          .doc(_pastTips[index]['id'])
          .update({
        'likes': _pastTips[index]['likes'],
        'dislikes': _pastTips[index]['dislikes'],
        'likedUsers':
        _pastTips[index]['likedUsers'],
        'dislikedUsers':
        _pastTips[index]['dislikedUsers'],
      });

    } catch (e) {

      debugPrint(
        'Error saving dislike: $e',
      );
    }
  }

  void _showCommentSection(BuildContext context, int index) {
    final TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comments on "${_pastTips[index]['title']}"',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                const Divider(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _pastTips[index]['comments'].length,
                    itemBuilder: (context, cIndex) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 18)),
                        title: Text(_pastTips[index]['comments'][cIndex], style: const TextStyle(fontSize: 14)),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.indigo),
                      onPressed: () async {
                        if (commentController.text.isNotEmpty) {

                          final messenger =
                          ScaffoldMessenger.of(context);

                          setState(() {
                            _pastTips[index]['comments'].add(
                              '${AppDataManager.userName}: ${commentController.text}',
                            );
                          });

                          try {

                            await FirebaseFirestore.instance
                                .collection('community_tips')
                                .doc(_pastTips[index]['id'])
                                .update({
                              'comments':
                              _pastTips[index]['comments'],
                            });

                          } catch (e) {

                            debugPrint(
                              'Error saving comment: $e',
                            );

                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to save comment.',
                                ),
                              ),
                            );
                          }

                          setModalState(() {});
                          commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Community Tips Forum",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Search Bar at Top
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for money management tips...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFFC2185B),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),

          // 2. Forum Bars
          Expanded(
            child: Builder(
              builder: (context) {
                final filteredTips = _pastTips.where((tip) {
                  return tip['title']
                      .toLowerCase()
                      .contains(searchText.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredTips.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    final tip = filteredTips[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [

                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [

                                    const SizedBox(height: 4),
                                    Row(
                                      children: [

                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: const Color(0xFFC2185B),
                                          child: Text(
                                            tip['postedBy']
                                                .toString()
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Text(
                                            tip['postedBy'],
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Text(
                                      tip['title'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      tip['summary'],
                                      style: TextStyle(
                                        color:
                                        Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          getTimeAgo(tip['datePosted']),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Container(
                              width: 65,
                              decoration:
                              const BoxDecoration(
                                borderRadius:
                                BorderRadius.only(
                                  topRight:
                                  Radius.circular(
                                      15),
                                  bottomRight:
                                  Radius.circular(
                                      15),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceEvenly,
                                children: [
                                  if (tip['postedBy'] == AppDataManager.userName)
                                    PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 20,
                                        color: Colors.black54,
                                      ),
                                      onSelected: (value) async {

                                        if (value == 'edit') {
                                          _showEditTipDialog(tip);
                                          return;
                                        }

                                        if (value == 'delete') {

                                          final messenger =
                                          ScaffoldMessenger.of(context);

                                          final confirm =
                                          await showDialog<bool>(
                                            context: context,
                                            builder: (context) =>
                                                AlertDialog(
                                                  title: const Text(
                                                    'Delete Tip',
                                                  ),
                                                  content: const Text(
                                                    'Are you sure you want to delete this tip?',
                                                  ),
                                                  actions: [

                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),

                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );

                                          if (confirm != true) return;

                                          try {

                                            await FirebaseFirestore.instance
                                                .collection(
                                                'community_tips')
                                                .doc(tip['id'])
                                                .delete();

                                            setState(() {
                                              _pastTips.remove(tip);
                                            });

                                            if (!mounted) return;

                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Tip deleted successfully.',
                                                ),
                                              ),
                                            );

                                          } catch (e) {

                                            debugPrint(
                                              'Error deleting tip: $e',
                                            );

                                            if (!mounted) return;

                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Failed to delete tip.',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),

                                  _buildInteractionAction(
                                    icon: tip['isLiked']
                                        ? Icons.thumb_up
                                        : Icons
                                        .thumb_up_alt_outlined,
                                    label: tip['likes']
                                        .toString(),
                                    color: tip['isLiked']
                                        ? Colors.green
                                        : Colors.grey
                                        .shade600,
                                    onTap: () async =>
                                    await _handleLike(_pastTips.indexOf(tip)),
                                  ),

                                  _buildInteractionAction(
                                    icon:
                                    tip['isDisliked']
                                        ? Icons
                                        .thumb_down
                                        : Icons
                                        .thumb_down_alt_outlined,
                                    label: tip[
                                    'dislikes']
                                        .toString(),
                                    color:
                                    tip['isDisliked']
                                        ? Colors.red
                                        : Colors.grey
                                        .shade600,
                                    onTap: () async =>
                                    await _handleDislike(_pastTips.indexOf(tip)),
                                  ),

                                  _buildInteractionAction(
                                    icon: Icons
                                        .comment_outlined,
                                    label: tip[
                                    'comments']
                                        .length
                                        .toString(),
                                    color: Colors.blue,
                                    onTap: () => _showCommentSection(
                                      context,
                                      _pastTips.indexOf(tip),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 3. Add Tip Button at Bottom
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: ElevatedButton.icon(
            onPressed: () => _showAddTipDialog(context),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text('Add Money Management Tip', style: TextStyle(color: Colors.white, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFC2185B),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTipDialog(
      Map<String, dynamic> tip) {

    final titleController =
    TextEditingController(
      text: tip['title'],
    );

    final descriptionController =
    TextEditingController(
      text: tip['summary'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {

        return Padding(
          padding: EdgeInsets.only(
            bottom:
            MediaQuery.of(dialogContext)
                .viewInsets
                .bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [

              const Text(
                'Edit Tip',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller:
                titleController,
                decoration:
                const InputDecoration(
                  labelText: 'Title',
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller:
                descriptionController,
                maxLines: 4,
                decoration:
                const InputDecoration(
                  labelText:
                  'Description',
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child:
                ElevatedButton(
                  onPressed: () async {

                    final navigator =
                    Navigator.of(dialogContext);

                    try {

                      await FirebaseFirestore
                          .instance
                          .collection(
                          'community_tips')
                          .doc(tip['id'])
                          .update({
                        'title':
                        titleController
                            .text,
                        'summary':
                        descriptionController
                            .text,
                      });

                      await loadTips();

                      if (!mounted) return;

                      navigator.pop();

                    } catch (e) {

                      debugPrint(
                        'Error updating tip: $e',
                      );
                    }
                  },
                  child: const Text(
                    'Update Tip',
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAddTipDialog(BuildContext context) {

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (dialogContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
          top: 30,
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share Your Tip', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFC2185B))),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. How to save on textbooks',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Tip Description',
                hintText: 'Share your experience...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  if (titleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {

                    final user =
                        FirebaseAuth.instance.currentUser;

                    if (user != null) {

                      final messenger =
                      ScaffoldMessenger.of(context);

                      try {

                        await FirebaseFirestore.instance
                            .collection('community_tips')
                            .add({
                          'postedBy': AppDataManager.userName,
                          'title': titleController.text,
                          'summary': descriptionController.text,
                          'datePosted': Timestamp.now(),
                          'likes': 0,
                          'dislikes': 0,
                          'comments': [],
                          'likedUsers': [],
                          'dislikedUsers': [],
                        });

                      } catch (e) {

                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to post tip. Please try again.',
                            ),
                          ),
                        );

                        return;
                      }
                    }

                    if (!mounted) return;

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }

                    await loadTips();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC2185B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Post to Community', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
