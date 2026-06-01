#Requires AutoHotkey v2.0

#Include <stdlib\re>

re_example_match := stdlib.re.search("(?P<key>\w+)=(?P<value>\d+)", "name=42")
re_example_key := re_example_match.group("key")
re_example_value := re_example_match.group("value")
re_example_span := re_example_match.span()
re_example_numbers := stdlib.re.findall("\d+", "a1 b22")
re_example_replaced := stdlib.re.sub("(\w+)=(\d+)", "\1:<\2>", "x=1")
