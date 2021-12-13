; ModuleID = 'llvm-tests/load_reuse.c'
source_filename = "llvm-tests/load_reuse.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.mat_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 2.000000e+00], [2 x float] [float 3.000000e+00, float 4.000000e+00]], align 16
@__const.main.f_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 1.000000e+00], [2 x float] [float 1.000000e+00, float 1.000000e+00]], align 16
@.str = private unnamed_addr constant [12 x i8] c"output: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @load_use_twice([2 x float]* %0, [2 x float]* %1, [3 x float]* %2, [3 x float]* %3) #0 {
  %5 = alloca [2 x float]*, align 8
  %6 = alloca [2 x float]*, align 8
  %7 = alloca [3 x float]*, align 8
  %8 = alloca [3 x float]*, align 8
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  %15 = alloca i32, align 4
  %16 = alloca i32, align 4
  %17 = alloca float, align 4
  store [2 x float]* %0, [2 x float]** %5, align 8
  store [2 x float]* %1, [2 x float]** %6, align 8
  store [3 x float]* %2, [3 x float]** %7, align 8
  store [3 x float]* %3, [3 x float]** %8, align 8
  store i32 0, i32* %9, align 4
  br label %18

18:                                               ; preds = %110, %4
  %19 = load i32, i32* %9, align 4
  %20 = icmp slt i32 %19, 3
  br i1 %20, label %21, label %113

21:                                               ; preds = %18
  store i32 0, i32* %10, align 4
  br label %22

22:                                               ; preds = %106, %21
  %23 = load i32, i32* %10, align 4
  %24 = icmp slt i32 %23, 3
  br i1 %24, label %25, label %109

25:                                               ; preds = %22
  store i32 0, i32* %11, align 4
  br label %26

26:                                               ; preds = %102, %25
  %27 = load i32, i32* %11, align 4
  %28 = icmp slt i32 %27, 2
  br i1 %28, label %29, label %105

29:                                               ; preds = %26
  store i32 0, i32* %12, align 4
  br label %30

30:                                               ; preds = %98, %29
  %31 = load i32, i32* %12, align 4
  %32 = icmp slt i32 %31, 2
  br i1 %32, label %33, label %101

33:                                               ; preds = %30
  %34 = load i32, i32* %11, align 4
  %35 = sub nsw i32 1, %34
  store i32 %35, i32* %13, align 4
  %36 = load i32, i32* %12, align 4
  %37 = sub nsw i32 1, %36
  store i32 %37, i32* %14, align 4
  %38 = load i32, i32* %9, align 4
  %39 = load i32, i32* %13, align 4
  %40 = sub nsw i32 %38, %39
  store i32 %40, i32* %15, align 4
  %41 = load i32, i32* %10, align 4
  %42 = load i32, i32* %14, align 4
  %43 = sub nsw i32 %41, %42
  store i32 %43, i32* %16, align 4
  %44 = load i32, i32* %15, align 4
  %45 = icmp sge i32 %44, 0
  br i1 %45, label %46, label %97

46:                                               ; preds = %33
  %47 = load i32, i32* %15, align 4
  %48 = icmp slt i32 %47, 2
  br i1 %48, label %49, label %97

49:                                               ; preds = %46
  %50 = load i32, i32* %16, align 4
  %51 = icmp sge i32 %50, 0
  br i1 %51, label %52, label %97

52:                                               ; preds = %49
  %53 = load i32, i32* %16, align 4
  %54 = icmp slt i32 %53, 2
  br i1 %54, label %55, label %97

55:                                               ; preds = %52
  %56 = load [2 x float]*, [2 x float]** %5, align 8
  %57 = load i32, i32* %15, align 4
  %58 = sext i32 %57 to i64
  %59 = getelementptr inbounds [2 x float], [2 x float]* %56, i64 %58
  %60 = load i32, i32* %16, align 4
  %61 = sext i32 %60 to i64
  %62 = getelementptr inbounds [2 x float], [2 x float]* %59, i64 0, i64 %61
  %63 = load float, float* %62, align 4
  %64 = load [2 x float]*, [2 x float]** %6, align 8
  %65 = load i32, i32* %13, align 4
  %66 = sext i32 %65 to i64
  %67 = getelementptr inbounds [2 x float], [2 x float]* %64, i64 %66
  %68 = load i32, i32* %14, align 4
  %69 = sext i32 %68 to i64
  %70 = getelementptr inbounds [2 x float], [2 x float]* %67, i64 0, i64 %69
  %71 = load float, float* %70, align 4
  %72 = fmul float %63, %71
  store float %72, float* %17, align 4
  %73 = load float, float* %17, align 4
  %74 = fmul float 3.000000e+00, %73
  %75 = fsub float %74, 4.000000e+00
  %76 = load [3 x float]*, [3 x float]** %7, align 8
  %77 = load i32, i32* %9, align 4
  %78 = sext i32 %77 to i64
  %79 = getelementptr inbounds [3 x float], [3 x float]* %76, i64 %78
  %80 = load i32, i32* %10, align 4
  %81 = sext i32 %80 to i64
  %82 = getelementptr inbounds [3 x float], [3 x float]* %79, i64 0, i64 %81
  %83 = load float, float* %82, align 4
  %84 = fadd float %83, %75
  store float %84, float* %82, align 4
  %85 = load float, float* %17, align 4
  %86 = fmul float 2.000000e+00, %85
  %87 = fadd float %86, 1.000000e+00
  %88 = load [3 x float]*, [3 x float]** %8, align 8
  %89 = load i32, i32* %9, align 4
  %90 = sext i32 %89 to i64
  %91 = getelementptr inbounds [3 x float], [3 x float]* %88, i64 %90
  %92 = load i32, i32* %10, align 4
  %93 = sext i32 %92 to i64
  %94 = getelementptr inbounds [3 x float], [3 x float]* %91, i64 0, i64 %93
  %95 = load float, float* %94, align 4
  %96 = fadd float %95, %87
  store float %96, float* %94, align 4
  br label %97

97:                                               ; preds = %55, %52, %49, %46, %33
  br label %98

98:                                               ; preds = %97
  %99 = load i32, i32* %12, align 4
  %100 = add nsw i32 %99, 1
  store i32 %100, i32* %12, align 4
  br label %30

101:                                              ; preds = %30
  br label %102

102:                                              ; preds = %101
  %103 = load i32, i32* %11, align 4
  %104 = add nsw i32 %103, 1
  store i32 %104, i32* %11, align 4
  br label %26

105:                                              ; preds = %26
  br label %106

106:                                              ; preds = %105
  %107 = load i32, i32* %10, align 4
  %108 = add nsw i32 %107, 1
  store i32 %108, i32* %10, align 4
  br label %22

109:                                              ; preds = %22
  br label %110

110:                                              ; preds = %109
  %111 = load i32, i32* %9, align 4
  %112 = add nsw i32 %111, 1
  store i32 %112, i32* %9, align 4
  br label %18

113:                                              ; preds = %18
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [2 x [2 x float]], align 16
  %3 = alloca [2 x [2 x float]], align 16
  %4 = alloca [3 x [3 x float]], align 16
  %5 = alloca [3 x [3 x float]], align 16
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %8 = bitcast [2 x [2 x float]]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %8, i8* align 16 bitcast ([2 x [2 x float]]* @__const.main.mat_in to i8*), i64 16, i1 false)
  %9 = bitcast [2 x [2 x float]]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %9, i8* align 16 bitcast ([2 x [2 x float]]* @__const.main.f_in to i8*), i64 16, i1 false)
  %10 = bitcast [3 x [3 x float]]* %4 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %10, i8 0, i64 36, i1 false)
  %11 = bitcast [3 x [3 x float]]* %5 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %11, i8 0, i64 36, i1 false)
  %12 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %2, i64 0, i64 0
  %13 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 0
  %14 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %4, i64 0, i64 0
  %15 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %5, i64 0, i64 0
  call void @load_use_twice([2 x float]* %12, [2 x float]* %13, [3 x float]* %14, [3 x float]* %15)
  store i32 0, i32* %6, align 4
  br label %16

16:                                               ; preds = %46, %0
  %17 = load i32, i32* %6, align 4
  %18 = icmp slt i32 %17, 3
  br i1 %18, label %19, label %49

19:                                               ; preds = %16
  store i32 0, i32* %7, align 4
  br label %20

20:                                               ; preds = %42, %19
  %21 = load i32, i32* %7, align 4
  %22 = icmp slt i32 %21, 3
  br i1 %22, label %23, label %45

23:                                               ; preds = %20
  %24 = load i32, i32* %6, align 4
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %4, i64 0, i64 %25
  %27 = load i32, i32* %7, align 4
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds [3 x float], [3 x float]* %26, i64 0, i64 %28
  %30 = load float, float* %29, align 4
  %31 = fpext float %30 to double
  %32 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %31)
  %33 = load i32, i32* %6, align 4
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %5, i64 0, i64 %34
  %36 = load i32, i32* %7, align 4
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds [3 x float], [3 x float]* %35, i64 0, i64 %37
  %39 = load float, float* %38, align 4
  %40 = fpext float %39 to double
  %41 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %40)
  br label %42

42:                                               ; preds = %23
  %43 = load i32, i32* %7, align 4
  %44 = add nsw i32 %43, 1
  store i32 %44, i32* %7, align 4
  br label %20

45:                                               ; preds = %20
  br label %46

46:                                               ; preds = %45
  %47 = load i32, i32* %6, align 4
  %48 = add nsw i32 %47, 1
  store i32 %48, i32* %6, align 4
  br label %16

49:                                               ; preds = %16
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
