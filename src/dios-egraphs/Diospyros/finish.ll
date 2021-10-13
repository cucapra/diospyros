; ModuleID = 'opt.ll'
source_filename = "llvm-tests/matrix_multiply.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.b_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@.str = private unnamed_addr constant [11 x i8] c"first: %f\0A\00", align 1
@.str.1 = private unnamed_addr constant [12 x i8] c"second: %f\0A\00", align 1
@.str.2 = private unnamed_addr constant [11 x i8] c"third: %f\0A\00", align 1
@.str.3 = private unnamed_addr constant [12 x i8] c"fourth: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @matrix_multiply(float* %0, float* %1, float* %2) #0 {
  %4 = load float, float* %2, align 4
  %5 = insertelement <4 x float> zeroinitializer, float %4, i32 1
  %6 = load float, float* %2, align 4
  %7 = insertelement <4 x float> %5, float %6, i32 2
  %8 = getelementptr inbounds float, float* %2, i64 1
  %9 = load float, float* %8, align 4
  %10 = insertelement <4 x float> %7, float %9, i32 3
  %11 = load float, float* %0, align 4
  %12 = insertelement <4 x float> zeroinitializer, float %11, i32 1
  %13 = getelementptr inbounds float, float* %0, i64 1
  %14 = load float, float* %13, align 4
  %15 = insertelement <4 x float> %12, float %14, i32 2
  %16 = load float, float* %0, align 4
  %17 = insertelement <4 x float> %15, float %16, i32 3
  %18 = load float, float* %1, align 4
  %19 = insertelement <4 x float> zeroinitializer, float %18, i32 1
  %20 = getelementptr inbounds float, float* %1, i64 2
  %21 = load float, float* %20, align 4
  %22 = insertelement <4 x float> %19, float %21, i32 2
  %23 = getelementptr inbounds float, float* %1, i64 1
  %24 = load float, float* %23, align 4
  %25 = insertelement <4 x float> %22, float %24, i32 3
  %26 = call <4 x float> @llvm.fma.f32(<4 x float> %17, <4 x float> %25, <4 x float> %10)
  %27 = getelementptr inbounds float, float* %2, i64 1
  %28 = load float, float* %27, align 4
  %29 = insertelement <4 x float> zeroinitializer, float %28, i32 0
  %30 = getelementptr inbounds float, float* %2, i64 2
  %31 = load float, float* %30, align 4
  %32 = insertelement <4 x float> %29, float %31, i32 1
  %33 = getelementptr inbounds float, float* %2, i64 2
  %34 = load float, float* %33, align 4
  %35 = insertelement <4 x float> %32, float %34, i32 2
  %36 = getelementptr inbounds float, float* %2, i64 3
  %37 = load float, float* %36, align 4
  %38 = insertelement <4 x float> %35, float %37, i32 3
  %39 = getelementptr inbounds float, float* %0, i64 1
  %40 = load float, float* %39, align 4
  %41 = insertelement <4 x float> zeroinitializer, float %40, i32 0
  %42 = getelementptr inbounds float, float* %0, i64 2
  %43 = load float, float* %42, align 4
  %44 = insertelement <4 x float> %41, float %43, i32 1
  %45 = getelementptr inbounds float, float* %0, i64 3
  %46 = load float, float* %45, align 4
  %47 = insertelement <4 x float> %44, float %46, i32 2
  %48 = getelementptr inbounds float, float* %0, i64 2
  %49 = load float, float* %48, align 4
  %50 = insertelement <4 x float> %47, float %49, i32 3
  %51 = getelementptr inbounds float, float* %1, i64 3
  %52 = load float, float* %51, align 4
  %53 = insertelement <4 x float> zeroinitializer, float %52, i32 0
  %54 = load float, float* %1, align 4
  %55 = insertelement <4 x float> %53, float %54, i32 1
  %56 = getelementptr inbounds float, float* %1, i64 2
  %57 = load float, float* %56, align 4
  %58 = insertelement <4 x float> %55, float %57, i32 2
  %59 = getelementptr inbounds float, float* %1, i64 1
  %60 = load float, float* %59, align 4
  %61 = insertelement <4 x float> %58, float %60, i32 3
  %62 = call <4 x float> @llvm.fma.f32.1(<4 x float> %50, <4 x float> %61, <4 x float> %38)
  %63 = shufflevector <4 x float> %26, <4 x float> %62, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %64 = getelementptr inbounds float, float* %2, i64 3
  %65 = load float, float* %64, align 4
  %66 = insertelement <4 x float> zeroinitializer, float %65, i32 0
  %67 = insertelement <4 x float> %66, float 0.000000e+00, i32 1
  %68 = insertelement <4 x float> %67, float 0.000000e+00, i32 2
  %69 = insertelement <4 x float> %68, float 0.000000e+00, i32 3
  %70 = getelementptr inbounds float, float* %0, i64 3
  %71 = load float, float* %70, align 4
  %72 = insertelement <4 x float> zeroinitializer, float %71, i32 0
  %73 = insertelement <4 x float> %72, float 0.000000e+00, i32 1
  %74 = insertelement <4 x float> %73, float 0.000000e+00, i32 2
  %75 = insertelement <4 x float> %74, float 0.000000e+00, i32 3
  %76 = getelementptr inbounds float, float* %1, i64 3
  %77 = load float, float* %76, align 4
  %78 = insertelement <4 x float> zeroinitializer, float %77, i32 0
  %79 = insertelement <4 x float> %78, float 0.000000e+00, i32 1
  %80 = insertelement <4 x float> %79, float 0.000000e+00, i32 2
  %81 = insertelement <4 x float> %80, float 0.000000e+00, i32 3
  %82 = call <4 x float> @llvm.fma.f32.2(<4 x float> %75, <4 x float> %81, <4 x float> %69)
  %83 = shufflevector <8 x float> %63, <4 x float> %82, <12 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11>
  %84 = extractelement <12 x float> %83, i32 0
  store float %84, float* %2, align 4
  %85 = extractelement <12 x float> %83, i32 1
  store float %85, float* %2, align 4
  %86 = extractelement <12 x float> %83, i32 2
  store float %86, float* %2, align 4
  %87 = extractelement <12 x float> %83, i32 3
  %88 = getelementptr inbounds float, float* %2, i64 1
  store float %87, float* %88, align 4
  %89 = extractelement <12 x float> %83, i32 4
  %90 = getelementptr inbounds float, float* %2, i64 1
  store float %89, float* %90, align 4
  %91 = extractelement <12 x float> %83, i32 5
  %92 = getelementptr inbounds float, float* %2, i64 1
  store float %91, float* %92, align 4
  %93 = extractelement <12 x float> %83, i32 6
  %94 = getelementptr inbounds float, float* %2, i64 2
  store float %93, float* %94, align 4
  %95 = extractelement <12 x float> %83, i32 7
  %96 = getelementptr inbounds float, float* %2, i64 2
  store float %95, float* %96, align 4
  %97 = extractelement <12 x float> %83, i32 8
  %98 = getelementptr inbounds float, float* %2, i64 2
  store float %97, float* %98, align 4
  %99 = extractelement <12 x float> %83, i32 9
  %100 = getelementptr inbounds float, float* %2, i64 3
  store float %99, float* %100, align 4
  %101 = extractelement <12 x float> %83, i32 10
  %102 = getelementptr inbounds float, float* %2, i64 3
  store float %101, float* %102, align 4
  %103 = extractelement <12 x float> %83, i32 11
  %104 = getelementptr inbounds float, float* %2, i64 3
  store float %103, float* %104, align 4
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [4 x float], align 16
  %2 = alloca [4 x float], align 16
  %3 = alloca [4 x float], align 16
  %4 = bitcast [4 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %4, i8* align 16 bitcast ([4 x float]* @__const.main.a_in to i8*), i64 16, i1 false)
  %5 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %5, i8* align 16 bitcast ([4 x float]* @__const.main.b_in to i8*), i64 16, i1 false)
  %6 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %6, i8 0, i64 16, i1 false)
  %7 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  call void @matrix_multiply(float* %7, float* %8, float* %9)
  %10 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %11 = load float, float* %10, align 16
  %12 = fpext float %11 to double
  %13 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i64 0, i64 0), double %12)
  %14 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 1
  %15 = load float, float* %14, align 4
  %16 = fpext float %15 to double
  %17 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i64 0, i64 0), double %16)
  %18 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 2
  %19 = load float, float* %18, align 8
  %20 = fpext float %19 to double
  %21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), double %20)
  %22 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 3
  %23 = load float, float* %22, align 4
  %24 = fpext float %23 to double
  %25 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.3, i64 0, i64 0), double %24)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

declare i32 @printf(i8*, ...) #3

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.1(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.2(<4 x float>, <4 x float>, <4 x float>) #4

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn writeonly }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind readnone speculatable willreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
