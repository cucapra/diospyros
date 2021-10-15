; ModuleID = 'finish.ll'
source_filename = "llvm-tests/width5_new.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [5 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 5.000000e+00], align 16
@__const.main.b_in = private unnamed_addr constant [5 x float] [float 6.000000e+00, float 7.000000e+00, float 8.000000e+00, float 9.000000e+00, float 1.000000e+01], align 16
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str = private unnamed_addr constant [24 x i8] c"llvm-tests/width5_new.c\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"c_out[0] == 7\00", align 1
@.str.2 = private unnamed_addr constant [14 x i8] c"c_out[1] == 9\00", align 1
@.str.3 = private unnamed_addr constant [15 x i8] c"c_out[2] == 11\00", align 1
@.str.4 = private unnamed_addr constant [15 x i8] c"c_out[3] == 13\00", align 1
@.str.5 = private unnamed_addr constant [15 x i8] c"c_out[4] == 15\00", align 1
@.str.6 = private unnamed_addr constant [11 x i8] c"first: %f\0A\00", align 1
@.str.7 = private unnamed_addr constant [12 x i8] c"second: %f\0A\00", align 1
@.str.8 = private unnamed_addr constant [11 x i8] c"third: %f\0A\00", align 1
@.str.9 = private unnamed_addr constant [12 x i8] c"fourth: %f\0A\00", align 1
@.str.10 = private unnamed_addr constant [11 x i8] c"fifth: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @sum(float* %0, float* %1, float* %2) #0 {
  %4 = getelementptr inbounds float, float* %0, i64 0
  %5 = load float, float* %4, align 4
  %6 = insertelement <4 x float> zeroinitializer, float %5, i32 0
  %7 = getelementptr inbounds float, float* %0, i64 1
  %8 = load float, float* %7, align 4
  %9 = insertelement <4 x float> %6, float %8, i32 1
  %10 = getelementptr inbounds float, float* %0, i64 2
  %11 = load float, float* %10, align 4
  %12 = insertelement <4 x float> %9, float %11, i32 2
  %13 = getelementptr inbounds float, float* %0, i64 3
  %14 = load float, float* %13, align 4
  %15 = insertelement <4 x float> %12, float %14, i32 3
  %16 = getelementptr inbounds float, float* %1, i64 0
  %17 = load float, float* %16, align 4
  %18 = insertelement <4 x float> zeroinitializer, float %17, i32 0
  %19 = getelementptr inbounds float, float* %1, i64 1
  %20 = load float, float* %19, align 4
  %21 = insertelement <4 x float> %18, float %20, i32 1
  %22 = getelementptr inbounds float, float* %1, i64 2
  %23 = load float, float* %22, align 4
  %24 = insertelement <4 x float> %21, float %23, i32 2
  %25 = getelementptr inbounds float, float* %1, i64 3
  %26 = load float, float* %25, align 4
  %27 = insertelement <4 x float> %24, float %26, i32 3
  %28 = fadd <4 x float> %15, %27
  %29 = getelementptr inbounds float, float* %0, i64 4
  %30 = load float, float* %29, align 4
  %31 = insertelement <4 x float> zeroinitializer, float %30, i32 0
  %32 = insertelement <4 x float> %31, float 0.000000e+00, i32 1
  %33 = insertelement <4 x float> %32, float 0.000000e+00, i32 2
  %34 = insertelement <4 x float> %33, float 0.000000e+00, i32 3
  %35 = getelementptr inbounds float, float* %1, i64 4
  %36 = load float, float* %35, align 4
  %37 = insertelement <4 x float> zeroinitializer, float %36, i32 0
  %38 = insertelement <4 x float> %37, float 0.000000e+00, i32 1
  %39 = insertelement <4 x float> %38, float 0.000000e+00, i32 2
  %40 = insertelement <4 x float> %39, float 0.000000e+00, i32 3
  %41 = fadd <4 x float> %34, %40
  %42 = shufflevector <4 x float> %28, <4 x float> %41, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %43 = extractelement <8 x float> %42, i32 0
  %44 = getelementptr inbounds float, float* %2, i64 0
  store float %43, float* %44, align 4
  %45 = extractelement <8 x float> %42, i32 1
  %46 = getelementptr inbounds float, float* %2, i64 1
  store float %45, float* %46, align 4
  %47 = extractelement <8 x float> %42, i32 2
  %48 = getelementptr inbounds float, float* %2, i64 2
  store float %47, float* %48, align 4
  %49 = extractelement <8 x float> %42, i32 3
  %50 = getelementptr inbounds float, float* %2, i64 3
  store float %49, float* %50, align 4
  %51 = extractelement <8 x float> %42, i32 4
  %52 = getelementptr inbounds float, float* %2, i64 4
  store float %51, float* %52, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca [5 x float], align 16
  %4 = alloca [5 x float], align 16
  %5 = alloca [5 x float], align 16
  %6 = bitcast [5 x float]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %6, i8* align 16 bitcast ([5 x float]* @__const.main.a_in to i8*), i64 20, i1 false)
  %7 = bitcast [5 x float]* %4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %7, i8* align 16 bitcast ([5 x float]* @__const.main.b_in to i8*), i64 20, i1 false)
  %8 = getelementptr inbounds [5 x float], [5 x float]* %3, i64 0, i64 0
  %9 = getelementptr inbounds [5 x float], [5 x float]* %4, i64 0, i64 0
  %10 = getelementptr inbounds [5 x float], [5 x float]* %5, i64 0, i64 0
  call void @sum(float* %8, float* %9, float* %10)
  %11 = getelementptr inbounds [5 x float], [5 x float]* %5, i64 0, i64 0
  %12 = load float, float* %11, align 16
  %13 = fcmp oeq float %12, 7.000000e+00
  %14 = xor i1 %13, true
  %15 = zext i1 %14 to i32
  %16 = sext i32 %15 to i64
  %17 = icmp ne i64 %16, 0
  br i1 %17, label %18, label %19

18:                                               ; preds = %2
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 18, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i64 0, i64 0)) #4
  unreachable

19:                                               ; preds = %2
  %20 = getelementptr inbounds [5 x float], [5 x float]* %5, i64 0, i64 1
  %21 = load float, float* %20, align 4
  %22 = fcmp oeq float %21, 9.000000e+00
  %23 = xor i1 %22, true
  %24 = zext i1 %23 to i32
  %25 = sext i32 %24 to i64
  %26 = icmp ne i64 %25, 0
  br i1 %26, label %27, label %28

27:                                               ; preds = %19
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 19, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.2, i64 0, i64 0)) #4
  unreachable

28:                                               ; preds = %19
  %29 = getelementptr inbounds [5 x float], [5 x float]* %5, i64 0, i64 2
  %30 = load float, float* %29, align 8
  %31 = fcmp oeq float %30, 1.100000e+01
  %32 = xor i1 %31, true
  %33 = zext i1 %32 to i32
  %34 = sext i32 %33 to i64
  %35 = icmp ne i64 %34, 0
  br i1 %35, label %36, label %37

36:                                               ; preds = %28
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 20, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.3, i64 0, i64 0)) #4
  unreachable

37:                                               ; preds = %28
  %38 = getelementptr inbounds [5 x float], [5 x float]* %5, i64 0, i64 3
  %39 = load float, float* %38, align 4
  %40 = fcmp oeq float %39, 1.300000e+01
  %41 = xor i1 %40, true
  %42 = zext i1 %41 to i32
  %43 = sext i32 %42 to i64
  %44 = icmp ne i64 %43, 0
  br i1 %44, label %45, label %46

45:                                               ; preds = %37
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 21, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.4, i64 0, i64 0)) #4
  unreachable

46:                                               ; preds = %37
  %47 = getelementptr inbounds [5 x float], [5 x float]* %5, i64 0, i64 4
  %48 = load float, float* %47, align 16
  %49 = fcmp oeq float %48, 1.500000e+01
  %50 = xor i1 %49, true
  %51 = zext i1 %50 to i32
  %52 = sext i32 %51 to i64
  %53 = icmp ne i64 %52, 0
  br i1 %53, label %54, label %55

54:                                               ; preds = %46
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 22, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.5, i64 0, i64 0)) #4
  unreachable

55:                                               ; preds = %46
  %56 = getelementptr inbounds [5 x float], [5 x float]* %5, i64 0, i64 0
  %57 = load float, float* %56, align 16
  %58 = fpext float %57 to double
  %59 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.6, i64 0, i64 0), double %58)
  %60 = getelementptr inbounds [5 x float], [5 x float]* %5, i64 0, i64 1
  %61 = load float, float* %60, align 4
  %62 = fpext float %61 to double
  %63 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.7, i64 0, i64 0), double %62)
  %64 = getelementptr inbounds [5 x float], [5 x float]* %5, i64 0, i64 2
  %65 = load float, float* %64, align 8
  %66 = fpext float %65 to double
  %67 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.8, i64 0, i64 0), double %66)
  %68 = getelementptr inbounds [5 x float], [5 x float]* %5, i64 0, i64 3
  %69 = load float, float* %68, align 4
  %70 = fpext float %69 to double
  %71 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.9, i64 0, i64 0), double %70)
  %72 = getelementptr inbounds [5 x float], [5 x float]* %5, i64 0, i64 4
  %73 = load float, float* %72, align 16
  %74 = fpext float %73 to double
  %75 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.10, i64 0, i64 0), double %74)
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
