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
  store float 0.000000e+00, float* %2, align 4
  %4 = load float, float* %2, align 4
  %5 = insertelement <4 x float> zeroinitializer, float %4, i32 0
  %6 = insertelement <4 x float> %5, float 0.000000e+00, i32 1
  %7 = insertelement <4 x float> %6, float 0.000000e+00, i32 2
  %8 = insertelement <4 x float> %7, float 0.000000e+00, i32 3
  %9 = load float, float* %0, align 4
  %10 = insertelement <4 x float> zeroinitializer, float %9, i32 0
  %11 = insertelement <4 x float> %10, float 0.000000e+00, i32 1
  %12 = insertelement <4 x float> %11, float 0.000000e+00, i32 2
  %13 = insertelement <4 x float> %12, float 0.000000e+00, i32 3
  %14 = load float, float* %1, align 4
  %15 = insertelement <4 x float> zeroinitializer, float %14, i32 0
  %16 = insertelement <4 x float> %15, float 0.000000e+00, i32 1
  %17 = insertelement <4 x float> %16, float 0.000000e+00, i32 2
  %18 = insertelement <4 x float> %17, float 0.000000e+00, i32 3
  %19 = call <4 x float> @llvm.fma.f32(<4 x float> %13, <4 x float> %18, <4 x float> %8)
  %20 = extractelement <4 x float> %19, i32 0
  store float %20, float* %2, align 4
  %21 = load float, float* %2, align 4
  %22 = insertelement <4 x float> zeroinitializer, float %21, i32 0
  %23 = insertelement <4 x float> %22, float 0.000000e+00, i32 1
  %24 = getelementptr inbounds float, float* %2, i64 1
  %25 = load float, float* %24, align 4
  %26 = insertelement <4 x float> %23, float %25, i32 2
  %27 = insertelement <4 x float> %26, float 0.000000e+00, i32 3
  %28 = getelementptr inbounds float, float* %0, i64 1
  %29 = load float, float* %28, align 4
  %30 = insertelement <4 x float> zeroinitializer, float %29, i32 0
  %31 = insertelement <4 x float> %30, float 0.000000e+00, i32 1
  %32 = load float, float* %0, align 4
  %33 = insertelement <4 x float> %31, float %32, i32 2
  %34 = insertelement <4 x float> %33, float 0.000000e+00, i32 3
  %35 = getelementptr inbounds float, float* %1, i64 2
  %36 = load float, float* %35, align 4
  %37 = insertelement <4 x float> zeroinitializer, float %36, i32 0
  %38 = insertelement <4 x float> %37, float 0.000000e+00, i32 1
  %39 = getelementptr inbounds float, float* %1, i64 1
  %40 = load float, float* %39, align 4
  %41 = insertelement <4 x float> %38, float %40, i32 2
  %42 = insertelement <4 x float> %41, float 0.000000e+00, i32 3
  %43 = call <4 x float> @llvm.fma.f32.1(<4 x float> %34, <4 x float> %42, <4 x float> %27)
  %44 = extractelement <4 x float> %43, i32 0
  store float %44, float* %2, align 4
  %45 = extractelement <4 x float> %43, i32 1
  %46 = getelementptr inbounds float, float* %2, i64 1
  store float %45, float* %46, align 4
  %47 = extractelement <4 x float> %43, i32 2
  %48 = getelementptr inbounds float, float* %2, i64 1
  store float %47, float* %48, align 4
  %49 = getelementptr inbounds float, float* %2, i64 1
  %50 = load float, float* %49, align 4
  %51 = insertelement <4 x float> zeroinitializer, float %50, i32 0
  %52 = insertelement <4 x float> %51, float 0.000000e+00, i32 1
  %53 = getelementptr inbounds float, float* %2, i64 2
  %54 = load float, float* %53, align 4
  %55 = insertelement <4 x float> %52, float %54, i32 2
  %56 = insertelement <4 x float> %55, float 0.000000e+00, i32 3
  %57 = getelementptr inbounds float, float* %0, i64 1
  %58 = load float, float* %57, align 4
  %59 = insertelement <4 x float> zeroinitializer, float %58, i32 0
  %60 = insertelement <4 x float> %59, float 0.000000e+00, i32 1
  %61 = getelementptr inbounds float, float* %0, i64 2
  %62 = load float, float* %61, align 4
  %63 = insertelement <4 x float> %60, float %62, i32 2
  %64 = insertelement <4 x float> %63, float 0.000000e+00, i32 3
  %65 = getelementptr inbounds float, float* %1, i64 3
  %66 = load float, float* %65, align 4
  %67 = insertelement <4 x float> zeroinitializer, float %66, i32 0
  %68 = insertelement <4 x float> %67, float 0.000000e+00, i32 1
  %69 = load float, float* %1, align 4
  %70 = insertelement <4 x float> %68, float %69, i32 2
  %71 = insertelement <4 x float> %70, float 0.000000e+00, i32 3
  %72 = call <4 x float> @llvm.fma.f32.2(<4 x float> %64, <4 x float> %71, <4 x float> %56)
  %73 = extractelement <4 x float> %72, i32 0
  %74 = getelementptr inbounds float, float* %2, i64 1
  store float %73, float* %74, align 4
  %75 = extractelement <4 x float> %72, i32 1
  %76 = getelementptr inbounds float, float* %2, i64 2
  store float %75, float* %76, align 4
  %77 = extractelement <4 x float> %72, i32 2
  %78 = getelementptr inbounds float, float* %2, i64 2
  store float %77, float* %78, align 4
  %79 = getelementptr inbounds float, float* %2, i64 2
  %80 = load float, float* %79, align 4
  %81 = insertelement <4 x float> zeroinitializer, float %80, i32 0
  %82 = insertelement <4 x float> %81, float 0.000000e+00, i32 1
  %83 = getelementptr inbounds float, float* %2, i64 3
  %84 = load float, float* %83, align 4
  %85 = insertelement <4 x float> %82, float %84, i32 2
  %86 = insertelement <4 x float> %85, float 0.000000e+00, i32 3
  %87 = getelementptr inbounds float, float* %0, i64 3
  %88 = load float, float* %87, align 4
  %89 = insertelement <4 x float> zeroinitializer, float %88, i32 0
  %90 = insertelement <4 x float> %89, float 0.000000e+00, i32 1
  %91 = getelementptr inbounds float, float* %0, i64 2
  %92 = load float, float* %91, align 4
  %93 = insertelement <4 x float> %90, float %92, i32 2
  %94 = insertelement <4 x float> %93, float 0.000000e+00, i32 3
  %95 = getelementptr inbounds float, float* %1, i64 2
  %96 = load float, float* %95, align 4
  %97 = insertelement <4 x float> zeroinitializer, float %96, i32 0
  %98 = insertelement <4 x float> %97, float 0.000000e+00, i32 1
  %99 = getelementptr inbounds float, float* %1, i64 1
  %100 = load float, float* %99, align 4
  %101 = insertelement <4 x float> %98, float %100, i32 2
  %102 = insertelement <4 x float> %101, float 0.000000e+00, i32 3
  %103 = call <4 x float> @llvm.fma.f32.3(<4 x float> %94, <4 x float> %102, <4 x float> %86)
  %104 = extractelement <4 x float> %103, i32 0
  %105 = getelementptr inbounds float, float* %2, i64 2
  store float %104, float* %105, align 4
  %106 = extractelement <4 x float> %103, i32 1
  %107 = getelementptr inbounds float, float* %2, i64 3
  store float %106, float* %107, align 4
  %108 = extractelement <4 x float> %103, i32 2
  %109 = getelementptr inbounds float, float* %2, i64 3
  store float %108, float* %109, align 4
  %110 = getelementptr inbounds float, float* %2, i64 3
  %111 = load float, float* %110, align 4
  %112 = insertelement <4 x float> zeroinitializer, float %111, i32 0
  %113 = insertelement <4 x float> %112, float 0.000000e+00, i32 1
  %114 = insertelement <4 x float> %113, float 0.000000e+00, i32 2
  %115 = insertelement <4 x float> %114, float 0.000000e+00, i32 3
  %116 = getelementptr inbounds float, float* %0, i64 3
  %117 = load float, float* %116, align 4
  %118 = insertelement <4 x float> zeroinitializer, float %117, i32 0
  %119 = insertelement <4 x float> %118, float 0.000000e+00, i32 1
  %120 = insertelement <4 x float> %119, float 0.000000e+00, i32 2
  %121 = insertelement <4 x float> %120, float 0.000000e+00, i32 3
  %122 = getelementptr inbounds float, float* %1, i64 3
  %123 = load float, float* %122, align 4
  %124 = insertelement <4 x float> zeroinitializer, float %123, i32 0
  %125 = insertelement <4 x float> %124, float 0.000000e+00, i32 1
  %126 = insertelement <4 x float> %125, float 0.000000e+00, i32 2
  %127 = insertelement <4 x float> %126, float 0.000000e+00, i32 3
  %128 = call <4 x float> @llvm.fma.f32.4(<4 x float> %121, <4 x float> %127, <4 x float> %115)
  %129 = extractelement <4 x float> %128, i32 0
  %130 = getelementptr inbounds float, float* %2, i64 3
  store float %129, float* %130, align 4
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

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.3(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.4(<4 x float>, <4 x float>, <4 x float>) #4

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
