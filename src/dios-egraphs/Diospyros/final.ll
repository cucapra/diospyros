; ModuleID = 'finish.ll'
source_filename = "llvm-tests/2d_new.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [4 x [4 x float]] [[4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], [4 x float] [float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00], [4 x float] [float 9.000000e+00, float 1.000000e+01, float 1.100000e+01, float 1.200000e+01], [4 x float] [float 1.300000e+01, float 1.400000e+01, float 1.500000e+01, float 1.600000e+01]], align 16
@__const.main.b_in = private unnamed_addr constant [4 x float] [float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00], align 16
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str = private unnamed_addr constant [20 x i8] c"llvm-tests/2d_new.c\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"c_out[0] == 9\00", align 1
@.str.2 = private unnamed_addr constant [15 x i8] c"c_out[1] == 14\00", align 1
@.str.3 = private unnamed_addr constant [15 x i8] c"c_out[2] == 19\00", align 1
@.str.4 = private unnamed_addr constant [15 x i8] c"c_out[3] == 18\00", align 1
@.str.5 = private unnamed_addr constant [11 x i8] c"first: %f\0A\00", align 1
@.str.6 = private unnamed_addr constant [12 x i8] c"second: %f\0A\00", align 1
@.str.7 = private unnamed_addr constant [11 x i8] c"third: %f\0A\00", align 1
@.str.8 = private unnamed_addr constant [12 x i8] c"fourth: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @sum([4 x float]* %0, float* %1, float* %2) #0 {
  %4 = getelementptr inbounds [4 x float], [4 x float]* %0, i64 0
  %5 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 3
  %6 = load float, float* %5, align 4
  %7 = insertelement <4 x float> zeroinitializer, float %6, i32 0
  %8 = getelementptr inbounds [4 x float], [4 x float]* %0, i64 1
  %9 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 3
  %10 = load float, float* %9, align 4
  %11 = insertelement <4 x float> %7, float %10, i32 1
  %12 = getelementptr inbounds [4 x float], [4 x float]* %0, i64 2
  %13 = getelementptr inbounds [4 x float], [4 x float]* %12, i64 0, i64 3
  %14 = load float, float* %13, align 4
  %15 = insertelement <4 x float> %11, float %14, i32 2
  %16 = getelementptr inbounds [4 x float], [4 x float]* %0, i64 3
  %17 = getelementptr inbounds [4 x float], [4 x float]* %16, i64 0, i64 3
  %18 = load float, float* %17, align 4
  %19 = insertelement <4 x float> %15, float %18, i32 3
  %20 = getelementptr inbounds float, float* %1, i64 0
  %21 = load float, float* %20, align 4
  %22 = insertelement <4 x float> zeroinitializer, float %21, i32 0
  %23 = getelementptr inbounds float, float* %1, i64 1
  %24 = load float, float* %23, align 4
  %25 = insertelement <4 x float> %22, float %24, i32 1
  %26 = getelementptr inbounds float, float* %1, i64 2
  %27 = load float, float* %26, align 4
  %28 = insertelement <4 x float> %25, float %27, i32 2
  %29 = getelementptr inbounds [4 x float], [4 x float]* %0, i64 0
  %30 = getelementptr inbounds [4 x float], [4 x float]* %29, i64 0, i64 1
  %31 = load float, float* %30, align 4
  %32 = insertelement <4 x float> %28, float %31, i32 3
  %33 = fadd <4 x float> %19, %32
  %34 = extractelement <4 x float> %33, i32 0
  %35 = getelementptr inbounds float, float* %2, i64 0
  store float %34, float* %35, align 4
  %36 = extractelement <4 x float> %33, i32 1
  %37 = getelementptr inbounds float, float* %2, i64 1
  store float %36, float* %37, align 4
  %38 = extractelement <4 x float> %33, i32 2
  %39 = getelementptr inbounds float, float* %2, i64 2
  store float %38, float* %39, align 4
  %40 = extractelement <4 x float> %33, i32 3
  %41 = getelementptr inbounds float, float* %2, i64 3
  store float %40, float* %41, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca [4 x [4 x float]], align 16
  %4 = alloca [4 x float], align 16
  %5 = alloca [4 x float], align 16
  %6 = bitcast [4 x [4 x float]]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %6, i8* align 16 bitcast ([4 x [4 x float]]* @__const.main.a_in to i8*), i64 64, i1 false)
  %7 = bitcast [4 x float]* %4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %7, i8* align 16 bitcast ([4 x float]* @__const.main.b_in to i8*), i64 16, i1 false)
  %8 = getelementptr inbounds [4 x [4 x float]], [4 x [4 x float]]* %3, i64 0, i64 0
  %9 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 0
  %10 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  call void @sum([4 x float]* %8, float* %9, float* %10)
  %11 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  %12 = load float, float* %11, align 16
  %13 = fcmp oeq float %12, 9.000000e+00
  %14 = xor i1 %13, true
  %15 = zext i1 %14 to i32
  %16 = sext i32 %15 to i64
  %17 = icmp ne i64 %16, 0
  br i1 %17, label %18, label %19

18:                                               ; preds = %2
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str, i64 0, i64 0), i32 18, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i64 0, i64 0)) #4
  unreachable

19:                                               ; preds = %2
  %20 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 1
  %21 = load float, float* %20, align 4
  %22 = fcmp oeq float %21, 1.400000e+01
  %23 = xor i1 %22, true
  %24 = zext i1 %23 to i32
  %25 = sext i32 %24 to i64
  %26 = icmp ne i64 %25, 0
  br i1 %26, label %27, label %28

27:                                               ; preds = %19
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str, i64 0, i64 0), i32 19, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.2, i64 0, i64 0)) #4
  unreachable

28:                                               ; preds = %19
  %29 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 2
  %30 = load float, float* %29, align 8
  %31 = fcmp oeq float %30, 1.900000e+01
  %32 = xor i1 %31, true
  %33 = zext i1 %32 to i32
  %34 = sext i32 %33 to i64
  %35 = icmp ne i64 %34, 0
  br i1 %35, label %36, label %37

36:                                               ; preds = %28
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str, i64 0, i64 0), i32 20, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.3, i64 0, i64 0)) #4
  unreachable

37:                                               ; preds = %28
  %38 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 3
  %39 = load float, float* %38, align 4
  %40 = fcmp oeq float %39, 1.800000e+01
  %41 = xor i1 %40, true
  %42 = zext i1 %41 to i32
  %43 = sext i32 %42 to i64
  %44 = icmp ne i64 %43, 0
  br i1 %44, label %45, label %46

45:                                               ; preds = %37
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str, i64 0, i64 0), i32 21, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.4, i64 0, i64 0)) #4
  unreachable

46:                                               ; preds = %37
  %47 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  %48 = load float, float* %47, align 16
  %49 = fpext float %48 to double
  %50 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.5, i64 0, i64 0), double %49)
  %51 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 1
  %52 = load float, float* %51, align 4
  %53 = fpext float %52 to double
  %54 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.6, i64 0, i64 0), double %53)
  %55 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 2
  %56 = load float, float* %55, align 8
  %57 = fpext float %56 to double
  %58 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.7, i64 0, i64 0), double %57)
  %59 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 3
  %60 = load float, float* %59, align 4
  %61 = fpext float %60 to double
  %62 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.8, i64 0, i64 0), double %61)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #2

declare i32 @printf(i8*, ...) #3

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
