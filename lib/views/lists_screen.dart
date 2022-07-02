import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:focused_menu/modals.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todozoid2/helpers/custom_icons_icons.dart';
import 'package:todozoid2/widgets/firestoreQueryBuilderNew.dart';

import '../Database/database.dart';
import '../consts/consts.dart';
import '../controllers/tasks_controller.dart';
import '../controllers/tasks_diary_controller.dart';
import '../models/list.dart';
import '../widgets/create_list_bottom_sheet.dart';
import '../widgets/customFocusedMenuHolder.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({Key? key}) : super(key: key);

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  final TasksController tasksController = Get.put(TasksController());

  final DatabaseController databaseController = Get.find();

  final TasksDiaryController tasksDiaryController =
      Get.put(TasksDiaryController());

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilderNew<ListTask>(
      query: listsCollection.orderBy('name'),
      builder: (BuildContext context,
          FirestoreQueryBuilderSnapshot<ListTask> snapshot, Widget? child) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        }
        if (snapshot.docs.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            tasksController.listsEmpty.value = true;
          });

          return Center(
              child: Text(
            'noactivelists'.tr,
            style: TextStyle(fontSize: 15.sp),
          ));
        } else if (snapshot.docs.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            tasksController.listsEmpty.value = false;
          });
        }
        return AnimationLimiter(
          child: GridView.builder(
            itemCount: snapshot.docs.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              // if we reached the end of the currently obtained items, we try to
              // obtain more items
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                // Tell FirestoreQueryBuilder to try to obtain more items.
                // It is safe to call this function from within the build method.
                snapshot.fetchMore();
              }

              final list = snapshot.docs[index].data();
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: ListsScreenElement(
                        index: index,
                        snapshot: snapshot,
                        tasksDiaryController: tasksDiaryController,
                        databaseController: databaseController,
                        list: list),
                  ),
                ),
              );
            },
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20),
          ),
        );
      },
    );
  }
}

class ListsScreenElement extends StatelessWidget {
  const ListsScreenElement({
    Key? key,
    required this.tasksDiaryController,
    required this.databaseController,
    required this.list,
    required this.snapshot,
    required this.index,
  }) : super(key: key);

  final TasksDiaryController tasksDiaryController;
  final DatabaseController databaseController;
  final ListTask list;
  final FirestoreQueryBuilderSnapshot<ListTask> snapshot;
  final int index;

  @override
  Widget build(BuildContext context) {
    return FocusedMenuHolderNew(
      menuWidth: 158,
      menuOffset: 5,
      blurBackgroundColor: Colors.black54,
      blurSize: 4.0,
      animateMenuItems: false,
      menuBoxDecoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(14.0))),
      menuItems: <FocusedMenuItem>[
        FocusedMenuItem(
            backgroundColor: context.isDarkMode
                ? Constants.kDarkThemeBGLightColor
                : Constants.kWhiteBgColor,
            title: Text('open'.tr),
            trailingIcon: const Icon(Icons.open_in_new),
            onPressed: () {
              tasksDiaryController.listOpenedFromListsScreen.value = true;
              showBarModalBottomSheet(
                isDismissible: false,
                enableDrag: false,
                expand: true,
                context: context,
                topControl: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    splashRadius: 1,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    iconSize: 30.0,
                  ),
                ),
                backgroundColor: Colors.transparent,
                builder: (context) => CreateListBottomSheetWidget(
                  firestoreData: snapshot.docs[index],
                ),
              );
            }),
        if (snapshot.docs[index].data().subLists!.isNotEmpty)
          FocusedMenuItem(
              backgroundColor: context.isDarkMode
                  ? Constants.kDarkThemeBGLightColor
                  : Constants.kWhiteBgColor,
              title: Text('clear'.tr),
              trailingIcon: const Icon(Icons.cleaning_services_outlined),
              onPressed: () async {
                databaseController.updateList(
                  snapshot.docs[index],
                  {
                    'sublists': [],
                  },
                );
              }),
        if (snapshot.docs[index].data().subLists!.isNotEmpty)
          FocusedMenuItem(
              backgroundColor: context.isDarkMode
                  ? Constants.kDarkThemeBGLightColor
                  : Constants.kWhiteBgColor,
              title: Text(
                'share'.tr,
              ),
              trailingIcon: const Icon(
                Icons.share,
              ),
              onPressed: () {
                String finalStringToShare =
                    '✨${snapshot.docs[index].data().name}✨\n';

                for (var element in snapshot.docs[index].data().subLists!) {
                  finalStringToShare += element['sublistIsDone'] == false
                      ? '❌  ${element['sublistDescription']}\n'
                      : '✅  ${element['sublistDescription']}\n';
                }

                Share.share(finalStringToShare);
              }),
        FocusedMenuItem(
            backgroundColor: context.isDarkMode
                ? Constants.kDarkThemeBGLightColor
                : Constants.kWhiteBgColor,
            title: Text(
              'delete'.tr,
              style: TextStyle(color: Colors.redAccent),
            ),
            trailingIcon: const Icon(
              CustomIcons.trashCan,
              color: Colors.redAccent,
            ),
            onPressed: () async {
              databaseController.deleteList(snapshot.docs[index]);
            }),
      ],
      onPressed: () {},
      child: Card(
        clipBehavior: Clip.hardEdge,
        color: context.isDarkMode
            ? Constants.kDarkThemeBGLightColor
            : Constants.kWhiteBgColor,
        shadowColor: Colors.black26,
        elevation: 7,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14))),
        child: InkWell(
          enableFeedback: true,
          onTap: () {
            tasksDiaryController.listOpenedFromListsScreen.value = true;
            showBarModalBottomSheet(
              isDismissible: false,
              enableDrag: false,
              expand: true,
              context: context,
              topControl: Material(
                color: Colors.transparent,
                child: IconButton(
                  splashRadius: 1,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  iconSize: 30.0,
                ),
              ),
              backgroundColor: Colors.transparent,
              builder: (context) => CreateListBottomSheetWidget(
                firestoreData: snapshot.docs[index],
              ),
            );
          },
          child: Stack(
            alignment: AlignmentDirectional.topStart,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 15.0),
                child: Text(
                  list.name,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              // IconButton(
              //   padding: EdgeInsets.zero,
              //   splashRadius: 20,
              //   visualDensity: VisualDensity.compact,
              //   icon: const Icon(Icons.more_vert_rounded),
              //   onPressed: () {
              //     showModal(
              //         context: context,
              //         configuration:
              //             const FadeScaleTransitionConfiguration(),
              //         builder: (context) {
              //           return AlertDialog(
              //             title: Text("Modal title"),
              //             content: Text(
              //                 "This is the modal content"),
              //           );
              //         });
              //   },
              // )),

              list.subLists != null
                  ? Positioned(
                      top: 70,
                      left: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tasks:'),
                          Text(
                            '${list.subLists!.where((element) => element['sublistIsDone'] == true).length}'
                            '/${list.subLists!.length}',
                            style: TextStyle(
                                fontSize: 15.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              list.icon != null
                  ? Positioned(
                      bottom: -18,
                      right: -18,
                      child: ShaderMask(
                          shaderCallback: (rect) {
                            return RadialGradient(
                              radius: 0.8,
                              tileMode: TileMode.clamp,
                              colors: <Color>[
                                Colors.black.withOpacity(1.0),
                                Colors.black.withOpacity(1.0),
                                Colors.black.withOpacity(0.3),
                                Colors.transparent, // <-- change this opacity
                              ],
                              stops: const [
                                0.0,
                                0.3,
                                0.7,
                                1.0
                              ], //<-- the gradient is interpolated, and these are where the colors above go into effect (that's why there are two colors repeated)
                            ).createShader(Rect.fromCircle(
                                radius: 65, center: const Offset(90, 90)));
                          },
                          blendMode: BlendMode.dstIn,
                          child: Text(
                            list.icon!,
                            textWidthBasis: TextWidthBasis.longestLine,
                            style: const TextStyle(
                              fontSize: 75,
                            ),
                          )),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
