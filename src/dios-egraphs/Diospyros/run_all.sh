for file in llvm-tests/*.c
do
  make run test="$file"
  ./a.out
done