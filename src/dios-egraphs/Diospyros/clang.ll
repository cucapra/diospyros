; ModuleID = 'llvm-tests/2d-matrix-multiply-new.c'
source_filename = "llvm-tests/2d-matrix-multiply-new.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 2.000000e+00], [2 x float] [float 3.000000e+00, float 4.000000e+00]], align 16
@__const.main.b_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 2.000000e+00], [2 x float] [float 3.000000e+00, float 4.000000e+00]], align 16
@.str = private unnamed_addr constant [11 x i8] c"first: %f\0A\00", align 1
@.str.1 = private unnamed_addr constant [12 x i8] c"second: %f\0A\00", align 1
@.str.2 = private unnamed_addr constant [11 x i8] c"third: %f\0A\00", align 1
@.str.3 = private unnamed_addr constant [12 x i8] c"fourth: %f\0A\00", align 1
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str.4 = private unnamed_addr constant [36 x i8] c"llvm-tests/2d-matrix-multiply-new.c\00", align 1
@.str.5 = private unnamed_addr constant [17 x i8] c"c_out[0][0] == 7\00", align 1
@.str.6 = private unnamed_addr constant [18 x i8] c"c_out[0][1] == 10\00", align 1
@.str.7 = private unnamed_addr constant [18 x i8] c"c_out[1][0] == 15\00", align 1
@.str.8 = private unnamed_addr constant [18 x i8] c"c_out[1][1] == 22\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @matrix_multiply([2 x float]* %0, [2 x float]* %1, [2 x float]* %2) #0 {
  %4 = alloca [2 x float]*, align 8
  %5 = alloca [2 x float]*, align 8
  %6 = alloca [2 x float]*, align 8
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca float, align 4
  %10 = alloca i32, align 4
  store [2 x float]* %0, [2 x float]** %4, align 8
  store [2 x float]* %1, [2 x float]** %5, align 8
  store [2 x float]* %2, [2 x float]** %6, align 8
  store i32 0, i32* %7, align 4
  br label %11

11:                                               ; preds = %58, %3
  %12 = load i32, i32* %7, align 4
  %13 = icmp slt i32 %12, 2
  br i1 %13, label %14, label %61

14:                                               ; preds = %11
  store i32 0, i32* %8, align 4
  br label %15

15:                                               ; preds = %54, %14
  %16 = load i32, i32* %8, align 4
  %17 = icmp slt i32 %16, 2
  br i1 %17, label %18, label %57

18:                                               ; preds = %15
  store float 0.000000e+00, float* %9, align 4
  store i32 0, i32* %10, align 4
  br label %19

19:                                               ; preds = %42, %18
  %20 = load i32, i32* %10, align 4
  %21 = icmp slt i32 %20, 2
  br i1 %21, label %22, label %45

22:                                               ; preds = %19
  %23 = load [2 x float]*, [2 x float]** %4, align 8
  %24 = load i32, i32* %7, align 4
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds [2 x float], [2 x float]* %23, i64 %25
  %27 = load i32, i32* %10, align 4
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds [2 x float], [2 x float]* %26, i64 0, i64 %28
  %30 = load float, float* %29, align 4
  %31 = load [2 x float]*, [2 x float]** %5, align 8
  %32 = load i32, i32* %10, align 4
  %33 = sext i32 %32 to i64
  %34 = getelementptr inbounds [2 x float], [2 x float]* %31, i64 %33
  %35 = load i32, i32* %8, align 4
  %36 = sext i32 %35 to i64
  %37 = getelementptr inbounds [2 x float], [2 x float]* %34, i64 0, i64 %36
  %38 = load float, float* %37, align 4
  %39 = fmul float %30, %38
  %40 = load float, float* %9, align 4
  %41 = fadd float %40, %39
  store float %41, float* %9, align 4
  br label %42

42:                                               ; preds = %22
  %43 = load i32, i32* %10, align 4
  %44 = add nsw i32 %43, 1
  store i32 %44, i32* %10, align 4
  br label %19

45:                                               ; preds = %19
  %46 = load float, float* %9, align 4
  %47 = load [2 x float]*, [2 x float]** %6, align 8
  %48 = load i32, i32* %7, align 4
  %49 = sext i32 %48 to i64
  %50 = getelementptr inbounds [2 x float], [2 x float]* %47, i64 %49
  %51 = load i32, i32* %8, align 4
  %52 = sext i32 %51 to i64
  %53 = getelementptr inbounds [2 x float], [2 x float]* %50, i64 0, i64 %52
  store float %46, float* %53, align 4
  br label %54

54:                                               ; preds = %45
  %55 = load i32, i32* %8, align 4
  %56 = add nsw i32 %55, 1
  store i32 %56, i32* %8, align 4
  br label %15

57:                                               ; preds = %15
  br label %58

58:                                               ; preds = %57
  %59 = load i32, i32* %7, align 4
  %60 = add nsw i32 %59, 1
  store i32 %60, i32* %7, align 4
  br label %11

61:                                               ; preds = %11
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [2 x [2 x float]], align 16
  %3 = alloca [2 x [2 x float]], align 16
  %4 = alloca [2 x [2 x float]], align 16
  store i32 0, i32* %1, align 4
  %5 = bitcast [2 x [2 x float]]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %5, i8* align 16 bitcast ([2 x [2 x float]]* @__const.main.a_in to i8*), i64 16, i1 false)
  %6 = bitcast [2 x [2 x float]]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %6, i8* align 16 bitcast ([2 x [2 x float]]* @__const.main.b_in to i8*), i64 16, i1 false)
  %7 = bitcast [2 x [2 x float]]* %4 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %7, i8 0, i64 16, i1 false)
  %8 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 0
  %10 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %4, i64 0, i64 0
  call void @matrix_multiply([2 x float]* %8, [2 x float]* %9, [2 x float]* %10)
  %11 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %4, i64 0, i64 0
  %12 = getelementptr inbounds [2 x float], [2 x float]* %11, i64 0, i64 0
  %13 = load float, float* %12, align 16
  %14 = fpext float %13 to double
  %15 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i64 0, i64 0), double %14)
  %16 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %4, i64 0, i64 0
  %17 = getelementptr inbounds [2 x float], [2 x float]* %16, i64 0, i64 1
  %18 = load float, float* %17, align 4
  %19 = fpext float %18 to double
  %20 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i64 0, i64 0), double %19)
  %21 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %4, i64 0, i64 1
  %22 = getelementptr inbounds [2 x float], [2 x float]* %21, i64 0, i64 0
  %23 = load float, float* %22, align 8
  %24 = fpext float %23 to double
  %25 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), double %24)
  %26 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %4, i64 0, i64 1
  %27 = getelementptr inbounds [2 x float], [2 x float]* %26, i64 0, i64 1
  %28 = load float, float* %27, align 4
  %29 = fpext float %28 to double
  %30 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.3, i64 0, i64 0), double %29)
  %31 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %4, i64 0, i64 0
  %32 = getelementptr inbounds [2 x float], [2 x float]* %31, i64 0, i64 0
  %33 = load float, float* %32, align 16
  %34 = fcmp oeq float %33, 7.000000e+00
  %35 = xor i1 %34, true
  %36 = zext i1 %35 to i32
  %37 = sext i32 %36 to i64
  %38 = icmp ne i64 %37, 0
  br i1 %38, label %39, label %41

39:                                               ; preds = %0
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.4, i64 0, i64 0), i32 30, i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.5, i64 0, i64 0)) #5
  unreachable

40:                                               ; No predecessors!
  br label %42

41:                                               ; preds = %0
  br label %42

42:                                               ; preds = %41, %40
  %43 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %4, i64 0, i64 0
  %44 = getelementptr inbounds [2 x float], [2 x float]* %43, i64 0, i64 1
  %45 = load float, float* %44, align 4
  %46 = fcmp oeq float %45, 1.000000e+01
  %47 = xor i1 %46, true
  %48 = zext i1 %47 to i32
  %49 = sext i32 %48 to i64
  %50 = icmp ne i64 %49, 0
  br i1 %50, label %51, label %53

51:                                               ; preds = %42
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.4, i64 0, i64 0), i32 31, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.6, i64 0, i64 0)) #5
  unreachable

52:                                               ; No predecessors!
  br label %54

53:                                               ; preds = %42
  br label %54

54:                                               ; preds = %53, %52
  %55 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %4, i64 0, i64 1
  %56 = getelementptr inbounds [2 x float], [2 x float]* %55, i64 0, i64 0
  %57 = load float, float* %56, align 8
  %58 = fcmp oeq float %57, 1.500000e+01
  %59 = xor i1 %58, true
  %60 = zext i1 %59 to i32
  %61 = sext i32 %60 to i64
  %62 = icmp ne i64 %61, 0
  br i1 %62, label %63, label %65

63:                                               ; preds = %54
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.4, i64 0, i64 0), i32 32, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.7, i64 0, i64 0)) #5
  unreachable

64:                                               ; No predecessors!
  br label %66

65:                                               ; preds = %54
  br label %66

66:                                               ; preds = %65, %64
  %67 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %4, i64 0, i64 1
  %68 = getelementptr inbounds [2 x float], [2 x float]* %67, i64 0, i64 1
  %69 = load float, float* %68, align 4
  %70 = fcmp oeq float %69, 2.200000e+01
  %71 = xor i1 %70, true
  %72 = zext i1 %71 to i32
  %73 = sext i32 %72 to i64
  %74 = icmp ne i64 %73, 0
  br i1 %74, label %75, label %77

75:                                               ; preds = %66
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.4, i64 0, i64 0), i32 33, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.8, i64 0, i64 0)) #5
  unreachable

76:                                               ; No predecessors!
  br label %78

77:                                               ; preds = %66
  br label %78

78:                                               ; preds = %77, %76
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
