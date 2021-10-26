; ModuleID = 'clang.ll'
source_filename = "llvm-tests/point-product.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.q_in = private unnamed_addr constant [4 x float] [float 0.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00], align 16
@__const.main.p_in = private unnamed_addr constant [4 x float] [float 0.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @cross_product(float* %0, float* %1, float* %2) #0 {
  %4 = getelementptr inbounds float, float* %0, i64 1
  %5 = load float, float* %4, align 4
  %6 = getelementptr inbounds float, float* %1, i64 2
  %7 = load float, float* %6, align 4
  %8 = fmul float %5, %7
  %9 = getelementptr inbounds float, float* %0, i64 2
  %10 = load float, float* %9, align 4
  %11 = getelementptr inbounds float, float* %1, i64 1
  %12 = load float, float* %11, align 4
  %13 = fmul float %10, %12
  %14 = fsub float %8, %13
  %15 = getelementptr inbounds float, float* %2, i64 0
  store float %14, float* %15, align 4
  %16 = getelementptr inbounds float, float* %0, i64 2
  %17 = load float, float* %16, align 4
  %18 = getelementptr inbounds float, float* %1, i64 0
  %19 = load float, float* %18, align 4
  %20 = fmul float %17, %19
  %21 = getelementptr inbounds float, float* %0, i64 0
  %22 = load float, float* %21, align 4
  %23 = getelementptr inbounds float, float* %1, i64 2
  %24 = load float, float* %23, align 4
  %25 = fmul float %22, %24
  %26 = fsub float %20, %25
  %27 = getelementptr inbounds float, float* %2, i64 1
  store float %26, float* %27, align 4
  %28 = getelementptr inbounds float, float* %0, i64 0
  %29 = load float, float* %28, align 4
  %30 = getelementptr inbounds float, float* %1, i64 1
  %31 = load float, float* %30, align 4
  %32 = fmul float %29, %31
  %33 = getelementptr inbounds float, float* %0, i64 1
  %34 = load float, float* %33, align 4
  %35 = getelementptr inbounds float, float* %1, i64 0
  %36 = load float, float* %35, align 4
  %37 = fmul float %34, %36
  %38 = fsub float %32, %37
  %39 = getelementptr inbounds float, float* %2, i64 2
  store float %38, float* %39, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @point_product(float* %0, float* %1, float* %2) #1 {
  %4 = alloca [3 x float], align 4
  %5 = alloca [3 x float], align 4
  %6 = alloca [3 x float], align 4
  %7 = getelementptr inbounds [3 x float], [3 x float]* %4, i64 0, i64 0
  %8 = getelementptr inbounds float, float* %0, i64 0
  %9 = load float, float* %8, align 4
  store float %9, float* %7, align 4
  %10 = getelementptr inbounds float, float* %7, i64 1
  %11 = getelementptr inbounds float, float* %0, i64 1
  %12 = load float, float* %11, align 4
  store float %12, float* %10, align 4
  %13 = getelementptr inbounds float, float* %10, i64 1
  %14 = getelementptr inbounds float, float* %0, i64 2
  %15 = load float, float* %14, align 4
  store float %15, float* %13, align 4
  %16 = getelementptr inbounds [3 x float], [3 x float]* %4, i64 0, i64 0
  %17 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  %18 = getelementptr inbounds float, float* %16, i64 1
  %19 = load float, float* %18, align 4
  %20 = getelementptr inbounds float, float* %1, i64 2
  %21 = load float, float* %20, align 4
  %22 = fmul float %19, %21
  %23 = getelementptr inbounds float, float* %16, i64 2
  %24 = load float, float* %23, align 4
  %25 = getelementptr inbounds float, float* %1, i64 1
  %26 = load float, float* %25, align 4
  %27 = fmul float %24, %26
  %28 = fsub float %22, %27
  store float %28, float* %17, align 4
  %29 = getelementptr inbounds float, float* %16, i64 2
  %30 = load float, float* %29, align 4
  %31 = load float, float* %1, align 4
  %32 = fmul float %30, %31
  %33 = load float, float* %16, align 4
  %34 = getelementptr inbounds float, float* %1, i64 2
  %35 = load float, float* %34, align 4
  %36 = fmul float %33, %35
  %37 = fsub float %32, %36
  %38 = getelementptr inbounds float, float* %17, i64 1
  store float %37, float* %38, align 4
  %39 = load float, float* %16, align 4
  %40 = getelementptr inbounds float, float* %1, i64 1
  %41 = load float, float* %40, align 4
  %42 = fmul float %39, %41
  %43 = getelementptr inbounds float, float* %16, i64 1
  %44 = load float, float* %43, align 4
  %45 = load float, float* %1, align 4
  %46 = fmul float %44, %45
  %47 = fsub float %42, %46
  %48 = getelementptr inbounds float, float* %17, i64 2
  store float %47, float* %48, align 4
  %49 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  %50 = load float, float* %49, align 4
  %51 = fmul float %50, 2.000000e+00
  %52 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  store float %51, float* %52, align 4
  %53 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 1
  %54 = load float, float* %53, align 4
  %55 = fmul float %54, 2.000000e+00
  %56 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 1
  store float %55, float* %56, align 4
  %57 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 2
  %58 = load float, float* %57, align 4
  %59 = fmul float %58, 2.000000e+00
  %60 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 2
  store float %59, float* %60, align 4
  %61 = getelementptr inbounds [3 x float], [3 x float]* %4, i64 0, i64 0
  %62 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  %63 = getelementptr inbounds [3 x float], [3 x float]* %6, i64 0, i64 0
  %64 = getelementptr inbounds float, float* %61, i64 1
  %65 = load float, float* %64, align 4
  %66 = getelementptr inbounds float, float* %62, i64 2
  %67 = load float, float* %66, align 4
  %68 = fmul float %65, %67
  %69 = getelementptr inbounds float, float* %61, i64 2
  %70 = load float, float* %69, align 4
  %71 = getelementptr inbounds float, float* %62, i64 1
  %72 = load float, float* %71, align 4
  %73 = fmul float %70, %72
  %74 = fsub float %68, %73
  store float %74, float* %63, align 4
  %75 = getelementptr inbounds float, float* %61, i64 2
  %76 = load float, float* %75, align 4
  %77 = load float, float* %62, align 4
  %78 = fmul float %76, %77
  %79 = load float, float* %61, align 4
  %80 = getelementptr inbounds float, float* %62, i64 2
  %81 = load float, float* %80, align 4
  %82 = fmul float %79, %81
  %83 = fsub float %78, %82
  %84 = getelementptr inbounds float, float* %63, i64 1
  store float %83, float* %84, align 4
  %85 = load float, float* %61, align 4
  %86 = getelementptr inbounds float, float* %62, i64 1
  %87 = load float, float* %86, align 4
  %88 = fmul float %85, %87
  %89 = getelementptr inbounds float, float* %61, i64 1
  %90 = load float, float* %89, align 4
  %91 = load float, float* %62, align 4
  %92 = fmul float %90, %91
  %93 = fsub float %88, %92
  %94 = getelementptr inbounds float, float* %63, i64 2
  store float %93, float* %94, align 4
  %95 = getelementptr inbounds float, float* %0, i64 3
  %96 = load float, float* %1, align 4
  %97 = load float, float* %95, align 4
  %98 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  %99 = load float, float* %98, align 4
  %100 = fmul float %97, %99
  %101 = fadd float %96, %100
  %102 = getelementptr inbounds [3 x float], [3 x float]* %6, i64 0, i64 0
  %103 = load float, float* %102, align 4
  %104 = fadd float %101, %103
  store float %104, float* %2, align 4
  %105 = getelementptr inbounds float, float* %1, i64 1
  %106 = load float, float* %105, align 4
  %107 = load float, float* %95, align 4
  %108 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 1
  %109 = load float, float* %108, align 4
  %110 = fmul float %107, %109
  %111 = fadd float %106, %110
  %112 = getelementptr inbounds [3 x float], [3 x float]* %6, i64 0, i64 1
  %113 = load float, float* %112, align 4
  %114 = fadd float %111, %113
  %115 = getelementptr inbounds float, float* %2, i64 1
  store float %114, float* %115, align 4
  %116 = getelementptr inbounds float, float* %1, i64 2
  %117 = load float, float* %116, align 4
  %118 = load float, float* %95, align 4
  %119 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 2
  %120 = load float, float* %119, align 4
  %121 = fmul float %118, %120
  %122 = fadd float %117, %121
  %123 = getelementptr inbounds [3 x float], [3 x float]* %6, i64 0, i64 2
  %124 = load float, float* %123, align 4
  %125 = fadd float %122, %124
  %126 = getelementptr inbounds float, float* %2, i64 2
  store float %125, float* %126, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #1 {
  %1 = alloca [4 x float], align 16
  %2 = alloca [4 x float], align 16
  %3 = alloca [4 x float], align 16
  %4 = bitcast [4 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %4, i8* align 16 bitcast ([4 x float]* @__const.main.q_in to i8*), i64 16, i1 false)
  %5 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %5, i8* align 16 bitcast ([4 x float]* @__const.main.p_in to i8*), i64 16, i1 false)
  %6 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %6, i8 0, i64 16, i1 false)
  %7 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  call void @point_product(float* %7, float* %8, float* %9)
  %10 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %11 = load float, float* %10, align 4
  %12 = fpext float %11 to double
  %13 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %12)
  %14 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 1
  %15 = load float, float* %14, align 4
  %16 = fpext float %15 to double
  %17 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %16)
  %18 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 2
  %19 = load float, float* %18, align 4
  %20 = fpext float %19 to double
  %21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %20)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

declare i32 @printf(i8*, ...) #4

attributes #0 = { alwaysinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly nounwind willreturn writeonly }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
