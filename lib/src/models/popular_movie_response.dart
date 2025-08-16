class PaginatedResponse<T> {
  int? page;
  List<T> results;
  int? totalPages;
  int? totalResults;

  PaginatedResponse({
    this.page,
    required this.results,
    this.totalPages,
    this.totalResults,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) => PaginatedResponse(
    page: json["page"],
    results: List<T>.from(json["results"]!.map((x) => fromJsonT(x))),
    totalPages: json["total_pages"],
    totalResults: json["total_results"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "results": List<T>.from(results.map((x) => (x as dynamic).toJson())),
    "total_pages": totalPages,
    "total_results": totalResults,
  };
}
