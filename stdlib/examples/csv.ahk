#Requires AutoHotkey v2.0

#Include <stdlib\csv>

csv_example_rows := []
for row in stdlib.csv.reader("name,score`nAda,7`n")
    csv_example_rows.Push(row)

csv_example_writer := stdlib.csv.writer()
csv_example_writer.writerow(["a,b", "c"])
csv_example_text := csv_example_writer.text

csv_example_dict_rows := []
for row in stdlib.csv.DictReader("name,score`nAda,7`n")
    csv_example_dict_rows.Push(row)

csv_example_dict_writer := stdlib.csv.DictWriter(["name", "score"])
csv_example_dict_writer.writeheader()
csv_example_dict_writer.writerow(Map("name", "Ada", "score", 7))
csv_example_dict_text := csv_example_dict_writer.text
