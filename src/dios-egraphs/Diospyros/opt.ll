; ModuleID = 'clang.ll'
source_filename = "llvm-tests/stencil-2d.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.orig_in = private unnamed_addr constant [32 x float] [float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00], align 16
@__const.main.sol_out = private unnamed_addr constant [32 x float] [float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00], align 16
@__const.main.filter_in = private unnamed_addr constant [9 x float] [float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @stencil(float* %0, float* %1, float* %2) #0 {
  br label %4

4:                                                ; preds = %5, %3
  %indvars.iv11 = phi i64 [ %indvars.iv.next12, %5 ], [ 0, %3 ]
  %exitcond13 = icmp ne i64 %indvars.iv11, 6
  br i1 %exitcond13, label %5, label %141

5:                                                ; preds = %4
  %6 = mul nuw nsw i64 %indvars.iv11, 4
  %7 = mul nuw nsw i64 %indvars.iv11, 4
  %8 = load float, float* %2, align 4
  %9 = getelementptr inbounds float, float* %0, i64 %7
  %10 = load float, float* %9, align 4
  %11 = fmul float %8, %10
  %12 = fadd float 0.000000e+00, %11
  %13 = getelementptr inbounds float, float* %2, i64 1
  %14 = load float, float* %13, align 4
  %15 = add nuw nsw i64 %7, 1
  %16 = getelementptr inbounds float, float* %0, i64 %15
  %17 = load float, float* %16, align 4
  %18 = fmul float %14, %17
  %19 = fadd float %12, %18
  %20 = getelementptr inbounds float, float* %2, i64 2
  %21 = load float, float* %20, align 4
  %22 = add nuw nsw i64 %7, 2
  %23 = getelementptr inbounds float, float* %0, i64 %22
  %24 = load float, float* %23, align 4
  %25 = fmul float %21, %24
  %26 = fadd float %19, %25
  %27 = add nuw nsw i64 %indvars.iv11, 1
  %28 = mul nuw nsw i64 %27, 4
  %29 = getelementptr inbounds float, float* %2, i64 3
  %30 = load float, float* %29, align 4
  %31 = getelementptr inbounds float, float* %0, i64 %28
  %32 = load float, float* %31, align 4
  %33 = fmul float %30, %32
  %34 = fadd float %26, %33
  %35 = getelementptr inbounds float, float* %2, i64 4
  %36 = load float, float* %35, align 4
  %37 = add nuw nsw i64 %28, 1
  %38 = getelementptr inbounds float, float* %0, i64 %37
  %39 = load float, float* %38, align 4
  %40 = fmul float %36, %39
  %41 = fadd float %34, %40
  %42 = getelementptr inbounds float, float* %2, i64 5
  %43 = load float, float* %42, align 4
  %44 = add nuw nsw i64 %28, 2
  %45 = getelementptr inbounds float, float* %0, i64 %44
  %46 = load float, float* %45, align 4
  %47 = fmul float %43, %46
  %48 = fadd float %41, %47
  %49 = add nuw nsw i64 %indvars.iv11, 2
  %50 = mul nuw nsw i64 %49, 4
  %51 = getelementptr inbounds float, float* %2, i64 6
  %52 = load float, float* %51, align 4
  %53 = getelementptr inbounds float, float* %0, i64 %50
  %54 = load float, float* %53, align 4
  %55 = fmul float %52, %54
  %56 = fadd float %48, %55
  %57 = getelementptr inbounds float, float* %2, i64 7
  %58 = load float, float* %57, align 4
  %59 = add nuw nsw i64 %50, 1
  %60 = getelementptr inbounds float, float* %0, i64 %59
  %61 = load float, float* %60, align 4
  %62 = fmul float %58, %61
  %63 = fadd float %56, %62
  %64 = getelementptr inbounds float, float* %2, i64 8
  %65 = load float, float* %64, align 4
  %66 = add nuw nsw i64 %50, 2
  %67 = getelementptr inbounds float, float* %0, i64 %66
  %68 = load float, float* %67, align 4
  %69 = fmul float %65, %68
  %70 = fadd float %63, %69
  %71 = getelementptr inbounds float, float* %1, i64 %6
  store float %70, float* %71, align 4
  %72 = mul nuw nsw i64 %indvars.iv11, 4
  %73 = add nuw nsw i64 %72, 1
  %74 = load float, float* %2, align 4
  %75 = getelementptr inbounds float, float* %0, i64 %73
  %76 = load float, float* %75, align 4
  %77 = fmul float %74, %76
  %78 = fadd float 0.000000e+00, %77
  %79 = getelementptr inbounds float, float* %2, i64 1
  %80 = load float, float* %79, align 4
  %81 = add nuw nsw i64 %73, 1
  %82 = getelementptr inbounds float, float* %0, i64 %81
  %83 = load float, float* %82, align 4
  %84 = fmul float %80, %83
  %85 = fadd float %78, %84
  %86 = getelementptr inbounds float, float* %2, i64 2
  %87 = load float, float* %86, align 4
  %88 = add nuw nsw i64 %73, 2
  %89 = getelementptr inbounds float, float* %0, i64 %88
  %90 = load float, float* %89, align 4
  %91 = fmul float %87, %90
  %92 = fadd float %85, %91
  %93 = add nuw nsw i64 %indvars.iv11, 1
  %94 = mul nuw nsw i64 %93, 4
  %95 = add nuw nsw i64 %94, 1
  %96 = getelementptr inbounds float, float* %2, i64 3
  %97 = load float, float* %96, align 4
  %98 = getelementptr inbounds float, float* %0, i64 %95
  %99 = load float, float* %98, align 4
  %100 = fmul float %97, %99
  %101 = fadd float %92, %100
  %102 = getelementptr inbounds float, float* %2, i64 4
  %103 = load float, float* %102, align 4
  %104 = add nuw nsw i64 %95, 1
  %105 = getelementptr inbounds float, float* %0, i64 %104
  %106 = load float, float* %105, align 4
  %107 = fmul float %103, %106
  %108 = fadd float %101, %107
  %109 = getelementptr inbounds float, float* %2, i64 5
  %110 = load float, float* %109, align 4
  %111 = add nuw nsw i64 %95, 2
  %112 = getelementptr inbounds float, float* %0, i64 %111
  %113 = load float, float* %112, align 4
  %114 = fmul float %110, %113
  %115 = fadd float %108, %114
  %116 = add nuw nsw i64 %indvars.iv11, 2
  %117 = mul nuw nsw i64 %116, 4
  %118 = add nuw nsw i64 %117, 1
  %119 = getelementptr inbounds float, float* %2, i64 6
  %120 = load float, float* %119, align 4
  %121 = getelementptr inbounds float, float* %0, i64 %118
  %122 = load float, float* %121, align 4
  %123 = fmul float %120, %122
  %124 = fadd float %115, %123
  %125 = getelementptr inbounds float, float* %2, i64 7
  %126 = load float, float* %125, align 4
  %127 = add nuw nsw i64 %118, 1
  %128 = getelementptr inbounds float, float* %0, i64 %127
  %129 = load float, float* %128, align 4
  %130 = fmul float %126, %129
  %131 = fadd float %124, %130
  %132 = getelementptr inbounds float, float* %2, i64 8
  %133 = load float, float* %132, align 4
  %134 = add nuw nsw i64 %118, 2
  %135 = getelementptr inbounds float, float* %0, i64 %134
  %136 = load float, float* %135, align 4
  %137 = fmul float %133, %136
  %138 = fadd float %131, %137
  %139 = add nuw nsw i64 %6, 1
  %140 = getelementptr inbounds float, float* %1, i64 %139
  store float %138, float* %140, align 4
  %indvars.iv.next12 = add nuw nsw i64 %indvars.iv11, 1
  br label %4

141:                                              ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [32 x float], align 16
  %2 = alloca [32 x float], align 16
  %3 = alloca [9 x float], align 16
  %4 = bitcast [32 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %4, i8* align 16 bitcast ([32 x float]* @__const.main.orig_in to i8*), i64 128, i1 false)
  %5 = bitcast [32 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %5, i8* align 16 bitcast ([32 x float]* @__const.main.sol_out to i8*), i64 128, i1 false)
  %6 = bitcast [9 x float]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %6, i8* align 16 bitcast ([9 x float]* @__const.main.filter_in to i8*), i64 36, i1 false)
  %7 = getelementptr inbounds [32 x float], [32 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [32 x float], [32 x float]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 0
  call void @stencil(float* %7, float* %8, float* %9)
  br label %10

10:                                               ; preds = %11, %0
  %indvars.iv = phi i64 [ %indvars.iv.next, %11 ], [ 0, %0 ]
  %exitcond = icmp ne i64 %indvars.iv, 32
  br i1 %exitcond, label %11, label %16

11:                                               ; preds = %10
  %12 = getelementptr inbounds [32 x float], [32 x float]* %2, i64 0, i64 %indvars.iv
  %13 = load float, float* %12, align 4
  %14 = fpext float %13 to double
  %15 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %14)
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  br label %10

16:                                               ; preds = %10
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

declare i32 @printf(i8*, ...) #2

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
