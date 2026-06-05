#Requires AutoHotkey v2.0

#Include <stdlib\tkinter>

root := stdlib.tkinter.Tk()
root.title("stdlib tkinter dashboard")
root.geometry("780x520")
root.minsize(720, 480)
root.configure({ background: "#eef3f8" })

count := 0
nameValue := stdlib.tkinter.StringVar(root, "AutoHotkey")
stageValue := stdlib.tkinter.StringVar(root, "draft")
statusValue := stdlib.tkinter.StringVar(root, "Ready")
scoreValue := stdlib.tkinter.DoubleVar(root, 64)
meterValue := stdlib.tkinter.DoubleVar(root, 64)

style := stdlib.tkinter.ttk.Style(root)
try style.theme_use("clam")
style.configure("App.TFrame", { background: "#eef3f8" })
style.configure("Header.TLabel", { background: "#eef3f8", foreground: "#12324a", font: "TkDefaultFont 18 bold" })
style.configure("Subtle.TLabel", { background: "#eef3f8", foreground: "#496477" })
style.configure("Panel.TLabelframe", { background: "#eef3f8", padding: 10 })
style.configure("Panel.TLabelframe.Label", { background: "#eef3f8", foreground: "#12324a", font: "TkDefaultFont 10 bold" })
style.configure("Accent.Horizontal.TProgressbar", { troughcolor: "#dce8f2", background: "#2878b8" })
style.configure("Dashboard.Treeview", { rowheight: 26, font: "TkDefaultFont 9" })
style.map("Dashboard.Treeview", { foreground: [["selected", "white"]], background: [["selected", "#2878b8"]] })

main := stdlib.tkinter.ttk.Frame(root, { padding: [18, 16], style: "App.TFrame" })
main.grid({ row: 0, column: 0, sticky: "nsew" })
root.columnconfigure(0, { weight: 1 })
root.rowconfigure(0, { weight: 1 })
main.columnconfigure(0, { weight: 2 })
main.columnconfigure(1, { weight: 3 })
main.rowconfigure(2, { weight: 1 })

stdlib.tkinter.ttk.Label(main, { text: "stdlib tkinter dashboard", style: "Header.TLabel" })
    .grid({ row: 0, column: 0, columnspan: 2, sticky: "w" })
stdlib.tkinter.ttk.Label(main, { text: "ttk widgets, variables, layout, callbacks, tree data, and canvas drawing in one window", style: "Subtle.TLabel" })
    .grid({ row: 1, column: 0, columnspan: 2, pady: [2, 14], sticky: "w" })

controls := stdlib.tkinter.ttk.LabelFrame(main, { text: "Controls", padding: [12, 10], style: "Panel.TLabelframe" })
controls.grid({ row: 2, column: 0, padx: [0, 12], sticky: "nsew" })
controls.columnconfigure(1, { weight: 1 })

stdlib.tkinter.ttk.Label(controls, { text: "Name" })
    .grid({ row: 0, column: 0, padx: [0, 8], pady: 6, sticky: "w" })
nameEntry := stdlib.tkinter.ttk.Entry(controls, { textvariable: nameValue, width: 24 })
nameEntry.grid({ row: 0, column: 1, pady: 6, sticky: "ew" })

stdlib.tkinter.ttk.Label(controls, { text: "Stage" })
    .grid({ row: 1, column: 0, padx: [0, 8], pady: 6, sticky: "w" })
stageChoice := stdlib.tkinter.ttk.Combobox(controls, { textvariable: stageValue, values: ["draft", "review", "ship"], state: "readonly", width: 18 })
stageChoice.grid({ row: 1, column: 1, pady: 6, sticky: "ew" })
stageChoice.current(0)

stdlib.tkinter.ttk.Label(controls, { text: "Score" })
    .grid({ row: 2, column: 0, padx: [0, 8], pady: 6, sticky: "w" })
scoreRow := stdlib.tkinter.ttk.Frame(controls)
scoreRow.grid({ row: 2, column: 1, pady: 6, sticky: "ew" })
scoreRow.columnconfigure(0, { weight: 1 })
scoreScale := stdlib.tkinter.ttk.Scale(scoreRow, { variable: scoreValue, from_: 0, to: 100, command: (*) => refresh_dashboard() })
scoreScale.grid({ row: 0, column: 0, sticky: "ew" })
stdlib.tkinter.ttk.Label(scoreRow, { textvariable: scoreValue, width: 5 })
    .grid({ row: 0, column: 1, padx: [8, 0], sticky: "e" })

progress := stdlib.tkinter.ttk.Progressbar(controls, { orient: "horizontal", mode: "determinate", maximum: 100, variable: meterValue, style: "Accent.Horizontal.TProgressbar" })
progress.grid({ row: 3, column: 0, columnspan: 2, pady: [10, 8], sticky: "ew" })

updateButton := stdlib.tkinter.ttk.Button(controls, { text: "Update", command: refresh_dashboard })
updateButton.grid({ row: 4, column: 0, columnspan: 2, pady: [4, 0], sticky: "ew" })
stdlib.tkinter.ttk.Label(controls, { textvariable: statusValue })
    .grid({ row: 5, column: 0, columnspan: 2, pady: [10, 0], sticky: "w" })

display := stdlib.tkinter.ttk.LabelFrame(main, { text: "Live output", padding: [12, 10], style: "Panel.TLabelframe" })
display.grid({ row: 2, column: 1, sticky: "nsew" })
display.columnconfigure(0, { weight: 1 })
display.rowconfigure(1, { weight: 1 })

canvas := stdlib.tkinter.Canvas(display, { width: 420, height: 140, bg: "white", highlightthickness: 0 })
canvas.grid({ row: 0, column: 0, sticky: "ew" })
canvas.create_rectangle(14, 18, 406, 124, { fill: "#f7fbff", outline: "#d4e3ef" })
canvas.create_text(28, 34, { text: "Current score", anchor: "nw", fill: "#496477" })
bar := canvas.create_rectangle(28, 82, 28, 108, { fill: "#2878b8", outline: "#2878b8" })
caption := canvas.create_text(28, 58, { text: "Ready", anchor: "nw", fill: "#12324a" })

tree := stdlib.tkinter.ttk.Treeview(display, { columns: ["value"], show: ["tree", "headings"], height: 6, style: "Dashboard.Treeview" })
tree.heading("#0", { text: "Signal" })
tree.heading("value", { text: "Value" })
tree.column("#0", { width: 160, anchor: "w" })
tree.column("value", { width: 180, anchor: "center" })
tree.insert("", "end", "stage", { text: "Stage", values: [stageValue.get()] })
tree.insert("", "end", "score", { text: "Score", values: [scoreValue.get() "%"] })
tree.insert("", "end", "updates", { text: "Updates", values: [0], tags: ["active"] })
tree.tag_configure("active", { foreground: "#12324a" })
tree.grid({ row: 1, column: 0, pady: [12, 0], sticky: "nsew" })

footer := stdlib.tkinter.ttk.Frame(main, { style: "App.TFrame" })
footer.grid({ row: 3, column: 0, columnspan: 2, pady: [12, 0], sticky: "ew" })
footer.columnconfigure(0, { weight: 1 })
notebook := stdlib.tkinter.ttk.Notebook(footer, { height: 72 })
noteOne := stdlib.tkinter.ttk.Frame(notebook)
noteTwo := stdlib.tkinter.ttk.Frame(notebook)
notebook.add(noteOne, { text: "Summary", padding: 8 })
notebook.add(noteTwo, { text: "Notes", padding: 8 })
stdlib.tkinter.ttk.Label(noteOne, { text: "Close the window when finished." }).grid({ row: 0, column: 0, sticky: "w" })
stdlib.tkinter.ttk.Label(noteTwo, { text: "Run with --capture <marker> for automated checks." }).grid({ row: 0, column: 0, sticky: "w" })
notebook.grid({ row: 0, column: 0, sticky: "ew" })

refresh_dashboard(*)
{
    global count, nameValue, stageValue, scoreValue, meterValue, statusValue, canvas, bar, caption, tree
    count += 1
    score := Integer(scoreValue.get())
    meterValue.set(score)
    status := stageValue.get() " for " nameValue.get() ": " score "%"
    statusValue.set(status)
    canvas.coords(bar, 28, 82, 28 + Round(score * 3.6), 108)
    canvas.itemconfigure(caption, { text: status })
    tree.set("stage", "value", stageValue.get())
    tree.set("score", "value", score "%")
    tree.set("updates", "value", count)
    tree.selection_set(["updates"])
    tree.see("updates")
    return stdlib.None
}

refresh_dashboard()

if A_Args.Length >= 1 && A_Args[1] = "--capture" {
    markerPath := A_Args.Length >= 2 ? A_Args[2] : A_Temp "\stdlib-tkinter-gui-example.marker"
    root.after(200, (*) => (scoreValue.set(82), stageValue.set("review"), refresh_dashboard(), FileAppend("tkinter-gui-example-ok`n", markerPath, "UTF-8"), root.destroy()))
}

root.mainloop()
