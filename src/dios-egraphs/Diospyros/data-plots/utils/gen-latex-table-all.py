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
            headers.append("Benchmark name")
            for header in row[2:]:
                headers.append(header + " avg (s)")
            # headers.append("SLP speedup")
            # headers.append("Diospyros speedup")
            continue

        group, bench_name, base_time, slp_time, diospyros_time = row
        if group not in group_data:
            group_data[group] = OrderedDict()
        group_data[group][str(bench_name)] = ["{:.4e}".format(float(base_time) / TOTAL, 2),
                                              "{:.4e}".format(
                                                  float(slp_time) / TOTAL, 2),
                                              "{:.4e}".format(
                                                  float(diospyros_time) / TOTAL, 2), ]
        #   "{:.2e}".format(float(base_time) /
        #                   float(slp_time), 2),
        #   "{:.2e}".format(float(base_time) / float(diospyros_time), 2)]


# https://tex.stackexchange.com/questions/631583/how-would-one-print-table-outputs-in-python-into-latex

textabular = f"l|{'r'*len(headers)}"
texheader = " & ".join(headers) + "\\\\"
texdata = ""
for group in group_data:
    texdata += "\\hline\n"
    for label in group_data[group]:
        cleaned_label = label
        cleaned_label = cleaned_label.replace(r'-by-', '×')
        cleaned_label = cleaned_label.replace('-', ' ')
        cleaned_label = cleaned_label.replace(' and ', ',')
        texdata += f"{cleaned_label} & {' & '.join(map(str,group_data[group][label]))} \\\\\n"

total_data = "\\begin{longtable}{"+textabular+"}" + "\n" + \
    texheader + "\n" + texdata + "\\end{longtable}"
print("\\begin{longtable}{"+textabular+"}")
print(texheader)
print(texdata, end="")
print("\\end{longtable}")

with open(out_path, "w") as fp:
    fp.write(total_data)
