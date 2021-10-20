; ModuleID = 'finish.ll'
source_filename = "llvm-tests/sqrt.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [8 x float] [float 9.000000e+00, float 8.000000e+00, float 7.000000e+00, float 6.000000e+00, float 5.000000e+00, float 4.000000e+00, float 3.000000e+00, float 2.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @vsqrt(float* %0, float* %1, float* %2) #0 {
  %4 = load float, float* %0, align 4
  %5 = insertelement <4 x float> zeroinitializer, float %4, i32 0
  %6 = load float, float* %0, align 4
  %7 = insertelement <4 x float> %5, float %6, i32 1
  %8 = getelementptr inbounds float, float* %0, i64 1
  %9 = load float, float* %8, align 4
  %10 = insertelement <4 x float> %7, float %9, i32 2
  %11 = getelementptr inbounds float, float* %0, i64 1
  %12 = load float, float* %11, align 4
  %13 = insertelement <4 x float> %10, float %12, i32 3
  %14 = call <4 x float> @llvm.sqrt.v4f32(<4 x float> %13)
  %15 = getelementptr inbounds float, float* %0, i64 2
  %16 = load float, float* %15, align 4
  %17 = insertelement <4 x float> zeroinitializer, float %16, i32 0
  %18 = getelementptr inbounds float, float* %0, i64 2
  %19 = load float, float* %18, align 4
  %20 = insertelement <4 x float> %17, float %19, i32 1
  %21 = getelementptr inbounds float, float* %0, i64 3
  %22 = load float, float* %21, align 4
  %23 = insertelement <4 x float> %20, float %22, i32 2
  %24 = getelementptr inbounds float, float* %0, i64 3
  %25 = load float, float* %24, align 4
  %26 = insertelement <4 x float> %23, float %25, i32 3
  %27 = call <4 x float> @llvm.sqrt.v4f32(<4 x float> %26)
  %28 = shufflevector <4 x float> %14, <4 x float> %27, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %29 = getelementptr inbounds float, float* %0, i64 4
  %30 = load float, float* %29, align 4
  %31 = insertelement <4 x float> zeroinitializer, float %30, i32 0
  %32 = getelementptr inbounds float, float* %0, i64 4
  %33 = load float, float* %32, align 4
  %34 = insertelement <4 x float> %31, float %33, i32 1
  %35 = getelementptr inbounds float, float* %0, i64 5
  %36 = load float, float* %35, align 4
  %37 = insertelement <4 x float> %34, float %36, i32 2
  %38 = getelementptr inbounds float, float* %0, i64 5
  %39 = load float, float* %38, align 4
  %40 = insertelement <4 x float> %37, float %39, i32 3
  %41 = call <4 x float> @llvm.sqrt.v4f32(<4 x float> %40)
  %42 = getelementptr inbounds float, float* %0, i64 6
  %43 = load float, float* %42, align 4
  %44 = insertelement <4 x float> zeroinitializer, float %43, i32 0
  %45 = getelementptr inbounds float, float* %0, i64 6
  %46 = load float, float* %45, align 4
  %47 = insertelement <4 x float> %44, float %46, i32 1
  %48 = getelementptr inbounds float, float* %0, i64 7
  %49 = load float, float* %48, align 4
  %50 = insertelement <4 x float> %47, float %49, i32 2
  %51 = getelementptr inbounds float, float* %0, i64 7
  %52 = load float, float* %51, align 4
  %53 = insertelement <4 x float> %50, float %52, i32 3
  %54 = call <4 x float> @llvm.sqrt.v4f32(<4 x float> %53)
  %55 = shufflevector <4 x float> %41, <4 x float> %54, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %56 = shufflevector <8 x float> %28, <8 x float> %55, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %57 = extractelement <16 x float> %56, i32 0
  store float %57, float* %1, align 4
  %58 = extractelement <16 x float> %56, i32 1
  store float %58, float* %2, align 4
  %59 = extractelement <16 x float> %56, i32 2
  %60 = getelementptr inbounds float, float* %1, i64 1
  store float %59, float* %60, align 4
  %61 = extractelement <16 x float> %56, i32 3
  %62 = getelementptr inbounds float, float* %2, i64 1
  store float %61, float* %62, align 4
  %63 = extractelement <16 x float> %56, i32 4
  %64 = getelementptr inbounds float, float* %1, i64 2
  store float %63, float* %64, align 4
  %65 = extractelement <16 x float> %56, i32 5
  %66 = getelementptr inbounds float, float* %2, i64 2
  store float %65, float* %66, align 4
  %67 = extractelement <16 x float> %56, i32 6
  %68 = getelementptr inbounds float, float* %1, i64 3
  store float %67, float* %68, align 4
  %69 = extractelement <16 x float> %56, i32 7
  %70 = getelementptr inbounds float, float* %2, i64 3
  store float %69, float* %70, align 4
  %71 = extractelement <16 x float> %56, i32 8
  %72 = getelementptr inbounds float, float* %1, i64 4
  store float %71, float* %72, align 4
  %73 = extractelement <16 x float> %56, i32 9
  %74 = getelementptr inbounds float, float* %2, i64 4
  store float %73, float* %74, align 4
  %75 = extractelement <16 x float> %56, i32 10
  %76 = getelementptr inbounds float, float* %1, i64 5
  store float %75, float* %76, align 4
  %77 = extractelement <16 x float> %56, i32 11
  %78 = getelementptr inbounds float, float* %2, i64 5
  store float %77, float* %78, align 4
  %79 = extractelement <16 x float> %56, i32 12
  %80 = getelementptr inbounds float, float* %1, i64 6
  store float %79, float* %80, align 4
  %81 = extractelement <16 x float> %56, i32 13
  %82 = getelementptr inbounds float, float* %2, i64 6
  store float %81, float* %82, align 4
  %83 = extractelement <16 x float> %56, i32 14
  %84 = getelementptr inbounds float, float* %1, i64 7
  store float %83, float* %84, align 4
  %85 = extractelement <16 x float> %56, i32 15
  %86 = getelementptr inbounds float, float* %2, i64 7
  store float %85, float* %86, align 4
  ret void
}

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.sqrt.f64(double) #1

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [8 x float], align 16
  %2 = alloca [8 x float], align 16
  %3 = alloca [8 x float], align 16
  %4 = bitcast [8 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %4, i8* align 16 bitcast ([8 x float]* @__const.main.a_in to i8*), i64 32, i1 false)
  %5 = bitcast [8 x float]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %5, i8 0, i64 32, i1 false)
  %6 = bitcast [8 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %6, i8 0, i64 32, i1 false)
  %7 = getelementptr inbounds [8 x float], [8 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 0
  call void @vsqrt(float* %7, float* %8, float* %9)
  %10 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  %11 = load float, float* %10, align 4
  %12 = fpext float %11 to double
  %13 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %12)
  %14 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 0
  %15 = load float, float* %14, align 4
  %16 = fpext float %15 to double
  %17 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %16)
  %18 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 1
  %19 = load float, float* %18, align 4
  %20 = fpext float %19 to double
  %21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %20)
  %22 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 1
  %23 = load float, float* %22, align 4
  %24 = fpext float %23 to double
  %25 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %24)
  %26 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 2
  %27 = load float, float* %26, align 4
  %28 = fpext float %27 to double
  %29 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %28)
  %30 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 2
  %31 = load float, float* %30, align 4
  %32 = fpext float %31 to double
  %33 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %32)
  %34 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 3
  %35 = load float, float* %34, align 4
  %36 = fpext float %35 to double
  %37 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %36)
  %38 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 3
  %39 = load float, float* %38, align 4
  %40 = fpext float %39 to double
  %41 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %40)
  %42 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 4
  %43 = load float, float* %42, align 4
  %44 = fpext float %43 to double
  %45 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %44)
  %46 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 4
  %47 = load float, float* %46, align 4
  %48 = fpext float %47 to double
  %49 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %48)
  %50 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 5
  %51 = load float, float* %50, align 4
  %52 = fpext float %51 to double
  %53 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %52)
  %54 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 5
  %55 = load float, float* %54, align 4
  %56 = fpext float %55 to double
  %57 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %56)
  %58 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 6
  %59 = load float, float* %58, align 4
  %60 = fpext float %59 to double
  %61 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %60)
  %62 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 6
  %63 = load float, float* %62, align 4
  %64 = fpext float %63 to double
  %65 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %64)
  %66 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 7
  %67 = load float, float* %66, align 4
  %68 = fpext float %67 to double
  %69 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %68)
  %70 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 7
  %71 = load float, float* %70, align 4
  %72 = fpext float %71 to double
  %73 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %72)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

declare i32 @printf(i8*, ...) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.sqrt.v4f32(<4 x float>) #1

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly nounwind willreturn writeonly }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
