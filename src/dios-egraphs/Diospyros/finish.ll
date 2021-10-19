; ModuleID = 'opt.ll'
source_filename = "llvm-tests/cube-new.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [8 x float] [float 9.000000e+00, float 8.000000e+00, float 7.000000e+00, float 6.000000e+00, float 5.000000e+00, float 4.000000e+00, float 3.000000e+00, float 2.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str.1 = private unnamed_addr constant [22 x i8] c"llvm-tests/cube-new.c\00", align 1
@.str.2 = private unnamed_addr constant [16 x i8] c"b_out[0] == 729\00", align 1
@.str.3 = private unnamed_addr constant [16 x i8] c"b_out[1] == 512\00", align 1
@.str.4 = private unnamed_addr constant [16 x i8] c"b_out[2] == 343\00", align 1
@.str.5 = private unnamed_addr constant [16 x i8] c"b_out[3] == 216\00", align 1
@.str.6 = private unnamed_addr constant [16 x i8] c"b_out[4] == 125\00", align 1
@.str.7 = private unnamed_addr constant [15 x i8] c"b_out[5] == 64\00", align 1
@.str.8 = private unnamed_addr constant [15 x i8] c"b_out[6] == 27\00", align 1
@.str.9 = private unnamed_addr constant [14 x i8] c"b_out[7] == 8\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @cube(float* %0, float* %1) #0 {
  %3 = load float, float* %0, align 4
  %4 = call float @llvm.pow.f32(float %3, float 3.000000e+00)
  %5 = getelementptr inbounds float, float* %0, i64 1
  %6 = load float, float* %5, align 4
  %7 = call float @llvm.pow.f32(float %6, float 3.000000e+00)
  %8 = getelementptr inbounds float, float* %1, i64 1
  %9 = getelementptr inbounds float, float* %0, i64 2
  %10 = load float, float* %9, align 4
  %11 = call float @llvm.pow.f32(float %10, float 3.000000e+00)
  %12 = getelementptr inbounds float, float* %1, i64 2
  %13 = getelementptr inbounds float, float* %0, i64 3
  %14 = load float, float* %13, align 4
  %15 = call float @llvm.pow.f32(float %14, float 3.000000e+00)
  %16 = getelementptr inbounds float, float* %1, i64 3
  %17 = getelementptr inbounds float, float* %0, i64 4
  %18 = load float, float* %17, align 4
  %19 = call float @llvm.pow.f32(float %18, float 3.000000e+00)
  %20 = getelementptr inbounds float, float* %1, i64 4
  %21 = getelementptr inbounds float, float* %0, i64 5
  %22 = load float, float* %21, align 4
  %23 = call float @llvm.pow.f32(float %22, float 3.000000e+00)
  %24 = getelementptr inbounds float, float* %1, i64 5
  %25 = getelementptr inbounds float, float* %0, i64 6
  %26 = load float, float* %25, align 4
  %27 = call float @llvm.pow.f32(float %26, float 3.000000e+00)
  %28 = getelementptr inbounds float, float* %1, i64 6
  %29 = getelementptr inbounds float, float* %0, i64 7
  %30 = load float, float* %29, align 4
  %31 = call float @llvm.pow.f32(float %30, float 3.000000e+00)
  %32 = getelementptr inbounds float, float* %1, i64 7
  %33 = insertelement <4 x float> zeroinitializer, float %4, i32 0
  %34 = insertelement <4 x float> %33, float %7, i32 1
  %35 = insertelement <4 x float> %34, float %11, i32 2
  %36 = insertelement <4 x float> %35, float %15, i32 3
  %37 = insertelement <4 x float> zeroinitializer, float %19, i32 0
  %38 = insertelement <4 x float> %37, float %23, i32 1
  %39 = insertelement <4 x float> %38, float %27, i32 2
  %40 = insertelement <4 x float> %39, float %31, i32 3
  %41 = shufflevector <4 x float> %36, <4 x float> %40, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %42 = extractelement <8 x float> %41, i32 0
  store float %42, float* %1, align 4
  %43 = extractelement <8 x float> %41, i32 1
  %44 = getelementptr inbounds float, float* %1, i64 1
  store float %43, float* %44, align 4
  %45 = extractelement <8 x float> %41, i32 2
  %46 = getelementptr inbounds float, float* %1, i64 2
  store float %45, float* %46, align 4
  %47 = extractelement <8 x float> %41, i32 3
  %48 = getelementptr inbounds float, float* %1, i64 3
  store float %47, float* %48, align 4
  %49 = extractelement <8 x float> %41, i32 4
  %50 = getelementptr inbounds float, float* %1, i64 4
  store float %49, float* %50, align 4
  %51 = extractelement <8 x float> %41, i32 5
  %52 = getelementptr inbounds float, float* %1, i64 5
  store float %51, float* %52, align 4
  %53 = extractelement <8 x float> %41, i32 6
  %54 = getelementptr inbounds float, float* %1, i64 6
  store float %53, float* %54, align 4
  %55 = extractelement <8 x float> %41, i32 7
  %56 = getelementptr inbounds float, float* %1, i64 7
  store float %55, float* %56, align 4
  ret void
}

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.pow.f32(float, float) #1

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [8 x float], align 16
  %2 = alloca [8 x float], align 16
  %3 = bitcast [8 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %3, i8* align 16 bitcast ([8 x float]* @__const.main.a_in to i8*), i64 32, i1 false)
  %4 = bitcast [8 x float]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %4, i8 0, i64 32, i1 false)
  %5 = getelementptr inbounds [8 x float], [8 x float]* %1, i64 0, i64 0
  %6 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  call void @cube(float* %5, float* %6)
  %7 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  %8 = load float, float* %7, align 4
  %9 = fpext float %8 to double
  %10 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %9)
  %11 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 1
  %12 = load float, float* %11, align 4
  %13 = fpext float %12 to double
  %14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %13)
  %15 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 2
  %16 = load float, float* %15, align 4
  %17 = fpext float %16 to double
  %18 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %17)
  %19 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 3
  %20 = load float, float* %19, align 4
  %21 = fpext float %20 to double
  %22 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %21)
  %23 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 4
  %24 = load float, float* %23, align 4
  %25 = fpext float %24 to double
  %26 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %25)
  %27 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 5
  %28 = load float, float* %27, align 4
  %29 = fpext float %28 to double
  %30 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %29)
  %31 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 6
  %32 = load float, float* %31, align 4
  %33 = fpext float %32 to double
  %34 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %33)
  %35 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 7
  %36 = load float, float* %35, align 4
  %37 = fpext float %36 to double
  %38 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %37)
  %39 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  %40 = load float, float* %39, align 16
  %41 = fcmp oeq float %40, 7.290000e+02
  %42 = xor i1 %41, true
  %43 = zext i1 %42 to i32
  %44 = sext i32 %43 to i64
  %45 = icmp ne i64 %44, 0
  br i1 %45, label %46, label %47

46:                                               ; preds = %0
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 18, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.2, i64 0, i64 0)) #6
  unreachable

47:                                               ; preds = %0
  %48 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 1
  %49 = load float, float* %48, align 4
  %50 = fcmp oeq float %49, 5.120000e+02
  %51 = xor i1 %50, true
  %52 = zext i1 %51 to i32
  %53 = sext i32 %52 to i64
  %54 = icmp ne i64 %53, 0
  br i1 %54, label %55, label %56

55:                                               ; preds = %47
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 19, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.3, i64 0, i64 0)) #6
  unreachable

56:                                               ; preds = %47
  %57 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 2
  %58 = load float, float* %57, align 8
  %59 = fcmp oeq float %58, 3.430000e+02
  %60 = xor i1 %59, true
  %61 = zext i1 %60 to i32
  %62 = sext i32 %61 to i64
  %63 = icmp ne i64 %62, 0
  br i1 %63, label %64, label %65

64:                                               ; preds = %56
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 20, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.4, i64 0, i64 0)) #6
  unreachable

65:                                               ; preds = %56
  %66 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 3
  %67 = load float, float* %66, align 4
  %68 = fcmp oeq float %67, 2.160000e+02
  %69 = xor i1 %68, true
  %70 = zext i1 %69 to i32
  %71 = sext i32 %70 to i64
  %72 = icmp ne i64 %71, 0
  br i1 %72, label %73, label %74

73:                                               ; preds = %65
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 21, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.5, i64 0, i64 0)) #6
  unreachable

74:                                               ; preds = %65
  %75 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 4
  %76 = load float, float* %75, align 16
  %77 = fcmp oeq float %76, 1.250000e+02
  %78 = xor i1 %77, true
  %79 = zext i1 %78 to i32
  %80 = sext i32 %79 to i64
  %81 = icmp ne i64 %80, 0
  br i1 %81, label %82, label %83

82:                                               ; preds = %74
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 22, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.6, i64 0, i64 0)) #6
  unreachable

83:                                               ; preds = %74
  %84 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 5
  %85 = load float, float* %84, align 4
  %86 = fcmp oeq float %85, 6.400000e+01
  %87 = xor i1 %86, true
  %88 = zext i1 %87 to i32
  %89 = sext i32 %88 to i64
  %90 = icmp ne i64 %89, 0
  br i1 %90, label %91, label %92

91:                                               ; preds = %83
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 23, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.7, i64 0, i64 0)) #6
  unreachable

92:                                               ; preds = %83
  %93 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 6
  %94 = load float, float* %93, align 8
  %95 = fcmp oeq float %94, 2.700000e+01
  %96 = xor i1 %95, true
  %97 = zext i1 %96 to i32
  %98 = sext i32 %97 to i64
  %99 = icmp ne i64 %98, 0
  br i1 %99, label %100, label %101

100:                                              ; preds = %92
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 24, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.8, i64 0, i64 0)) #6
  unreachable

101:                                              ; preds = %92
  %102 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 7
  %103 = load float, float* %102, align 4
  %104 = fcmp oeq float %103, 8.000000e+00
  %105 = xor i1 %104, true
  %106 = zext i1 %105 to i32
  %107 = sext i32 %106 to i64
  %108 = icmp ne i64 %107, 0
  br i1 %108, label %109, label %110

109:                                              ; preds = %101
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 25, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.9, i64 0, i64 0)) #6
  unreachable

110:                                              ; preds = %101
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

declare i32 @printf(i8*, ...) #4

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #5

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly nounwind willreturn writeonly }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { noreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
