; ModuleID = 'llvm-tests/2d-2d-conv.c'
source_filename = "llvm-tests/2d-2d-conv.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.mat_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 2.000000e+00], [2 x float] [float 3.000000e+00, float 4.000000e+00]], align 16
@__const.main.f_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 1.000000e+00], [2 x float] [float 1.000000e+00, float 1.000000e+00]], align 16
@.str = private unnamed_addr constant [12 x i8] c"output: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @convolution([2 x float]* %0, [2 x float]* %1, [3 x float]* %2) #0 {
  %4 = alloca [2 x float]*, align 8
  %5 = alloca [2 x float]*, align 8
  %6 = alloca [3 x float]*, align 8
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  %15 = alloca float, align 4
  store [2 x float]* %0, [2 x float]** %4, align 8
  store [2 x float]* %1, [2 x float]** %5, align 8
  store [3 x float]* %2, [3 x float]** %6, align 8
  store i32 0, i32* %7, align 4
  br label %16

16:                                               ; preds = %94, %3
  %17 = load i32, i32* %7, align 4
  %18 = icmp slt i32 %17, 3
  br i1 %18, label %19, label %97

19:                                               ; preds = %16
  store i32 0, i32* %8, align 4
  br label %20

20:                                               ; preds = %90, %19
  %21 = load i32, i32* %8, align 4
  %22 = icmp slt i32 %21, 3
  br i1 %22, label %23, label %93

23:                                               ; preds = %20
  store i32 0, i32* %9, align 4
  br label %24

24:                                               ; preds = %86, %23
  %25 = load i32, i32* %9, align 4
  %26 = icmp slt i32 %25, 2
  br i1 %26, label %27, label %89

27:                                               ; preds = %24
  store i32 0, i32* %10, align 4
  br label %28

28:                                               ; preds = %82, %27
  %29 = load i32, i32* %10, align 4
  %30 = icmp slt i32 %29, 2
  br i1 %30, label %31, label %85

31:                                               ; preds = %28
  %32 = load i32, i32* %9, align 4
  %33 = sub nsw i32 1, %32
  store i32 %33, i32* %11, align 4
  %34 = load i32, i32* %10, align 4
  %35 = sub nsw i32 1, %34
  store i32 %35, i32* %12, align 4
  %36 = load i32, i32* %7, align 4
  %37 = load i32, i32* %11, align 4
  %38 = sub nsw i32 %36, %37
  store i32 %38, i32* %13, align 4
  %39 = load i32, i32* %8, align 4
  %40 = load i32, i32* %12, align 4
  %41 = sub nsw i32 %39, %40
  store i32 %41, i32* %14, align 4
  %42 = load i32, i32* %13, align 4
  %43 = icmp sge i32 %42, 0
  br i1 %43, label %44, label %81

44:                                               ; preds = %31
  %45 = load i32, i32* %13, align 4
  %46 = icmp slt i32 %45, 2
  br i1 %46, label %47, label %81

47:                                               ; preds = %44
  %48 = load i32, i32* %14, align 4
  %49 = icmp sge i32 %48, 0
  br i1 %49, label %50, label %81

50:                                               ; preds = %47
  %51 = load i32, i32* %14, align 4
  %52 = icmp slt i32 %51, 2
  br i1 %52, label %53, label %81

53:                                               ; preds = %50
  %54 = load [2 x float]*, [2 x float]** %4, align 8
  %55 = load i32, i32* %13, align 4
  %56 = sext i32 %55 to i64
  %57 = getelementptr inbounds [2 x float], [2 x float]* %54, i64 %56
  %58 = load i32, i32* %14, align 4
  %59 = sext i32 %58 to i64
  %60 = getelementptr inbounds [2 x float], [2 x float]* %57, i64 0, i64 %59
  %61 = load float, float* %60, align 4
  %62 = load [2 x float]*, [2 x float]** %5, align 8
  %63 = load i32, i32* %11, align 4
  %64 = sext i32 %63 to i64
  %65 = getelementptr inbounds [2 x float], [2 x float]* %62, i64 %64
  %66 = load i32, i32* %12, align 4
  %67 = sext i32 %66 to i64
  %68 = getelementptr inbounds [2 x float], [2 x float]* %65, i64 0, i64 %67
  %69 = load float, float* %68, align 4
  %70 = fmul float %61, %69
  store float %70, float* %15, align 4
  %71 = load float, float* %15, align 4
  %72 = load [3 x float]*, [3 x float]** %6, align 8
  %73 = load i32, i32* %7, align 4
  %74 = sext i32 %73 to i64
  %75 = getelementptr inbounds [3 x float], [3 x float]* %72, i64 %74
  %76 = load i32, i32* %8, align 4
  %77 = sext i32 %76 to i64
  %78 = getelementptr inbounds [3 x float], [3 x float]* %75, i64 0, i64 %77
  %79 = load float, float* %78, align 4
  %80 = fadd float %79, %71
  store float %80, float* %78, align 4
  br label %81

81:                                               ; preds = %53, %50, %47, %44, %31
  br label %82

82:                                               ; preds = %81
  %83 = load i32, i32* %10, align 4
  %84 = add nsw i32 %83, 1
  store i32 %84, i32* %10, align 4
  br label %28

85:                                               ; preds = %28
  br label %86

86:                                               ; preds = %85
  %87 = load i32, i32* %9, align 4
  %88 = add nsw i32 %87, 1
  store i32 %88, i32* %9, align 4
  br label %24

89:                                               ; preds = %24
  br label %90

90:                                               ; preds = %89
  %91 = load i32, i32* %8, align 4
  %92 = add nsw i32 %91, 1
  store i32 %92, i32* %8, align 4
  br label %20

93:                                               ; preds = %20
  br label %94

94:                                               ; preds = %93
  %95 = load i32, i32* %7, align 4
  %96 = add nsw i32 %95, 1
  store i32 %96, i32* %7, align 4
  br label %16

97:                                               ; preds = %16
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [2 x [2 x float]], align 16
  %3 = alloca [2 x [2 x float]], align 16
  %4 = alloca [3 x [3 x float]], align 16
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %7 = bitcast [2 x [2 x float]]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %7, i8* align 16 bitcast ([2 x [2 x float]]* @__const.main.mat_in to i8*), i64 16, i1 false)
  %8 = bitcast [2 x [2 x float]]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %8, i8* align 16 bitcast ([2 x [2 x float]]* @__const.main.f_in to i8*), i64 16, i1 false)
  %9 = bitcast [3 x [3 x float]]* %4 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %9, i8 0, i64 36, i1 false)
  %10 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %2, i64 0, i64 0
  %11 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 0
  %12 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %4, i64 0, i64 0
  call void @convolution([2 x float]* %10, [2 x float]* %11, [3 x float]* %12)
  store i32 0, i32* %5, align 4
  br label %13

13:                                               ; preds = %34, %0
  %14 = load i32, i32* %5, align 4
  %15 = icmp slt i32 %14, 3
  br i1 %15, label %16, label %37

16:                                               ; preds = %13
  store i32 0, i32* %6, align 4
  br label %17

17:                                               ; preds = %30, %16
  %18 = load i32, i32* %6, align 4
  %19 = icmp slt i32 %18, 3
  br i1 %19, label %20, label %33

20:                                               ; preds = %17
  %21 = load i32, i32* %5, align 4
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %4, i64 0, i64 %22
  %24 = load i32, i32* %6, align 4
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds [3 x float], [3 x float]* %23, i64 0, i64 %25
  %27 = load float, float* %26, align 4
  %28 = fpext float %27 to double
  %29 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %28)
  br label %30

30:                                               ; preds = %20
  %31 = load i32, i32* %6, align 4
  %32 = add nsw i32 %31, 1
  store i32 %32, i32* %6, align 4
  br label %17

33:                                               ; preds = %17
  br label %34

34:                                               ; preds = %33
  %35 = load i32, i32* %5, align 4
  %36 = add nsw i32 %35, 1
  store i32 %36, i32* %5, align 4
  br label %13

37:                                               ; preds = %13
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

declare i32 @printf(i8*, ...) #3

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn writeonly }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
