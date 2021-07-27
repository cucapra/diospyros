; ModuleID = 'mult.c'
source_filename = "mult.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@a_in = global [4 x i32] [i32 1, i32 2, i32 3, i32 4], align 16
@b_in = global [4 x i32] [i32 5, i32 6, i32 7, i32 8], align 16
@.str = private unnamed_addr constant [11 x i8] c"first: %i\0A\00", align 1
@.str.1 = private unnamed_addr constant [12 x i8] c"second: %i\0A\00", align 1
@.str.2 = private unnamed_addr constant [11 x i8] c"third: %i\0A\00", align 1
@.str.3 = private unnamed_addr constant [12 x i8] c"fourth: %i\0A\00", align 1

; Function Attrs: noinline nounwind optnone ssp uwtable
define i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca [4 x i32], align 16
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  store i8** %1, i8*** %5, align 8
  %7 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 0), align 16
  %8 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 0), align 16
  %9 = mul nsw i32 %7, %8
  %10 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 0
  store i32 %9, i32* %10, align 16
  %11 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 1), align 4
  %12 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 1), align 4
  %13 = mul nsw i32 %11, %12
  %14 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 1
  store i32 %13, i32* %14, align 4
  %15 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 2), align 8
  %16 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 2), align 8
  %17 = mul nsw i32 %15, %16
  %18 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 2
  store i32 %17, i32* %18, align 8
  %19 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 3), align 4
  %20 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 3), align 4
  %21 = mul nsw i32 %19, %20
  %22 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 3
  store i32 %21, i32* %22, align 4
  %23 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 0
  %24 = load i32, i32* %23, align 16
  %25 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 0), align 4
  %26 = insertelement <4 x i64> zeroinitializer, i32 %25, i64 0
  %27 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 1), align 4
  %28 = insertelement <4 x i64> %26, i32 %27, i64 1
  %29 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 2), align 4
  %30 = insertelement <4 x i64> %28, i32 %29, i64 2
  %31 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 3), align 4
  %32 = insertelement <4 x i64> %30, i32 %31, i64 3
  %33 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 0), align 4
  %34 = insertelement <4 x i64> zeroinitializer, i32 %33, i64 0
  %35 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 1), align 4
  %36 = insertelement <4 x i64> %34, i32 %35, i64 1
  %37 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 2), align 4
  %38 = insertelement <4 x i64> %36, i32 %37, i64 2
  %39 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 3), align 4
  %40 = insertelement <4 x i64> %38, i32 %39, i64 3
  %41 = mul <4 x i64> %32, %40
  %42 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i64 0, i64 0), i32 %24)
  %43 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 1
  %44 = load i32, i32* %43, align 4
  %45 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i64 0, i64 0), i32 %44)
  %46 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 2
  %47 = load i32, i32* %46, align 8
  %48 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), i32 %47)
  %49 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 3
  %50 = load i32, i32* %49, align 4
  %51 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.3, i64 0, i64 0), i32 %50)
  ret i32 0
}

declare i32 @printf(i8*, ...) #1

attributes #0 = { noinline nounwind optnone ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
