import 'package:flutter/material.dart';

class StoreInfo extends StatefulWidget {
  const StoreInfo({super.key});

  @override
  State<StoreInfo> createState() => _StoreInfoState();
}

class _StoreInfoState extends State<StoreInfo> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1, // 메인에서 좌우 각각 1씩 차지하기 위해 필수!
      child: Container(
        // 배경색
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 28.0),
          child: Column(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 앱 로고 or 타이틀
                  Text(
                    'CATCHTABLE',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // 안내 문구
                  Text(
                    'Enter your phone number to receive\nreal-time waiting updates.',
                    style: TextStyle(fontSize: 24, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 1,
                height: 50,
              ),

              // 가게 상호
              Text(
                'Mang Inasal',
                style: TextStyle(
                  fontSize: 52,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 0.55,
                height: 50,
              ),

              // 대기 정보
              Flexible(
                fit: FlexFit.tight,
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text(
                      'Currently\nWaiting',
                      style: TextStyle(fontSize: 24, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 42.0),
                    Text(
                      '34',
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 18.0),
                    Text(
                      'Groups',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
