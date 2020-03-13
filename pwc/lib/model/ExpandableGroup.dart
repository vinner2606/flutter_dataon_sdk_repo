import 'package:json_annotation/json_annotation.dart';
part 'ExpandableGroup.g.dart';
@JsonSerializable()
class ExpandableGroup {
  @JsonKey()
  String title;
  @JsonKey(ignore: true)
  List<Object> items;


  ExpandableGroup();

  ExpandableGroup.name(this.title, this.items);

  String getTitle() {
    return title;
  }

  List<Object> getItems() {
    return items;
  }

  int getItemCount() {
    return items == null ? 0 : items.length;
  }
}
