import sys
import csv


def avg(lst):
    return sum(lst) / len(lst)


def calc(csv_path):
    data = []
    with open(csv_path, "r+") as csvfile:
        csvreader = csv.reader(csvfile)
        for i, row in enumerate(csvreader):
            if i == 0:
                continue
            data.append((row[1], row[2], row[3]))

    average_base = avg(list(map(lambda trip: float(trip[0]), data)))
    average_slp = avg(list(map(lambda trip: float(trip[1]), data)))
    average_dios = avg(list(map(lambda trip: float(trip[2]), data)))

    print(average_base, average_slp, average_dios)
    print(average_base / average_dios, average_slp / average_dios)


def main():
    csv_path = sys.argv[1]
    calc(csv_path)


main()
