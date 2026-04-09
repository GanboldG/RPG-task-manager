Documentation / History:

- pubspec.yaml тохиргооны файлд:
    - flutter_launcher_icons (App-н icon-ийг өөрчлөх сан)
    - just_audio (Дуун файл тоглуулах сан)
    - provider (InheritedWidget-ын хялбарчилсан хувилбар, ашиглахад амархан)

- Өнгөнүүдийг зөвхөн AppColors.dart файлд тодорхойлж, ThemeData-с өнгөө хэрэглэнэ.

- InheritedWidget ашиглахын оронд Provider ашиглаж, controller-үүдээ build() руу subscribe хийнэ.

Widget _buildTaskList(BuildContext context){
    final controller = context.read<TaskController>();
    final tasks = controller.tasks;

    return Expanded(
      child: ReorderableListView(
        buildDefaultDragHandles: true, 
        children: <Widget>[
          for (int i = 0; i < tasks.length; i++)
          _buildTaskTile(i),
        ],
        onReorder: (oldIndex, newIndex){
          setState(() {
            if (newIndex > oldIndex){newIndex--;}
            final item = tasks.removeAt(oldIndex);
            tasks.insert(newIndex, item);
          });
        },  
      )
    );
  }