; ModuleID = 'diospyros.ll'
source_filename = "llvm-tests/sqrt.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [8 x float] [float 9.000000e+00, float 8.000000e+00, float 7.000000e+00, float 6.000000e+00, float 5.000000e+00, float 4.000000e+00, float 3.000000e+00, float 2.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @vsqrt(float* %0, float* %1, float* %2) #0 {
  %4 = load float, float* %0, align 4
  %5 = call float @llvm.sqrt.f32(float %4)
  %6 = insertelement <4 x float> zeroinitializer, float %5, i32 0
  %7 = insertelement <4 x float> %6, float 0.000000e+00, i32 1
  %8 = insertelement <4 x float> %7, float 0.000000e+00, i32 2
  %9 = insertelement <4 x float> %8, float 0.000000e+00, i32 3
  %10 = extractelement <4 x float> %9, i32 0
  store float %10, float* %1, align 4
  %11 = load float, float* %0, align 4
  %12 = call float @llvm.sqrt.f32(float %11)
  %13 = insertelement <4 x float> zeroinitializer, float %12, i32 0
  %14 = insertelement <4 x float> %13, float 0.000000e+00, i32 1
  %15 = insertelement <4 x float> %14, float 0.000000e+00, i32 2
  %16 = insertelement <4 x float> %15, float 0.000000e+00, i32 3
  %17 = extractelement <4 x float> %16, i32 0
  store float %17, float* %2, align 4
  %18 = getelementptr inbounds float, float* %0, i64 1
  %19 = load float, float* %18, align 4
  %20 = call float @llvm.sqrt.f32(float %19)
  %21 = insertelement <4 x float> zeroinitializer, float %20, i32 0
  %22 = insertelement <4 x float> %21, float 0.000000e+00, i32 1
  %23 = insertelement <4 x float> %22, float 0.000000e+00, i32 2
  %24 = insertelement <4 x float> %23, float 0.000000e+00, i32 3
  %25 = extractelement <4 x float> %24, i32 0
  %26 = getelementptr inbounds float, float* %1, i64 1
  store float %25, float* %26, align 4
  %27 = getelementptr inbounds float, float* %0, i64 1
  %28 = load float, float* %27, align 4
  %29 = call float @llvm.sqrt.f32(float %28)
  %30 = insertelement <4 x float> zeroinitializer, float %29, i32 0
  %31 = insertelement <4 x float> %30, float 0.000000e+00, i32 1
  %32 = insertelement <4 x float> %31, float 0.000000e+00, i32 2
  %33 = insertelement <4 x float> %32, float 0.000000e+00, i32 3
  %34 = extractelement <4 x float> %33, i32 0
  %35 = getelementptr inbounds float, float* %2, i64 1
  store float %34, float* %35, align 4
  %36 = getelementptr inbounds float, float* %0, i64 2
  %37 = load float, float* %36, align 4
  %38 = call float @llvm.sqrt.f32(float %37)
  %39 = insertelement <4 x float> zeroinitializer, float %38, i32 0
  %40 = insertelement <4 x float> %39, float 0.000000e+00, i32 1
  %41 = insertelement <4 x float> %40, float 0.000000e+00, i32 2
  %42 = insertelement <4 x float> %41, float 0.000000e+00, i32 3
  %43 = extractelement <4 x float> %42, i32 0
  %44 = getelementptr inbounds float, float* %1, i64 2
  store float %43, float* %44, align 4
  %45 = getelementptr inbounds float, float* %0, i64 2
  %46 = load float, float* %45, align 4
  %47 = call float @llvm.sqrt.f32(float %46)
  %48 = insertelement <4 x float> zeroinitializer, float %47, i32 0
  %49 = insertelement <4 x float> %48, float 0.000000e+00, i32 1
  %50 = insertelement <4 x float> %49, float 0.000000e+00, i32 2
  %51 = insertelement <4 x float> %50, float 0.000000e+00, i32 3
  %52 = extractelement <4 x float> %51, i32 0
  %53 = getelementptr inbounds float, float* %2, i64 2
  store float %52, float* %53, align 4
  %54 = getelementptr inbounds float, float* %0, i64 3
  %55 = load float, float* %54, align 4
  %56 = call float @llvm.sqrt.f32(float %55)
  %57 = insertelement <4 x float> zeroinitializer, float %56, i32 0
  %58 = insertelement <4 x float> %57, float 0.000000e+00, i32 1
  %59 = insertelement <4 x float> %58, float 0.000000e+00, i32 2
  %60 = insertelement <4 x float> %59, float 0.000000e+00, i32 3
  %61 = extractelement <4 x float> %60, i32 0
  %62 = getelementptr inbounds float, float* %1, i64 3
  store float %61, float* %62, align 4
  %63 = getelementptr inbounds float, float* %0, i64 3
  %64 = load float, float* %63, align 4
  %65 = call float @llvm.sqrt.f32(float %64)
  %66 = insertelement <4 x float> zeroinitializer, float %65, i32 0
  %67 = insertelement <4 x float> %66, float 0.000000e+00, i32 1
  %68 = insertelement <4 x float> %67, float 0.000000e+00, i32 2
  %69 = insertelement <4 x float> %68, float 0.000000e+00, i32 3
  %70 = extractelement <4 x float> %69, i32 0
  %71 = getelementptr inbounds float, float* %2, i64 3
  store float %70, float* %71, align 4
  %72 = getelementptr inbounds float, float* %0, i64 4
  %73 = load float, float* %72, align 4
  %74 = call float @llvm.sqrt.f32(float %73)
  %75 = insertelement <4 x float> zeroinitializer, float %74, i32 0
  %76 = insertelement <4 x float> %75, float 0.000000e+00, i32 1
  %77 = insertelement <4 x float> %76, float 0.000000e+00, i32 2
  %78 = insertelement <4 x float> %77, float 0.000000e+00, i32 3
  %79 = extractelement <4 x float> %78, i32 0
  %80 = getelementptr inbounds float, float* %1, i64 4
  store float %79, float* %80, align 4
  %81 = getelementptr inbounds float, float* %0, i64 4
  %82 = load float, float* %81, align 4
  %83 = call float @llvm.sqrt.f32(float %82)
  %84 = insertelement <4 x float> zeroinitializer, float %83, i32 0
  %85 = insertelement <4 x float> %84, float 0.000000e+00, i32 1
  %86 = insertelement <4 x float> %85, float 0.000000e+00, i32 2
  %87 = insertelement <4 x float> %86, float 0.000000e+00, i32 3
  %88 = extractelement <4 x float> %87, i32 0
  %89 = getelementptr inbounds float, float* %2, i64 4
  store float %88, float* %89, align 4
  %90 = getelementptr inbounds float, float* %0, i64 5
  %91 = load float, float* %90, align 4
  %92 = call float @llvm.sqrt.f32(float %91)
  %93 = insertelement <4 x float> zeroinitializer, float %92, i32 0
  %94 = insertelement <4 x float> %93, float 0.000000e+00, i32 1
  %95 = insertelement <4 x float> %94, float 0.000000e+00, i32 2
  %96 = insertelement <4 x float> %95, float 0.000000e+00, i32 3
  %97 = extractelement <4 x float> %96, i32 0
  %98 = getelementptr inbounds float, float* %1, i64 5
  store float %97, float* %98, align 4
  %99 = getelementptr inbounds float, float* %0, i64 5
  %100 = load float, float* %99, align 4
  %101 = call float @llvm.sqrt.f32(float %100)
  %102 = insertelement <4 x float> zeroinitializer, float %101, i32 0
  %103 = insertelement <4 x float> %102, float 0.000000e+00, i32 1
  %104 = insertelement <4 x float> %103, float 0.000000e+00, i32 2
  %105 = insertelement <4 x float> %104, float 0.000000e+00, i32 3
  %106 = extractelement <4 x float> %105, i32 0
  %107 = getelementptr inbounds float, float* %2, i64 5
  store float %106, float* %107, align 4
  %108 = getelementptr inbounds float, float* %0, i64 6
  %109 = load float, float* %108, align 4
  %110 = call float @llvm.sqrt.f32(float %109)
  %111 = insertelement <4 x float> zeroinitializer, float %110, i32 0
  %112 = insertelement <4 x float> %111, float 0.000000e+00, i32 1
  %113 = insertelement <4 x float> %112, float 0.000000e+00, i32 2
  %114 = insertelement <4 x float> %113, float 0.000000e+00, i32 3
  %115 = extractelement <4 x float> %114, i32 0
  %116 = getelementptr inbounds float, float* %1, i64 6
  store float %115, float* %116, align 4
  %117 = getelementptr inbounds float, float* %0, i64 6
  %118 = load float, float* %117, align 4
  %119 = call float @llvm.sqrt.f32(float %118)
  %120 = insertelement <4 x float> zeroinitializer, float %119, i32 0
  %121 = insertelement <4 x float> %120, float 0.000000e+00, i32 1
  %122 = insertelement <4 x float> %121, float 0.000000e+00, i32 2
  %123 = insertelement <4 x float> %122, float 0.000000e+00, i32 3
  %124 = extractelement <4 x float> %123, i32 0
  %125 = getelementptr inbounds float, float* %2, i64 6
  store float %124, float* %125, align 4
  %126 = getelementptr inbounds float, float* %0, i64 7
  %127 = load float, float* %126, align 4
  %128 = call float @llvm.sqrt.f32(float %127)
  %129 = insertelement <4 x float> zeroinitializer, float %128, i32 0
  %130 = getelementptr inbounds float, float* %0, i64 7
  %131 = load float, float* %130, align 4
  %132 = call float @llvm.sqrt.f32(float %131)
  %133 = insertelement <4 x float> %129, float %132, i32 1
  %134 = insertelement <4 x float> %133, float 0.000000e+00, i32 2
  %135 = insertelement <4 x float> %134, float 0.000000e+00, i32 3
  %136 = extractelement <4 x float> %135, i32 0
  %137 = getelementptr inbounds float, float* %1, i64 7
  store float %136, float* %137, align 4
  %138 = extractelement <4 x float> %135, i32 1
  %139 = getelementptr inbounds float, float* %2, i64 7
  store float %138, float* %139, align 4
  ret void
}

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32(float) #1

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [8 x float], align 16
  %2 = alloca [8 x float], align 16
  %3 = alloca [8 x float], align 16
  %4 = bitcast [8 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(32) %4, i8* nonnull align 16 dereferenceable(32) bitcast ([8 x float]* @__const.main.a_in to i8*), i64 32, i1 false)
  %5 = bitcast [8 x float]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(32) %5, i8 0, i64 32, i1 false)
  %6 = bitcast [8 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(32) %6, i8 0, i64 32, i1 false)
  %7 = getelementptr inbounds [8 x float], [8 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 0
  call void @vsqrt(float* nonnull %7, float* nonnull %8, float* nonnull %9)
  %10 = load float, float* %8, align 16
  %11 = fpext float %10 to double
  %12 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %11) #5
  %13 = load float, float* %9, align 16
  %14 = fpext float %13 to double
  %15 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %14) #5
  %16 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 1
  %17 = load float, float* %16, align 4
  %18 = fpext float %17 to double
  %19 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %18) #5
  %20 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 1
  %21 = load float, float* %20, align 4
  %22 = fpext float %21 to double
  %23 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %22) #5
  %24 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 2
  %25 = load float, float* %24, align 8
  %26 = fpext float %25 to double
  %27 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %26) #5
  %28 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 2
  %29 = load float, float* %28, align 8
  %30 = fpext float %29 to double
  %31 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %30) #5
  %32 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 3
  %33 = load float, float* %32, align 4
  %34 = fpext float %33 to double
  %35 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %34) #5
  %36 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 3
  %37 = load float, float* %36, align 4
  %38 = fpext float %37 to double
  %39 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %38) #5
  %40 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 4
  %41 = load float, float* %40, align 16
  %42 = fpext float %41 to double
  %43 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %42) #5
  %44 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 4
  %45 = load float, float* %44, align 16
  %46 = fpext float %45 to double
  %47 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %46) #5
  %48 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 5
  %49 = load float, float* %48, align 4
  %50 = fpext float %49 to double
  %51 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %50) #5
  %52 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 5
  %53 = load float, float* %52, align 4
  %54 = fpext float %53 to double
  %55 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %54) #5
  %56 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 6
  %57 = load float, float* %56, align 8
  %58 = fpext float %57 to double
  %59 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %58) #5
  %60 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 6
  %61 = load float, float* %60, align 8
  %62 = fpext float %61 to double
  %63 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %62) #5
  %64 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 7
  %65 = load float, float* %64, align 4
  %66 = fpext float %65 to double
  %67 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %66) #5
  %68 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 7
  %69 = load float, float* %68, align 4
  %70 = fpext float %69 to double
  %71 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %70) #5
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

declare i32 @printf(i8*, ...) #4

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly nounwind willreturn writeonly }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
