Enum? getEnumFromString(Map<Enum, String> enumMap, String locale) {
  return enumMap.keys.firstWhere((k) => enumMap[k] == locale);
}
