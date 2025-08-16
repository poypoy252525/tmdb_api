abstract class DTO<T> {
  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
