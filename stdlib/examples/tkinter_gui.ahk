#Requires AutoHotkey v2.0

#Include <stdlib\tkinter>

root := stdlib.tkinter.Tk()
root.title("stdlib tkinter studio")
root.geometry("960x620")
root.minsize(860, 540)
root.configure({ background: "#f5f7f8" })

count := 0
nameValue := stdlib.tkinter.StringVar(root, "AutoHotkey")
stageValue := stdlib.tkinter.StringVar(root, "draft")
statusValue := stdlib.tkinter.StringVar(root, "Ready")
scoreValue := stdlib.tkinter.DoubleVar(root, 68)
meterValue := stdlib.tkinter.DoubleVar(root, 68)
riskValue := stdlib.tkinter.StringVar(root, "steady")
metricValueCallbacks := ""
metricValueRisk := ""
metricValueToolkit := ""

style := stdlib.tkinter.ttk.Style(root)
try style.theme_use("clam")
style.configure("Shell.TFrame", { background: "#f5f7f8" })
style.configure("Sidebar.TFrame", { background: "#202a33" })
style.configure("SidebarTitle.TLabel", { background: "#202a33", foreground: "#f4f7f8", font: "TkDefaultFont 15 bold" })
style.configure("SidebarMuted.TLabel", { background: "#202a33", foreground: "#9fb0bc" })
style.configure("SidebarMetric.TLabel", { background: "#202a33", foreground: "#d9f3ee", font: "TkDefaultFont 20 bold" })
style.configure("Main.TFrame", { background: "#f5f7f8" })
style.configure("Panel.TFrame", { background: "#ffffff", relief: "flat" })
style.configure("PanelTitle.TLabel", { background: "#ffffff", foreground: "#202a33", font: "TkDefaultFont 11 bold" })
style.configure("PanelMuted.TLabel", { background: "#ffffff", foreground: "#667782" })
style.configure("Hero.TLabel", { background: "#f5f7f8", foreground: "#202a33", font: "TkDefaultFont 20 bold" })
style.configure("Subtle.TLabel", { background: "#f5f7f8", foreground: "#667782" })
style.configure("Field.TLabel", { background: "#ffffff", foreground: "#40515d" })
style.configure("Status.TLabel", { background: "#ffffff", foreground: "#202a33", font: "TkDefaultFont 10 bold" })
style.configure("Accent.Horizontal.TProgressbar", { troughcolor: "#e6ecef", background: "#2d8f84", thickness: 8 })
style.configure("Studio.Treeview", { rowheight: 28, font: "TkDefaultFont 9", background: "#ffffff", fieldbackground: "#ffffff", foreground: "#24333d" })
style.configure("Studio.Treeview.Heading", { font: "TkDefaultFont 9 bold", foreground: "#40515d" })
style.map("Studio.Treeview", { foreground: [["selected", "#ffffff"]], background: [["selected", "#2d8f84"]] })
style.configure("Accent.TButton", { padding: [14, 8], background: "#2d8f84", foreground: "#ffffff" })
style.map("Accent.TButton", { background: [["active", "#25786f"], ["pressed", "#1f655e"]] })

shell := stdlib.tkinter.ttk.Frame(root, { style: "Shell.TFrame" })
shell.grid({ row: 0, column: 0, sticky: "nsew" })
root.columnconfigure(0, { weight: 1 })
root.rowconfigure(0, { weight: 1 })
shell.columnconfigure(0, { weight: 0, minsize: 230 })
shell.columnconfigure(1, { weight: 1 })
shell.rowconfigure(0, { weight: 1 })

sidebar := stdlib.tkinter.ttk.Frame(shell, { padding: [22, 24], style: "Sidebar.TFrame" })
sidebar.grid({ row: 0, column: 0, sticky: "nsew" })
sidebar.columnconfigure(0, { weight: 1 })
sidebar.rowconfigure(7, { weight: 1 })

stdlib.tkinter.ttk.Label(sidebar, { text: "tk studio", style: "SidebarTitle.TLabel" })
    .grid({ row: 0, column: 0, sticky: "w" })
stdlib.tkinter.ttk.Label(sidebar, { text: "stdlib/tkinter demo", style: "SidebarMuted.TLabel" })
    .grid({ row: 1, column: 0, pady: [2, 26], sticky: "w" })

stdlib.tkinter.ttk.Label(sidebar, { text: "current score", style: "SidebarMuted.TLabel" })
    .grid({ row: 2, column: 0, sticky: "w" })
scoreReadout := stdlib.tkinter.ttk.Label(sidebar, { text: "68%", style: "SidebarMetric.TLabel" })
scoreReadout.grid({ row: 3, column: 0, pady: [4, 22], sticky: "w" })

stdlib.tkinter.ttk.Label(sidebar, { text: "stage", style: "SidebarMuted.TLabel" })
    .grid({ row: 4, column: 0, sticky: "w" })
stageReadout := stdlib.tkinter.ttk.Label(sidebar, { text: "draft", style: "SidebarTitle.TLabel" })
stageReadout.grid({ row: 5, column: 0, pady: [4, 22], sticky: "w" })

stdlib.tkinter.ttk.Label(sidebar, { text: "status", style: "SidebarMuted.TLabel" })
    .grid({ row: 6, column: 0, sticky: "w" })
sideStatus := stdlib.tkinter.ttk.Label(sidebar, { textvariable: statusValue, wraplength: 180, style: "SidebarMuted.TLabel" })
sideStatus.grid({ row: 7, column: 0, pady: [4, 0], sticky: "nw" })

main := stdlib.tkinter.ttk.Frame(shell, { padding: [26, 22], style: "Main.TFrame" })
main.grid({ row: 0, column: 1, sticky: "nsew" })
main.columnconfigure(0, { weight: 3 })
main.columnconfigure(1, { weight: 2 })
main.rowconfigure(3, { weight: 1 })

stdlib.tkinter.ttk.Label(main, { text: "Workspace overview", style: "Hero.TLabel" })
    .grid({ row: 0, column: 0, sticky: "w" })
stdlib.tkinter.ttk.Label(main, { text: "Variables, callbacks, canvas drawing, tree data, and ttk styling in one AutoHotkey window.", style: "Subtle.TLabel" })
    .grid({ row: 1, column: 0, columnspan: 2, pady: [2, 18], sticky: "w" })

actionPanel := stdlib.tkinter.ttk.Frame(main, { padding: [18, 16], style: "Panel.TFrame" })
actionPanel.grid({ row: 0, column: 1, rowspan: 3, padx: [18, 0], sticky: "nsew" })
actionPanel.columnconfigure(0, { weight: 1 })

stdlib.tkinter.ttk.Label(actionPanel, { text: "Control surface", style: "PanelTitle.TLabel" })
    .grid({ row: 0, column: 0, sticky: "w" })
stdlib.tkinter.ttk.Label(actionPanel, { text: "Update state through Tk variables.", style: "PanelMuted.TLabel" })
    .grid({ row: 1, column: 0, pady: [2, 14], sticky: "w" })

stdlib.tkinter.ttk.Label(actionPanel, { text: "Name", style: "Field.TLabel" })
    .grid({ row: 2, column: 0, pady: [0, 4], sticky: "w" })
nameEntry := stdlib.tkinter.ttk.Entry(actionPanel, { textvariable: nameValue, width: 28 })
nameEntry.grid({ row: 3, column: 0, sticky: "ew" })

stdlib.tkinter.ttk.Label(actionPanel, { text: "Stage", style: "Field.TLabel" })
    .grid({ row: 4, column: 0, pady: [14, 4], sticky: "w" })
stageChoice := stdlib.tkinter.ttk.Combobox(actionPanel, { textvariable: stageValue, values: ["draft", "review", "ship"], state: "readonly" })
stageChoice.grid({ row: 5, column: 0, sticky: "ew" })
stageChoice.current(0)

stdlib.tkinter.ttk.Label(actionPanel, { text: "Score", style: "Field.TLabel" })
    .grid({ row: 6, column: 0, pady: [14, 4], sticky: "w" })
scoreScale := stdlib.tkinter.ttk.Scale(actionPanel, { variable: scoreValue, from_: 0, to: 100, command: (*) => refresh_dashboard() })
scoreScale.grid({ row: 7, column: 0, sticky: "ew" })

progress := stdlib.tkinter.ttk.Progressbar(actionPanel, { orient: "horizontal", mode: "determinate", maximum: 100, variable: meterValue, style: "Accent.Horizontal.TProgressbar" })
progress.grid({ row: 8, column: 0, pady: [12, 0], sticky: "ew" })

updateButton := stdlib.tkinter.ttk.Button(actionPanel, { text: "Update workspace", command: refresh_dashboard, style: "Accent.TButton" })
updateButton.grid({ row: 9, column: 0, pady: [18, 0], sticky: "ew" })

stdlib.tkinter.ttk.Label(actionPanel, { textvariable: statusValue, wraplength: 260, style: "PanelMuted.TLabel" })
    .grid({ row: 10, column: 0, pady: [14, 0], sticky: "w" })

metricPanel := stdlib.tkinter.ttk.Frame(main, { padding: [18, 16], style: "Panel.TFrame" })
metricPanel.grid({ row: 2, column: 0, sticky: "nsew" })
metricPanel.columnconfigure(0, { weight: 1 })
metricPanel.columnconfigure(1, { weight: 1 })
metricPanel.columnconfigure(2, { weight: 1 })

AddMetric(metricPanel, 0, "Callbacks", "0")
AddMetric(metricPanel, 1, "Risk", "steady")
AddMetric(metricPanel, 2, "Toolkit", "Tk 8.6")

visualPanel := stdlib.tkinter.ttk.Frame(main, { padding: [18, 16], style: "Panel.TFrame" })
visualPanel.grid({ row: 3, column: 0, columnspan: 2, pady: [18, 0], sticky: "nsew" })
visualPanel.columnconfigure(0, { weight: 3 })
visualPanel.columnconfigure(1, { weight: 2 })
visualPanel.rowconfigure(1, { weight: 1 })

stdlib.tkinter.ttk.Label(visualPanel, { text: "Live output", style: "PanelTitle.TLabel" })
    .grid({ row: 0, column: 0, sticky: "w" })
stdlib.tkinter.ttk.Label(visualPanel, { text: "Canvas and Treeview update from the same state.", style: "PanelMuted.TLabel" })
    .grid({ row: 0, column: 1, sticky: "e" })

canvas := stdlib.tkinter.Canvas(visualPanel, { width: 440, height: 230, bg: "#ffffff", highlightthickness: 0 })
canvas.grid({ row: 1, column: 0, pady: [12, 0], sticky: "nsew" })
canvas.create_rectangle(16, 18, 426, 214, { fill: "#f8faf9", outline: "#d8e2df" })
canvas.create_text(32, 34, { text: "Project signal", anchor: "nw", fill: "#667782" })
canvas.create_line(32, 174, 408, 174, { fill: "#d8e2df", width: 1 })
canvas.create_line(32, 132, 408, 132, { fill: "#edf2f1", width: 1 })
canvas.create_line(32, 90, 408, 90, { fill: "#edf2f1", width: 1 })
curve := canvas.create_line(40, 150, 110, 130, 180, 136, 250, 96, 320, 110, 398, 76, { fill: "#2d8f84", width: 3, smooth: 1 })
bar := canvas.create_rectangle(32, 184, 32, 196, { fill: "#2d8f84", outline: "#2d8f84" })
caption := canvas.create_text(32, 62, { text: "Ready", anchor: "nw", fill: "#202a33" })

tree := stdlib.tkinter.ttk.Treeview(visualPanel, { columns: ["value"], show: ["tree", "headings"], height: 7, style: "Studio.Treeview" })
tree.heading("#0", { text: "Signal" })
tree.heading("value", { text: "Value" })
tree.column("#0", { width: 145, anchor: "w" })
tree.column("value", { width: 145, anchor: "center" })
tree.insert("", "end", "stage", { text: "Stage", values: [stageValue.get()] })
tree.insert("", "end", "score", { text: "Score", values: [scoreValue.get() "%"] })
tree.insert("", "end", "risk", { text: "Risk", values: [riskValue.get()] })
tree.insert("", "end", "updates", { text: "Updates", values: [0] })
tree.grid({ row: 1, column: 1, padx: [18, 0], pady: [12, 0], sticky: "nsew" })

notebook := stdlib.tkinter.ttk.Notebook(main, { height: 88 })
noteOne := stdlib.tkinter.ttk.Frame(notebook, { padding: [12, 10], style: "Panel.TFrame" })
noteTwo := stdlib.tkinter.ttk.Frame(notebook, { padding: [12, 10], style: "Panel.TFrame" })
notebook.add(noteOne, { text: "Summary", padding: 8 })
notebook.add(noteTwo, { text: "Automation", padding: 8 })
stdlib.tkinter.ttk.Label(noteOne, { text: "The demo uses Tk variables, ttk widgets, grid layout, canvas drawing, and tree data.", style: "PanelMuted.TLabel" })
    .grid({ row: 0, column: 0, sticky: "w" })
stdlib.tkinter.ttk.Label(noteTwo, { text: "Run with --capture <marker> for automated checks.", style: "PanelMuted.TLabel" })
    .grid({ row: 0, column: 0, sticky: "w" })
notebook.grid({ row: 4, column: 0, columnspan: 2, pady: [16, 0], sticky: "ew" })

AddMetric(parent, column, label, value)
{
    global metricValueCallbacks, metricValueRisk, metricValueToolkit

    block := stdlib.tkinter.ttk.Frame(parent, { padding: [12, 10], style: "Panel.TFrame" })
    block.grid({ row: 0, column: column, padx: column = 0 ? [0, 8] : [8, 8], sticky: "ew" })
    stdlib.tkinter.ttk.Label(block, { text: label, style: "PanelMuted.TLabel" }).grid({ row: 0, column: 0, sticky: "w" })
    valueLabel := stdlib.tkinter.ttk.Label(block, { text: value, style: "PanelTitle.TLabel" })
    valueLabel.grid({ row: 1, column: 0, pady: [4, 0], sticky: "w" })

    if label = "Callbacks"
        metricValueCallbacks := valueLabel
    else if label = "Risk"
        metricValueRisk := valueLabel
    else if label = "Toolkit"
        metricValueToolkit := valueLabel

    return block
}

refresh_dashboard(*)
{
    global count, nameValue, stageValue, scoreValue, meterValue, riskValue, statusValue
    global canvas, bar, caption, curve, tree, scoreReadout, stageReadout
    global metricValueCallbacks, metricValueRisk

    count += 1
    score := Integer(scoreValue.get())
    risk := score < 40 ? "attention" : score < 75 ? "steady" : "strong"
    status := stageValue.get() " for " nameValue.get() ": " score "%"

    meterValue.set(score)
    riskValue.set(risk)
    statusValue.set(status)
    scoreReadout.configure({ text: score "%" })
    stageReadout.configure({ text: stageValue.get() })

    canvas.coords(bar, 32, 184, 32 + Round(score * 3.76), 196)
    canvas.itemconfigure(caption, { text: status })
    canvas.itemconfigure(curve, { fill: risk = "attention" ? "#b95b52" : risk = "steady" ? "#2d8f84" : "#225f99" })

    tree.set("stage", "value", stageValue.get())
    tree.set("score", "value", score "%")
    tree.set("risk", "value", risk)
    tree.set("updates", "value", count)
    tree.selection_set(["updates"])
    tree.see("updates")

    metricValueCallbacks.configure({ text: count })
    metricValueRisk.configure({ text: risk })

    return stdlib.None
}

refresh_dashboard()

if A_Args.Length >= 1 && A_Args[1] = "--capture" {
    markerPath := A_Args.Length >= 2 ? A_Args[2] : A_Temp "\stdlib-tkinter-gui-example.marker"
    root.after(200, (*) => (scoreValue.set(82), stageValue.set("review"), refresh_dashboard(), FileAppend("tkinter-gui-example-ok`n", markerPath, "UTF-8"), root.destroy()))
}

root.mainloop()
