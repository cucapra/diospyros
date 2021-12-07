; ModuleID = 'opt.ll'
source_filename = "llvm-tests/2d-2d-conv.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.mat_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 2.000000e+00], [2 x float] [float 3.000000e+00, float 4.000000e+00]], align 16
@__const.main.f_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 1.000000e+00], [2 x float] [float 1.000000e+00, float 1.000000e+00]], align 16
@.str = private unnamed_addr constant [12 x i8] c"output: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @convolution([2 x float]* %0, [2 x float]* %1, [3 x float]* %2) #0 {
.preheader7:
  %3 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 0
  %4 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %5 = load float, float* %4, align 4
  %6 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 0
  %7 = load float, float* %6, align 4
  %8 = fmul float %5, %7
  %9 = load float, float* %3, align 4
  %10 = fadd float %9, %8
  store float %10, float* %3, align 4
  %11 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 1
  %12 = load float, float* %4, align 4
  %13 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 1
  %14 = load float, float* %13, align 4
  %15 = fmul float %12, %14
  %16 = load float, float* %11, align 4
  %17 = fadd float %16, %15
  store float %17, float* %11, align 4
  %18 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %19 = load float, float* %18, align 4
  %20 = load float, float* %6, align 4
  %21 = fmul float %19, %20
  %22 = fadd float %17, %21
  store float %22, float* %11, align 4
  %23 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 2
  %24 = load float, float* %18, align 4
  %25 = load float, float* %13, align 4
  %26 = fmul float %24, %25
  %27 = load float, float* %23, align 4
  %28 = fadd float %27, %26
  store float %28, float* %23, align 4
  %29 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 0
  %30 = load float, float* %4, align 4
  %31 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 0
  %32 = load float, float* %31, align 4
  %33 = fmul float %30, %32
  %34 = load float, float* %29, align 4
  %35 = fadd float %34, %33
  store float %35, float* %29, align 4
  %36 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 0
  %37 = load float, float* %36, align 4
  %38 = load float, float* %6, align 4
  %39 = fmul float %37, %38
  %40 = fadd float %35, %39
  store float %40, float* %29, align 4
  %41 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 1
  %42 = load float, float* %4, align 4
  %43 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %44 = load float, float* %43, align 4
  %45 = fmul float %42, %44
  %46 = load float, float* %41, align 4
  %47 = fadd float %46, %45
  store float %47, float* %41, align 4
  %48 = load float, float* %18, align 4
  %49 = load float, float* %31, align 4
  %50 = fmul float %48, %49
  %51 = fadd float %47, %50
  store float %51, float* %41, align 4
  %52 = load float, float* %36, align 4
  %53 = load float, float* %13, align 4
  %54 = fmul float %52, %53
  %55 = fadd float %51, %54
  store float %55, float* %41, align 4
  %56 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 1
  %57 = load float, float* %56, align 4
  %58 = load float, float* %6, align 4
  %59 = fmul float %57, %58
  %60 = fadd float %55, %59
  store float %60, float* %41, align 4
  %61 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 2
  %62 = load float, float* %18, align 4
  %63 = load float, float* %43, align 4
  %64 = fmul float %62, %63
  %65 = load float, float* %61, align 4
  %66 = fadd float %65, %64
  store float %66, float* %61, align 4
  %67 = load float, float* %56, align 4
  %68 = load float, float* %13, align 4
  %69 = fmul float %67, %68
  %70 = fadd float %66, %69
  store float %70, float* %61, align 4
  %71 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 0
  %72 = load float, float* %36, align 4
  %73 = load float, float* %31, align 4
  %74 = fmul float %72, %73
  %75 = load float, float* %71, align 4
  %76 = fadd float %75, %74
  store float %76, float* %71, align 4
  %77 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 1
  %78 = load float, float* %36, align 4
  %79 = load float, float* %43, align 4
  %80 = fmul float %78, %79
  %81 = load float, float* %77, align 4
  %82 = fadd float %81, %80
  store float %82, float* %77, align 4
  %83 = load float, float* %56, align 4
  %84 = load float, float* %31, align 4
  %85 = fmul float %83, %84
  %86 = fadd float %82, %85
  store float %86, float* %77, align 4
  %87 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 2
  %88 = load float, float* %56, align 4
  %89 = load float, float* %43, align 4
  %90 = fmul float %88, %89
  %91 = load float, float* %87, align 4
  %92 = fadd float %91, %90
  store float %92, float* %87, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
.preheader:
  %0 = alloca [2 x [2 x float]], align 16
  %1 = alloca [2 x [2 x float]], align 16
  %2 = alloca [3 x [3 x float]], align 16
  %3 = bitcast [2 x [2 x float]]* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %3, i8* nonnull align 16 dereferenceable(16) bitcast ([2 x [2 x float]]* @__const.main.mat_in to i8*), i64 16, i1 false)
  %4 = bitcast [2 x [2 x float]]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %4, i8* nonnull align 16 dereferenceable(16) bitcast ([2 x [2 x float]]* @__const.main.f_in to i8*), i64 16, i1 false)
  %5 = bitcast [3 x [3 x float]]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(36) %5, i8 0, i64 36, i1 false)
  %6 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %0, i64 0, i64 0
  %7 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0
  call void @convolution([2 x float]* nonnull %6, [2 x float]* nonnull %7, [3 x float]* nonnull %8)
  %9 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0, i64 0
  %10 = load float, float* %9, align 16
  %11 = fpext float %10 to double
  %12 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %11) #4
  %13 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0, i64 1
  %14 = load float, float* %13, align 4
  %15 = fpext float %14 to double
  %16 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %15) #4
  %17 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0, i64 2
  %18 = load float, float* %17, align 8
  %19 = fpext float %18 to double
  %20 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %19) #4
  %21 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 1, i64 0
  %22 = load float, float* %21, align 4
  %23 = fpext float %22 to double
  %24 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %23) #4
  %25 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 1, i64 1
  %26 = load float, float* %25, align 4
  %27 = fpext float %26 to double
  %28 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %27) #4
  %29 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 1, i64 2
  %30 = load float, float* %29, align 4
  %31 = fpext float %30 to double
  %32 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %31) #4
  %33 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 2, i64 0
  %34 = load float, float* %33, align 8
  %35 = fpext float %34 to double
  %36 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %35) #4
  %37 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 2, i64 1
  %38 = load float, float* %37, align 4
  %39 = fpext float %38 to double
  %40 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %39) #4
  %41 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 2, i64 2
  %42 = load float, float* %41, align 8
  %43 = fpext float %42 to double
  %44 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %43) #4
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

declare i32 @printf(i8*, ...) #3

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn writeonly }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
