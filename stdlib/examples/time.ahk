#Requires AutoHotkey v2.0

#Include <stdlib\time>

time_example_epoch_seconds := stdlib.time.time()
time_example_epoch_nanoseconds := stdlib.time.time_ns()
time_example_monotonic_seconds := stdlib.time.monotonic()
time_example_monotonic_nanoseconds := stdlib.time.monotonic_ns()
time_example_perf_seconds := stdlib.time.perf_counter()
time_example_perf_nanoseconds := stdlib.time.perf_counter_ns()
time_example_sleep_result := stdlib.time.sleep(0)
time_example_utc_tuple := stdlib.time.gmtime(0)
time_example_local_tuple := stdlib.time.localtime(0)
time_example_root_tuple := stdlib.tuple([2024, 1, 2, 3, 4, 5, 1, 2, -1])
time_example_utc_text := stdlib.time.strftime("%Y-%m-%d %H:%M:%S", time_example_utc_tuple)
time_example_root_tuple_text := stdlib.time.strftime("%Y-%m-%d %H:%M:%S", time_example_root_tuple)
time_example_root_tuple_asctime := stdlib.time.asctime(time_example_root_tuple)
time_example_local_text := stdlib.time.ctime(0)
