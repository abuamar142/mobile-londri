extension JsonCleaner on Map<String, dynamic> {
  Map<String, dynamic> cleanNulls() {
    final result = Map<String, dynamic>.from(this);
    result.removeWhere((key, value) => value == null);
    return result;
  }
}
