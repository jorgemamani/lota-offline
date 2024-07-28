// Dart imports:
import 'dart:convert';

// Project imports:
import '../../src/support/sort_criterion.dart';
import 'filter_criterion.dart';

class QueryCriteria {
  List<SortCriterion>? sorts;
  List<FilterCriterion>? filters;

  QueryCriteria({this.filters, this.sorts});

  QueryCriteria build(FilterCriterion item) {
    return QueryCriteria(filters: [item]);
  }

  QueryCriteria buildAnd(List<FilterCriterion> items) {
    return QueryCriteria(filters: [FilterCriterion(and: items)]);
  }

  String queryCriteriaBase64() {
    String json = jsonEncode(this);
    return base64.encode(utf8.encode(json));
  }

  Map<String, dynamic> toJson() => {
        "sorts": sorts != null
            ? List<dynamic>.from(sorts!.map((x) => x.toJson()).toList())
            : [],
        "filters": filters != null
            ? List<dynamic>.from(filters!.map((x) => x.toJson()).toList())
            : [],
      };
}
