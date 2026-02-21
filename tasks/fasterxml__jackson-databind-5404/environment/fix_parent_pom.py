#!/usr/bin/env python3
"""Fix parent POM version: replace 2.19.5-SNAPSHOT with 2.19.0 in <parent> section."""
import re
import sys

pom_file = sys.argv[1] if len(sys.argv) > 1 else "pom.xml"
content = open(pom_file).read()
fixed = re.sub(
    r'(<parent>.*?<version>)2\.19\.5-SNAPSHOT(</version>.*?</parent>)',
    r'\g<1>2.19.0\2',
    content, count=1, flags=re.DOTALL
)
open(pom_file, 'w').write(fixed)
print(f"Fixed parent POM version in {pom_file}")
