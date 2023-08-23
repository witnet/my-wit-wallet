// Generic implementation of read through cache pattern
class ReadThrough<T> {
  // Consume the value if it's not already stored
  Future<T?> Function(String) _fetch;
  // Save the value in cache
  Future<bool> Function(T) _save;
  // Read Value from Cache
  Future<T?> Function(String) _read;

  ReadThrough(this._fetch, this._save, this._read);

  Future<bool> _insert(T value) async {
    return await _save(value);
  }

  // Check if value is stored and call the fetch function if it's not found
  Future<T?> get(String key) async {
    T? storedValue = await _read(key);

    if (storedValue != null) {
      return storedValue;
    } else {
      T? value = await _fetch(key);

      if (value != null) {
        await _insert(value);
      }

      return value;
    }
  }
}
