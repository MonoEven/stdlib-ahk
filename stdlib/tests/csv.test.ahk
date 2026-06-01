#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\csv>

class StdlibCsvTest
{
    static TestDialectsExposePythonDefaults()
    {
        AhkTest.AssertEqual("1.0", stdlib.csv.__version__)
        AhkTest.AssertEqual(["excel", "excel-tab", "unix"], stdlib.csv.list_dialects())

        excel := stdlib.csv.get_dialect("excel")
        AhkTest.AssertEqual(",", excel.delimiter)
        AhkTest.AssertEqual("`"", excel.quotechar)
        AhkTest.AssertEqual("", excel.escapechar)
        AhkTest.AssertEqual(true, excel.doublequote)
        AhkTest.AssertEqual(false, excel.skipinitialspace)
        AhkTest.AssertEqual("`r`n", excel.lineterminator)
        AhkTest.AssertEqual(stdlib.csv.QUOTE_MINIMAL, excel.quoting)
        AhkTest.AssertEqual(false, excel.strict)
    }

    static TestReaderParsesPlainRowsAndEmptyFields()
    {
        AhkTest.AssertEqual([["a", "", "c"]], stdlib_csv_test_rows(stdlib.csv.reader("a,,c`n")))
    }

    static TestReaderLineArraysAreStatefulAndTrackLineNum()
    {
        reader := stdlib.csv.reader(["a,b", "c,d"])

        AhkTest.AssertEqual(0, reader.line_num)

        rows := []
        for row in reader {
            rows.Push(row)
            if rows.Length = 1
                AhkTest.AssertEqual(1, reader.line_num)
        }

        AhkTest.AssertEqual([["a", "b"], ["c", "d"]], rows)
        AhkTest.AssertEqual(2, reader.line_num)
        AhkTest.AssertEqual([], stdlib_csv_test_rows(reader))
        AhkTest.AssertEqual(2, reader.line_num)
    }

    static TestReaderLineNumCountsPhysicalLinesInMultilineRecords()
    {
        reader := stdlib.csv.reader(["`"a`n", "b`",c`n"])

        rows := stdlib_csv_test_rows(reader)

        AhkTest.AssertEqual([["a`nb", "c"]], rows)
        AhkTest.AssertEqual(2, reader.line_num)
    }

    static TestReaderParsesQuotedCommasQuotesAndEmbeddedNewlines()
    {
        AhkTest.AssertEqual([["a,b", "c"]], stdlib_csv_test_rows(stdlib.csv.reader("`"a,b`",c`n")))
        AhkTest.AssertEqual([["a`"b", "c"]], stdlib_csv_test_rows(stdlib.csv.reader("`"a`"`"b`",c`n")))
        AhkTest.AssertEqual([["a`nb", "c"]], stdlib_csv_test_rows(stdlib.csv.reader("`"a`nb`",c`r`n")))
    }

    static TestReaderSkipInitialSpaceOnlyAfterDelimiter()
    {
        AhkTest.AssertEqual([[" a", " b", " c "]], stdlib_csv_test_rows(stdlib.csv.reader(" a, b,`" c `"`n")))
        AhkTest.AssertEqual([["a", "b", "c"]], stdlib_csv_test_rows(stdlib.csv.reader("a, b, c`n", "excel", { skipinitialspace: true })))
    }

    static TestReaderStrictRejectsUnclosedQuotedField()
    {
        AhkTest.RaisesMatch(stdlib.csv.Error, "unexpected end of data", (*) => stdlib.csv.reader("`"unterminated", "excel", { strict: true }))
    }

    static TestReaderHonorsEscapecharWhenQuotingNone()
    {
        rows := stdlib_csv_test_rows(stdlib.csv.reader("a\,b,c`n", "excel", { quoting: stdlib.csv.QUOTE_NONE, escapechar: "\" }))

        AhkTest.AssertEqual([["a,b", "c"]], rows)
    }

    static TestReaderQuoteNonnumericConvertsUnquotedFieldsToFloat()
    {
        rows := stdlib_csv_test_rows(stdlib.csv.reader("`"a`",1,1.5`n`"1`",2,`n", "excel", { quoting: stdlib.csv.QUOTE_NONNUMERIC }))

        AhkTest.AssertEqual("a", rows[1][1])
        AhkTest.AssertEqual(1.0, rows[1][2])
        AhkTest.AssertEqual("Float", Type(rows[1][2]))
        AhkTest.AssertEqual(1.5, rows[1][3])
        AhkTest.AssertEqual("Float", Type(rows[1][3]))
        AhkTest.AssertEqual("1", rows[2][1])
        AhkTest.AssertEqual("String", Type(rows[2][1]))
        AhkTest.AssertEqual(2.0, rows[2][2])
        AhkTest.AssertEqual("", rows[2][3])
    }

    static TestWriterQuoteMinimalAndLineTerminator()
    {
        writer := stdlib.csv.writer()

        written := writer.writerow(["a,b", "c"])

        AhkTest.AssertEqual("`"a,b`",c`r`n", writer.text)
        AhkTest.AssertEqual(StrLen(writer.text), written)
    }

    static TestWriterEscapesQuotesAndQuoteAll()
    {
        minimal := stdlib.csv.writer()
        minimal.writerow(["a`"b", "c"])
        AhkTest.AssertEqual("`"a`"`"b`",c`r`n", minimal.text)

        all := stdlib.csv.writer({ quoting: stdlib.csv.QUOTE_ALL })
        all.writerow(["a", "b"])
        AhkTest.AssertEqual("`"a`",`"b`"`r`n", all.text)
    }

    static TestWriterQuoteNonnumericQuotesStrings()
    {
        writer := stdlib.csv.writer({ quoting: stdlib.csv.QUOTE_NONNUMERIC })

        written := writer.writerow(["a", 1, 1.5])

        AhkTest.AssertEqual("`"a`",1,1.5`r`n", writer.text)
        AhkTest.AssertEqual(StrLen(writer.text), written)
    }

    static TestWriterWriterowsWritesRowsWithoutReturnValue()
    {
        writer := stdlib.csv.writer()

        result := writer.writerows([["a"], ["b"]])

        AhkTest.AssertEqual("a`r`nb`r`n", writer.text)
        AhkTest.AssertEqual("", result)
    }

    static TestWriterQuoteNoneRequiresEscapeChar()
    {
        noEscape := stdlib.csv.writer({ quoting: stdlib.csv.QUOTE_NONE })
        AhkTest.RaisesMatch(stdlib.csv.Error, "need to escape, but no escapechar set", (*) => noEscape.writerow(["a,b", "c"]))

        escaped := stdlib.csv.writer({ quoting: stdlib.csv.QUOTE_NONE, escapechar: "\" })
        escaped.writerow(["a,b", "c"])
        AhkTest.AssertEqual("a\,b,c`r`n", escaped.text)
    }

    static TestDictReaderUsesFirstRowAsFieldnames()
    {
        reader := stdlib.csv.DictReader("name,score`nAda,7`nGrace,8`n")

        rows := stdlib_csv_test_rows(reader)

        AhkTest.AssertEqual(["name", "score"], reader.fieldnames)
        AhkTest.AssertEqual(2, rows.Length)
        AhkTest.AssertEqual("Ada", rows[1]["name"])
        AhkTest.AssertEqual("7", rows[1]["score"])
        AhkTest.AssertEqual("Grace", rows[2]["name"])
        AhkTest.AssertEqual("8", rows[2]["score"])
    }

    static TestDictWriterWritesHeaderAndRowsInFieldOrder()
    {
        writer := stdlib.csv.DictWriter(["name", "score"])

        headerWritten := writer.writeheader()
        rowWritten := writer.writerow(Map("score", 7, "name", "Ada"))

        AhkTest.AssertEqual("name,score`r`nAda,7`r`n", writer.text)
        AhkTest.AssertEqual(StrLen("name,score`r`n"), headerWritten)
        AhkTest.AssertEqual(StrLen("Ada,7`r`n"), rowWritten)
    }

    static TestDictWriterRestvalAndExtrasaction()
    {
        writer := stdlib.csv.DictWriter(["name", "score"], { restval: "missing" })
        writer.writerow(Map("name", "Ada"))
        AhkTest.AssertEqual("Ada,missing`r`n", writer.text)

        strict := stdlib.csv.DictWriter(["name"])
        AhkTest.RaisesMatch(ValueError, "dict contains fields not in fieldnames: 'score'", (*) => strict.writerow(Map("name", "Ada", "score", 7)))

        ignoring := stdlib.csv.DictWriter(["name"], { extrasaction: "ignore" })
        ignoring.writerow(Map("name", "Ada", "score", 7))
        AhkTest.AssertEqual("Ada`r`n", ignoring.text)
    }

    static TestDictWriterWriterowsWritesRowsWithoutReturnValue()
    {
        writer := stdlib.csv.DictWriter(["name"])

        result := writer.writerows([Map("name", "Ada"), Map("name", "Grace")])

        AhkTest.AssertEqual("Ada`r`nGrace`r`n", writer.text)
        AhkTest.AssertEqual("", result)
    }

    static TestDictReaderUsesExplicitFieldnamesRestkeyRestvalAndSkipsBlankRows()
    {
        reader := stdlib.csv.DictReader(
            "Ada,7,extra`n`nGrace`n",
            ["name", "score"],
            { restkey: "extra", restval: "missing" }
        )

        rows := stdlib_csv_test_rows(reader)

        AhkTest.AssertEqual(["name", "score"], reader.fieldnames)
        AhkTest.AssertEqual(2, rows.Length)
        AhkTest.AssertEqual("Ada", rows[1]["name"])
        AhkTest.AssertEqual("7", rows[1]["score"])
        AhkTest.AssertEqual(["extra"], rows[1]["extra"])
        AhkTest.AssertEqual("Grace", rows[2]["name"])
        AhkTest.AssertEqual("missing", rows[2]["score"])
        AhkTest.AssertFalse(rows[2].Has("extra"))
    }
}

stdlib_csv_test_rows(reader)
{
    rows := []
    for row in reader
        rows.Push(row)
    return rows
}

AhkTest.Collect(StdlibCsvTest)
