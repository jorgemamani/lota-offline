class FilterCriterion {
  String? propertyName;
  String? type;
  Object? value;
  Object? from;
  Object? to;
  List<FilterCriterion>? or;
  List<FilterCriterion>? and;

  FilterCriterion(
      {this.propertyName,
      this.value,
      this.type,
      this.from,
      this.and,
      this.or,
      this.to});

  Map<String, dynamic> toJson() => {
        "propertyName": propertyName,
        "type": type,
        "value": value,
        "from": from,
        "to": to,
        "or": or != null
            ? List<dynamic>.from(or!.map((x) => x.toJson()).toList())
            : [],
        "and": and != null
            ? List<dynamic>.from(and!.map((x) => x.toJson()).toList())
            : [],
      };
}
