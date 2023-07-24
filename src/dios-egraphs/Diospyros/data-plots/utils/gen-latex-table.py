import sys
import csv
from collections import OrderedDict

TOTAL = 10**7

csv_file_path = sys.argv[1]
out_path = sys.argv[2]

headers = []
group_data = OrderedDict()

with open(csv_file_path) as csvfile:
    csvreader = csv.reader(csvfile)

    for i, row in enumerate(csvreader):
        assert len(row) == 5
        if i == 0:
            for header in row[2:]:
                headers.append(header + " avg (s)")
            continue

        group, bench_name, base_time, slp_time, diospyros_time = row
        if group not in group_data:
            group_data[group] = OrderedDict()
        group_data[group][str(bench_name)] = [float(base_time) / TOTAL,
                                              float(slp_time) / TOTAL, float(diospyros_time) / TOTAL]


# https://tex.stackexchange.com/questions/631583/how-would-one-print-table-outputs-in-python-into-latex

textabular = f"l|{'r'*len(headers)}"
texheader = " & " + " & ".join(headers) + "\\\\"
texdata = ""
for group in group_data:
    texdata += "\\hline\n"
    for label in group_data[group]:
        cleaned_label = label
        cleaned_label = cleaned_label.replace(r'-by-', '×')
        cleaned_label = cleaned_label.replace('-', ' ')
        texdata += f"{cleaned_label} & {' & '.join(map(str,group_data[group][label]))} \\\\\n"

total_data = "\\begin{tabular}{"+textabular+"}" + "\n" + \
    texheader + "\n" + texdata + "\\end{tabular}"
print("\\begin{tabular}{"+textabular+"}")
print(texheader)
print(texdata, end="")
print("\\end{tabular}")

with open(out_path, "w") as fp:
    fp.write(total_data)
