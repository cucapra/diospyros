; ModuleID = 'opt.ll'
source_filename = "llvm-tests/scalar-new.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [8 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00], align 16
@__const.main.b_in = private unnamed_addr constant [8 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str.1 = private unnamed_addr constant [24 x i8] c"llvm-tests/scalar-new.c\00", align 1
@.str.2 = private unnamed_addr constant [14 x i8] c"b_in[0] == 10\00", align 1
@.str.3 = private unnamed_addr constant [14 x i8] c"b_in[1] == 20\00", align 1
@.str.4 = private unnamed_addr constant [14 x i8] c"b_in[2] == 30\00", align 1
@.str.5 = private unnamed_addr constant [14 x i8] c"b_in[3] == 40\00", align 1
@.str.6 = private unnamed_addr constant [14 x i8] c"b_in[4] == 50\00", align 1
@.str.7 = private unnamed_addr constant [14 x i8] c"b_in[5] == 60\00", align 1
@.str.8 = private unnamed_addr constant [14 x i8] c"b_in[6] == 70\00", align 1
@.str.9 = private unnamed_addr constant [14 x i8] c"b_in[7] == 80\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @matrix_multiply(float* %0, float %1, float* %2) #0 {
  %4 = load float, float* %0, align 4
  %5 = fmul float %4, %1
  %6 = getelementptr inbounds float, float* %0, i64 1
  %7 = load float, float* %6, align 4
  %8 = fmul float %7, %1
  %9 = getelementptr inbounds float, float* %2, i64 1
  %10 = getelementptr inbounds float, float* %0, i64 2
  %11 = load float, float* %10, align 4
  %12 = fmul float %11, %1
  %13 = getelementptr inbounds float, float* %2, i64 2
  %14 = getelementptr inbounds float, float* %0, i64 3
  %15 = load float, float* %14, align 4
  %16 = fmul float %15, %1
  %17 = getelementptr inbounds float, float* %2, i64 3
  %18 = getelementptr inbounds float, float* %0, i64 4
  %19 = load float, float* %18, align 4
  %20 = fmul float %19, %1
  %21 = getelementptr inbounds float, float* %2, i64 4
  %22 = getelementptr inbounds float, float* %0, i64 5
  %23 = load float, float* %22, align 4
  %24 = fmul float %23, %1
  %25 = getelementptr inbounds float, float* %2, i64 5
  %26 = getelementptr inbounds float, float* %0, i64 6
  %27 = load float, float* %26, align 4
  %28 = fmul float %27, %1
  %29 = getelementptr inbounds float, float* %2, i64 6
  %30 = getelementptr inbounds float, float* %0, i64 7
  %31 = load float, float* %30, align 4
  %32 = fmul float %31, %1
  %33 = getelementptr inbounds float, float* %2, i64 7
  %34 = load float, float* %0, align 4
  %35 = insertelement <4 x float> zeroinitializer, float %34, i32 0
  %36 = getelementptr inbounds float, float* %0, i64 1
  %37 = load float, float* %36, align 4
  %38 = insertelement <4 x float> %35, float %37, i32 1
  %39 = getelementptr inbounds float, float* %0, i64 2
  %40 = load float, float* %39, align 4
  %41 = insertelement <4 x float> %38, float %40, i32 2
  %42 = getelementptr inbounds float, float* %0, i64 3
  %43 = load float, float* %42, align 4
  %44 = insertelement <4 x float> %41, float %43, i32 3
  %45 = insertelement <4 x float> zeroinitializer, float %1, i32 0
  %46 = insertelement <4 x float> %45, float %1, i32 1
  %47 = insertelement <4 x float> %46, float %1, i32 2
  %48 = insertelement <4 x float> %47, float %1, i32 3
  %49 = fmul <4 x float> %44, %48
  %50 = getelementptr inbounds float, float* %0, i64 4
  %51 = load float, float* %50, align 4
  %52 = insertelement <4 x float> zeroinitializer, float %51, i32 0
  %53 = getelementptr inbounds float, float* %0, i64 5
  %54 = load float, float* %53, align 4
  %55 = insertelement <4 x float> %52, float %54, i32 1
  %56 = getelementptr inbounds float, float* %0, i64 6
  %57 = load float, float* %56, align 4
  %58 = insertelement <4 x float> %55, float %57, i32 2
  %59 = getelementptr inbounds float, float* %0, i64 7
  %60 = load float, float* %59, align 4
  %61 = insertelement <4 x float> %58, float %60, i32 3
  %62 = insertelement <4 x float> zeroinitializer, float %1, i32 0
  %63 = insertelement <4 x float> %62, float %1, i32 1
  %64 = insertelement <4 x float> %63, float %1, i32 2
  %65 = insertelement <4 x float> %64, float %1, i32 3
  %66 = fmul <4 x float> %61, %65
  %67 = shufflevector <4 x float> %49, <4 x float> %66, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %68 = extractelement <8 x float> %67, i32 0
  store float %68, float* %2, align 4
  %69 = extractelement <8 x float> %67, i32 1
  %70 = getelementptr inbounds float, float* %2, i64 1
  store float %69, float* %70, align 4
  %71 = extractelement <8 x float> %67, i32 2
  %72 = getelementptr inbounds float, float* %2, i64 2
  store float %71, float* %72, align 4
  %73 = extractelement <8 x float> %67, i32 3
  %74 = getelementptr inbounds float, float* %2, i64 3
  store float %73, float* %74, align 4
  %75 = extractelement <8 x float> %67, i32 4
  %76 = getelementptr inbounds float, float* %2, i64 4
  store float %75, float* %76, align 4
  %77 = extractelement <8 x float> %67, i32 5
  %78 = getelementptr inbounds float, float* %2, i64 5
  store float %77, float* %78, align 4
  %79 = extractelement <8 x float> %67, i32 6
  %80 = getelementptr inbounds float, float* %2, i64 6
  store float %79, float* %80, align 4
  %81 = extractelement <8 x float> %67, i32 7
  %82 = getelementptr inbounds float, float* %2, i64 7
  store float %81, float* %82, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [8 x float], align 16
  %2 = alloca [8 x float], align 16
  %3 = bitcast [8 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %3, i8* align 16 bitcast ([8 x float]* @__const.main.a_in to i8*), i64 32, i1 false)
  %4 = bitcast [8 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %4, i8* align 16 bitcast ([8 x float]* @__const.main.b_in to i8*), i64 32, i1 false)
  %5 = getelementptr inbounds [8 x float], [8 x float]* %1, i64 0, i64 0
  %6 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  call void @matrix_multiply(float* %5, float 1.000000e+01, float* %6)
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
  %41 = fcmp oeq float %40, 1.000000e+01
  %42 = xor i1 %41, true
  %43 = zext i1 %42 to i32
  %44 = sext i32 %43 to i64
  %45 = icmp ne i64 %44, 0
  br i1 %45, label %46, label %47

46:                                               ; preds = %0
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 19, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.2, i64 0, i64 0)) #4
  unreachable

47:                                               ; preds = %0
  %48 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 1
  %49 = load float, float* %48, align 4
  %50 = fcmp oeq float %49, 2.000000e+01
  %51 = xor i1 %50, true
  %52 = zext i1 %51 to i32
  %53 = sext i32 %52 to i64
  %54 = icmp ne i64 %53, 0
  br i1 %54, label %55, label %56

55:                                               ; preds = %47
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 20, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.3, i64 0, i64 0)) #4
  unreachable

56:                                               ; preds = %47
  %57 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 2
  %58 = load float, float* %57, align 8
  %59 = fcmp oeq float %58, 3.000000e+01
  %60 = xor i1 %59, true
  %61 = zext i1 %60 to i32
  %62 = sext i32 %61 to i64
  %63 = icmp ne i64 %62, 0
  br i1 %63, label %64, label %65

64:                                               ; preds = %56
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 21, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.4, i64 0, i64 0)) #4
  unreachable

65:                                               ; preds = %56
  %66 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 3
  %67 = load float, float* %66, align 4
  %68 = fcmp oeq float %67, 4.000000e+01
  %69 = xor i1 %68, true
  %70 = zext i1 %69 to i32
  %71 = sext i32 %70 to i64
  %72 = icmp ne i64 %71, 0
  br i1 %72, label %73, label %74

73:                                               ; preds = %65
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 22, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.5, i64 0, i64 0)) #4
  unreachable

74:                                               ; preds = %65
  %75 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 4
  %76 = load float, float* %75, align 16
  %77 = fcmp oeq float %76, 5.000000e+01
  %78 = xor i1 %77, true
  %79 = zext i1 %78 to i32
  %80 = sext i32 %79 to i64
  %81 = icmp ne i64 %80, 0
  br i1 %81, label %82, label %83

82:                                               ; preds = %74
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 23, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.6, i64 0, i64 0)) #4
  unreachable

83:                                               ; preds = %74
  %84 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 5
  %85 = load float, float* %84, align 4
  %86 = fcmp oeq float %85, 6.000000e+01
  %87 = xor i1 %86, true
  %88 = zext i1 %87 to i32
  %89 = sext i32 %88 to i64
  %90 = icmp ne i64 %89, 0
  br i1 %90, label %91, label %92

91:                                               ; preds = %83
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 24, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.7, i64 0, i64 0)) #4
  unreachable

92:                                               ; preds = %83
  %93 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 6
  %94 = load float, float* %93, align 8
  %95 = fcmp oeq float %94, 7.000000e+01
  %96 = xor i1 %95, true
  %97 = zext i1 %96 to i32
  %98 = sext i32 %97 to i64
  %99 = icmp ne i64 %98, 0
  br i1 %99, label %100, label %101

100:                                              ; preds = %92
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 25, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.8, i64 0, i64 0)) #4
  unreachable

101:                                              ; preds = %92
  %102 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 7
  %103 = load float, float* %102, align 4
  %104 = fcmp oeq float %103, 8.000000e+01
  %105 = xor i1 %104, true
  %106 = zext i1 %105 to i32
  %107 = sext i32 %106 to i64
  %108 = icmp ne i64 %107, 0
  br i1 %108, label %109, label %110

109:                                              ; preds = %101
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 26, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.9, i64 0, i64 0)) #4
  unreachable

110:                                              ; preds = %101
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

declare i32 @printf(i8*, ...) #2

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #3

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
