import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/theme/aim_color.dart';
import 'assets/asset_allocation_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _showComingSoon() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text("준비중입니다.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final localStorage = LocalStorageService();
    await localStorage.removeData("user_id");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("로그아웃"),
        content: const Text("로그아웃 하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text("로그아웃"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AimColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(1.0, -1.0),
            child: const Icon(Icons.notes, color: Colors.black),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: SvgPicture.asset(
          "assets/images/logo_black.svg",
          height: 12,
        ),
        centerTitle: false,
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEmptyPage("MY AIM"),
                _buildEmptyPage("자산추이"),
                AssetAllocationScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(){
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(20),
            color: AimColors.primary,
            alignment: Alignment.bottomLeft,
            child: const Text(
              "AIM에 오신 것을\n환영합니다.",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height:24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:16),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 18),
                      label: const Text(
                        "추가계약",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(double.maxFinite, 56),
                        backgroundColor: AimColors.primary,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          width:2,
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    margin: EdgeInsets.symmetric(horizontal:16, vertical: 12),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Column(
                      children: [
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "간편결제",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    "한 번 등록으로 간편하게 이체",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.black12,
                              size: 36,
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, color: Colors.black, size: 18),
                          label: const Text(
                            "연동하기",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(double.maxFinite, 48),
                            backgroundColor: Colors.black.withOpacity(0.05),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment_turned_in_outlined),
                    title: const Text("AIM 가이드라인"),
                    onTap: _showComingSoon,
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text("AIM 이용방법"),
                    onTap: _showComingSoon,
                  ),
                  ListTile(
                    leading: const Icon(Icons.emoji_events_outlined),
                    title: const Text("AIM Score"),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("New", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    onTap: _showComingSoon,
                  ),
                  Divider(
                    height:1,
                    indent: 16,
                  ),
                  ListTile(
                    leading: const Icon(Icons.quiz_outlined),
                    title: const Text("Q&A"),
                    onTap: _showComingSoon,
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat_outlined),
                    title: const Text("HELP"),
                    onTap: _showComingSoon,
                  ),
                  Divider(
                    height:1,
                    indent: 16,
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart_outlined),
                    title: const Text("수익 현황"),
                    onTap: _showComingSoon,
                  ),
                  ListTile(
                    leading: const Icon(Icons.list_outlined),
                    title: const Text("계약 내역"),
                    onTap: _showComingSoon,
                  ),
                  Divider(
                    height:1,
                    indent: 16,
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("설정"),
                    onTap: _showComingSoon,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }


  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      indicatorColor: AimColors.primary,
      tabs: const [
        Tab(text: "MY AIM"),
        Tab(text: "자산추이"),
        Tab(text: "자산배분"),
      ],
    );
  }

  Widget _buildEmptyPage(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
