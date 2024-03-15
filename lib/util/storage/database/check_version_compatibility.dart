import 'package:pub_semver/pub_semver.dart';

bool checkVersionCompatibility({apiVersion, compatibleVersion}) {
  VersionConstraint versionConstraint =
      VersionConstraint.compatibleWith(Version.parse(compatibleVersion));
  return apiVersion != null &&
      versionConstraint.allows(Version.parse(apiVersion));
}
