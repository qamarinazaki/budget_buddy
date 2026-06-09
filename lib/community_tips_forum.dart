import 'package:flutter/material.dart';

class CommunityTipsForum extends StatefulWidget {
  const CommunityTipsForum({super.key});

  @override
  State<CommunityTipsForum> createState() => _CommunityTipsForumState();
}

class _CommunityTipsForumState extends State<CommunityTipsForum> {
  final List<Map<String, dynamic>> _pastTips = [
    {
      'title': 'Smart Grocery Shopping',
      'summary': 'Always buy store brands and use a list to avoid impulse buys.',
      'likes': 245,
      'dislikes': 12,
      'isLiked': false,
      'isDisliked': false,
      'comments': ['Great tip!', 'I saved \$50 this week thanks to this!'],
    },
    {
      'title': 'Student Transportation Hacks',
      'summary': 'Use the campus shuttle and bike sharing to save on commute costs.',
      'likes': 189,
      'dislikes': 5,
      'isLiked': false,
      'isDisliked': false,
      'comments': ['Biking is healthy too.', 'Shuttle is always late though.'],
    },
    {
      'title': 'Textbook Savings',
      'summary': 'Rent your textbooks or buy second-hand from upperclassmen.',
      'likes': 310,
      'dislikes': 8,
      'isLiked': false,
      'isDisliked': false,
      'comments': ['Never buy new!', 'Library usually has a copy.'],
    },
  ];

  void _handleLike(int index) {
    setState(() {
      if (_pastTips[index]['isLiked']) {
        _pastTips[index]['likes']--;
        _pastTips[index]['isLiked'] = false;
      } else {
        _pastTips[index]['likes']++;
        _pastTips[index]['isLiked'] = true;
        if (_pastTips[index]['isDisliked']) {
          _pastTips[index]['dislikes']--;
          _pastTips[index]['isDisliked'] = false;
        }
      }
    });
  }

  void _handleDislike(int index) {
    setState(() {
      if (_pastTips[index]['isDisliked']) {
        _pastTips[index]['dislikes']--;
        _pastTips[index]['isDisliked'] = false;
      } else {
        _pastTips[index]['dislikes']++;
        _pastTips[index]['isDisliked'] = true;
        if (_pastTips[index]['isLiked']) {
          _pastTips[index]['likes']--;
          _pastTips[index]['isLiked'] = false;
        }
      }
    });
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
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
                      onPressed: () {
                        if (commentController.text.isNotEmpty) {
                          setState(() {
                            _pastTips[index]['comments'].add(commentController.text);
                          });
                          setModalState(() {}); // Refresh modal
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Community Tips Forum',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 1. Search Bar at Top
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for money management tips...',
                prefixIcon: const Icon(Icons.search, color: Colors.indigo),
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
            child: ListView.builder(
              itemCount: _pastTips.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final tip = _pastTips[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Main Content Area (Left)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip['title'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tip['summary'],
                                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Interaction Section (Behind Right - Vertical Stack: Like, Dislike, Comment)
                        Container(
                          width: 65,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Like Action (Top)
                              _buildInteractionAction(
                                icon: tip['isLiked'] ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                label: tip['likes'].toString(),
                                color: tip['isLiked'] ? Colors.green : Colors.grey.shade600,
                                onTap: () => _handleLike(index),
                              ),
                              // Dislike Action (Middle)
                              _buildInteractionAction(
                                icon: tip['isDisliked'] ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
                                label: tip['dislikes'].toString(),
                                color: tip['isDisliked'] ? Colors.red : Colors.grey.shade600,
                                onTap: () => _handleDislike(index),
                              ),
                              // Comment Action (Bottom)
                              _buildInteractionAction(
                                icon: Icons.comment_outlined,
                                label: tip['comments'].length.toString(),
                                color: Colors.blue,
                                onTap: () => _showCommentSection(context, index),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // 3. Add Tip Button at Bottom
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddTipDialog(context),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text('Add Money Management Tip', style: TextStyle(color: Colors.white, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(vertical: 16),
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

  void _showAddTipDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 30,
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share Your Tip', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. How to save on textbooks',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
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
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
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
