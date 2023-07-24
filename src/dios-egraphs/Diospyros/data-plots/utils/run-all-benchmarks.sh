benchtypes=( conv qr-decomp mat-mul q-prod stencil )
for name in "${benchtypes[@]}" 
do
     python3 run-benchmarks.py ../../benchmarks/$name/ ../data/$name-data.csv
done