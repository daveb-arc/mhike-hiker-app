import 'package:flutter/material.dart';
import 'package:mhike/constants/routes.dart';
import 'package:mhike/services/crud/model/hike.dart';
import 'package:mhike/utilities/utility.dart';

typedef DeleteNoteCallback = void Function(Hike hike);

class HikeListView extends StatelessWidget {
  final List<Hike> hikes;
  final DeleteNoteCallback onDeleteHike;

  const HikeListView({
    super.key,
    required this.hikes,
    required this.onDeleteHike,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(
        color: Colors.transparent,
        height: 18,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: hikes.length,
      itemBuilder: (context, index) {
        final hike = hikes[index];
        return Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: Stack(
            children: [
              InkWell(
                onTap: (() {
                  Navigator.of(context).pushNamed(
                    hikeDetailRoute,
                    arguments: hike,
                  );
                }),
                child: PhysicalModel(
                  color: Colors.white,
                  elevation: 10,
                  borderRadius: BorderRadius.circular(15.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.memory(
                          Utility.dataFromBase64String(
                            hike.coverImage,
                          ),
                          height: 290,
                          width: 290,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        height: 290,
                        width: 290,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 50, 50, 50).withOpacity(0.8),
                              const Color.fromARGB(255, 96, 96, 96).withOpacity(0.2),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            tileMode: TileMode.mirror,
                            stops: const [0.2, 0.4],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 18,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 260,
                      child: Text(
                        hike.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'Length: ${hike.length}mi • Est. ${hike.estimatedTime}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(
                      height: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.5,
                        vertical: 5,
                      ),
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.indigo.shade800,
                      ),
                      child: Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: hike.difficulty,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              children: const [
                                TextSpan(
                                  text: ' • ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: '0.0 (0)'),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            width: 4,
                          ),
                          Image.asset(
                            'assets/star.png',
                            height: 14,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
