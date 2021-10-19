; ModuleID = 'finish.ll'
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
  %4 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %5 = load float, float* %4, align 4
  %6 = insertelement <4 x float> zeroinitializer, float %5, i32 0
  %7 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %8 = load float, float* %7, align 4
  %9 = insertelement <4 x float> %6, float %8, i32 1
  %10 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1
  %11 = getelementptr inbounds [2 x float], [2 x float]* %10, i64 0, i64 0
  %12 = load float, float* %11, align 4
  %13 = insertelement <4 x float> %9, float %12, i32 2
  %14 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1
  %15 = getelementptr inbounds [2 x float], [2 x float]* %14, i64 0, i64 0
  %16 = load float, float* %15, align 4
  %17 = insertelement <4 x float> %13, float %16, i32 3
  %18 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 0
  %19 = load float, float* %18, align 4
  %20 = insertelement <4 x float> zeroinitializer, float %19, i32 0
  %21 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 1
  %22 = load float, float* %21, align 4
  %23 = insertelement <4 x float> %20, float %22, i32 1
  %24 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 0
  %25 = load float, float* %24, align 4
  %26 = insertelement <4 x float> %23, float %25, i32 2
  %27 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 1
  %28 = load float, float* %27, align 4
  %29 = insertelement <4 x float> %26, float %28, i32 3
  %30 = fmul <4 x float> %17, %29
  %31 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %32 = load float, float* %31, align 4
  %33 = insertelement <4 x float> zeroinitializer, float %32, i32 0
  %34 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %35 = load float, float* %34, align 4
  %36 = insertelement <4 x float> %33, float %35, i32 1
  %37 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1
  %38 = getelementptr inbounds [2 x float], [2 x float]* %37, i64 0, i64 1
  %39 = load float, float* %38, align 4
  %40 = insertelement <4 x float> %36, float %39, i32 2
  %41 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1
  %42 = getelementptr inbounds [2 x float], [2 x float]* %41, i64 0, i64 1
  %43 = load float, float* %42, align 4
  %44 = insertelement <4 x float> %40, float %43, i32 3
  %45 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1
  %46 = getelementptr inbounds [2 x float], [2 x float]* %45, i64 0, i64 0
  %47 = load float, float* %46, align 4
  %48 = insertelement <4 x float> zeroinitializer, float %47, i32 0
  %49 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1
  %50 = getelementptr inbounds [2 x float], [2 x float]* %49, i64 0, i64 1
  %51 = load float, float* %50, align 4
  %52 = insertelement <4 x float> %48, float %51, i32 1
  %53 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1
  %54 = getelementptr inbounds [2 x float], [2 x float]* %53, i64 0, i64 0
  %55 = load float, float* %54, align 4
  %56 = insertelement <4 x float> %52, float %55, i32 2
  %57 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1
  %58 = getelementptr inbounds [2 x float], [2 x float]* %57, i64 0, i64 1
  %59 = load float, float* %58, align 4
  %60 = insertelement <4 x float> %56, float %59, i32 3
  %61 = call <4 x float> @llvm.fma.v4f32(<4 x float> %44, <4 x float> %60, <4 x float> %30)
  %62 = extractelement <4 x float> %61, i32 0
  %63 = getelementptr inbounds [2 x float], [2 x float]* %2, i64 0, i64 0
  store float %62, float* %63, align 4
  %64 = extractelement <4 x float> %61, i32 1
  %65 = getelementptr inbounds [2 x float], [2 x float]* %2, i64 0, i64 1
  store float %64, float* %65, align 4
  %66 = extractelement <4 x float> %61, i32 2
  %67 = getelementptr inbounds [2 x float], [2 x float]* %2, i64 1
  %68 = getelementptr inbounds [2 x float], [2 x float]* %67, i64 0, i64 0
  store float %66, float* %68, align 4
  %69 = extractelement <4 x float> %61, i32 3
  %70 = getelementptr inbounds [2 x float], [2 x float]* %2, i64 1
  %71 = getelementptr inbounds [2 x float], [2 x float]* %70, i64 0, i64 1
  store float %69, float* %71, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [2 x [2 x float]], align 16
  %2 = alloca [2 x [2 x float]], align 16
  %3 = alloca [2 x [2 x float]], align 16
  %4 = bitcast [2 x [2 x float]]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %4, i8* align 16 bitcast ([2 x [2 x float]]* @__const.main.a_in to i8*), i64 16, i1 false)
  %5 = bitcast [2 x [2 x float]]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %5, i8* align 16 bitcast ([2 x [2 x float]]* @__const.main.b_in to i8*), i64 16, i1 false)
  %6 = bitcast [2 x [2 x float]]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %6, i8 0, i64 16, i1 false)
  %7 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 0
  call void @matrix_multiply([2 x float]* %7, [2 x float]* %8, [2 x float]* %9)
  %10 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 0
  %11 = getelementptr inbounds [2 x float], [2 x float]* %10, i64 0, i64 0
  %12 = load float, float* %11, align 16
  %13 = fpext float %12 to double
  %14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i64 0, i64 0), double %13)
  %15 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 0
  %16 = getelementptr inbounds [2 x float], [2 x float]* %15, i64 0, i64 1
  %17 = load float, float* %16, align 4
  %18 = fpext float %17 to double
  %19 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i64 0, i64 0), double %18)
  %20 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 1
  %21 = getelementptr inbounds [2 x float], [2 x float]* %20, i64 0, i64 0
  %22 = load float, float* %21, align 8
  %23 = fpext float %22 to double
  %24 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), double %23)
  %25 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 1
  %26 = getelementptr inbounds [2 x float], [2 x float]* %25, i64 0, i64 1
  %27 = load float, float* %26, align 4
  %28 = fpext float %27 to double
  %29 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.3, i64 0, i64 0), double %28)
  %30 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 0
  %31 = getelementptr inbounds [2 x float], [2 x float]* %30, i64 0, i64 0
  %32 = load float, float* %31, align 16
  %33 = fcmp oeq float %32, 7.000000e+00
  %34 = xor i1 %33, true
  %35 = zext i1 %34 to i32
  %36 = sext i32 %35 to i64
  %37 = icmp ne i64 %36, 0
  br i1 %37, label %38, label %39

38:                                               ; preds = %0
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.4, i64 0, i64 0), i32 30, i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.5, i64 0, i64 0)) #6
  unreachable

39:                                               ; preds = %0
  %40 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 0
  %41 = getelementptr inbounds [2 x float], [2 x float]* %40, i64 0, i64 1
  %42 = load float, float* %41, align 4
  %43 = fcmp oeq float %42, 1.000000e+01
  %44 = xor i1 %43, true
  %45 = zext i1 %44 to i32
  %46 = sext i32 %45 to i64
  %47 = icmp ne i64 %46, 0
  br i1 %47, label %48, label %49

48:                                               ; preds = %39
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.4, i64 0, i64 0), i32 31, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.6, i64 0, i64 0)) #6
  unreachable

49:                                               ; preds = %39
  %50 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 1
  %51 = getelementptr inbounds [2 x float], [2 x float]* %50, i64 0, i64 0
  %52 = load float, float* %51, align 8
  %53 = fcmp oeq float %52, 1.500000e+01
  %54 = xor i1 %53, true
  %55 = zext i1 %54 to i32
  %56 = sext i32 %55 to i64
  %57 = icmp ne i64 %56, 0
  br i1 %57, label %58, label %59

58:                                               ; preds = %49
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.4, i64 0, i64 0), i32 32, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.7, i64 0, i64 0)) #6
  unreachable

59:                                               ; preds = %49
  %60 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %3, i64 0, i64 1
  %61 = getelementptr inbounds [2 x float], [2 x float]* %60, i64 0, i64 1
  %62 = load float, float* %61, align 4
  %63 = fcmp oeq float %62, 2.200000e+01
  %64 = xor i1 %63, true
  %65 = zext i1 %64 to i32
  %66 = sext i32 %65 to i64
  %67 = icmp ne i64 %66, 0
  br i1 %67, label %68, label %69

68:                                               ; preds = %59
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.4, i64 0, i64 0), i32 33, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.8, i64 0, i64 0)) #6
  unreachable

69:                                               ; preds = %59
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

declare i32 @printf(i8*, ...) #3

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.v4f32(<4 x float>, <4 x float>, <4 x float>) #5

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn writeonly }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind readnone speculatable willreturn }
attributes #6 = { noreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
