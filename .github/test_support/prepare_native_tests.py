from pathlib import Path
import shutil,sys
app=Path(sys.argv[1]);repo=Path(__file__).resolve().parents[2]
tests=app/'ios/RunnerTests';tests.mkdir(exist_ok=True)
# Compile precisely the production Swift source in a separate native test module.
shutil.copyfile(repo/'ios/mindful_minutes/Sources/mindful_minutes/MindfulMinutesPlugin.swift', tests/'PluginUnderTest.swift')
shutil.copyfile(repo/'.github/test_support/MindfulMinutesNativeTests.swift',tests/'RunnerTests.swift')
p=app/'ios/Runner.xcodeproj/project.pbxproj';s=p.read_text()
for anchor in ['/* Begin PBXBuildFile section */', '/* Begin PBXFileReference section */',
               '331C807B294A618700263BE5 /* RunnerTests.swift */,',
               '331C808B294A63AB00263BE5 /* RunnerTests.swift in Sources */,']:
    if s.count(anchor) != 1:
        raise RuntimeError('Unexpected generated XCTest project: ' + anchor)
s=s.replace('/* Begin PBXBuildFile section */','''/* Begin PBXBuildFile section */
        B070CAFE0000000000000001 /* PluginUnderTest.swift in Sources */ = {isa = PBXBuildFile; fileRef = B070CAFE0000000000000002 /* PluginUnderTest.swift */; };''')
s=s.replace('/* Begin PBXFileReference section */','''/* Begin PBXFileReference section */
        B070CAFE0000000000000002 /* PluginUnderTest.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PluginUnderTest.swift; sourceTree = "<group>"; };''')
s=s.replace('331C807B294A618700263BE5 /* RunnerTests.swift */,','331C807B294A618700263BE5 /* RunnerTests.swift */,\n                B070CAFE0000000000000002 /* PluginUnderTest.swift */,')
s=s.replace('331C808B294A63AB00263BE5 /* RunnerTests.swift in Sources */,','331C808B294A63AB00263BE5 /* RunnerTests.swift in Sources */,\n                B070CAFE0000000000000001 /* PluginUnderTest.swift in Sources */,')
p.write_text(s)
