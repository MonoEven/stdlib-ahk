#Requires AutoHotkey v2.0

#Include <stdlib\base64>
#Include <stdlib\collections>
#Include <stdlib\csv>
#Include <stdlib\hashlib>
#Include <stdlib\hmac>
#Include <stdlib\io>
#Include <stdlib\json>
#Include <stdlib\logging>
#Include <stdlib\pathlib>
#Include <stdlib\shutil>
#Include <stdlib\statistics>
#Include <stdlib\tempfile>
#Include <stdlib\textwrap>

if A_Args.Length >= 1 && A_Args[1] = "--bench" {
    iterations := A_Args.Length >= 2 ? Integer(A_Args[2]) : 100
    StdlibDataPipelineBenchmark(iterations)
} else {
    result := StdlibDataPipelineRun()
    FileAppend result["summary"], "*", "UTF-8"
}

StdlibDataPipelineBenchmark(iterations)
{
    if iterations < 1
        throw ValueError("iterations must be >= 1", -1)

    start := StdlibDataPipelinePerfCounter()
    result := unset
    loop iterations
        result := StdlibDataPipelineRun()
    elapsed_ms := (StdlibDataPipelinePerfCounter() - start) * 1000

    output := stdlib.textwrap.dedent(
        "    stdlib-data-pipeline-benchmark`n"
        . "    benchmark_iterations=" iterations "`n"
        . "    total_ms=" Format("{:.3f}", elapsed_ms) "`n"
        . "    avg_ms=" Format("{:.3f}", elapsed_ms / iterations) "`n"
        . "    report_sha256=" result["report_sha256"] "`n"
        . "    signature_b64=" result["signature_b64"] "`n"
    )
    FileAppend output, "*", "UTF-8"
}

StdlibDataPipelineRun()
{
    fieldnames := ["order_id", "customer", "region", "status", "amount", "units"]
    orders := [
        Map("order_id", "A100", "customer", "Ada", "region", "west", "status", "paid", "amount", "42.00", "units", "2"),
        Map("order_id", "A101", "customer", "Grace", "region", "east", "status", "paid", "amount", "63.00", "units", "3"),
        Map("order_id", "A102", "customer", "Lin", "region", "west", "status", "open", "amount", "18.00", "units", "1"),
        Map("order_id", "A103", "customer", "Ada", "region", "west", "status", "paid", "amount", "37.00", "units", "1"),
        Map("order_id", "A104", "customer", "Ken", "region", "north", "status", "cancelled", "amount", "90.00", "units", "4"),
        Map("order_id", "A105", "customer", "Mia", "region", "east", "status", "paid", "amount", "34.00", "units", "2")
    ]

    root := stdlib.tempfile.mkdtemp("", "stdlib-data-pipeline-", stdlib.tempfile.gettempdir())
    stdlib.logging._resetForTests()
    try {
        data_dir := stdlib.pathlib.Path(root, "data")
        output_dir := stdlib.pathlib.Path(root, "out")
        data_dir.mkdir()
        output_dir.mkdir()

        csv_writer := stdlib.csv.DictWriter(fieldnames)
        csv_writer.writeheader()
        for order in orders
            csv_writer.writerow(order)

        csv_path := data_dir.joinpath("orders.csv")
        csv_path.write_text(csv_writer.text, "UTF-8")

        parsed_orders := []
        for row in stdlib.csv.DictReader(csv_path.read_text("UTF-8"))
            parsed_orders.Push(row)

        regions := []
        statuses := []
        paid_amounts := []
        cancelled_order := ""
        for row in parsed_orders {
            regions.Push(row["region"])
            statuses.Push(row["status"])
            if row["status"] = "paid"
                paid_amounts.Push(row["amount"] + 0)
            if row["status"] = "cancelled"
                cancelled_order := row["order_id"]
        }

        region_counts := stdlib.collections.Counter(regions)
        status_counts := stdlib.collections.Counter(statuses)
        top_region := region_counts.most_common(1)[1]
        mean_text := Format("{:.2f}", stdlib.statistics.mean(paid_amounts))
        median_text := Format("{:.2f}", stdlib.statistics.median(paid_amounts))
        stdev_text := Format("{:.2f}", stdlib.statistics.stdev(paid_amounts))

        report := Map(
            "gross_mean", mean_text,
            "gross_median", median_text,
            "gross_stdev", stdev_text,
            "orders", String(parsed_orders.Length),
            "paid_orders", String(status_counts["paid"]),
            "top_region", top_region[1] ":" top_region[2]
        )
        canonical_report := stdlib.json.dumps(report, { sort_keys: true, separators: [",", ":"] })
        report_path := output_dir.joinpath("report.json")
        report_path.write_text(canonical_report, "UTF-8")
        archive_path := stdlib.pathlib.Path(root, "archive-report.json")
        stdlib.shutil.copy2(report_path, archive_path)
        archive_exists := archive_path.exists() && (archive_path.read_text("UTF-8") = canonical_report)

        report_bytes := StdlibDataPipelineBytes(canonical_report)
        report_sha256 := stdlib.hashlib.sha256(report_bytes).hexdigest()
        signature := stdlib.hmac.new(StdlibDataPipelineBytes("stdlib-demo-key"), report_bytes, "sha256")
        signature_b64 := StrGet(stdlib.base64.urlsafe_b64encode(signature.digest()), "UTF-8")

        log_buffer := stdlib.io.StringIO()
        stdlib.logging.basicConfig({ stream: log_buffer, level: "INFO", format: "%(levelname)s:%(message)s", force: true })
        stdlib.logging.info("loaded " parsed_orders.Length " orders")
        stdlib.logging.warning("cancelled order " cancelled_order)
        log_summary := Trim(log_buffer.getvalue(), "`r`n")
        log_summary := StrReplace(log_summary, "`r`n", "`n")
        log_summary := StrReplace(log_summary, "`n", " | ")

        summary := stdlib.textwrap.dedent(
            "    stdlib-data-pipeline-ok`n"
            . "    orders=" parsed_orders.Length " paid=" status_counts["paid"] "`n"
            . "    top_region=" top_region[1] ":" top_region[2] "`n"
            . "    paid_mean=" mean_text " median=" median_text " stdev=" stdev_text "`n"
            . "    report_sha256=" report_sha256 "`n"
            . "    signature_b64=" signature_b64 "`n"
            . "    archive_exists=" (archive_exists ? "true" : "false") "`n"
            . "    log=" log_summary "`n"
        )
        return Map(
            "summary", summary,
            "report_sha256", report_sha256,
            "signature_b64", signature_b64,
            "archive_exists", archive_exists
        )
    } finally {
        stdlib.logging._resetForTests()
        if DirExist(root)
            DirDelete root, true
    }
}

StdlibDataPipelinePerfCounter()
{
    DllCall("QueryPerformanceFrequency", "Int64*", &frequency := 0)
    DllCall("QueryPerformanceCounter", "Int64*", &counter := 0)
    return counter / frequency
}

StdlibDataPipelineBytes(text)
{
    size := StrPut(text, "UTF-8") - 1
    bytes := Buffer(size, 0)
    if size > 0
        StrPut(text, bytes, "UTF-8")
    return bytes
}
