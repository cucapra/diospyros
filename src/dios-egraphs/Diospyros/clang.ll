; ModuleID = 'llvm-tests/2d-conv.c'
source_filename = "llvm-tests/2d-conv.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.mat_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.f_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00], align 16
@__const.main.expected = private unnamed_addr constant [9 x float] [float 1.000000e+00, float 3.000000e+00, float 2.000000e+00, float 4.000000e+00, float 1.000000e+01, float 6.000000e+00, float 3.000000e+00, float 7.000000e+00, float 4.000000e+00], align 16
@.str = private unnamed_addr constant [12 x i8] c"output: %f\0A\00", align 1
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str.1 = private unnamed_addr constant [21 x i8] c"llvm-tests/2d-conv.c\00", align 1
@.str.2 = private unnamed_addr constant [26 x i8] c"mat_out[i] == expected[i]\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @convolution(float* %0, float* %1, float* %2) #0 {
  %4 = alloca float*, align 8
  %5 = alloca float*, align 8
  %6 = alloca float*, align 8
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  %15 = alloca float, align 4
  store float* %0, float** %4, align 8
  store float* %1, float** %5, align 8
  store float* %2, float** %6, align 8
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
  %54 = load float*, float** %4, align 8
  %55 = load i32, i32* %13, align 4
  %56 = mul nsw i32 %55, 2
  %57 = load i32, i32* %14, align 4
  %58 = add nsw i32 %56, %57
  %59 = sext i32 %58 to i64
  %60 = getelementptr inbounds float, float* %54, i64 %59
  %61 = load float, float* %60, align 4
  %62 = load float*, float** %5, align 8
  %63 = load i32, i32* %11, align 4
  %64 = mul nsw i32 %63, 2
  %65 = load i32, i32* %12, align 4
  %66 = add nsw i32 %64, %65
  %67 = sext i32 %66 to i64
  %68 = getelementptr inbounds float, float* %62, i64 %67
  %69 = load float, float* %68, align 4
  %70 = fmul float %61, %69
  store float %70, float* %15, align 4
  %71 = load float, float* %15, align 4
  %72 = load float*, float** %6, align 8
  %73 = load i32, i32* %7, align 4
  %74 = mul nsw i32 %73, 3
  %75 = load i32, i32* %8, align 4
  %76 = add nsw i32 %74, %75
  %77 = sext i32 %76 to i64
  %78 = getelementptr inbounds float, float* %72, i64 %77
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
  %2 = alloca [4 x float], align 16
  %3 = alloca [4 x float], align 16
  %4 = alloca [9 x float], align 16
  %5 = alloca [9 x float], align 16
  %6 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %7 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %7, i8* align 16 bitcast ([4 x float]* @__const.main.mat_in to i8*), i64 16, i1 false)
  %8 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %8, i8* align 16 bitcast ([4 x float]* @__const.main.f_in to i8*), i64 16, i1 false)
  %9 = bitcast [9 x float]* %4 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %9, i8 0, i64 36, i1 false)
  %10 = bitcast [9 x float]* %5 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %10, i8* align 16 bitcast ([9 x float]* @__const.main.expected to i8*), i64 36, i1 false)
  %11 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %12 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %13 = getelementptr inbounds [9 x float], [9 x float]* %4, i64 0, i64 0
  call void @convolution(float* %11, float* %12, float* %13)
  store i32 0, i32* %6, align 4
  br label %14

14:                                               ; preds = %41, %0
  %15 = load i32, i32* %6, align 4
  %16 = icmp slt i32 %15, 9
  br i1 %16, label %17, label %44

17:                                               ; preds = %14
  %18 = load i32, i32* %6, align 4
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds [9 x float], [9 x float]* %4, i64 0, i64 %19
  %21 = load float, float* %20, align 4
  %22 = fpext float %21 to double
  %23 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %22)
  %24 = load i32, i32* %6, align 4
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds [9 x float], [9 x float]* %4, i64 0, i64 %25
  %27 = load float, float* %26, align 4
  %28 = load i32, i32* %6, align 4
  %29 = sext i32 %28 to i64
  %30 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 %29
  %31 = load float, float* %30, align 4
  %32 = fcmp oeq float %27, %31
  %33 = xor i1 %32, true
  %34 = zext i1 %33 to i32
  %35 = sext i32 %34 to i64
  %36 = icmp ne i64 %35, 0
  br i1 %36, label %37, label %39

37:                                               ; preds = %17
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.1, i64 0, i64 0), i32 46, i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.2, i64 0, i64 0)) #5
  unreachable

38:                                               ; No predecessors!
  br label %40

39:                                               ; preds = %17
  br label %40

40:                                               ; preds = %39, %38
  br label %41

41:                                               ; preds = %40
  %42 = load i32, i32* %6, align 4
  %43 = add nsw i32 %42, 1
  store i32 %43, i32* %6, align 4
  br label %14

44:                                               ; preds = %14
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

declare i32 @printf(i8*, ...) #3

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #4

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn writeonly }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { noreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
