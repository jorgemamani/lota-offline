class SortCriterion {
  String? propertyName;
  bool? descending;

  SortCriterion({this.descending, this.propertyName});

  Map<String, dynamic> toJson() => {
        "propertyName": propertyName,
        "descending": descending,
      };
}
