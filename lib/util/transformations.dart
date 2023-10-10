Enum? getEnumFromString(Map<Enum, String> enumMap, String value) {
  return enumMap.keys.firstWhere((k) => enumMap[k] == value);
}
