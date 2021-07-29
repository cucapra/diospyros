; ModuleID = 'llvm-tests/add_mult.c'
source_filename = "llvm-tests/add_mult.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@a_in = global [4 x i32] [i32 1, i32 2, i32 3, i32 4], align 16
@b_in = global [4 x i32] [i32 2, i32 3, i32 4, i32 5], align 16
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
  %9 = add nsw i32 %7, %8
  %10 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 0
  store i32 %9, i32* %10, align 16
  %11 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 1), align 4
  %12 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 1), align 4
  %13 = mul nsw i32 %11, %12
  %14 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 1
  store i32 %13, i32* %14, align 4
  %15 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 2), align 8
  %16 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 2), align 8
  %17 = add nsw i32 %15, %16
  %18 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 2
  store i32 %17, i32* %18, align 8
  %19 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 3), align 4
  %20 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 3), align 4
  %21 = mul nsw i32 %19, %20
  %22 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 3
  store i32 %21, i32* %22, align 4
  %23 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 0), align 4
  %24 = insertelement <4 x i32> zeroinitializer, i32 %23, i32 0
  %25 = insertelement <4 x i32> %24, i32 0, i32 1
  %26 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 2), align 4
  %27 = insertelement <4 x i32> %25, i32 %26, i32 2
  %28 = insertelement <4 x i32> %27, i32 0, i32 3
  %29 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 1), align 4
  %30 = insertelement <4 x i32> <i32 1, i32 0, i32 0, i32 0>, i32 %29, i32 1
  %31 = insertelement <4 x i32> %30, i32 1, i32 2
  %32 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @a_in, i64 0, i64 3), align 4
  %33 = insertelement <4 x i32> %31, i32 %32, i32 3
  %34 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 0), align 4
  %35 = insertelement <4 x i32> zeroinitializer, i32 %34, i32 0
  %36 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 1), align 4
  %37 = insertelement <4 x i32> %35, i32 %36, i32 1
  %38 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 2), align 4
  %39 = insertelement <4 x i32> %37, i32 %38, i32 2
  %40 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @b_in, i64 0, i64 3), align 4
  %41 = insertelement <4 x i32> %39, i32 %40, i32 3
  %42 = mul <4 x i32> %33, %41
  %43 = add <4 x i32> %28, %42
  %44 = extractelement <4 x i32> %43, i32 0
  store i32 %44, i32* %10, align 16
  %45 = extractelement <4 x i32> %43, i32 1
  store i32 %45, i32* %14, align 4
  %46 = extractelement <4 x i32> %43, i32 2
  store i32 %46, i32* %18, align 8
  %47 = extractelement <4 x i32> %43, i32 3
  store i32 %47, i32* %22, align 4
  %48 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 0
  %49 = load i32, i32* %48, align 16
  %50 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i64 0, i64 0), i32 %49)
  %51 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 1
  %52 = load i32, i32* %51, align 4
  %53 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i64 0, i64 0), i32 %52)
  %54 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 2
  %55 = load i32, i32* %54, align 8
  %56 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), i32 %55)
  %57 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 3
  %58 = load i32, i32* %57, align 4
  %59 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.3, i64 0, i64 0), i32 %58)
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
