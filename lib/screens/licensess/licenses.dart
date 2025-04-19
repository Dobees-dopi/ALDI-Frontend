import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:umi/theme.dart';
import 'oss_licenses.dart';
import 'package:get/get.dart';
class OssLicensesPage extends StatelessWidget {
  const OssLicensesPage({super.key});

  static Future<List<Package>> loadLicenses() async {
    // merging non-dart dependency list using LicenseRegistry.
    final lm = <String, List<String>>{};
    await for (var l in LicenseRegistry.licenses) {
      for (var p in l.packages) {
        final lp = lm.putIfAbsent(p, () => []);
        lp.addAll(l.paragraphs.map((p) => p.text));
      }
    }
    final licenses = allDependencies.toList();
    for (var key in lm.keys) {
      licenses.add(Package(
        name: key,
        description: '',
        authors: [],
        version: '',
        license: lm[key]!.join('\n\n'),
        isMarkdown: false,
        isSdk: false,
        dependencies: [],
      ));
    }
    return licenses..sort((a, b) => a.name.compareTo(b.name));
  }

  static final _licenses = loadLicenses();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),  // AppBar's default height
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 240, 240, 240),  // Border color
                  width: 2,           // Border width
                ),
              ),
            ),
            child: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Temas.blackicon),
                onPressed: () => Get.back(),
              ),
              centerTitle: true,
              title: const Text(
                '오픈소스 라이선스',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              elevation: 0,
            ),
          ),
        ),
body: FutureBuilder<List<Package>>(
  future: _licenses,
  initialData: const [],
  builder: (context, snapshot) {
    return Container(
      color: Colors.grey[100], // 회색 배경 색상
      child: ListView.separated(
        padding: const EdgeInsets.all(8.0), // ListView의 패딩 설정
        itemCount: snapshot.data?.length ?? 0,
        itemBuilder: (context, index) {
          final package = snapshot.data![index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white, // 리스트 아이템의 배경색
              borderRadius: BorderRadius.circular(15.0), // 둥근 모서리
              boxShadow: [
                  BoxShadow(
              color: const Color.fromARGB(255, 209, 209, 209).withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              title: Text('${package.name} ${package.version}',
              style: TextStyle(
                fontWeight: FontWeight.w400
              ),),
              subtitle: package.description.isNotEmpty ? Text(package.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                
              ),) : null,
              trailing: const Icon(Icons.chevron_right,
              size: 26,
                color: Colors.black54,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MiscOssLicenseSingle(package: package),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8.0), // 항목 간 간격
      ),
    );
  },
)

);
  }
}



class MiscOssLicenseSingle extends StatelessWidget {
  final Package package;

  const MiscOssLicenseSingle({super.key, required this.package});

  String _bodyText() {
    return package.license!.split('\n').map((line) {
      if (line.startsWith('//')) line = line.substring(2);
      line = line.trim();
      return line;
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),  // AppBar's default height
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromARGB(255, 240, 240, 240),  // Border color
                width: 2,           // Border width
              ),
            ),
          ),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Text(
              '${package.name} ${package.version}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            elevation: 0,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Scrollbar(

          thickness: 0.0, // 스크롤바 두께 설정
          radius: Radius.circular(10.0), // 스크롤바 끝을 둥글게 설정
          thumbVisibility: true, // 스크롤바가 항상 보이도록 설정 (필요에 따라 조정)

          child: ListView(
            children: <Widget>[
              if (package.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
                  child: Text(
                    package.description,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                ),
              if (package.homepage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0, bottom: 10),
                  child: InkWell(
                    child: Text(
                      package.homepage!,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () => launchUrl(Uri.parse(package.homepage!)),
                  ),
                ),
              if (package.description.isNotEmpty || package.homepage != null)
                const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0, bottom: 15),
                child: Text(
                  _bodyText(),
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
