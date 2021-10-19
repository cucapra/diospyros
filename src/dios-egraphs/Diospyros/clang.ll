; ModuleID = 'llvm-tests/stencil-2d.c'
source_filename = "llvm-tests/stencil-2d.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.orig_in = private unnamed_addr constant [32 x float] [float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00], align 16
@__const.main.sol_out = private unnamed_addr constant [32 x float] [float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00], align 16
@__const.main.filter_in = private unnamed_addr constant [9 x float] [float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @stencil(float* %0, float* %1, float* %2) #0 {
  %4 = alloca float*, align 8
  %5 = alloca float*, align 8
  %6 = alloca float*, align 8
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca float, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  store float* %0, float** %4, align 8
  store float* %1, float** %5, align 8
  store float* %2, float** %6, align 8
  store i32 0, i32* %7, align 4
  br label %12

12:                                               ; preds = %71, %3
  %13 = load i32, i32* %7, align 4
  %14 = icmp slt i32 %13, 6
  br i1 %14, label %15, label %74

15:                                               ; preds = %12
  store i32 0, i32* %8, align 4
  br label %16

16:                                               ; preds = %67, %15
  %17 = load i32, i32* %8, align 4
  %18 = icmp slt i32 %17, 2
  br i1 %18, label %19, label %70

19:                                               ; preds = %16
  store float 0.000000e+00, float* %9, align 4
  store i32 0, i32* %10, align 4
  br label %20

20:                                               ; preds = %55, %19
  %21 = load i32, i32* %10, align 4
  %22 = icmp slt i32 %21, 3
  br i1 %22, label %23, label %58

23:                                               ; preds = %20
  store i32 0, i32* %11, align 4
  br label %24

24:                                               ; preds = %51, %23
  %25 = load i32, i32* %11, align 4
  %26 = icmp slt i32 %25, 3
  br i1 %26, label %27, label %54

27:                                               ; preds = %24
  %28 = load float*, float** %6, align 8
  %29 = load i32, i32* %10, align 4
  %30 = mul nsw i32 %29, 3
  %31 = load i32, i32* %11, align 4
  %32 = add nsw i32 %30, %31
  %33 = sext i32 %32 to i64
  %34 = getelementptr inbounds float, float* %28, i64 %33
  %35 = load float, float* %34, align 4
  %36 = load float*, float** %4, align 8
  %37 = load i32, i32* %7, align 4
  %38 = load i32, i32* %10, align 4
  %39 = add nsw i32 %37, %38
  %40 = mul nsw i32 %39, 4
  %41 = load i32, i32* %8, align 4
  %42 = add nsw i32 %40, %41
  %43 = load i32, i32* %11, align 4
  %44 = add nsw i32 %42, %43
  %45 = sext i32 %44 to i64
  %46 = getelementptr inbounds float, float* %36, i64 %45
  %47 = load float, float* %46, align 4
  %48 = fmul float %35, %47
  %49 = load float, float* %9, align 4
  %50 = fadd float %49, %48
  store float %50, float* %9, align 4
  br label %51

51:                                               ; preds = %27
  %52 = load i32, i32* %11, align 4
  %53 = add nsw i32 %52, 1
  store i32 %53, i32* %11, align 4
  br label %24

54:                                               ; preds = %24
  br label %55

55:                                               ; preds = %54
  %56 = load i32, i32* %10, align 4
  %57 = add nsw i32 %56, 1
  store i32 %57, i32* %10, align 4
  br label %20

58:                                               ; preds = %20
  %59 = load float, float* %9, align 4
  %60 = load float*, float** %5, align 8
  %61 = load i32, i32* %7, align 4
  %62 = mul nsw i32 %61, 4
  %63 = load i32, i32* %8, align 4
  %64 = add nsw i32 %62, %63
  %65 = sext i32 %64 to i64
  %66 = getelementptr inbounds float, float* %60, i64 %65
  store float %59, float* %66, align 4
  br label %67

67:                                               ; preds = %58
  %68 = load i32, i32* %8, align 4
  %69 = add nsw i32 %68, 1
  store i32 %69, i32* %8, align 4
  br label %16

70:                                               ; preds = %16
  br label %71

71:                                               ; preds = %70
  %72 = load i32, i32* %7, align 4
  %73 = add nsw i32 %72, 1
  store i32 %73, i32* %7, align 4
  br label %12

74:                                               ; preds = %12
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [32 x float], align 16
  %3 = alloca [32 x float], align 16
  %4 = alloca [9 x float], align 16
  %5 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %6 = bitcast [32 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %6, i8* align 16 bitcast ([32 x float]* @__const.main.orig_in to i8*), i64 128, i1 false)
  %7 = bitcast [32 x float]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %7, i8* align 16 bitcast ([32 x float]* @__const.main.sol_out to i8*), i64 128, i1 false)
  %8 = bitcast [9 x float]* %4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %8, i8* align 16 bitcast ([9 x float]* @__const.main.filter_in to i8*), i64 36, i1 false)
  %9 = getelementptr inbounds [32 x float], [32 x float]* %2, i64 0, i64 0
  %10 = getelementptr inbounds [32 x float], [32 x float]* %3, i64 0, i64 0
  %11 = getelementptr inbounds [9 x float], [9 x float]* %4, i64 0, i64 0
  call void @stencil(float* %9, float* %10, float* %11)
  store i32 0, i32* %5, align 4
  br label %12

12:                                               ; preds = %22, %0
  %13 = load i32, i32* %5, align 4
  %14 = icmp slt i32 %13, 32
  br i1 %14, label %15, label %25

15:                                               ; preds = %12
  %16 = load i32, i32* %5, align 4
  %17 = sext i32 %16 to i64
  %18 = getelementptr inbounds [32 x float], [32 x float]* %3, i64 0, i64 %17
  %19 = load float, float* %18, align 4
  %20 = fpext float %19 to double
  %21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %20)
  br label %22

22:                                               ; preds = %15
  %23 = load i32, i32* %5, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %5, align 4
  br label %12

25:                                               ; preds = %12
  %26 = load i32, i32* %1, align 4
  ret i32 %26
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

declare i32 @printf(i8*, ...) #2

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
