// lib/src/views/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 로그아웃 확인 다이얼로그
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('로그아웃 하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('로그아웃'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                // ignore: use_build_context_synchronously
                await context.read<AuthViewModel>().signOut();
              }
            },
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          final user = authViewModel.user;

          if (user == null) {
            return const Center(
              child: Text('로그인이 필요합니다.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 사용자 정보 카드
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // 사용자 아이콘
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.deepPurple,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 닉네임 표시
                        Text(
                          user.displayName ??
                              user.email?.split('@')[0] ??
                              '사용자',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 이메일
                        Text(
                          user.email ?? '이메일 없음',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 닉네임 변경 버튼
                        ElevatedButton(
                          onPressed: () async {
                            final TextEditingController controller =
                                TextEditingController(
                              text: user.displayName ??
                                  user.email?.split('@')[0] ??
                                  '사용자',
                            );

                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('닉네임 변경'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    labelText: '새로운 닉네임',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (controller.text.isNotEmpty) {
                                        try {
                                          await user.updateDisplayName(
                                              controller.text);
                                          await context
                                              .read<AuthViewModel>()
                                              .reloadUser();
                                          if (mounted) {
                                            Navigator.pop(context);
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('닉네임 변경에 실패했습니다.'),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: const Text('변경'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('닉네임 변경'),
                        ),
                        const SizedBox(height: 24),
                        // 이메일 인증 상태
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  user.emailVerified
                                      ? Icons.verified
                                      : Icons.warning,
                                  color: user.emailVerified
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  user.emailVerified ? '인증된 사용자' : '이메일 인증 필요',
                                  style: TextStyle(
                                    color: user.emailVerified
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            if (!user.emailVerified) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      try {
                                        await context
                                            .read<AuthViewModel>()
                                            .sendEmailVerification();
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                '인증 메일이 발송되었습니다. 메일함을 확인해주세요.'),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('에러가 발생했습니다: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('인증 메일 보내기'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () async {
                                      await context
                                          .read<AuthViewModel>()
                                          .reloadUser();
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('인증 상태가 갱신되었습니다.'),
                                        ),
                                      );
                                    },
                                    child: const Text('인증 상태 확인'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 추가 메뉴나 설정들을 여기에 추가할 수 있습니다.
              ],
            ),
          );
        },
      ),
    );
  }
}
