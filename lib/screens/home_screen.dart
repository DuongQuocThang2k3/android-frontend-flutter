import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/postFacebook.dart';
import 'add_post_screen.dart';
import 'edit_post.dart';
import 'delete_post.dart';
import 'search_post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<postFacebook> posts = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final String apiUrl = 'https://foundgreenpen14.conveyor.cloud/api/PostApi'; // URL API của bạn

  @override
  void initState() {
    super.initState();
    fetchPosts(); // Gọi phương thức fetchPosts() thay vì _loadPosts()
  }

  // Phương thức tải danh sách bài viết từ API
  Future<void> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // Xử lý response
      if (response.statusCode == 200) {
        setState(() {
          posts = (json.decode(response.body) as List)
              .map((post) => postFacebook.fromJson(post))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      // Xử lý lỗi
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Thêm bài viết mới
  Future<bool> _addPost(postFacebook post) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPosts(); // Đảm bảo fetchPosts là một Future
        return true; // Thêm bài viết thành công
      } else {
        print('Failed to create post. Status code: ${response.statusCode}');
        return false; // Thêm bài viết thất bại
      }
    } catch (e) {
      print('Error adding post: $e');
      return false; // Xử lý lỗi
    }
  }

  // Cập nhật bài viết
  Future<void> _updatePost(postFacebook post) async {
    final url = 'https://goodshinytrail60.conveyor.cloud/api/PostApi/${post.id}';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': post.id,
        'ten': post.ten,
        'moTa': post.moTa,
        'anhDaiDien': post.anhDaiDien,
        'hinhAnh': post.hinhAnh,
        'soLuotThich': post.soLuotThich,
        'soLuotBinhLuan': post.soLuotBinhLuan,
        'soLuotChiaSe': post.soLuotChiaSe,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Cập nhật thành công, hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật bài đăng thành công!')),
      );
    } else {
      // Lỗi khi cập nhật bài viết
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể cập nhật bài đăng')),
      );
    }
  }

  // Xóa bài viết
  void _deletePost(int postId) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/posts/$postId'));

      if (response.statusCode == 200) {
        // Xóa bài viết từ danh sách local ngay lập tức sau khi xóa thành công
        setState(() {
          posts.removeWhere((post) => post.id == postId);
        });
      } else {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  // Tìm kiếm bài viết theo ID
  void _searchPost() {
    final searchId = _searchController.text;
    if (searchId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SearchPostScreen(
                searchId: searchId,
                // Truyền searchId qua widget SearchPostScreen
                fetchPosts: fetchPosts, // Hàm để fetch lại tất cả bài viết
              ),
        ),
      );
    } else {
      setState(() {
        fetchPosts(); // Hiển thị lại tất cả bài viết khi không có ID tìm kiếm
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                fetchPosts(); // Làm mới danh sách khi bấm nút refresh
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPostScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by ID',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchPost,
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(post.anhDaiDien),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.ten,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '1 hour ago',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditPostScreen(post: post),
                                  ),
                                ).then((updatedPost) {
                                  if (updatedPost != null) {
                                    setState(() {
                                      int index = posts.indexWhere((
                                          item) => item.id == post.id);
                                      if (index != -1) {
                                        posts[index] = updatedPost;
                                      }
                                    });
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DeletePostScreen(post: post),
                                  ),
                                ).then((_) {
                                  setState(() {
                                    posts.removeWhere((item) =>
                                    item.id == post.id);
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(post.moTa),
                        ),
                        post.hinhAnh.isNotEmpty
                            ? Image.network(post.hinhAnh)
                            : const SizedBox.shrink(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn('Like', post.soLuotThich),
                            _buildStatColumn('Comment', post.soLuotBinhLuan),
                            _buildStatColumn('Share', post.soLuotChiaSe),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.thumb_up),
                              onPressed: () {
                                setState(() {
                                  post.soLuotThich++;
                                });
                                _updatePost(post);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.comment),
                              onPressed: () {
                                setState(() {
                                  post.soLuotBinhLuan++;
                                });
                                _updatePost(post);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                setState(() {
                                  post.soLuotChiaSe++;
                                });
                                _updatePost(post);
                              },
                            ),
                          ],
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
    );
  }

// Phương thức xây dựng cột thống kê cho Like, Comment, Share
  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(label),
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}