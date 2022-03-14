; ModuleID = 'build/aa.ll'
source_filename = "fail-tests/qr-decomp-local-arrays.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@.str = private unnamed_addr constant [14 x i8] c"Q Output: %f\0A\00", align 1
@.str.1 = private unnamed_addr constant [23 x i8] c"Expected Q Output: %f\0A\00", align 1
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str.2 = private unnamed_addr constant [36 x i8] c"fail-tests/qr-decomp-local-arrays.c\00", align 1
@.str.3 = private unnamed_addr constant [34 x i8] c"fabs(expectedQ[i] - Q[i]) < DELTA\00", align 1
@.str.4 = private unnamed_addr constant [14 x i8] c"R Output: %f\0A\00", align 1
@.str.5 = private unnamed_addr constant [23 x i8] c"Expected R Output: %f\0A\00", align 1
@.str.6 = private unnamed_addr constant [34 x i8] c"fabs(expectedR[i] - R[i]) < DELTA\00", align 1

; Function Attrs: alwaysinline nounwind ssp uwtable
define float @sgn(float %0) #0 {
  %2 = fcmp ogt float %0, 0.000000e+00
  %3 = zext i1 %2 to i32
  %4 = fcmp olt float %0, 0.000000e+00
  %.neg = sext i1 %4 to i32
  %5 = add nsw i32 %.neg, %3
  %6 = sitofp i32 %5 to float
  ret float %6
}

; Function Attrs: noinline nounwind ssp uwtable
define float @no_opt_sgn(float %0) #1 {
  %2 = fcmp ogt float %0, 0.000000e+00
  %3 = zext i1 %2 to i32
  %4 = fcmp olt float %0, 0.000000e+00
  %.neg = sext i1 %4 to i32
  %5 = add nsw i32 %.neg, %3
  %6 = sitofp i32 %5 to float
  ret float %6
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define float @naive_norm(float* %0, i32 %1) #0 {
  %3 = icmp sgt i32 %1, 0
  %smax = select i1 %3, i32 %1, i32 0
  %wide.trip.count = zext i32 %smax to i64
  br i1 %3, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %2
  %4 = add nsw i64 %wide.trip.count, -1
  %xtraiter = and i64 %wide.trip.count, 3
  %5 = icmp ult i64 %4, 3
  br i1 %5, label %._crit_edge.unr-lcssa, label %.lr.ph.new

.lr.ph.new:                                       ; preds = %.lr.ph
  %unroll_iter = and i64 %wide.trip.count, 2147483644
  br label %6

6:                                                ; preds = %6, %.lr.ph.new
  %.013 = phi float [ 0.000000e+00, %.lr.ph.new ], [ %22, %6 ]
  %indvars.iv2 = phi i64 [ 0, %.lr.ph.new ], [ %indvars.iv.next.3, %6 ]
  %niter = phi i64 [ %unroll_iter, %.lr.ph.new ], [ %niter.nsub.3, %6 ]
  %7 = getelementptr inbounds float, float* %0, i64 %indvars.iv2
  %8 = load float, float* %7, align 4
  %9 = fmul float %8, %8
  %10 = fadd float %.013, %9
  %indvars.iv.next = or i64 %indvars.iv2, 1
  %11 = getelementptr inbounds float, float* %0, i64 %indvars.iv.next
  %12 = load float, float* %11, align 4
  %13 = fmul float %12, %12
  %14 = fadd float %10, %13
  %indvars.iv.next.1 = or i64 %indvars.iv2, 2
  %15 = getelementptr inbounds float, float* %0, i64 %indvars.iv.next.1
  %16 = load float, float* %15, align 4
  %17 = fmul float %16, %16
  %18 = fadd float %14, %17
  %indvars.iv.next.2 = or i64 %indvars.iv2, 3
  %19 = getelementptr inbounds float, float* %0, i64 %indvars.iv.next.2
  %20 = load float, float* %19, align 4
  %21 = fmul float %20, %20
  %22 = fadd float %18, %21
  %indvars.iv.next.3 = add nuw nsw i64 %indvars.iv2, 4
  %niter.nsub.3 = add i64 %niter, -4
  %niter.ncmp.3.not = icmp eq i64 %niter.nsub.3, 0
  br i1 %niter.ncmp.3.not, label %._crit_edge.unr-lcssa, label %6

._crit_edge.unr-lcssa:                            ; preds = %6, %.lr.ph
  %split.ph = phi float [ undef, %.lr.ph ], [ %22, %6 ]
  %.013.unr = phi float [ 0.000000e+00, %.lr.ph ], [ %22, %6 ]
  %indvars.iv2.unr = phi i64 [ 0, %.lr.ph ], [ %indvars.iv.next.3, %6 ]
  %lcmp.mod.not = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod.not, label %._crit_edge, label %.epil.preheader

.epil.preheader:                                  ; preds = %.epil.preheader, %._crit_edge.unr-lcssa
  %.013.epil = phi float [ %26, %.epil.preheader ], [ %.013.unr, %._crit_edge.unr-lcssa ]
  %indvars.iv2.epil = phi i64 [ %indvars.iv.next.epil, %.epil.preheader ], [ %indvars.iv2.unr, %._crit_edge.unr-lcssa ]
  %epil.iter = phi i64 [ %epil.iter.sub, %.epil.preheader ], [ %xtraiter, %._crit_edge.unr-lcssa ]
  %23 = getelementptr inbounds float, float* %0, i64 %indvars.iv2.epil
  %24 = load float, float* %23, align 4
  %25 = fmul float %24, %24
  %26 = fadd float %.013.epil, %25
  %indvars.iv.next.epil = add nuw nsw i64 %indvars.iv2.epil, 1
  %epil.iter.sub = add i64 %epil.iter, -1
  %epil.iter.cmp.not = icmp eq i64 %epil.iter.sub, 0
  br i1 %epil.iter.cmp.not, label %._crit_edge, label %.epil.preheader, !llvm.loop !3

._crit_edge:                                      ; preds = %.epil.preheader, %._crit_edge.unr-lcssa, %2
  %.01.lcssa = phi float [ 0.000000e+00, %2 ], [ %split.ph, %._crit_edge.unr-lcssa ], [ %26, %.epil.preheader ]
  %27 = call float @llvm.sqrt.f32(float %.01.lcssa)
  ret float %27
}

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32(float) #2

; Function Attrs: noinline nounwind ssp uwtable
define float @no_opt_naive_norm(float* %0, i32 %1) #1 {
  %3 = icmp sgt i32 %1, 0
  %smax = select i1 %3, i32 %1, i32 0
  %wide.trip.count = zext i32 %smax to i64
  br i1 %3, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %2
  %4 = add nsw i64 %wide.trip.count, -1
  %xtraiter = and i64 %wide.trip.count, 3
  %5 = icmp ult i64 %4, 3
  br i1 %5, label %._crit_edge.unr-lcssa, label %.lr.ph.new

.lr.ph.new:                                       ; preds = %.lr.ph
  %unroll_iter = and i64 %wide.trip.count, 2147483644
  br label %6

6:                                                ; preds = %6, %.lr.ph.new
  %.013 = phi float [ 0.000000e+00, %.lr.ph.new ], [ %22, %6 ]
  %indvars.iv2 = phi i64 [ 0, %.lr.ph.new ], [ %indvars.iv.next.3, %6 ]
  %niter = phi i64 [ %unroll_iter, %.lr.ph.new ], [ %niter.nsub.3, %6 ]
  %7 = getelementptr inbounds float, float* %0, i64 %indvars.iv2
  %8 = load float, float* %7, align 4
  %9 = fmul float %8, %8
  %10 = fadd float %.013, %9
  %indvars.iv.next = or i64 %indvars.iv2, 1
  %11 = getelementptr inbounds float, float* %0, i64 %indvars.iv.next
  %12 = load float, float* %11, align 4
  %13 = fmul float %12, %12
  %14 = fadd float %10, %13
  %indvars.iv.next.1 = or i64 %indvars.iv2, 2
  %15 = getelementptr inbounds float, float* %0, i64 %indvars.iv.next.1
  %16 = load float, float* %15, align 4
  %17 = fmul float %16, %16
  %18 = fadd float %14, %17
  %indvars.iv.next.2 = or i64 %indvars.iv2, 3
  %19 = getelementptr inbounds float, float* %0, i64 %indvars.iv.next.2
  %20 = load float, float* %19, align 4
  %21 = fmul float %20, %20
  %22 = fadd float %18, %21
  %indvars.iv.next.3 = add nuw nsw i64 %indvars.iv2, 4
  %niter.nsub.3 = add i64 %niter, -4
  %niter.ncmp.3.not = icmp eq i64 %niter.nsub.3, 0
  br i1 %niter.ncmp.3.not, label %._crit_edge.unr-lcssa, label %6

._crit_edge.unr-lcssa:                            ; preds = %6, %.lr.ph
  %split.ph = phi float [ undef, %.lr.ph ], [ %22, %6 ]
  %.013.unr = phi float [ 0.000000e+00, %.lr.ph ], [ %22, %6 ]
  %indvars.iv2.unr = phi i64 [ 0, %.lr.ph ], [ %indvars.iv.next.3, %6 ]
  %lcmp.mod.not = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod.not, label %._crit_edge, label %.epil.preheader

.epil.preheader:                                  ; preds = %.epil.preheader, %._crit_edge.unr-lcssa
  %.013.epil = phi float [ %26, %.epil.preheader ], [ %.013.unr, %._crit_edge.unr-lcssa ]
  %indvars.iv2.epil = phi i64 [ %indvars.iv.next.epil, %.epil.preheader ], [ %indvars.iv2.unr, %._crit_edge.unr-lcssa ]
  %epil.iter = phi i64 [ %epil.iter.sub, %.epil.preheader ], [ %xtraiter, %._crit_edge.unr-lcssa ]
  %23 = getelementptr inbounds float, float* %0, i64 %indvars.iv2.epil
  %24 = load float, float* %23, align 4
  %25 = fmul float %24, %24
  %26 = fadd float %.013.epil, %25
  %indvars.iv.next.epil = add nuw nsw i64 %indvars.iv2.epil, 1
  %epil.iter.sub = add i64 %epil.iter, -1
  %epil.iter.cmp.not = icmp eq i64 %epil.iter.sub, 0
  br i1 %epil.iter.cmp.not, label %._crit_edge, label %.epil.preheader, !llvm.loop !5

._crit_edge:                                      ; preds = %.epil.preheader, %._crit_edge.unr-lcssa, %2
  %.01.lcssa = phi float [ 0.000000e+00, %2 ], [ %split.ph, %._crit_edge.unr-lcssa ], [ %26, %.epil.preheader ]
  %27 = call float @llvm.sqrt.f32(float %.01.lcssa)
  ret float %27
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_fixed_transpose(float* %0) #0 {
.lr.ph:
  %1 = getelementptr inbounds float, float* %0, i64 1
  %2 = bitcast float* %1 to i32*
  %3 = load i32, i32* %2, align 4
  %4 = getelementptr inbounds float, float* %0, i64 2
  %5 = bitcast float* %4 to i32*
  %6 = load i32, i32* %5, align 4
  store i32 %6, i32* %2, align 4
  store i32 %3, i32* %5, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @no_opt_naive_fixed_transpose(float* %0) #1 {
.lr.ph:
  %1 = getelementptr inbounds float, float* %0, i64 1
  %2 = bitcast float* %1 to i32*
  %3 = load i32, i32* %2, align 4
  %4 = getelementptr inbounds float, float* %0, i64 2
  %5 = bitcast float* %4 to i32*
  %6 = load i32, i32* %5, align 4
  store i32 %6, i32* %2, align 4
  store i32 %3, i32* %5, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_fixed_matrix_multiply(float* %0, float* %1, float* %2) #0 {
.preheader:
  %3 = load float, float* %0, align 4
  %4 = load float, float* %1, align 4
  %5 = fmul float %3, %4
  %6 = fadd float %5, 0.000000e+00
  %7 = getelementptr inbounds float, float* %0, i64 1
  %8 = load float, float* %7, align 4
  %9 = getelementptr inbounds float, float* %1, i64 2
  %10 = load float, float* %9, align 4
  %11 = fmul float %8, %10
  %12 = fadd float %6, %11
  %13 = getelementptr inbounds float, float* %2, i64 1
  %14 = load float, float* %0, align 4
  %15 = getelementptr inbounds float, float* %1, i64 1
  %16 = load float, float* %15, align 4
  %17 = fmul float %14, %16
  %18 = fadd float %17, 0.000000e+00
  %19 = load float, float* %7, align 4
  %20 = getelementptr inbounds float, float* %1, i64 3
  %21 = load float, float* %20, align 4
  %22 = fmul float %19, %21
  %23 = fadd float %18, %22
  %24 = getelementptr inbounds float, float* %0, i64 2
  %25 = getelementptr inbounds float, float* %2, i64 2
  %26 = load float, float* %24, align 4
  %27 = load float, float* %1, align 4
  %28 = fmul float %26, %27
  %29 = fadd float %28, 0.000000e+00
  %30 = getelementptr inbounds float, float* %0, i64 3
  %31 = load float, float* %30, align 4
  %32 = load float, float* %9, align 4
  %33 = fmul float %31, %32
  %34 = fadd float %29, %33
  %35 = getelementptr inbounds float, float* %2, i64 3
  %36 = load float, float* %24, align 4
  %37 = load float, float* %15, align 4
  %38 = fmul float %36, %37
  %39 = fadd float %38, 0.000000e+00
  %40 = load float, float* %30, align 4
  %41 = load float, float* %20, align 4
  %42 = fmul float %40, %41
  %43 = fadd float %39, %42
  store float 0.000000e+00, float* %2, align 4
  %44 = getelementptr float, float* %0, i32 0
  %45 = load float, float* %44, align 4
  %46 = insertelement <4 x float> zeroinitializer, float %45, i32 0
  %47 = insertelement <4 x float> %46, float 0.000000e+00, i32 1
  %48 = insertelement <4 x float> %47, float 0.000000e+00, i32 2
  %49 = insertelement <4 x float> %48, float 0.000000e+00, i32 3
  %50 = getelementptr float, float* %1, i32 0
  %51 = load float, float* %50, align 4
  %52 = insertelement <4 x float> zeroinitializer, float %51, i32 0
  %53 = insertelement <4 x float> %52, float 0.000000e+00, i32 1
  %54 = insertelement <4 x float> %53, float 0.000000e+00, i32 2
  %55 = insertelement <4 x float> %54, float 0.000000e+00, i32 3
  %56 = call <4 x float> @llvm.fma.f32(<4 x float> %49, <4 x float> %55, <4 x float> zeroinitializer)
  %57 = extractelement <4 x float> %56, i32 0
  store float %57, float* %2, align 4
  %58 = insertelement <4 x float> zeroinitializer, float %45, i32 0
  %59 = insertelement <4 x float> %58, float 1.000000e+00, i32 1
  %60 = insertelement <4 x float> %59, float 1.000000e+00, i32 2
  %61 = insertelement <4 x float> %60, float 1.000000e+00, i32 3
  %62 = getelementptr float, float* %1, i32 0
  %63 = load float, float* %62, align 4
  %64 = insertelement <4 x float> zeroinitializer, float %63, i32 0
  %65 = insertelement <4 x float> %64, float 0.000000e+00, i32 1
  %66 = insertelement <4 x float> %65, float 0.000000e+00, i32 2
  %67 = insertelement <4 x float> %66, float 0.000000e+00, i32 3
  %68 = fmul <4 x float> %61, %67
  %69 = fadd <4 x float> %68, zeroinitializer
  %70 = getelementptr float, float* %0, i32 0
  %71 = getelementptr inbounds float, float* %70, i64 1
  %72 = load float, float* %71, align 4
  %73 = insertelement <4 x float> zeroinitializer, float %72, i32 0
  %74 = insertelement <4 x float> %73, float 0.000000e+00, i32 1
  %75 = insertelement <4 x float> %74, float 0.000000e+00, i32 2
  %76 = insertelement <4 x float> %75, float 0.000000e+00, i32 3
  %77 = getelementptr float, float* %1, i32 0
  %78 = getelementptr inbounds float, float* %77, i64 2
  %79 = load float, float* %78, align 4
  %80 = insertelement <4 x float> zeroinitializer, float %79, i32 0
  %81 = insertelement <4 x float> %80, float 0.000000e+00, i32 1
  %82 = insertelement <4 x float> %81, float 0.000000e+00, i32 2
  %83 = insertelement <4 x float> %82, float 0.000000e+00, i32 3
  %84 = call <4 x float> @llvm.fma.f32.1(<4 x float> %76, <4 x float> %83, <4 x float> %69)
  %85 = extractelement <4 x float> %84, i32 0
  store float %85, float* %2, align 4
  %86 = extractelement <4 x float> %84, i32 1
  %87 = getelementptr float, float* %2, i32 0
  %88 = getelementptr inbounds float, float* %87, i64 1
  store float %86, float* %88, align 4
  %89 = getelementptr float, float* %0, i32 0
  %90 = load float, float* %89, align 4
  %91 = insertelement <4 x float> zeroinitializer, float %90, i32 0
  %92 = insertelement <4 x float> %91, float 0.000000e+00, i32 1
  %93 = insertelement <4 x float> %92, float 0.000000e+00, i32 2
  %94 = insertelement <4 x float> %93, float 0.000000e+00, i32 3
  %95 = getelementptr float, float* %1, i32 0
  %96 = getelementptr inbounds float, float* %95, i64 1
  %97 = load float, float* %96, align 4
  %98 = insertelement <4 x float> zeroinitializer, float %97, i32 0
  %99 = insertelement <4 x float> %98, float 0.000000e+00, i32 1
  %100 = insertelement <4 x float> %99, float 0.000000e+00, i32 2
  %101 = insertelement <4 x float> %100, float 0.000000e+00, i32 3
  %102 = call <4 x float> @llvm.fma.f32.2(<4 x float> %94, <4 x float> %101, <4 x float> zeroinitializer)
  %103 = extractelement <4 x float> %102, i32 0
  %104 = getelementptr float, float* %2, i32 0
  %105 = getelementptr inbounds float, float* %104, i64 1
  store float %103, float* %105, align 4
  %106 = insertelement <4 x float> zeroinitializer, float %90, i32 0
  %107 = insertelement <4 x float> %106, float 1.000000e+00, i32 1
  %108 = insertelement <4 x float> %107, float 1.000000e+00, i32 2
  %109 = insertelement <4 x float> %108, float 1.000000e+00, i32 3
  %110 = load float, float* %96, align 4
  %111 = insertelement <4 x float> zeroinitializer, float %110, i32 0
  %112 = insertelement <4 x float> %111, float 0.000000e+00, i32 1
  %113 = insertelement <4 x float> %112, float 0.000000e+00, i32 2
  %114 = insertelement <4 x float> %113, float 0.000000e+00, i32 3
  %115 = fmul <4 x float> %109, %114
  %116 = fadd <4 x float> %115, zeroinitializer
  %117 = getelementptr float, float* %0, i32 0
  %118 = getelementptr inbounds float, float* %117, i64 1
  %119 = load float, float* %118, align 4
  %120 = insertelement <4 x float> zeroinitializer, float %119, i32 0
  %121 = insertelement <4 x float> %120, float 0.000000e+00, i32 1
  %122 = insertelement <4 x float> %121, float 0.000000e+00, i32 2
  %123 = insertelement <4 x float> %122, float 0.000000e+00, i32 3
  %124 = getelementptr float, float* %1, i32 0
  %125 = getelementptr inbounds float, float* %124, i64 3
  %126 = load float, float* %125, align 4
  %127 = insertelement <4 x float> zeroinitializer, float %126, i32 0
  %128 = insertelement <4 x float> %127, float 0.000000e+00, i32 1
  %129 = insertelement <4 x float> %128, float 0.000000e+00, i32 2
  %130 = insertelement <4 x float> %129, float 0.000000e+00, i32 3
  %131 = call <4 x float> @llvm.fma.f32.3(<4 x float> %123, <4 x float> %130, <4 x float> %116)
  %132 = extractelement <4 x float> %131, i32 0
  %133 = getelementptr float, float* %2, i32 0
  %134 = getelementptr inbounds float, float* %133, i64 1
  store float %132, float* %134, align 4
  %135 = extractelement <4 x float> %131, i32 1
  %136 = getelementptr float, float* %2, i32 0
  %137 = getelementptr inbounds float, float* %136, i64 2
  store float %135, float* %137, align 4
  %138 = getelementptr float, float* %0, i32 0
  %139 = getelementptr inbounds float, float* %138, i64 2
  %140 = load float, float* %139, align 4
  %141 = insertelement <4 x float> zeroinitializer, float %140, i32 0
  %142 = insertelement <4 x float> %141, float 0.000000e+00, i32 1
  %143 = insertelement <4 x float> %142, float 0.000000e+00, i32 2
  %144 = insertelement <4 x float> %143, float 0.000000e+00, i32 3
  %145 = getelementptr float, float* %1, i32 0
  %146 = load float, float* %145, align 4
  %147 = insertelement <4 x float> zeroinitializer, float %146, i32 0
  %148 = insertelement <4 x float> %147, float 0.000000e+00, i32 1
  %149 = insertelement <4 x float> %148, float 0.000000e+00, i32 2
  %150 = insertelement <4 x float> %149, float 0.000000e+00, i32 3
  %151 = call <4 x float> @llvm.fma.f32.4(<4 x float> %144, <4 x float> %150, <4 x float> zeroinitializer)
  %152 = extractelement <4 x float> %151, i32 0
  %153 = getelementptr float, float* %2, i32 0
  %154 = getelementptr inbounds float, float* %153, i64 2
  store float %152, float* %154, align 4
  %155 = insertelement <4 x float> zeroinitializer, float %140, i32 0
  %156 = insertelement <4 x float> %155, float 1.000000e+00, i32 1
  %157 = insertelement <4 x float> %156, float 1.000000e+00, i32 2
  %158 = insertelement <4 x float> %157, float 1.000000e+00, i32 3
  %159 = insertelement <4 x float> zeroinitializer, float %146, i32 0
  %160 = insertelement <4 x float> %159, float 0.000000e+00, i32 1
  %161 = insertelement <4 x float> %160, float 0.000000e+00, i32 2
  %162 = insertelement <4 x float> %161, float 0.000000e+00, i32 3
  %163 = fmul <4 x float> %158, %162
  %164 = fadd <4 x float> %163, zeroinitializer
  %165 = getelementptr float, float* %0, i32 0
  %166 = getelementptr inbounds float, float* %165, i64 3
  %167 = load float, float* %166, align 4
  %168 = insertelement <4 x float> zeroinitializer, float %167, i32 0
  %169 = insertelement <4 x float> %168, float 0.000000e+00, i32 1
  %170 = insertelement <4 x float> %169, float 0.000000e+00, i32 2
  %171 = insertelement <4 x float> %170, float 0.000000e+00, i32 3
  %172 = load float, float* %78, align 4
  %173 = insertelement <4 x float> zeroinitializer, float %172, i32 0
  %174 = insertelement <4 x float> %173, float 0.000000e+00, i32 1
  %175 = insertelement <4 x float> %174, float 0.000000e+00, i32 2
  %176 = insertelement <4 x float> %175, float 0.000000e+00, i32 3
  %177 = call <4 x float> @llvm.fma.f32.5(<4 x float> %171, <4 x float> %176, <4 x float> %164)
  %178 = extractelement <4 x float> %177, i32 0
  store float %178, float* %154, align 4
  %179 = extractelement <4 x float> %177, i32 1
  %180 = getelementptr float, float* %2, i32 0
  %181 = getelementptr inbounds float, float* %180, i64 3
  store float %179, float* %181, align 4
  %182 = load float, float* %139, align 4
  %183 = insertelement <4 x float> zeroinitializer, float %182, i32 0
  %184 = insertelement <4 x float> %183, float 0.000000e+00, i32 1
  %185 = insertelement <4 x float> %184, float 0.000000e+00, i32 2
  %186 = insertelement <4 x float> %185, float 0.000000e+00, i32 3
  %187 = load float, float* %96, align 4
  %188 = insertelement <4 x float> zeroinitializer, float %187, i32 0
  %189 = insertelement <4 x float> %188, float 0.000000e+00, i32 1
  %190 = insertelement <4 x float> %189, float 0.000000e+00, i32 2
  %191 = insertelement <4 x float> %190, float 0.000000e+00, i32 3
  %192 = call <4 x float> @llvm.fma.f32.6(<4 x float> %186, <4 x float> %191, <4 x float> zeroinitializer)
  %193 = extractelement <4 x float> %192, i32 0
  store float %193, float* %181, align 4
  %194 = insertelement <4 x float> zeroinitializer, float %182, i32 0
  %195 = insertelement <4 x float> %194, float 1.000000e+00, i32 1
  %196 = insertelement <4 x float> %195, float 1.000000e+00, i32 2
  %197 = insertelement <4 x float> %196, float 1.000000e+00, i32 3
  %198 = insertelement <4 x float> zeroinitializer, float %187, i32 0
  %199 = insertelement <4 x float> %198, float 0.000000e+00, i32 1
  %200 = insertelement <4 x float> %199, float 0.000000e+00, i32 2
  %201 = insertelement <4 x float> %200, float 0.000000e+00, i32 3
  %202 = fmul <4 x float> %197, %201
  %203 = fadd <4 x float> %202, zeroinitializer
  %204 = getelementptr float, float* %0, i32 0
  %205 = getelementptr inbounds float, float* %204, i64 3
  %206 = load float, float* %205, align 4
  %207 = insertelement <4 x float> zeroinitializer, float %206, i32 0
  %208 = insertelement <4 x float> %207, float 0.000000e+00, i32 1
  %209 = insertelement <4 x float> %208, float 0.000000e+00, i32 2
  %210 = insertelement <4 x float> %209, float 0.000000e+00, i32 3
  %211 = load float, float* %125, align 4
  %212 = insertelement <4 x float> zeroinitializer, float %211, i32 0
  %213 = insertelement <4 x float> %212, float 0.000000e+00, i32 1
  %214 = insertelement <4 x float> %213, float 0.000000e+00, i32 2
  %215 = insertelement <4 x float> %214, float 0.000000e+00, i32 3
  %216 = call <4 x float> @llvm.fma.f32.7(<4 x float> %210, <4 x float> %215, <4 x float> %203)
  %217 = extractelement <4 x float> %216, i32 0
  store float %217, float* %181, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @no_opt_naive_fixed_matrix_multiply(float* %0, float* %1, float* %2) #1 {
.preheader:
  store float 0.000000e+00, float* %2, align 4
  %3 = load float, float* %0, align 4
  %4 = load float, float* %1, align 4
  %5 = fmul float %3, %4
  %6 = fadd float %5, 0.000000e+00
  store float %6, float* %2, align 4
  %7 = getelementptr inbounds float, float* %0, i64 1
  %8 = load float, float* %7, align 4
  %9 = getelementptr inbounds float, float* %1, i64 2
  %10 = load float, float* %9, align 4
  %11 = fmul float %8, %10
  %12 = fadd float %6, %11
  store float %12, float* %2, align 4
  %13 = getelementptr inbounds float, float* %2, i64 1
  store float 0.000000e+00, float* %13, align 4
  %14 = load float, float* %0, align 4
  %15 = getelementptr inbounds float, float* %1, i64 1
  %16 = load float, float* %15, align 4
  %17 = fmul float %14, %16
  %18 = fadd float %17, 0.000000e+00
  store float %18, float* %13, align 4
  %19 = load float, float* %7, align 4
  %20 = getelementptr inbounds float, float* %1, i64 3
  %21 = load float, float* %20, align 4
  %22 = fmul float %19, %21
  %23 = fadd float %18, %22
  store float %23, float* %13, align 4
  %24 = getelementptr inbounds float, float* %0, i64 2
  %25 = getelementptr inbounds float, float* %2, i64 2
  store float 0.000000e+00, float* %25, align 4
  %26 = load float, float* %24, align 4
  %27 = load float, float* %1, align 4
  %28 = fmul float %26, %27
  %29 = fadd float %28, 0.000000e+00
  store float %29, float* %25, align 4
  %30 = getelementptr inbounds float, float* %0, i64 3
  %31 = load float, float* %30, align 4
  %32 = load float, float* %9, align 4
  %33 = fmul float %31, %32
  %34 = fadd float %29, %33
  store float %34, float* %25, align 4
  %35 = getelementptr inbounds float, float* %2, i64 3
  store float 0.000000e+00, float* %35, align 4
  %36 = load float, float* %24, align 4
  %37 = load float, float* %15, align 4
  %38 = fmul float %36, %37
  %39 = fadd float %38, 0.000000e+00
  store float %39, float* %35, align 4
  %40 = load float, float* %30, align 4
  %41 = load float, float* %20, align 4
  %42 = fmul float %40, %41
  %43 = fadd float %39, %42
  store float %43, float* %35, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @naive_fixed_qr_decomp(float* %0, float* %1, float* %2) #1 {
.preheader49:
  %3 = bitcast float* %1 to i8*
  %4 = alloca [4 x float], align 16
  %5 = bitcast [4 x float]* %4 to i8*
  %6 = bitcast float* %0 to i32*
  %7 = load i32, i32* %6, align 4
  %8 = bitcast float* %2 to i32*
  %9 = getelementptr inbounds float, float* %0, i64 1
  %10 = bitcast float* %9 to i32*
  %11 = load i32, i32* %10, align 4
  %12 = getelementptr inbounds float, float* %2, i64 1
  %13 = bitcast float* %12 to i32*
  %14 = getelementptr inbounds float, float* %0, i64 2
  %15 = bitcast float* %14 to i32*
  %16 = load i32, i32* %15, align 4
  %17 = getelementptr inbounds float, float* %2, i64 2
  %18 = bitcast float* %17 to i32*
  %19 = getelementptr inbounds float, float* %0, i64 3
  %20 = bitcast float* %19 to i32*
  %21 = load i32, i32* %20, align 4
  %22 = getelementptr inbounds float, float* %2, i64 3
  %23 = bitcast float* %22 to i32*
  %24 = bitcast i32 %7 to float
  %25 = fcmp ogt float %24, 0.000000e+00
  %26 = zext i1 %25 to i32
  %27 = fcmp olt float %24, 0.000000e+00
  %.neg = sext i1 %27 to i32
  %28 = add nsw i32 %.neg, %26
  %29 = sitofp i32 %28 to float
  %30 = fmul float %24, %24
  %31 = fadd float %30, 0.000000e+00
  %32 = bitcast i32 %16 to float
  %33 = fmul float %32, %32
  %34 = fadd float %31, %33
  %35 = call float @llvm.sqrt.f32(float %34) #9
  %36 = fneg float %29
  %37 = fmul float %35, %36
  %38 = fadd float %24, %37
  %39 = fmul float %37, 0.000000e+00
  %40 = fadd float %32, %39
  %41 = fmul float %38, %38
  %42 = fadd float %41, 0.000000e+00
  %43 = fmul float %40, %40
  %44 = fadd float %42, %43
  %45 = call float @llvm.sqrt.f32(float %44) #9
  %46 = fadd float %45, 0x3EE4F8B580000000
  %47 = fdiv float %38, %46
  %48 = fdiv float %40, %46
  %49 = fmul float %47, 2.000000e+00
  %50 = fmul float %49, %47
  %51 = fsub float 1.000000e+00, %50
  %52 = fmul float %49, %48
  %53 = fsub float 0.000000e+00, %52
  %54 = fmul float %48, 2.000000e+00
  %55 = fmul float %54, %47
  %56 = fsub float 0.000000e+00, %55
  %57 = fmul float %54, %48
  %58 = fsub float 1.000000e+00, %57
  %59 = bitcast float %51 to i32
  %60 = bitcast [4 x float]* %4 to i32*
  %61 = bitcast float %53 to i32
  %62 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 1
  %63 = bitcast float* %62 to i32*
  %64 = bitcast float %56 to i32
  %65 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 2
  %66 = bitcast float* %65 to i32*
  %67 = bitcast float %58 to i32
  %68 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 3
  %69 = bitcast float* %68 to i32*
  %70 = load float, float* %0, align 4
  %71 = fmul float %51, %70
  %72 = fadd float %71, 0.000000e+00
  %73 = load float, float* %14, align 4
  %74 = fmul float %53, %73
  %75 = fadd float %72, %74
  %76 = load float, float* %9, align 4
  %77 = fmul float %51, %76
  %78 = fadd float %77, 0.000000e+00
  %79 = load float, float* %19, align 4
  %80 = fmul float %53, %79
  %81 = fadd float %78, %80
  %82 = load float, float* %0, align 4
  %83 = fmul float %56, %82
  %84 = fadd float %83, 0.000000e+00
  %85 = load float, float* %14, align 4
  %86 = fmul float %58, %85
  %87 = fadd float %84, %86
  %88 = load float, float* %9, align 4
  %89 = fmul float %56, %88
  %90 = fadd float %89, 0.000000e+00
  %91 = load float, float* %19, align 4
  %92 = fmul float %58, %91
  %93 = fadd float %90, %92
  %94 = getelementptr inbounds float, float* %1, i64 1
  %95 = bitcast float* %94 to i32*
  %96 = load i32, i32* %95, align 4
  %97 = getelementptr inbounds float, float* %1, i64 2
  %98 = bitcast float* %97 to i32*
  %99 = load i32, i32* %98, align 4
  %100 = getelementptr float, float* %0, i32 0
  %101 = bitcast float* %100 to i32*
  %102 = load i32, i32* %101, align 4
  %103 = bitcast i32 %102 to float
  %104 = insertelement <4 x float> zeroinitializer, float %103, i32 0
  %105 = insertelement <4 x float> %104, float 0.000000e+00, i32 1
  %106 = insertelement <4 x float> %105, float 0.000000e+00, i32 2
  %107 = insertelement <4 x float> %106, float 0.000000e+00, i32 3
  %108 = extractelement <4 x float> %107, i32 0
  %109 = bitcast i32* %8 to float*
  %110 = getelementptr float, float* %2, i32 0
  %111 = bitcast float* %110 to i32*
  %112 = bitcast i32* %111 to float*
  store float %108, float* %112, align 4
  %113 = getelementptr float, float* %0, i32 0
  %114 = getelementptr inbounds float, float* %113, i64 1
  %115 = bitcast float* %114 to i32*
  %116 = load i32, i32* %115, align 4
  %117 = bitcast i32 %116 to float
  %118 = insertelement <4 x float> zeroinitializer, float %117, i32 0
  %119 = insertelement <4 x float> %118, float 0.000000e+00, i32 1
  %120 = insertelement <4 x float> %119, float 0.000000e+00, i32 2
  %121 = insertelement <4 x float> %120, float 0.000000e+00, i32 3
  %122 = extractelement <4 x float> %121, i32 0
  %123 = bitcast i32* %13 to float*
  %124 = getelementptr float, float* %2, i32 0
  %125 = getelementptr inbounds float, float* %124, i64 1
  %126 = bitcast float* %125 to i32*
  %127 = bitcast i32* %126 to float*
  store float %122, float* %127, align 4
  %128 = getelementptr float, float* %0, i32 0
  %129 = getelementptr inbounds float, float* %128, i64 2
  %130 = bitcast float* %129 to i32*
  %131 = load i32, i32* %130, align 4
  %132 = bitcast i32 %131 to float
  %133 = insertelement <4 x float> zeroinitializer, float %132, i32 0
  %134 = insertelement <4 x float> %133, float 0.000000e+00, i32 1
  %135 = insertelement <4 x float> %134, float 0.000000e+00, i32 2
  %136 = insertelement <4 x float> %135, float 0.000000e+00, i32 3
  %137 = extractelement <4 x float> %136, i32 0
  %138 = bitcast i32* %18 to float*
  %139 = getelementptr float, float* %2, i32 0
  %140 = getelementptr inbounds float, float* %139, i64 2
  %141 = bitcast float* %140 to i32*
  %142 = bitcast i32* %141 to float*
  store float %137, float* %142, align 4
  %143 = getelementptr float, float* %0, i32 0
  %144 = getelementptr inbounds float, float* %143, i64 3
  %145 = bitcast float* %144 to i32*
  %146 = load i32, i32* %145, align 4
  %147 = bitcast i32 %146 to float
  %148 = fneg float %147
  %149 = insertelement <4 x float> zeroinitializer, float %148, i32 0
  %150 = getelementptr float, float* %0, i32 0
  %151 = bitcast float* %150 to i32*
  %152 = load i32, i32* %151, align 4
  %153 = bitcast i32 %152 to float
  %154 = bitcast i32 %152 to float
  %155 = fmul float %153, %154
  %156 = fadd float %155, 0.000000e+00
  %157 = bitcast i32 %131 to float
  %158 = bitcast i32 %131 to float
  %159 = fmul float %157, %158
  %160 = fadd float %156, %159
  %161 = call float @llvm.sqrt.f32.8(float %160)
  %162 = bitcast i32 %152 to float
  %163 = fcmp olt float %162, 0.000000e+00
  %164 = sext i1 %163 to i32
  %165 = fcmp ogt float %162, 0.000000e+00
  %166 = zext i1 %165 to i32
  %167 = add nsw i32 %164, %166
  %168 = sitofp i32 %167 to float
  %169 = fneg float %168
  %170 = fmul float %161, %169
  %171 = bitcast i32 %152 to float
  %172 = fadd float %171, %170
  %173 = bitcast i32 %152 to float
  %174 = bitcast i32 %152 to float
  %175 = fmul float %173, %174
  %176 = fadd float %175, 0.000000e+00
  %177 = bitcast i32 %131 to float
  %178 = bitcast i32 %131 to float
  %179 = fmul float %177, %178
  %180 = fadd float %176, %179
  %181 = call float @llvm.sqrt.f32.9(float %180)
  %182 = fneg float %168
  %183 = fmul float %181, %182
  %184 = bitcast i32 %152 to float
  %185 = fadd float %184, %183
  %186 = bitcast i32 %152 to float
  %187 = bitcast i32 %152 to float
  %188 = fmul float %186, %187
  %189 = fadd float %188, 0.000000e+00
  %190 = bitcast i32 %131 to float
  %191 = bitcast i32 %131 to float
  %192 = fmul float %190, %191
  %193 = fadd float %189, %192
  %194 = call float @llvm.sqrt.f32.10(float %193)
  %195 = fneg float %168
  %196 = fmul float %194, %195
  %197 = bitcast i32 %152 to float
  %198 = fadd float %197, %196
  %199 = fmul float %185, %198
  %200 = fadd float %199, 0.000000e+00
  %201 = bitcast i32 %152 to float
  %202 = bitcast i32 %152 to float
  %203 = fmul float %201, %202
  %204 = fadd float %203, 0.000000e+00
  %205 = bitcast i32 %131 to float
  %206 = bitcast i32 %131 to float
  %207 = fmul float %205, %206
  %208 = fadd float %204, %207
  %209 = call float @llvm.sqrt.f32.11(float %208)
  %210 = fneg float %168
  %211 = fmul float %209, %210
  %212 = fmul float %211, 0.000000e+00
  %213 = bitcast i32 %131 to float
  %214 = fadd float %213, %212
  %215 = bitcast i32 %152 to float
  %216 = bitcast i32 %152 to float
  %217 = fmul float %215, %216
  %218 = fadd float %217, 0.000000e+00
  %219 = bitcast i32 %131 to float
  %220 = bitcast i32 %131 to float
  %221 = fmul float %219, %220
  %222 = fadd float %218, %221
  %223 = call float @llvm.sqrt.f32.12(float %222)
  %224 = fneg float %168
  %225 = fmul float %223, %224
  %226 = fmul float %225, 0.000000e+00
  %227 = bitcast i32 %131 to float
  %228 = fadd float %227, %226
  %229 = fmul float %214, %228
  %230 = fadd float %200, %229
  %231 = call float @llvm.sqrt.f32.13(float %230)
  %232 = fadd float %231, 0.000000e+00
  %233 = fdiv float %172, %232
  %234 = fmul float %233, 2.000000e+00
  %235 = bitcast i32 %152 to float
  %236 = bitcast i32 %152 to float
  %237 = fmul float %235, %236
  %238 = fadd float %237, 0.000000e+00
  %239 = bitcast i32 %131 to float
  %240 = bitcast i32 %131 to float
  %241 = fmul float %239, %240
  %242 = fadd float %238, %241
  %243 = call float @llvm.sqrt.f32.14(float %242)
  %244 = fneg float %168
  %245 = fmul float %243, %244
  %246 = bitcast i32 %152 to float
  %247 = fadd float %246, %245
  %248 = bitcast i32 %152 to float
  %249 = bitcast i32 %152 to float
  %250 = fmul float %248, %249
  %251 = fadd float %250, 0.000000e+00
  %252 = bitcast i32 %131 to float
  %253 = bitcast i32 %131 to float
  %254 = fmul float %252, %253
  %255 = fadd float %251, %254
  %256 = call float @llvm.sqrt.f32.15(float %255)
  %257 = fneg float %168
  %258 = fmul float %256, %257
  %259 = bitcast i32 %152 to float
  %260 = fadd float %259, %258
  %261 = bitcast i32 %152 to float
  %262 = bitcast i32 %152 to float
  %263 = fmul float %261, %262
  %264 = fadd float %263, 0.000000e+00
  %265 = bitcast i32 %131 to float
  %266 = bitcast i32 %131 to float
  %267 = fmul float %265, %266
  %268 = fadd float %264, %267
  %269 = call float @llvm.sqrt.f32.16(float %268)
  %270 = fneg float %168
  %271 = fmul float %269, %270
  %272 = bitcast i32 %152 to float
  %273 = fadd float %272, %271
  %274 = fmul float %260, %273
  %275 = fadd float %274, 0.000000e+00
  %276 = bitcast i32 %152 to float
  %277 = bitcast i32 %152 to float
  %278 = fmul float %276, %277
  %279 = fadd float %278, 0.000000e+00
  %280 = bitcast i32 %131 to float
  %281 = bitcast i32 %131 to float
  %282 = fmul float %280, %281
  %283 = fadd float %279, %282
  %284 = call float @llvm.sqrt.f32.17(float %283)
  %285 = fneg float %168
  %286 = fmul float %284, %285
  %287 = fmul float %286, 0.000000e+00
  %288 = bitcast i32 %131 to float
  %289 = fadd float %288, %287
  %290 = bitcast i32 %152 to float
  %291 = bitcast i32 %152 to float
  %292 = fmul float %290, %291
  %293 = fadd float %292, 0.000000e+00
  %294 = bitcast i32 %131 to float
  %295 = bitcast i32 %131 to float
  %296 = fmul float %294, %295
  %297 = fadd float %293, %296
  %298 = call float @llvm.sqrt.f32.18(float %297)
  %299 = fneg float %168
  %300 = fmul float %298, %299
  %301 = fmul float %300, 0.000000e+00
  %302 = bitcast i32 %131 to float
  %303 = fadd float %302, %301
  %304 = fmul float %289, %303
  %305 = fadd float %275, %304
  %306 = call float @llvm.sqrt.f32.19(float %305)
  %307 = fadd float %306, 0.000000e+00
  %308 = fdiv float %247, %307
  %309 = fmul float %234, %308
  %310 = insertelement <4 x float> %149, float %309, i32 1
  %311 = bitcast i32 %152 to float
  %312 = bitcast i32 %152 to float
  %313 = fmul float %311, %312
  %314 = fadd float %313, 0.000000e+00
  %315 = bitcast i32 %131 to float
  %316 = bitcast i32 %131 to float
  %317 = fmul float %315, %316
  %318 = fadd float %314, %317
  %319 = call float @llvm.sqrt.f32.20(float %318)
  %320 = fneg float %168
  %321 = fmul float %319, %320
  %322 = bitcast i32 %152 to float
  %323 = fadd float %322, %321
  %324 = bitcast i32 %152 to float
  %325 = bitcast i32 %152 to float
  %326 = fmul float %324, %325
  %327 = fadd float %326, 0.000000e+00
  %328 = bitcast i32 %131 to float
  %329 = bitcast i32 %131 to float
  %330 = fmul float %328, %329
  %331 = fadd float %327, %330
  %332 = call float @llvm.sqrt.f32.21(float %331)
  %333 = fneg float %168
  %334 = fmul float %332, %333
  %335 = bitcast i32 %152 to float
  %336 = fadd float %335, %334
  %337 = bitcast i32 %152 to float
  %338 = bitcast i32 %152 to float
  %339 = fmul float %337, %338
  %340 = fadd float %339, 0.000000e+00
  %341 = bitcast i32 %131 to float
  %342 = bitcast i32 %131 to float
  %343 = fmul float %341, %342
  %344 = fadd float %340, %343
  %345 = call float @llvm.sqrt.f32.22(float %344)
  %346 = fneg float %168
  %347 = fmul float %345, %346
  %348 = bitcast i32 %152 to float
  %349 = fadd float %348, %347
  %350 = fmul float %336, %349
  %351 = fadd float %350, 0.000000e+00
  %352 = bitcast i32 %152 to float
  %353 = bitcast i32 %152 to float
  %354 = fmul float %352, %353
  %355 = fadd float %354, 0.000000e+00
  %356 = bitcast i32 %131 to float
  %357 = bitcast i32 %131 to float
  %358 = fmul float %356, %357
  %359 = fadd float %355, %358
  %360 = call float @llvm.sqrt.f32.23(float %359)
  %361 = fneg float %168
  %362 = fmul float %360, %361
  %363 = fmul float %362, 0.000000e+00
  %364 = bitcast i32 %131 to float
  %365 = fadd float %364, %363
  %366 = bitcast i32 %152 to float
  %367 = bitcast i32 %152 to float
  %368 = fmul float %366, %367
  %369 = fadd float %368, 0.000000e+00
  %370 = bitcast i32 %131 to float
  %371 = bitcast i32 %131 to float
  %372 = fmul float %370, %371
  %373 = fadd float %369, %372
  %374 = call float @llvm.sqrt.f32.24(float %373)
  %375 = fneg float %168
  %376 = fmul float %374, %375
  %377 = fmul float %376, 0.000000e+00
  %378 = bitcast i32 %131 to float
  %379 = fadd float %378, %377
  %380 = fmul float %365, %379
  %381 = fadd float %351, %380
  %382 = call float @llvm.sqrt.f32.25(float %381)
  %383 = fadd float %382, 0.000000e+00
  %384 = fdiv float %323, %383
  %385 = fmul float %384, 2.000000e+00
  %386 = bitcast i32 %152 to float
  %387 = bitcast i32 %152 to float
  %388 = fmul float %386, %387
  %389 = fadd float %388, 0.000000e+00
  %390 = bitcast i32 %131 to float
  %391 = bitcast i32 %131 to float
  %392 = fmul float %390, %391
  %393 = fadd float %389, %392
  %394 = call float @llvm.sqrt.f32.26(float %393)
  %395 = fneg float %168
  %396 = fmul float %394, %395
  %397 = fmul float %396, 0.000000e+00
  %398 = bitcast i32 %131 to float
  %399 = fadd float %398, %397
  %400 = bitcast i32 %152 to float
  %401 = bitcast i32 %152 to float
  %402 = fmul float %400, %401
  %403 = fadd float %402, 0.000000e+00
  %404 = bitcast i32 %131 to float
  %405 = bitcast i32 %131 to float
  %406 = fmul float %404, %405
  %407 = fadd float %403, %406
  %408 = call float @llvm.sqrt.f32.27(float %407)
  %409 = fneg float %168
  %410 = fmul float %408, %409
  %411 = bitcast i32 %152 to float
  %412 = fadd float %411, %410
  %413 = bitcast i32 %152 to float
  %414 = bitcast i32 %152 to float
  %415 = fmul float %413, %414
  %416 = fadd float %415, 0.000000e+00
  %417 = bitcast i32 %131 to float
  %418 = bitcast i32 %131 to float
  %419 = fmul float %417, %418
  %420 = fadd float %416, %419
  %421 = call float @llvm.sqrt.f32.28(float %420)
  %422 = fneg float %168
  %423 = fmul float %421, %422
  %424 = bitcast i32 %152 to float
  %425 = fadd float %424, %423
  %426 = fmul float %412, %425
  %427 = fadd float %426, 0.000000e+00
  %428 = bitcast i32 %152 to float
  %429 = bitcast i32 %152 to float
  %430 = fmul float %428, %429
  %431 = fadd float %430, 0.000000e+00
  %432 = bitcast i32 %131 to float
  %433 = bitcast i32 %131 to float
  %434 = fmul float %432, %433
  %435 = fadd float %431, %434
  %436 = call float @llvm.sqrt.f32.29(float %435)
  %437 = fneg float %168
  %438 = fmul float %436, %437
  %439 = fmul float %438, 0.000000e+00
  %440 = bitcast i32 %131 to float
  %441 = fadd float %440, %439
  %442 = bitcast i32 %152 to float
  %443 = bitcast i32 %152 to float
  %444 = fmul float %442, %443
  %445 = fadd float %444, 0.000000e+00
  %446 = bitcast i32 %131 to float
  %447 = bitcast i32 %131 to float
  %448 = fmul float %446, %447
  %449 = fadd float %445, %448
  %450 = call float @llvm.sqrt.f32.30(float %449)
  %451 = fneg float %168
  %452 = fmul float %450, %451
  %453 = fmul float %452, 0.000000e+00
  %454 = bitcast i32 %131 to float
  %455 = fadd float %454, %453
  %456 = fmul float %441, %455
  %457 = fadd float %427, %456
  %458 = call float @llvm.sqrt.f32.31(float %457)
  %459 = fadd float %458, 0.000000e+00
  %460 = fdiv float %399, %459
  %461 = fmul float %385, %460
  %462 = insertelement <4 x float> %310, float %461, i32 2
  %463 = bitcast i32 %152 to float
  %464 = bitcast i32 %152 to float
  %465 = fmul float %463, %464
  %466 = fadd float %465, 0.000000e+00
  %467 = bitcast i32 %131 to float
  %468 = bitcast i32 %131 to float
  %469 = fmul float %467, %468
  %470 = fadd float %466, %469
  %471 = call float @llvm.sqrt.f32.32(float %470)
  %472 = fneg float %168
  %473 = fmul float %471, %472
  %474 = fmul float %473, 0.000000e+00
  %475 = bitcast i32 %131 to float
  %476 = fadd float %475, %474
  %477 = bitcast i32 %152 to float
  %478 = bitcast i32 %152 to float
  %479 = fmul float %477, %478
  %480 = fadd float %479, 0.000000e+00
  %481 = bitcast i32 %131 to float
  %482 = bitcast i32 %131 to float
  %483 = fmul float %481, %482
  %484 = fadd float %480, %483
  %485 = call float @llvm.sqrt.f32.33(float %484)
  %486 = fneg float %168
  %487 = fmul float %485, %486
  %488 = bitcast i32 %152 to float
  %489 = fadd float %488, %487
  %490 = bitcast i32 %152 to float
  %491 = bitcast i32 %152 to float
  %492 = fmul float %490, %491
  %493 = fadd float %492, 0.000000e+00
  %494 = bitcast i32 %131 to float
  %495 = bitcast i32 %131 to float
  %496 = fmul float %494, %495
  %497 = fadd float %493, %496
  %498 = call float @llvm.sqrt.f32.34(float %497)
  %499 = fneg float %168
  %500 = fmul float %498, %499
  %501 = bitcast i32 %152 to float
  %502 = fadd float %501, %500
  %503 = fmul float %489, %502
  %504 = fadd float %503, 0.000000e+00
  %505 = bitcast i32 %152 to float
  %506 = bitcast i32 %152 to float
  %507 = fmul float %505, %506
  %508 = fadd float %507, 0.000000e+00
  %509 = bitcast i32 %131 to float
  %510 = bitcast i32 %131 to float
  %511 = fmul float %509, %510
  %512 = fadd float %508, %511
  %513 = call float @llvm.sqrt.f32.35(float %512)
  %514 = fneg float %168
  %515 = fmul float %513, %514
  %516 = fmul float %515, 0.000000e+00
  %517 = bitcast i32 %131 to float
  %518 = fadd float %517, %516
  %519 = bitcast i32 %152 to float
  %520 = bitcast i32 %152 to float
  %521 = fmul float %519, %520
  %522 = fadd float %521, 0.000000e+00
  %523 = bitcast i32 %131 to float
  %524 = bitcast i32 %131 to float
  %525 = fmul float %523, %524
  %526 = fadd float %522, %525
  %527 = call float @llvm.sqrt.f32.36(float %526)
  %528 = fneg float %168
  %529 = fmul float %527, %528
  %530 = fmul float %529, 0.000000e+00
  %531 = bitcast i32 %131 to float
  %532 = fadd float %531, %530
  %533 = fmul float %518, %532
  %534 = fadd float %504, %533
  %535 = call float @llvm.sqrt.f32.37(float %534)
  %536 = fadd float %535, 0.000000e+00
  %537 = fdiv float %476, %536
  %538 = fmul float %537, 2.000000e+00
  %539 = bitcast i32 %152 to float
  %540 = bitcast i32 %152 to float
  %541 = fmul float %539, %540
  %542 = fadd float %541, 0.000000e+00
  %543 = bitcast i32 %131 to float
  %544 = bitcast i32 %131 to float
  %545 = fmul float %543, %544
  %546 = fadd float %542, %545
  %547 = call float @llvm.sqrt.f32.38(float %546)
  %548 = fneg float %168
  %549 = fmul float %547, %548
  %550 = bitcast i32 %152 to float
  %551 = fadd float %550, %549
  %552 = bitcast i32 %152 to float
  %553 = bitcast i32 %152 to float
  %554 = fmul float %552, %553
  %555 = fadd float %554, 0.000000e+00
  %556 = bitcast i32 %131 to float
  %557 = bitcast i32 %131 to float
  %558 = fmul float %556, %557
  %559 = fadd float %555, %558
  %560 = call float @llvm.sqrt.f32.39(float %559)
  %561 = fneg float %168
  %562 = fmul float %560, %561
  %563 = bitcast i32 %152 to float
  %564 = fadd float %563, %562
  %565 = bitcast i32 %152 to float
  %566 = bitcast i32 %152 to float
  %567 = fmul float %565, %566
  %568 = fadd float %567, 0.000000e+00
  %569 = bitcast i32 %131 to float
  %570 = bitcast i32 %131 to float
  %571 = fmul float %569, %570
  %572 = fadd float %568, %571
  %573 = call float @llvm.sqrt.f32.40(float %572)
  %574 = fneg float %168
  %575 = fmul float %573, %574
  %576 = bitcast i32 %152 to float
  %577 = fadd float %576, %575
  %578 = fmul float %564, %577
  %579 = fadd float %578, 0.000000e+00
  %580 = bitcast i32 %152 to float
  %581 = bitcast i32 %152 to float
  %582 = fmul float %580, %581
  %583 = fadd float %582, 0.000000e+00
  %584 = bitcast i32 %131 to float
  %585 = bitcast i32 %131 to float
  %586 = fmul float %584, %585
  %587 = fadd float %583, %586
  %588 = call float @llvm.sqrt.f32.41(float %587)
  %589 = fneg float %168
  %590 = fmul float %588, %589
  %591 = fmul float %590, 0.000000e+00
  %592 = bitcast i32 %131 to float
  %593 = fadd float %592, %591
  %594 = bitcast i32 %152 to float
  %595 = bitcast i32 %152 to float
  %596 = fmul float %594, %595
  %597 = fadd float %596, 0.000000e+00
  %598 = bitcast i32 %131 to float
  %599 = bitcast i32 %131 to float
  %600 = fmul float %598, %599
  %601 = fadd float %597, %600
  %602 = call float @llvm.sqrt.f32.42(float %601)
  %603 = fneg float %168
  %604 = fmul float %602, %603
  %605 = fmul float %604, 0.000000e+00
  %606 = bitcast i32 %131 to float
  %607 = fadd float %606, %605
  %608 = fmul float %593, %607
  %609 = fadd float %579, %608
  %610 = call float @llvm.sqrt.f32.43(float %609)
  %611 = fadd float %610, 0.000000e+00
  %612 = fdiv float %551, %611
  %613 = fmul float %538, %612
  %614 = insertelement <4 x float> %462, float %613, i32 3
  %615 = fsub <4 x float> <float 0.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, %614
  %616 = bitcast i32 %152 to float
  %617 = bitcast i32 %152 to float
  %618 = fmul float %616, %617
  %619 = fadd float %618, 0.000000e+00
  %620 = bitcast i32 %131 to float
  %621 = bitcast i32 %131 to float
  %622 = fmul float %620, %621
  %623 = fadd float %619, %622
  %624 = call float @llvm.sqrt.f32.44(float %623)
  %625 = fneg float %168
  %626 = fmul float %624, %625
  %627 = fmul float %626, 0.000000e+00
  %628 = bitcast i32 %131 to float
  %629 = fadd float %628, %627
  %630 = bitcast i32 %152 to float
  %631 = bitcast i32 %152 to float
  %632 = fmul float %630, %631
  %633 = fadd float %632, 0.000000e+00
  %634 = bitcast i32 %131 to float
  %635 = bitcast i32 %131 to float
  %636 = fmul float %634, %635
  %637 = fadd float %633, %636
  %638 = call float @llvm.sqrt.f32.45(float %637)
  %639 = fneg float %168
  %640 = fmul float %638, %639
  %641 = bitcast i32 %152 to float
  %642 = fadd float %641, %640
  %643 = bitcast i32 %152 to float
  %644 = bitcast i32 %152 to float
  %645 = fmul float %643, %644
  %646 = fadd float %645, 0.000000e+00
  %647 = bitcast i32 %131 to float
  %648 = bitcast i32 %131 to float
  %649 = fmul float %647, %648
  %650 = fadd float %646, %649
  %651 = call float @llvm.sqrt.f32.46(float %650)
  %652 = fneg float %168
  %653 = fmul float %651, %652
  %654 = bitcast i32 %152 to float
  %655 = fadd float %654, %653
  %656 = fmul float %642, %655
  %657 = fadd float %656, 0.000000e+00
  %658 = bitcast i32 %152 to float
  %659 = bitcast i32 %152 to float
  %660 = fmul float %658, %659
  %661 = fadd float %660, 0.000000e+00
  %662 = bitcast i32 %131 to float
  %663 = bitcast i32 %131 to float
  %664 = fmul float %662, %663
  %665 = fadd float %661, %664
  %666 = call float @llvm.sqrt.f32.47(float %665)
  %667 = fneg float %168
  %668 = fmul float %666, %667
  %669 = fmul float %668, 0.000000e+00
  %670 = bitcast i32 %131 to float
  %671 = fadd float %670, %669
  %672 = bitcast i32 %152 to float
  %673 = bitcast i32 %152 to float
  %674 = fmul float %672, %673
  %675 = fadd float %674, 0.000000e+00
  %676 = bitcast i32 %131 to float
  %677 = bitcast i32 %131 to float
  %678 = fmul float %676, %677
  %679 = fadd float %675, %678
  %680 = call float @llvm.sqrt.f32.48(float %679)
  %681 = fneg float %168
  %682 = fmul float %680, %681
  %683 = fmul float %682, 0.000000e+00
  %684 = bitcast i32 %131 to float
  %685 = fadd float %684, %683
  %686 = fmul float %671, %685
  %687 = fadd float %657, %686
  %688 = call float @llvm.sqrt.f32.49(float %687)
  %689 = fadd float %688, 0.000000e+00
  %690 = fdiv float %629, %689
  %691 = fmul float %690, 2.000000e+00
  %692 = bitcast i32 %152 to float
  %693 = bitcast i32 %152 to float
  %694 = fmul float %692, %693
  %695 = fadd float %694, 0.000000e+00
  %696 = bitcast i32 %131 to float
  %697 = bitcast i32 %131 to float
  %698 = fmul float %696, %697
  %699 = fadd float %695, %698
  %700 = call float @llvm.sqrt.f32.50(float %699)
  %701 = fneg float %168
  %702 = fmul float %700, %701
  %703 = fmul float %702, 0.000000e+00
  %704 = bitcast i32 %131 to float
  %705 = fadd float %704, %703
  %706 = bitcast i32 %152 to float
  %707 = bitcast i32 %152 to float
  %708 = fmul float %706, %707
  %709 = fadd float %708, 0.000000e+00
  %710 = bitcast i32 %131 to float
  %711 = bitcast i32 %131 to float
  %712 = fmul float %710, %711
  %713 = fadd float %709, %712
  %714 = call float @llvm.sqrt.f32.51(float %713)
  %715 = fneg float %168
  %716 = fmul float %714, %715
  %717 = bitcast i32 %152 to float
  %718 = fadd float %717, %716
  %719 = bitcast i32 %152 to float
  %720 = bitcast i32 %152 to float
  %721 = fmul float %719, %720
  %722 = fadd float %721, 0.000000e+00
  %723 = bitcast i32 %131 to float
  %724 = bitcast i32 %131 to float
  %725 = fmul float %723, %724
  %726 = fadd float %722, %725
  %727 = call float @llvm.sqrt.f32.52(float %726)
  %728 = fneg float %168
  %729 = fmul float %727, %728
  %730 = bitcast i32 %152 to float
  %731 = fadd float %730, %729
  %732 = fmul float %718, %731
  %733 = fadd float %732, 0.000000e+00
  %734 = bitcast i32 %152 to float
  %735 = bitcast i32 %152 to float
  %736 = fmul float %734, %735
  %737 = fadd float %736, 0.000000e+00
  %738 = bitcast i32 %131 to float
  %739 = bitcast i32 %131 to float
  %740 = fmul float %738, %739
  %741 = fadd float %737, %740
  %742 = call float @llvm.sqrt.f32.53(float %741)
  %743 = fneg float %168
  %744 = fmul float %742, %743
  %745 = fmul float %744, 0.000000e+00
  %746 = bitcast i32 %131 to float
  %747 = fadd float %746, %745
  %748 = bitcast i32 %152 to float
  %749 = bitcast i32 %152 to float
  %750 = fmul float %748, %749
  %751 = fadd float %750, 0.000000e+00
  %752 = bitcast i32 %131 to float
  %753 = bitcast i32 %131 to float
  %754 = fmul float %752, %753
  %755 = fadd float %751, %754
  %756 = call float @llvm.sqrt.f32.54(float %755)
  %757 = fneg float %168
  %758 = fmul float %756, %757
  %759 = fmul float %758, 0.000000e+00
  %760 = bitcast i32 %131 to float
  %761 = fadd float %760, %759
  %762 = fmul float %747, %761
  %763 = fadd float %733, %762
  %764 = call float @llvm.sqrt.f32.55(float %763)
  %765 = fadd float %764, 0.000000e+00
  %766 = fdiv float %705, %765
  %767 = fmul float %691, %766
  %768 = fsub float 1.000000e+00, %767
  %769 = insertelement <4 x float> zeroinitializer, float %768, i32 0
  %770 = insertelement <4 x float> %769, float 0.000000e+00, i32 1
  %771 = insertelement <4 x float> %770, float 0.000000e+00, i32 2
  %772 = insertelement <4 x float> %771, float 0.000000e+00, i32 3
  %773 = shufflevector <4 x float> %615, <4 x float> %772, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %774 = extractelement <8 x float> %773, i32 0
  %775 = bitcast i32* %23 to float*
  %776 = getelementptr float, float* %2, i32 0
  %777 = getelementptr inbounds float, float* %776, i64 3
  %778 = bitcast float* %777 to i32*
  %779 = bitcast i32* %778 to float*
  store float %774, float* %779, align 4
  %780 = extractelement <8 x float> %773, i32 1
  %781 = bitcast i32* %60 to float*
  %782 = alloca [4 x float], align 16
  %783 = bitcast [4 x float]* %782 to i32*
  %784 = bitcast i32* %783 to float*
  store float %780, float* %784, align 4
  %785 = extractelement <8 x float> %773, i32 2
  %786 = bitcast i32* %63 to float*
  %787 = getelementptr inbounds [4 x float], [4 x float]* %782, i64 0, i64 1
  %788 = bitcast float* %787 to i32*
  %789 = bitcast i32* %788 to float*
  store float %785, float* %789, align 4
  %790 = extractelement <8 x float> %773, i32 3
  %791 = bitcast i32* %66 to float*
  %792 = getelementptr inbounds [4 x float], [4 x float]* %782, i64 0, i64 2
  %793 = bitcast float* %792 to i32*
  %794 = bitcast i32* %793 to float*
  store float %790, float* %794, align 4
  %795 = extractelement <8 x float> %773, i32 4
  %796 = bitcast i32* %69 to float*
  %797 = getelementptr inbounds [4 x float], [4 x float]* %782, i64 0, i64 3
  %798 = bitcast float* %797 to i32*
  %799 = bitcast i32* %798 to float*
  store float %795, float* %799, align 4
  %800 = bitcast float* %1 to i8*
  %801 = alloca [4 x float], align 16
  %802 = bitcast [4 x float]* %801 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 4 dereferenceable(16) %800, i8* nonnull align 16 dereferenceable(16) %802, i64 16, i1 false)
  store float 0.000000e+00, float* %2, align 4
  %803 = bitcast i32 %152 to float
  %804 = bitcast i32 %152 to float
  %805 = fmul float %803, %804
  %806 = fadd float %805, 0.000000e+00
  %807 = load i32, i32* %130, align 4
  %808 = bitcast i32 %807 to float
  %809 = bitcast i32 %807 to float
  %810 = fmul float %808, %809
  %811 = fadd float %806, %810
  %812 = call float @llvm.sqrt.f32.56(float %811)
  %813 = sitofp i32 %167 to float
  %814 = fneg float %813
  %815 = fmul float %812, %814
  %816 = bitcast i32 %152 to float
  %817 = fadd float %816, %815
  %818 = bitcast i32 %152 to float
  %819 = bitcast i32 %152 to float
  %820 = fmul float %818, %819
  %821 = fadd float %820, 0.000000e+00
  %822 = bitcast i32 %807 to float
  %823 = bitcast i32 %807 to float
  %824 = fmul float %822, %823
  %825 = fadd float %821, %824
  %826 = call float @llvm.sqrt.f32.57(float %825)
  %827 = fneg float %813
  %828 = fmul float %826, %827
  %829 = bitcast i32 %152 to float
  %830 = fadd float %829, %828
  %831 = bitcast i32 %152 to float
  %832 = bitcast i32 %152 to float
  %833 = fmul float %831, %832
  %834 = fadd float %833, 0.000000e+00
  %835 = bitcast i32 %807 to float
  %836 = bitcast i32 %807 to float
  %837 = fmul float %835, %836
  %838 = fadd float %834, %837
  %839 = call float @llvm.sqrt.f32.58(float %838)
  %840 = fneg float %813
  %841 = fmul float %839, %840
  %842 = bitcast i32 %152 to float
  %843 = fadd float %842, %841
  %844 = fmul float %830, %843
  %845 = fadd float %844, 0.000000e+00
  %846 = bitcast i32 %152 to float
  %847 = bitcast i32 %152 to float
  %848 = fmul float %846, %847
  %849 = fadd float %848, 0.000000e+00
  %850 = bitcast i32 %807 to float
  %851 = bitcast i32 %807 to float
  %852 = fmul float %850, %851
  %853 = fadd float %849, %852
  %854 = call float @llvm.sqrt.f32.59(float %853)
  %855 = fneg float %813
  %856 = fmul float %854, %855
  %857 = fmul float %856, 0.000000e+00
  %858 = bitcast i32 %807 to float
  %859 = fadd float %858, %857
  %860 = bitcast i32 %152 to float
  %861 = bitcast i32 %152 to float
  %862 = fmul float %860, %861
  %863 = fadd float %862, 0.000000e+00
  %864 = bitcast i32 %807 to float
  %865 = bitcast i32 %807 to float
  %866 = fmul float %864, %865
  %867 = fadd float %863, %866
  %868 = call float @llvm.sqrt.f32.60(float %867)
  %869 = fneg float %813
  %870 = fmul float %868, %869
  %871 = fmul float %870, 0.000000e+00
  %872 = bitcast i32 %807 to float
  %873 = fadd float %872, %871
  %874 = fmul float %859, %873
  %875 = fadd float %845, %874
  %876 = call float @llvm.sqrt.f32.61(float %875)
  %877 = fadd float %876, 0.000000e+00
  %878 = fdiv float %817, %877
  %879 = fmul float %878, 2.000000e+00
  %880 = bitcast i32 %152 to float
  %881 = bitcast i32 %152 to float
  %882 = fmul float %880, %881
  %883 = fadd float %882, 0.000000e+00
  %884 = bitcast i32 %807 to float
  %885 = bitcast i32 %807 to float
  %886 = fmul float %884, %885
  %887 = fadd float %883, %886
  %888 = call float @llvm.sqrt.f32.62(float %887)
  %889 = fneg float %813
  %890 = fmul float %888, %889
  %891 = bitcast i32 %152 to float
  %892 = fadd float %891, %890
  %893 = bitcast i32 %152 to float
  %894 = bitcast i32 %152 to float
  %895 = fmul float %893, %894
  %896 = fadd float %895, 0.000000e+00
  %897 = bitcast i32 %807 to float
  %898 = bitcast i32 %807 to float
  %899 = fmul float %897, %898
  %900 = fadd float %896, %899
  %901 = call float @llvm.sqrt.f32.63(float %900)
  %902 = fneg float %813
  %903 = fmul float %901, %902
  %904 = bitcast i32 %152 to float
  %905 = fadd float %904, %903
  %906 = bitcast i32 %152 to float
  %907 = bitcast i32 %152 to float
  %908 = fmul float %906, %907
  %909 = fadd float %908, 0.000000e+00
  %910 = bitcast i32 %807 to float
  %911 = bitcast i32 %807 to float
  %912 = fmul float %910, %911
  %913 = fadd float %909, %912
  %914 = call float @llvm.sqrt.f32.64(float %913)
  %915 = fneg float %813
  %916 = fmul float %914, %915
  %917 = bitcast i32 %152 to float
  %918 = fadd float %917, %916
  %919 = fmul float %905, %918
  %920 = fadd float %919, 0.000000e+00
  %921 = bitcast i32 %152 to float
  %922 = bitcast i32 %152 to float
  %923 = fmul float %921, %922
  %924 = fadd float %923, 0.000000e+00
  %925 = bitcast i32 %807 to float
  %926 = bitcast i32 %807 to float
  %927 = fmul float %925, %926
  %928 = fadd float %924, %927
  %929 = call float @llvm.sqrt.f32.65(float %928)
  %930 = fneg float %813
  %931 = fmul float %929, %930
  %932 = fmul float %931, 0.000000e+00
  %933 = bitcast i32 %807 to float
  %934 = fadd float %933, %932
  %935 = bitcast i32 %152 to float
  %936 = bitcast i32 %152 to float
  %937 = fmul float %935, %936
  %938 = fadd float %937, 0.000000e+00
  %939 = bitcast i32 %807 to float
  %940 = bitcast i32 %807 to float
  %941 = fmul float %939, %940
  %942 = fadd float %938, %941
  %943 = call float @llvm.sqrt.f32.66(float %942)
  %944 = fneg float %813
  %945 = fmul float %943, %944
  %946 = fmul float %945, 0.000000e+00
  %947 = bitcast i32 %807 to float
  %948 = fadd float %947, %946
  %949 = fmul float %934, %948
  %950 = fadd float %920, %949
  %951 = call float @llvm.sqrt.f32.67(float %950)
  %952 = fadd float %951, 0.000000e+00
  %953 = fdiv float %892, %952
  %954 = fmul float %879, %953
  %955 = fsub float 1.000000e+00, %954
  %956 = insertelement <4 x float> zeroinitializer, float %955, i32 0
  %957 = insertelement <4 x float> %956, float 0.000000e+00, i32 1
  %958 = insertelement <4 x float> %957, float 0.000000e+00, i32 2
  %959 = insertelement <4 x float> %958, float 0.000000e+00, i32 3
  %960 = getelementptr float, float* %0, i32 0
  %961 = load float, float* %960, align 4
  %962 = insertelement <4 x float> zeroinitializer, float %961, i32 0
  %963 = insertelement <4 x float> %962, float 0.000000e+00, i32 1
  %964 = insertelement <4 x float> %963, float 0.000000e+00, i32 2
  %965 = insertelement <4 x float> %964, float 0.000000e+00, i32 3
  %966 = call <4 x float> @llvm.fma.f32.68(<4 x float> %959, <4 x float> %965, <4 x float> zeroinitializer)
  %967 = extractelement <4 x float> %966, i32 0
  store float %967, float* %2, align 4
  %968 = bitcast i32 %152 to float
  %969 = bitcast i32 %152 to float
  %970 = fmul float %968, %969
  %971 = fadd float %970, 0.000000e+00
  %972 = bitcast i32 %807 to float
  %973 = bitcast i32 %807 to float
  %974 = fmul float %972, %973
  %975 = fadd float %971, %974
  %976 = call float @llvm.sqrt.f32.69(float %975)
  %977 = fneg float %813
  %978 = fmul float %976, %977
  %979 = bitcast i32 %152 to float
  %980 = fadd float %979, %978
  %981 = bitcast i32 %152 to float
  %982 = bitcast i32 %152 to float
  %983 = fmul float %981, %982
  %984 = fadd float %983, 0.000000e+00
  %985 = bitcast i32 %807 to float
  %986 = bitcast i32 %807 to float
  %987 = fmul float %985, %986
  %988 = fadd float %984, %987
  %989 = call float @llvm.sqrt.f32.70(float %988)
  %990 = fneg float %813
  %991 = fmul float %989, %990
  %992 = bitcast i32 %152 to float
  %993 = fadd float %992, %991
  %994 = bitcast i32 %152 to float
  %995 = bitcast i32 %152 to float
  %996 = fmul float %994, %995
  %997 = fadd float %996, 0.000000e+00
  %998 = bitcast i32 %807 to float
  %999 = bitcast i32 %807 to float
  %1000 = fmul float %998, %999
  %1001 = fadd float %997, %1000
  %1002 = call float @llvm.sqrt.f32.71(float %1001)
  %1003 = fneg float %813
  %1004 = fmul float %1002, %1003
  %1005 = bitcast i32 %152 to float
  %1006 = fadd float %1005, %1004
  %1007 = fmul float %993, %1006
  %1008 = fadd float %1007, 0.000000e+00
  %1009 = bitcast i32 %152 to float
  %1010 = bitcast i32 %152 to float
  %1011 = fmul float %1009, %1010
  %1012 = fadd float %1011, 0.000000e+00
  %1013 = bitcast i32 %807 to float
  %1014 = bitcast i32 %807 to float
  %1015 = fmul float %1013, %1014
  %1016 = fadd float %1012, %1015
  %1017 = call float @llvm.sqrt.f32.72(float %1016)
  %1018 = fneg float %813
  %1019 = fmul float %1017, %1018
  %1020 = fmul float %1019, 0.000000e+00
  %1021 = bitcast i32 %807 to float
  %1022 = fadd float %1021, %1020
  %1023 = bitcast i32 %152 to float
  %1024 = bitcast i32 %152 to float
  %1025 = fmul float %1023, %1024
  %1026 = fadd float %1025, 0.000000e+00
  %1027 = bitcast i32 %807 to float
  %1028 = bitcast i32 %807 to float
  %1029 = fmul float %1027, %1028
  %1030 = fadd float %1026, %1029
  %1031 = call float @llvm.sqrt.f32.73(float %1030)
  %1032 = fneg float %813
  %1033 = fmul float %1031, %1032
  %1034 = fmul float %1033, 0.000000e+00
  %1035 = bitcast i32 %807 to float
  %1036 = fadd float %1035, %1034
  %1037 = fmul float %1022, %1036
  %1038 = fadd float %1008, %1037
  %1039 = call float @llvm.sqrt.f32.74(float %1038)
  %1040 = fadd float %1039, 0.000000e+00
  %1041 = fdiv float %980, %1040
  %1042 = fmul float %1041, 2.000000e+00
  %1043 = bitcast i32 %152 to float
  %1044 = bitcast i32 %152 to float
  %1045 = fmul float %1043, %1044
  %1046 = fadd float %1045, 0.000000e+00
  %1047 = bitcast i32 %807 to float
  %1048 = bitcast i32 %807 to float
  %1049 = fmul float %1047, %1048
  %1050 = fadd float %1046, %1049
  %1051 = call float @llvm.sqrt.f32.75(float %1050)
  %1052 = fneg float %813
  %1053 = fmul float %1051, %1052
  %1054 = bitcast i32 %152 to float
  %1055 = fadd float %1054, %1053
  %1056 = bitcast i32 %152 to float
  %1057 = bitcast i32 %152 to float
  %1058 = fmul float %1056, %1057
  %1059 = fadd float %1058, 0.000000e+00
  %1060 = bitcast i32 %807 to float
  %1061 = bitcast i32 %807 to float
  %1062 = fmul float %1060, %1061
  %1063 = fadd float %1059, %1062
  %1064 = call float @llvm.sqrt.f32.76(float %1063)
  %1065 = fneg float %813
  %1066 = fmul float %1064, %1065
  %1067 = bitcast i32 %152 to float
  %1068 = fadd float %1067, %1066
  %1069 = bitcast i32 %152 to float
  %1070 = bitcast i32 %152 to float
  %1071 = fmul float %1069, %1070
  %1072 = fadd float %1071, 0.000000e+00
  %1073 = bitcast i32 %807 to float
  %1074 = bitcast i32 %807 to float
  %1075 = fmul float %1073, %1074
  %1076 = fadd float %1072, %1075
  %1077 = call float @llvm.sqrt.f32.77(float %1076)
  %1078 = fneg float %813
  %1079 = fmul float %1077, %1078
  %1080 = bitcast i32 %152 to float
  %1081 = fadd float %1080, %1079
  %1082 = fmul float %1068, %1081
  %1083 = fadd float %1082, 0.000000e+00
  %1084 = bitcast i32 %152 to float
  %1085 = bitcast i32 %152 to float
  %1086 = fmul float %1084, %1085
  %1087 = fadd float %1086, 0.000000e+00
  %1088 = bitcast i32 %807 to float
  %1089 = bitcast i32 %807 to float
  %1090 = fmul float %1088, %1089
  %1091 = fadd float %1087, %1090
  %1092 = call float @llvm.sqrt.f32.78(float %1091)
  %1093 = fneg float %813
  %1094 = fmul float %1092, %1093
  %1095 = fmul float %1094, 0.000000e+00
  %1096 = bitcast i32 %807 to float
  %1097 = fadd float %1096, %1095
  %1098 = bitcast i32 %152 to float
  %1099 = bitcast i32 %152 to float
  %1100 = fmul float %1098, %1099
  %1101 = fadd float %1100, 0.000000e+00
  %1102 = bitcast i32 %807 to float
  %1103 = bitcast i32 %807 to float
  %1104 = fmul float %1102, %1103
  %1105 = fadd float %1101, %1104
  %1106 = call float @llvm.sqrt.f32.79(float %1105)
  %1107 = fneg float %813
  %1108 = fmul float %1106, %1107
  %1109 = fmul float %1108, 0.000000e+00
  %1110 = bitcast i32 %807 to float
  %1111 = fadd float %1110, %1109
  %1112 = fmul float %1097, %1111
  %1113 = fadd float %1083, %1112
  %1114 = call float @llvm.sqrt.f32.80(float %1113)
  %1115 = fadd float %1114, 0.000000e+00
  %1116 = fdiv float %1055, %1115
  %1117 = fmul float %1042, %1116
  %1118 = fsub float 1.000000e+00, %1117
  %1119 = fmul float %1118, %961
  %1120 = fadd float %1119, 0.000000e+00
  %1121 = bitcast i32 %152 to float
  %1122 = bitcast i32 %152 to float
  %1123 = fmul float %1121, %1122
  %1124 = fadd float %1123, 0.000000e+00
  %1125 = bitcast i32 %807 to float
  %1126 = bitcast i32 %807 to float
  %1127 = fmul float %1125, %1126
  %1128 = fadd float %1124, %1127
  %1129 = call float @llvm.sqrt.f32.81(float %1128)
  %1130 = fneg float %813
  %1131 = fmul float %1129, %1130
  %1132 = bitcast i32 %152 to float
  %1133 = fadd float %1132, %1131
  %1134 = bitcast i32 %152 to float
  %1135 = bitcast i32 %152 to float
  %1136 = fmul float %1134, %1135
  %1137 = fadd float %1136, 0.000000e+00
  %1138 = bitcast i32 %807 to float
  %1139 = bitcast i32 %807 to float
  %1140 = fmul float %1138, %1139
  %1141 = fadd float %1137, %1140
  %1142 = call float @llvm.sqrt.f32.82(float %1141)
  %1143 = fneg float %813
  %1144 = fmul float %1142, %1143
  %1145 = bitcast i32 %152 to float
  %1146 = fadd float %1145, %1144
  %1147 = bitcast i32 %152 to float
  %1148 = bitcast i32 %152 to float
  %1149 = fmul float %1147, %1148
  %1150 = fadd float %1149, 0.000000e+00
  %1151 = bitcast i32 %807 to float
  %1152 = bitcast i32 %807 to float
  %1153 = fmul float %1151, %1152
  %1154 = fadd float %1150, %1153
  %1155 = call float @llvm.sqrt.f32.83(float %1154)
  %1156 = fneg float %813
  %1157 = fmul float %1155, %1156
  %1158 = bitcast i32 %152 to float
  %1159 = fadd float %1158, %1157
  %1160 = fmul float %1146, %1159
  %1161 = fadd float %1160, 0.000000e+00
  %1162 = bitcast i32 %152 to float
  %1163 = bitcast i32 %152 to float
  %1164 = fmul float %1162, %1163
  %1165 = fadd float %1164, 0.000000e+00
  %1166 = bitcast i32 %807 to float
  %1167 = bitcast i32 %807 to float
  %1168 = fmul float %1166, %1167
  %1169 = fadd float %1165, %1168
  %1170 = call float @llvm.sqrt.f32.84(float %1169)
  %1171 = fneg float %813
  %1172 = fmul float %1170, %1171
  %1173 = fmul float %1172, 0.000000e+00
  %1174 = bitcast i32 %807 to float
  %1175 = fadd float %1174, %1173
  %1176 = bitcast i32 %152 to float
  %1177 = bitcast i32 %152 to float
  %1178 = fmul float %1176, %1177
  %1179 = fadd float %1178, 0.000000e+00
  %1180 = bitcast i32 %807 to float
  %1181 = bitcast i32 %807 to float
  %1182 = fmul float %1180, %1181
  %1183 = fadd float %1179, %1182
  %1184 = call float @llvm.sqrt.f32.85(float %1183)
  %1185 = fneg float %813
  %1186 = fmul float %1184, %1185
  %1187 = fmul float %1186, 0.000000e+00
  %1188 = bitcast i32 %807 to float
  %1189 = fadd float %1188, %1187
  %1190 = fmul float %1175, %1189
  %1191 = fadd float %1161, %1190
  %1192 = call float @llvm.sqrt.f32.86(float %1191)
  %1193 = fadd float %1192, 0.000000e+00
  %1194 = fdiv float %1133, %1193
  %1195 = fmul float %1194, 2.000000e+00
  %1196 = bitcast i32 %152 to float
  %1197 = bitcast i32 %152 to float
  %1198 = fmul float %1196, %1197
  %1199 = fadd float %1198, 0.000000e+00
  %1200 = bitcast i32 %807 to float
  %1201 = bitcast i32 %807 to float
  %1202 = fmul float %1200, %1201
  %1203 = fadd float %1199, %1202
  %1204 = call float @llvm.sqrt.f32.87(float %1203)
  %1205 = fneg float %813
  %1206 = fmul float %1204, %1205
  %1207 = fmul float %1206, 0.000000e+00
  %1208 = bitcast i32 %807 to float
  %1209 = fadd float %1208, %1207
  %1210 = bitcast i32 %152 to float
  %1211 = bitcast i32 %152 to float
  %1212 = fmul float %1210, %1211
  %1213 = fadd float %1212, 0.000000e+00
  %1214 = bitcast i32 %807 to float
  %1215 = bitcast i32 %807 to float
  %1216 = fmul float %1214, %1215
  %1217 = fadd float %1213, %1216
  %1218 = call float @llvm.sqrt.f32.88(float %1217)
  %1219 = fneg float %813
  %1220 = fmul float %1218, %1219
  %1221 = bitcast i32 %152 to float
  %1222 = fadd float %1221, %1220
  %1223 = bitcast i32 %152 to float
  %1224 = bitcast i32 %152 to float
  %1225 = fmul float %1223, %1224
  %1226 = fadd float %1225, 0.000000e+00
  %1227 = bitcast i32 %807 to float
  %1228 = bitcast i32 %807 to float
  %1229 = fmul float %1227, %1228
  %1230 = fadd float %1226, %1229
  %1231 = call float @llvm.sqrt.f32.89(float %1230)
  %1232 = fneg float %813
  %1233 = fmul float %1231, %1232
  %1234 = bitcast i32 %152 to float
  %1235 = fadd float %1234, %1233
  %1236 = fmul float %1222, %1235
  %1237 = fadd float %1236, 0.000000e+00
  %1238 = bitcast i32 %152 to float
  %1239 = bitcast i32 %152 to float
  %1240 = fmul float %1238, %1239
  %1241 = fadd float %1240, 0.000000e+00
  %1242 = bitcast i32 %807 to float
  %1243 = bitcast i32 %807 to float
  %1244 = fmul float %1242, %1243
  %1245 = fadd float %1241, %1244
  %1246 = call float @llvm.sqrt.f32.90(float %1245)
  %1247 = fneg float %813
  %1248 = fmul float %1246, %1247
  %1249 = fmul float %1248, 0.000000e+00
  %1250 = bitcast i32 %807 to float
  %1251 = fadd float %1250, %1249
  %1252 = bitcast i32 %152 to float
  %1253 = bitcast i32 %152 to float
  %1254 = fmul float %1252, %1253
  %1255 = fadd float %1254, 0.000000e+00
  %1256 = bitcast i32 %807 to float
  %1257 = bitcast i32 %807 to float
  %1258 = fmul float %1256, %1257
  %1259 = fadd float %1255, %1258
  %1260 = call float @llvm.sqrt.f32.91(float %1259)
  %1261 = fneg float %813
  %1262 = fmul float %1260, %1261
  %1263 = fmul float %1262, 0.000000e+00
  %1264 = bitcast i32 %807 to float
  %1265 = fadd float %1264, %1263
  %1266 = fmul float %1251, %1265
  %1267 = fadd float %1237, %1266
  %1268 = call float @llvm.sqrt.f32.92(float %1267)
  %1269 = fadd float %1268, 0.000000e+00
  %1270 = fdiv float %1209, %1269
  %1271 = fmul float %1195, %1270
  %1272 = fneg float %1271
  %1273 = getelementptr float, float* %0, i32 0
  %1274 = getelementptr inbounds float, float* %1273, i64 2
  %1275 = load float, float* %1274, align 4
  %1276 = fmul float %1272, %1275
  %1277 = fadd float %1120, %1276
  %1278 = insertelement <4 x float> zeroinitializer, float %1277, i32 0
  %1279 = insertelement <4 x float> %1278, float 0.000000e+00, i32 1
  %1280 = insertelement <4 x float> %1279, float 0.000000e+00, i32 2
  %1281 = insertelement <4 x float> %1280, float 0.000000e+00, i32 3
  %1282 = extractelement <4 x float> %1281, i32 0
  store float %1282, float* %2, align 4
  %1283 = extractelement <4 x float> %1281, i32 1
  %1284 = getelementptr float, float* %2, i32 0
  %1285 = getelementptr inbounds float, float* %1284, i64 1
  store float %1283, float* %1285, align 4
  %1286 = bitcast i32 %152 to float
  %1287 = bitcast i32 %152 to float
  %1288 = fmul float %1286, %1287
  %1289 = fadd float %1288, 0.000000e+00
  %1290 = bitcast i32 %807 to float
  %1291 = bitcast i32 %807 to float
  %1292 = fmul float %1290, %1291
  %1293 = fadd float %1289, %1292
  %1294 = call float @llvm.sqrt.f32.93(float %1293)
  %1295 = fneg float %813
  %1296 = fmul float %1294, %1295
  %1297 = bitcast i32 %152 to float
  %1298 = fadd float %1297, %1296
  %1299 = bitcast i32 %152 to float
  %1300 = bitcast i32 %152 to float
  %1301 = fmul float %1299, %1300
  %1302 = fadd float %1301, 0.000000e+00
  %1303 = bitcast i32 %807 to float
  %1304 = bitcast i32 %807 to float
  %1305 = fmul float %1303, %1304
  %1306 = fadd float %1302, %1305
  %1307 = call float @llvm.sqrt.f32.94(float %1306)
  %1308 = fneg float %813
  %1309 = fmul float %1307, %1308
  %1310 = bitcast i32 %152 to float
  %1311 = fadd float %1310, %1309
  %1312 = bitcast i32 %152 to float
  %1313 = bitcast i32 %152 to float
  %1314 = fmul float %1312, %1313
  %1315 = fadd float %1314, 0.000000e+00
  %1316 = bitcast i32 %807 to float
  %1317 = bitcast i32 %807 to float
  %1318 = fmul float %1316, %1317
  %1319 = fadd float %1315, %1318
  %1320 = call float @llvm.sqrt.f32.95(float %1319)
  %1321 = fneg float %813
  %1322 = fmul float %1320, %1321
  %1323 = bitcast i32 %152 to float
  %1324 = fadd float %1323, %1322
  %1325 = fmul float %1311, %1324
  %1326 = fadd float %1325, 0.000000e+00
  %1327 = bitcast i32 %152 to float
  %1328 = bitcast i32 %152 to float
  %1329 = fmul float %1327, %1328
  %1330 = fadd float %1329, 0.000000e+00
  %1331 = bitcast i32 %807 to float
  %1332 = bitcast i32 %807 to float
  %1333 = fmul float %1331, %1332
  %1334 = fadd float %1330, %1333
  %1335 = call float @llvm.sqrt.f32.96(float %1334)
  %1336 = fneg float %813
  %1337 = fmul float %1335, %1336
  %1338 = fmul float %1337, 0.000000e+00
  %1339 = bitcast i32 %807 to float
  %1340 = fadd float %1339, %1338
  %1341 = bitcast i32 %152 to float
  %1342 = bitcast i32 %152 to float
  %1343 = fmul float %1341, %1342
  %1344 = fadd float %1343, 0.000000e+00
  %1345 = bitcast i32 %807 to float
  %1346 = bitcast i32 %807 to float
  %1347 = fmul float %1345, %1346
  %1348 = fadd float %1344, %1347
  %1349 = call float @llvm.sqrt.f32.97(float %1348)
  %1350 = fneg float %813
  %1351 = fmul float %1349, %1350
  %1352 = fmul float %1351, 0.000000e+00
  %1353 = bitcast i32 %807 to float
  %1354 = fadd float %1353, %1352
  %1355 = fmul float %1340, %1354
  %1356 = fadd float %1326, %1355
  %1357 = call float @llvm.sqrt.f32.98(float %1356)
  %1358 = fadd float %1357, 0.000000e+00
  %1359 = fdiv float %1298, %1358
  %1360 = fmul float %1359, 2.000000e+00
  %1361 = bitcast i32 %152 to float
  %1362 = bitcast i32 %152 to float
  %1363 = fmul float %1361, %1362
  %1364 = fadd float %1363, 0.000000e+00
  %1365 = bitcast i32 %807 to float
  %1366 = bitcast i32 %807 to float
  %1367 = fmul float %1365, %1366
  %1368 = fadd float %1364, %1367
  %1369 = call float @llvm.sqrt.f32.99(float %1368)
  %1370 = fneg float %813
  %1371 = fmul float %1369, %1370
  %1372 = bitcast i32 %152 to float
  %1373 = fadd float %1372, %1371
  %1374 = bitcast i32 %152 to float
  %1375 = bitcast i32 %152 to float
  %1376 = fmul float %1374, %1375
  %1377 = fadd float %1376, 0.000000e+00
  %1378 = bitcast i32 %807 to float
  %1379 = bitcast i32 %807 to float
  %1380 = fmul float %1378, %1379
  %1381 = fadd float %1377, %1380
  %1382 = call float @llvm.sqrt.f32.100(float %1381)
  %1383 = fneg float %813
  %1384 = fmul float %1382, %1383
  %1385 = bitcast i32 %152 to float
  %1386 = fadd float %1385, %1384
  %1387 = bitcast i32 %152 to float
  %1388 = bitcast i32 %152 to float
  %1389 = fmul float %1387, %1388
  %1390 = fadd float %1389, 0.000000e+00
  %1391 = bitcast i32 %807 to float
  %1392 = bitcast i32 %807 to float
  %1393 = fmul float %1391, %1392
  %1394 = fadd float %1390, %1393
  %1395 = call float @llvm.sqrt.f32.101(float %1394)
  %1396 = fneg float %813
  %1397 = fmul float %1395, %1396
  %1398 = bitcast i32 %152 to float
  %1399 = fadd float %1398, %1397
  %1400 = fmul float %1386, %1399
  %1401 = fadd float %1400, 0.000000e+00
  %1402 = bitcast i32 %152 to float
  %1403 = bitcast i32 %152 to float
  %1404 = fmul float %1402, %1403
  %1405 = fadd float %1404, 0.000000e+00
  %1406 = bitcast i32 %807 to float
  %1407 = bitcast i32 %807 to float
  %1408 = fmul float %1406, %1407
  %1409 = fadd float %1405, %1408
  %1410 = call float @llvm.sqrt.f32.102(float %1409)
  %1411 = fneg float %813
  %1412 = fmul float %1410, %1411
  %1413 = fmul float %1412, 0.000000e+00
  %1414 = bitcast i32 %807 to float
  %1415 = fadd float %1414, %1413
  %1416 = bitcast i32 %152 to float
  %1417 = bitcast i32 %152 to float
  %1418 = fmul float %1416, %1417
  %1419 = fadd float %1418, 0.000000e+00
  %1420 = bitcast i32 %807 to float
  %1421 = bitcast i32 %807 to float
  %1422 = fmul float %1420, %1421
  %1423 = fadd float %1419, %1422
  %1424 = call float @llvm.sqrt.f32.103(float %1423)
  %1425 = fneg float %813
  %1426 = fmul float %1424, %1425
  %1427 = fmul float %1426, 0.000000e+00
  %1428 = bitcast i32 %807 to float
  %1429 = fadd float %1428, %1427
  %1430 = fmul float %1415, %1429
  %1431 = fadd float %1401, %1430
  %1432 = call float @llvm.sqrt.f32.104(float %1431)
  %1433 = fadd float %1432, 0.000000e+00
  %1434 = fdiv float %1373, %1433
  %1435 = fmul float %1360, %1434
  %1436 = fsub float 1.000000e+00, %1435
  %1437 = insertelement <4 x float> zeroinitializer, float %1436, i32 0
  %1438 = insertelement <4 x float> %1437, float 0.000000e+00, i32 1
  %1439 = insertelement <4 x float> %1438, float 0.000000e+00, i32 2
  %1440 = insertelement <4 x float> %1439, float 0.000000e+00, i32 3
  %1441 = getelementptr float, float* %0, i32 0
  %1442 = getelementptr inbounds float, float* %1441, i64 1
  %1443 = load float, float* %1442, align 4
  %1444 = insertelement <4 x float> zeroinitializer, float %1443, i32 0
  %1445 = insertelement <4 x float> %1444, float 0.000000e+00, i32 1
  %1446 = insertelement <4 x float> %1445, float 0.000000e+00, i32 2
  %1447 = insertelement <4 x float> %1446, float 0.000000e+00, i32 3
  %1448 = call <4 x float> @llvm.fma.f32.105(<4 x float> %1440, <4 x float> %1447, <4 x float> zeroinitializer)
  %1449 = extractelement <4 x float> %1448, i32 0
  store float %1449, float* %1285, align 4
  %1450 = bitcast i32 %152 to float
  %1451 = bitcast i32 %152 to float
  %1452 = fmul float %1450, %1451
  %1453 = fadd float %1452, 0.000000e+00
  %1454 = bitcast i32 %807 to float
  %1455 = bitcast i32 %807 to float
  %1456 = fmul float %1454, %1455
  %1457 = fadd float %1453, %1456
  %1458 = call float @llvm.sqrt.f32.106(float %1457)
  %1459 = fneg float %813
  %1460 = fmul float %1458, %1459
  %1461 = bitcast i32 %152 to float
  %1462 = fadd float %1461, %1460
  %1463 = bitcast i32 %152 to float
  %1464 = bitcast i32 %152 to float
  %1465 = fmul float %1463, %1464
  %1466 = fadd float %1465, 0.000000e+00
  %1467 = bitcast i32 %807 to float
  %1468 = bitcast i32 %807 to float
  %1469 = fmul float %1467, %1468
  %1470 = fadd float %1466, %1469
  %1471 = call float @llvm.sqrt.f32.107(float %1470)
  %1472 = fneg float %813
  %1473 = fmul float %1471, %1472
  %1474 = bitcast i32 %152 to float
  %1475 = fadd float %1474, %1473
  %1476 = bitcast i32 %152 to float
  %1477 = bitcast i32 %152 to float
  %1478 = fmul float %1476, %1477
  %1479 = fadd float %1478, 0.000000e+00
  %1480 = bitcast i32 %807 to float
  %1481 = bitcast i32 %807 to float
  %1482 = fmul float %1480, %1481
  %1483 = fadd float %1479, %1482
  %1484 = call float @llvm.sqrt.f32.108(float %1483)
  %1485 = fneg float %813
  %1486 = fmul float %1484, %1485
  %1487 = bitcast i32 %152 to float
  %1488 = fadd float %1487, %1486
  %1489 = fmul float %1475, %1488
  %1490 = fadd float %1489, 0.000000e+00
  %1491 = bitcast i32 %152 to float
  %1492 = bitcast i32 %152 to float
  %1493 = fmul float %1491, %1492
  %1494 = fadd float %1493, 0.000000e+00
  %1495 = bitcast i32 %807 to float
  %1496 = bitcast i32 %807 to float
  %1497 = fmul float %1495, %1496
  %1498 = fadd float %1494, %1497
  %1499 = call float @llvm.sqrt.f32.109(float %1498)
  %1500 = fneg float %813
  %1501 = fmul float %1499, %1500
  %1502 = fmul float %1501, 0.000000e+00
  %1503 = bitcast i32 %807 to float
  %1504 = fadd float %1503, %1502
  %1505 = bitcast i32 %152 to float
  %1506 = bitcast i32 %152 to float
  %1507 = fmul float %1505, %1506
  %1508 = fadd float %1507, 0.000000e+00
  %1509 = bitcast i32 %807 to float
  %1510 = bitcast i32 %807 to float
  %1511 = fmul float %1509, %1510
  %1512 = fadd float %1508, %1511
  %1513 = call float @llvm.sqrt.f32.110(float %1512)
  %1514 = fneg float %813
  %1515 = fmul float %1513, %1514
  %1516 = fmul float %1515, 0.000000e+00
  %1517 = bitcast i32 %807 to float
  %1518 = fadd float %1517, %1516
  %1519 = fmul float %1504, %1518
  %1520 = fadd float %1490, %1519
  %1521 = call float @llvm.sqrt.f32.111(float %1520)
  %1522 = fadd float %1521, 0.000000e+00
  %1523 = fdiv float %1462, %1522
  %1524 = fmul float %1523, 2.000000e+00
  %1525 = bitcast i32 %152 to float
  %1526 = bitcast i32 %152 to float
  %1527 = fmul float %1525, %1526
  %1528 = fadd float %1527, 0.000000e+00
  %1529 = bitcast i32 %807 to float
  %1530 = bitcast i32 %807 to float
  %1531 = fmul float %1529, %1530
  %1532 = fadd float %1528, %1531
  %1533 = call float @llvm.sqrt.f32.112(float %1532)
  %1534 = fneg float %813
  %1535 = fmul float %1533, %1534
  %1536 = bitcast i32 %152 to float
  %1537 = fadd float %1536, %1535
  %1538 = bitcast i32 %152 to float
  %1539 = bitcast i32 %152 to float
  %1540 = fmul float %1538, %1539
  %1541 = fadd float %1540, 0.000000e+00
  %1542 = bitcast i32 %807 to float
  %1543 = bitcast i32 %807 to float
  %1544 = fmul float %1542, %1543
  %1545 = fadd float %1541, %1544
  %1546 = call float @llvm.sqrt.f32.113(float %1545)
  %1547 = fneg float %813
  %1548 = fmul float %1546, %1547
  %1549 = bitcast i32 %152 to float
  %1550 = fadd float %1549, %1548
  %1551 = bitcast i32 %152 to float
  %1552 = bitcast i32 %152 to float
  %1553 = fmul float %1551, %1552
  %1554 = fadd float %1553, 0.000000e+00
  %1555 = bitcast i32 %807 to float
  %1556 = bitcast i32 %807 to float
  %1557 = fmul float %1555, %1556
  %1558 = fadd float %1554, %1557
  %1559 = call float @llvm.sqrt.f32.114(float %1558)
  %1560 = fneg float %813
  %1561 = fmul float %1559, %1560
  %1562 = bitcast i32 %152 to float
  %1563 = fadd float %1562, %1561
  %1564 = fmul float %1550, %1563
  %1565 = fadd float %1564, 0.000000e+00
  %1566 = bitcast i32 %152 to float
  %1567 = bitcast i32 %152 to float
  %1568 = fmul float %1566, %1567
  %1569 = fadd float %1568, 0.000000e+00
  %1570 = bitcast i32 %807 to float
  %1571 = bitcast i32 %807 to float
  %1572 = fmul float %1570, %1571
  %1573 = fadd float %1569, %1572
  %1574 = call float @llvm.sqrt.f32.115(float %1573)
  %1575 = fneg float %813
  %1576 = fmul float %1574, %1575
  %1577 = fmul float %1576, 0.000000e+00
  %1578 = bitcast i32 %807 to float
  %1579 = fadd float %1578, %1577
  %1580 = bitcast i32 %152 to float
  %1581 = bitcast i32 %152 to float
  %1582 = fmul float %1580, %1581
  %1583 = fadd float %1582, 0.000000e+00
  %1584 = bitcast i32 %807 to float
  %1585 = bitcast i32 %807 to float
  %1586 = fmul float %1584, %1585
  %1587 = fadd float %1583, %1586
  %1588 = call float @llvm.sqrt.f32.116(float %1587)
  %1589 = fneg float %813
  %1590 = fmul float %1588, %1589
  %1591 = fmul float %1590, 0.000000e+00
  %1592 = bitcast i32 %807 to float
  %1593 = fadd float %1592, %1591
  %1594 = fmul float %1579, %1593
  %1595 = fadd float %1565, %1594
  %1596 = call float @llvm.sqrt.f32.117(float %1595)
  %1597 = fadd float %1596, 0.000000e+00
  %1598 = fdiv float %1537, %1597
  %1599 = fmul float %1524, %1598
  %1600 = fsub float 1.000000e+00, %1599
  %1601 = fmul float %1600, %1443
  %1602 = fadd float %1601, 0.000000e+00
  %1603 = bitcast i32 %152 to float
  %1604 = bitcast i32 %152 to float
  %1605 = fmul float %1603, %1604
  %1606 = fadd float %1605, 0.000000e+00
  %1607 = bitcast i32 %807 to float
  %1608 = bitcast i32 %807 to float
  %1609 = fmul float %1607, %1608
  %1610 = fadd float %1606, %1609
  %1611 = call float @llvm.sqrt.f32.118(float %1610)
  %1612 = fneg float %813
  %1613 = fmul float %1611, %1612
  %1614 = bitcast i32 %152 to float
  %1615 = fadd float %1614, %1613
  %1616 = bitcast i32 %152 to float
  %1617 = bitcast i32 %152 to float
  %1618 = fmul float %1616, %1617
  %1619 = fadd float %1618, 0.000000e+00
  %1620 = bitcast i32 %807 to float
  %1621 = bitcast i32 %807 to float
  %1622 = fmul float %1620, %1621
  %1623 = fadd float %1619, %1622
  %1624 = call float @llvm.sqrt.f32.119(float %1623)
  %1625 = fneg float %813
  %1626 = fmul float %1624, %1625
  %1627 = bitcast i32 %152 to float
  %1628 = fadd float %1627, %1626
  %1629 = bitcast i32 %152 to float
  %1630 = bitcast i32 %152 to float
  %1631 = fmul float %1629, %1630
  %1632 = fadd float %1631, 0.000000e+00
  %1633 = bitcast i32 %807 to float
  %1634 = bitcast i32 %807 to float
  %1635 = fmul float %1633, %1634
  %1636 = fadd float %1632, %1635
  %1637 = call float @llvm.sqrt.f32.120(float %1636)
  %1638 = fneg float %813
  %1639 = fmul float %1637, %1638
  %1640 = bitcast i32 %152 to float
  %1641 = fadd float %1640, %1639
  %1642 = fmul float %1628, %1641
  %1643 = fadd float %1642, 0.000000e+00
  %1644 = bitcast i32 %152 to float
  %1645 = bitcast i32 %152 to float
  %1646 = fmul float %1644, %1645
  %1647 = fadd float %1646, 0.000000e+00
  %1648 = bitcast i32 %807 to float
  %1649 = bitcast i32 %807 to float
  %1650 = fmul float %1648, %1649
  %1651 = fadd float %1647, %1650
  %1652 = call float @llvm.sqrt.f32.121(float %1651)
  %1653 = fneg float %813
  %1654 = fmul float %1652, %1653
  %1655 = fmul float %1654, 0.000000e+00
  %1656 = bitcast i32 %807 to float
  %1657 = fadd float %1656, %1655
  %1658 = bitcast i32 %152 to float
  %1659 = bitcast i32 %152 to float
  %1660 = fmul float %1658, %1659
  %1661 = fadd float %1660, 0.000000e+00
  %1662 = bitcast i32 %807 to float
  %1663 = bitcast i32 %807 to float
  %1664 = fmul float %1662, %1663
  %1665 = fadd float %1661, %1664
  %1666 = call float @llvm.sqrt.f32.122(float %1665)
  %1667 = fneg float %813
  %1668 = fmul float %1666, %1667
  %1669 = fmul float %1668, 0.000000e+00
  %1670 = bitcast i32 %807 to float
  %1671 = fadd float %1670, %1669
  %1672 = fmul float %1657, %1671
  %1673 = fadd float %1643, %1672
  %1674 = call float @llvm.sqrt.f32.123(float %1673)
  %1675 = fadd float %1674, 0.000000e+00
  %1676 = fdiv float %1615, %1675
  %1677 = fmul float %1676, 2.000000e+00
  %1678 = bitcast i32 %152 to float
  %1679 = bitcast i32 %152 to float
  %1680 = fmul float %1678, %1679
  %1681 = fadd float %1680, 0.000000e+00
  %1682 = bitcast i32 %807 to float
  %1683 = bitcast i32 %807 to float
  %1684 = fmul float %1682, %1683
  %1685 = fadd float %1681, %1684
  %1686 = call float @llvm.sqrt.f32.124(float %1685)
  %1687 = fneg float %813
  %1688 = fmul float %1686, %1687
  %1689 = fmul float %1688, 0.000000e+00
  %1690 = bitcast i32 %807 to float
  %1691 = fadd float %1690, %1689
  %1692 = bitcast i32 %152 to float
  %1693 = bitcast i32 %152 to float
  %1694 = fmul float %1692, %1693
  %1695 = fadd float %1694, 0.000000e+00
  %1696 = bitcast i32 %807 to float
  %1697 = bitcast i32 %807 to float
  %1698 = fmul float %1696, %1697
  %1699 = fadd float %1695, %1698
  %1700 = call float @llvm.sqrt.f32.125(float %1699)
  %1701 = fneg float %813
  %1702 = fmul float %1700, %1701
  %1703 = bitcast i32 %152 to float
  %1704 = fadd float %1703, %1702
  %1705 = bitcast i32 %152 to float
  %1706 = bitcast i32 %152 to float
  %1707 = fmul float %1705, %1706
  %1708 = fadd float %1707, 0.000000e+00
  %1709 = bitcast i32 %807 to float
  %1710 = bitcast i32 %807 to float
  %1711 = fmul float %1709, %1710
  %1712 = fadd float %1708, %1711
  %1713 = call float @llvm.sqrt.f32.126(float %1712)
  %1714 = fneg float %813
  %1715 = fmul float %1713, %1714
  %1716 = bitcast i32 %152 to float
  %1717 = fadd float %1716, %1715
  %1718 = fmul float %1704, %1717
  %1719 = fadd float %1718, 0.000000e+00
  %1720 = bitcast i32 %152 to float
  %1721 = bitcast i32 %152 to float
  %1722 = fmul float %1720, %1721
  %1723 = fadd float %1722, 0.000000e+00
  %1724 = bitcast i32 %807 to float
  %1725 = bitcast i32 %807 to float
  %1726 = fmul float %1724, %1725
  %1727 = fadd float %1723, %1726
  %1728 = call float @llvm.sqrt.f32.127(float %1727)
  %1729 = fneg float %813
  %1730 = fmul float %1728, %1729
  %1731 = fmul float %1730, 0.000000e+00
  %1732 = bitcast i32 %807 to float
  %1733 = fadd float %1732, %1731
  %1734 = bitcast i32 %152 to float
  %1735 = bitcast i32 %152 to float
  %1736 = fmul float %1734, %1735
  %1737 = fadd float %1736, 0.000000e+00
  %1738 = bitcast i32 %807 to float
  %1739 = bitcast i32 %807 to float
  %1740 = fmul float %1738, %1739
  %1741 = fadd float %1737, %1740
  %1742 = call float @llvm.sqrt.f32.128(float %1741)
  %1743 = fneg float %813
  %1744 = fmul float %1742, %1743
  %1745 = fmul float %1744, 0.000000e+00
  %1746 = bitcast i32 %807 to float
  %1747 = fadd float %1746, %1745
  %1748 = fmul float %1733, %1747
  %1749 = fadd float %1719, %1748
  %1750 = call float @llvm.sqrt.f32.129(float %1749)
  %1751 = fadd float %1750, 0.000000e+00
  %1752 = fdiv float %1691, %1751
  %1753 = fmul float %1677, %1752
  %1754 = fneg float %1753
  %1755 = load float, float* %144, align 4
  %1756 = fmul float %1754, %1755
  %1757 = fadd float %1602, %1756
  %1758 = insertelement <4 x float> zeroinitializer, float %1757, i32 0
  %1759 = insertelement <4 x float> %1758, float 0.000000e+00, i32 1
  %1760 = insertelement <4 x float> %1759, float 0.000000e+00, i32 2
  %1761 = insertelement <4 x float> %1760, float 0.000000e+00, i32 3
  %1762 = extractelement <4 x float> %1761, i32 0
  store float %1762, float* %1285, align 4
  %1763 = extractelement <4 x float> %1761, i32 1
  %1764 = getelementptr float, float* %2, i32 0
  %1765 = getelementptr inbounds float, float* %1764, i64 2
  store float %1763, float* %1765, align 4
  %1766 = bitcast i32 %152 to float
  %1767 = bitcast i32 %152 to float
  %1768 = fmul float %1766, %1767
  %1769 = fadd float %1768, 0.000000e+00
  %1770 = bitcast i32 %807 to float
  %1771 = bitcast i32 %807 to float
  %1772 = fmul float %1770, %1771
  %1773 = fadd float %1769, %1772
  %1774 = call float @llvm.sqrt.f32.130(float %1773)
  %1775 = fneg float %813
  %1776 = fmul float %1774, %1775
  %1777 = fmul float %1776, 0.000000e+00
  %1778 = bitcast i32 %807 to float
  %1779 = fadd float %1778, %1777
  %1780 = bitcast i32 %152 to float
  %1781 = bitcast i32 %152 to float
  %1782 = fmul float %1780, %1781
  %1783 = fadd float %1782, 0.000000e+00
  %1784 = bitcast i32 %807 to float
  %1785 = bitcast i32 %807 to float
  %1786 = fmul float %1784, %1785
  %1787 = fadd float %1783, %1786
  %1788 = call float @llvm.sqrt.f32.131(float %1787)
  %1789 = fneg float %813
  %1790 = fmul float %1788, %1789
  %1791 = bitcast i32 %152 to float
  %1792 = fadd float %1791, %1790
  %1793 = bitcast i32 %152 to float
  %1794 = bitcast i32 %152 to float
  %1795 = fmul float %1793, %1794
  %1796 = fadd float %1795, 0.000000e+00
  %1797 = bitcast i32 %807 to float
  %1798 = bitcast i32 %807 to float
  %1799 = fmul float %1797, %1798
  %1800 = fadd float %1796, %1799
  %1801 = call float @llvm.sqrt.f32.132(float %1800)
  %1802 = fneg float %813
  %1803 = fmul float %1801, %1802
  %1804 = bitcast i32 %152 to float
  %1805 = fadd float %1804, %1803
  %1806 = fmul float %1792, %1805
  %1807 = fadd float %1806, 0.000000e+00
  %1808 = bitcast i32 %152 to float
  %1809 = bitcast i32 %152 to float
  %1810 = fmul float %1808, %1809
  %1811 = fadd float %1810, 0.000000e+00
  %1812 = bitcast i32 %807 to float
  %1813 = bitcast i32 %807 to float
  %1814 = fmul float %1812, %1813
  %1815 = fadd float %1811, %1814
  %1816 = call float @llvm.sqrt.f32.133(float %1815)
  %1817 = fneg float %813
  %1818 = fmul float %1816, %1817
  %1819 = fmul float %1818, 0.000000e+00
  %1820 = bitcast i32 %807 to float
  %1821 = fadd float %1820, %1819
  %1822 = bitcast i32 %152 to float
  %1823 = bitcast i32 %152 to float
  %1824 = fmul float %1822, %1823
  %1825 = fadd float %1824, 0.000000e+00
  %1826 = bitcast i32 %807 to float
  %1827 = bitcast i32 %807 to float
  %1828 = fmul float %1826, %1827
  %1829 = fadd float %1825, %1828
  %1830 = call float @llvm.sqrt.f32.134(float %1829)
  %1831 = fneg float %813
  %1832 = fmul float %1830, %1831
  %1833 = fmul float %1832, 0.000000e+00
  %1834 = bitcast i32 %807 to float
  %1835 = fadd float %1834, %1833
  %1836 = fmul float %1821, %1835
  %1837 = fadd float %1807, %1836
  %1838 = call float @llvm.sqrt.f32.135(float %1837)
  %1839 = fadd float %1838, 0.000000e+00
  %1840 = fdiv float %1779, %1839
  %1841 = fmul float %1840, 2.000000e+00
  %1842 = bitcast i32 %152 to float
  %1843 = bitcast i32 %152 to float
  %1844 = fmul float %1842, %1843
  %1845 = fadd float %1844, 0.000000e+00
  %1846 = bitcast i32 %807 to float
  %1847 = bitcast i32 %807 to float
  %1848 = fmul float %1846, %1847
  %1849 = fadd float %1845, %1848
  %1850 = call float @llvm.sqrt.f32.136(float %1849)
  %1851 = fneg float %813
  %1852 = fmul float %1850, %1851
  %1853 = bitcast i32 %152 to float
  %1854 = fadd float %1853, %1852
  %1855 = bitcast i32 %152 to float
  %1856 = bitcast i32 %152 to float
  %1857 = fmul float %1855, %1856
  %1858 = fadd float %1857, 0.000000e+00
  %1859 = bitcast i32 %807 to float
  %1860 = bitcast i32 %807 to float
  %1861 = fmul float %1859, %1860
  %1862 = fadd float %1858, %1861
  %1863 = call float @llvm.sqrt.f32.137(float %1862)
  %1864 = fneg float %813
  %1865 = fmul float %1863, %1864
  %1866 = bitcast i32 %152 to float
  %1867 = fadd float %1866, %1865
  %1868 = bitcast i32 %152 to float
  %1869 = bitcast i32 %152 to float
  %1870 = fmul float %1868, %1869
  %1871 = fadd float %1870, 0.000000e+00
  %1872 = bitcast i32 %807 to float
  %1873 = bitcast i32 %807 to float
  %1874 = fmul float %1872, %1873
  %1875 = fadd float %1871, %1874
  %1876 = call float @llvm.sqrt.f32.138(float %1875)
  %1877 = fneg float %813
  %1878 = fmul float %1876, %1877
  %1879 = bitcast i32 %152 to float
  %1880 = fadd float %1879, %1878
  %1881 = fmul float %1867, %1880
  %1882 = fadd float %1881, 0.000000e+00
  %1883 = bitcast i32 %152 to float
  %1884 = bitcast i32 %152 to float
  %1885 = fmul float %1883, %1884
  %1886 = fadd float %1885, 0.000000e+00
  %1887 = bitcast i32 %807 to float
  %1888 = bitcast i32 %807 to float
  %1889 = fmul float %1887, %1888
  %1890 = fadd float %1886, %1889
  %1891 = call float @llvm.sqrt.f32.139(float %1890)
  %1892 = fneg float %813
  %1893 = fmul float %1891, %1892
  %1894 = fmul float %1893, 0.000000e+00
  %1895 = bitcast i32 %807 to float
  %1896 = fadd float %1895, %1894
  %1897 = bitcast i32 %152 to float
  %1898 = bitcast i32 %152 to float
  %1899 = fmul float %1897, %1898
  %1900 = fadd float %1899, 0.000000e+00
  %1901 = bitcast i32 %807 to float
  %1902 = bitcast i32 %807 to float
  %1903 = fmul float %1901, %1902
  %1904 = fadd float %1900, %1903
  %1905 = call float @llvm.sqrt.f32.140(float %1904)
  %1906 = fneg float %813
  %1907 = fmul float %1905, %1906
  %1908 = fmul float %1907, 0.000000e+00
  %1909 = bitcast i32 %807 to float
  %1910 = fadd float %1909, %1908
  %1911 = fmul float %1896, %1910
  %1912 = fadd float %1882, %1911
  %1913 = call float @llvm.sqrt.f32.141(float %1912)
  %1914 = fadd float %1913, 0.000000e+00
  %1915 = fdiv float %1854, %1914
  %1916 = fmul float %1841, %1915
  %1917 = fneg float %1916
  %1918 = insertelement <4 x float> zeroinitializer, float %1917, i32 0
  %1919 = insertelement <4 x float> %1918, float 0.000000e+00, i32 1
  %1920 = insertelement <4 x float> %1919, float 0.000000e+00, i32 2
  %1921 = insertelement <4 x float> %1920, float 0.000000e+00, i32 3
  %1922 = getelementptr float, float* %0, i32 0
  %1923 = load float, float* %1922, align 4
  %1924 = insertelement <4 x float> zeroinitializer, float %1923, i32 0
  %1925 = insertelement <4 x float> %1924, float 0.000000e+00, i32 1
  %1926 = insertelement <4 x float> %1925, float 0.000000e+00, i32 2
  %1927 = insertelement <4 x float> %1926, float 0.000000e+00, i32 3
  %1928 = call <4 x float> @llvm.fma.f32.142(<4 x float> %1921, <4 x float> %1927, <4 x float> zeroinitializer)
  %1929 = extractelement <4 x float> %1928, i32 0
  store float %1929, float* %1765, align 4
  %1930 = bitcast i32 %152 to float
  %1931 = bitcast i32 %152 to float
  %1932 = fmul float %1930, %1931
  %1933 = fadd float %1932, 0.000000e+00
  %1934 = bitcast i32 %807 to float
  %1935 = bitcast i32 %807 to float
  %1936 = fmul float %1934, %1935
  %1937 = fadd float %1933, %1936
  %1938 = call float @llvm.sqrt.f32.143(float %1937)
  %1939 = fneg float %813
  %1940 = fmul float %1938, %1939
  %1941 = fmul float %1940, 0.000000e+00
  %1942 = bitcast i32 %807 to float
  %1943 = fadd float %1942, %1941
  %1944 = bitcast i32 %152 to float
  %1945 = bitcast i32 %152 to float
  %1946 = fmul float %1944, %1945
  %1947 = fadd float %1946, 0.000000e+00
  %1948 = bitcast i32 %807 to float
  %1949 = bitcast i32 %807 to float
  %1950 = fmul float %1948, %1949
  %1951 = fadd float %1947, %1950
  %1952 = call float @llvm.sqrt.f32.144(float %1951)
  %1953 = fneg float %813
  %1954 = fmul float %1952, %1953
  %1955 = bitcast i32 %152 to float
  %1956 = fadd float %1955, %1954
  %1957 = bitcast i32 %152 to float
  %1958 = bitcast i32 %152 to float
  %1959 = fmul float %1957, %1958
  %1960 = fadd float %1959, 0.000000e+00
  %1961 = bitcast i32 %807 to float
  %1962 = bitcast i32 %807 to float
  %1963 = fmul float %1961, %1962
  %1964 = fadd float %1960, %1963
  %1965 = call float @llvm.sqrt.f32.145(float %1964)
  %1966 = fneg float %813
  %1967 = fmul float %1965, %1966
  %1968 = bitcast i32 %152 to float
  %1969 = fadd float %1968, %1967
  %1970 = fmul float %1956, %1969
  %1971 = fadd float %1970, 0.000000e+00
  %1972 = bitcast i32 %152 to float
  %1973 = bitcast i32 %152 to float
  %1974 = fmul float %1972, %1973
  %1975 = fadd float %1974, 0.000000e+00
  %1976 = bitcast i32 %807 to float
  %1977 = bitcast i32 %807 to float
  %1978 = fmul float %1976, %1977
  %1979 = fadd float %1975, %1978
  %1980 = call float @llvm.sqrt.f32.146(float %1979)
  %1981 = fneg float %813
  %1982 = fmul float %1980, %1981
  %1983 = fmul float %1982, 0.000000e+00
  %1984 = bitcast i32 %807 to float
  %1985 = fadd float %1984, %1983
  %1986 = bitcast i32 %152 to float
  %1987 = bitcast i32 %152 to float
  %1988 = fmul float %1986, %1987
  %1989 = fadd float %1988, 0.000000e+00
  %1990 = bitcast i32 %807 to float
  %1991 = bitcast i32 %807 to float
  %1992 = fmul float %1990, %1991
  %1993 = fadd float %1989, %1992
  %1994 = call float @llvm.sqrt.f32.147(float %1993)
  %1995 = fneg float %813
  %1996 = fmul float %1994, %1995
  %1997 = fmul float %1996, 0.000000e+00
  %1998 = bitcast i32 %807 to float
  %1999 = fadd float %1998, %1997
  %2000 = fmul float %1985, %1999
  %2001 = fadd float %1971, %2000
  %2002 = call float @llvm.sqrt.f32.148(float %2001)
  %2003 = fadd float %2002, 0.000000e+00
  %2004 = fdiv float %1943, %2003
  %2005 = fmul float %2004, 2.000000e+00
  %2006 = bitcast i32 %152 to float
  %2007 = bitcast i32 %152 to float
  %2008 = fmul float %2006, %2007
  %2009 = fadd float %2008, 0.000000e+00
  %2010 = bitcast i32 %807 to float
  %2011 = bitcast i32 %807 to float
  %2012 = fmul float %2010, %2011
  %2013 = fadd float %2009, %2012
  %2014 = call float @llvm.sqrt.f32.149(float %2013)
  %2015 = fneg float %813
  %2016 = fmul float %2014, %2015
  %2017 = bitcast i32 %152 to float
  %2018 = fadd float %2017, %2016
  %2019 = bitcast i32 %152 to float
  %2020 = bitcast i32 %152 to float
  %2021 = fmul float %2019, %2020
  %2022 = fadd float %2021, 0.000000e+00
  %2023 = bitcast i32 %807 to float
  %2024 = bitcast i32 %807 to float
  %2025 = fmul float %2023, %2024
  %2026 = fadd float %2022, %2025
  %2027 = call float @llvm.sqrt.f32.150(float %2026)
  %2028 = fneg float %813
  %2029 = fmul float %2027, %2028
  %2030 = bitcast i32 %152 to float
  %2031 = fadd float %2030, %2029
  %2032 = bitcast i32 %152 to float
  %2033 = bitcast i32 %152 to float
  %2034 = fmul float %2032, %2033
  %2035 = fadd float %2034, 0.000000e+00
  %2036 = bitcast i32 %807 to float
  %2037 = bitcast i32 %807 to float
  %2038 = fmul float %2036, %2037
  %2039 = fadd float %2035, %2038
  %2040 = call float @llvm.sqrt.f32.151(float %2039)
  %2041 = fneg float %813
  %2042 = fmul float %2040, %2041
  %2043 = bitcast i32 %152 to float
  %2044 = fadd float %2043, %2042
  %2045 = fmul float %2031, %2044
  %2046 = fadd float %2045, 0.000000e+00
  %2047 = bitcast i32 %152 to float
  %2048 = bitcast i32 %152 to float
  %2049 = fmul float %2047, %2048
  %2050 = fadd float %2049, 0.000000e+00
  %2051 = bitcast i32 %807 to float
  %2052 = bitcast i32 %807 to float
  %2053 = fmul float %2051, %2052
  %2054 = fadd float %2050, %2053
  %2055 = call float @llvm.sqrt.f32.152(float %2054)
  %2056 = fneg float %813
  %2057 = fmul float %2055, %2056
  %2058 = fmul float %2057, 0.000000e+00
  %2059 = bitcast i32 %807 to float
  %2060 = fadd float %2059, %2058
  %2061 = bitcast i32 %152 to float
  %2062 = bitcast i32 %152 to float
  %2063 = fmul float %2061, %2062
  %2064 = fadd float %2063, 0.000000e+00
  %2065 = bitcast i32 %807 to float
  %2066 = bitcast i32 %807 to float
  %2067 = fmul float %2065, %2066
  %2068 = fadd float %2064, %2067
  %2069 = call float @llvm.sqrt.f32.153(float %2068)
  %2070 = fneg float %813
  %2071 = fmul float %2069, %2070
  %2072 = fmul float %2071, 0.000000e+00
  %2073 = bitcast i32 %807 to float
  %2074 = fadd float %2073, %2072
  %2075 = fmul float %2060, %2074
  %2076 = fadd float %2046, %2075
  %2077 = call float @llvm.sqrt.f32.154(float %2076)
  %2078 = fadd float %2077, 0.000000e+00
  %2079 = fdiv float %2018, %2078
  %2080 = fmul float %2005, %2079
  %2081 = fneg float %2080
  %2082 = fmul float %2081, %1923
  %2083 = fadd float %2082, 0.000000e+00
  %2084 = bitcast i32 %152 to float
  %2085 = bitcast i32 %152 to float
  %2086 = fmul float %2084, %2085
  %2087 = fadd float %2086, 0.000000e+00
  %2088 = bitcast i32 %807 to float
  %2089 = bitcast i32 %807 to float
  %2090 = fmul float %2088, %2089
  %2091 = fadd float %2087, %2090
  %2092 = call float @llvm.sqrt.f32.155(float %2091)
  %2093 = fneg float %813
  %2094 = fmul float %2092, %2093
  %2095 = fmul float %2094, 0.000000e+00
  %2096 = bitcast i32 %807 to float
  %2097 = fadd float %2096, %2095
  %2098 = bitcast i32 %152 to float
  %2099 = bitcast i32 %152 to float
  %2100 = fmul float %2098, %2099
  %2101 = fadd float %2100, 0.000000e+00
  %2102 = bitcast i32 %807 to float
  %2103 = bitcast i32 %807 to float
  %2104 = fmul float %2102, %2103
  %2105 = fadd float %2101, %2104
  %2106 = call float @llvm.sqrt.f32.156(float %2105)
  %2107 = fneg float %813
  %2108 = fmul float %2106, %2107
  %2109 = bitcast i32 %152 to float
  %2110 = fadd float %2109, %2108
  %2111 = bitcast i32 %152 to float
  %2112 = bitcast i32 %152 to float
  %2113 = fmul float %2111, %2112
  %2114 = fadd float %2113, 0.000000e+00
  %2115 = bitcast i32 %807 to float
  %2116 = bitcast i32 %807 to float
  %2117 = fmul float %2115, %2116
  %2118 = fadd float %2114, %2117
  %2119 = call float @llvm.sqrt.f32.157(float %2118)
  %2120 = fneg float %813
  %2121 = fmul float %2119, %2120
  %2122 = bitcast i32 %152 to float
  %2123 = fadd float %2122, %2121
  %2124 = fmul float %2110, %2123
  %2125 = fadd float %2124, 0.000000e+00
  %2126 = bitcast i32 %152 to float
  %2127 = bitcast i32 %152 to float
  %2128 = fmul float %2126, %2127
  %2129 = fadd float %2128, 0.000000e+00
  %2130 = bitcast i32 %807 to float
  %2131 = bitcast i32 %807 to float
  %2132 = fmul float %2130, %2131
  %2133 = fadd float %2129, %2132
  %2134 = call float @llvm.sqrt.f32.158(float %2133)
  %2135 = fneg float %813
  %2136 = fmul float %2134, %2135
  %2137 = fmul float %2136, 0.000000e+00
  %2138 = bitcast i32 %807 to float
  %2139 = fadd float %2138, %2137
  %2140 = bitcast i32 %152 to float
  %2141 = bitcast i32 %152 to float
  %2142 = fmul float %2140, %2141
  %2143 = fadd float %2142, 0.000000e+00
  %2144 = bitcast i32 %807 to float
  %2145 = bitcast i32 %807 to float
  %2146 = fmul float %2144, %2145
  %2147 = fadd float %2143, %2146
  %2148 = call float @llvm.sqrt.f32.159(float %2147)
  %2149 = fneg float %813
  %2150 = fmul float %2148, %2149
  %2151 = fmul float %2150, 0.000000e+00
  %2152 = bitcast i32 %807 to float
  %2153 = fadd float %2152, %2151
  %2154 = fmul float %2139, %2153
  %2155 = fadd float %2125, %2154
  %2156 = call float @llvm.sqrt.f32.160(float %2155)
  %2157 = fadd float %2156, 0.000000e+00
  %2158 = fdiv float %2097, %2157
  %2159 = fmul float %2158, 2.000000e+00
  %2160 = bitcast i32 %152 to float
  %2161 = bitcast i32 %152 to float
  %2162 = fmul float %2160, %2161
  %2163 = fadd float %2162, 0.000000e+00
  %2164 = bitcast i32 %807 to float
  %2165 = bitcast i32 %807 to float
  %2166 = fmul float %2164, %2165
  %2167 = fadd float %2163, %2166
  %2168 = call float @llvm.sqrt.f32.161(float %2167)
  %2169 = fneg float %813
  %2170 = fmul float %2168, %2169
  %2171 = fmul float %2170, 0.000000e+00
  %2172 = bitcast i32 %807 to float
  %2173 = fadd float %2172, %2171
  %2174 = bitcast i32 %152 to float
  %2175 = bitcast i32 %152 to float
  %2176 = fmul float %2174, %2175
  %2177 = fadd float %2176, 0.000000e+00
  %2178 = bitcast i32 %807 to float
  %2179 = bitcast i32 %807 to float
  %2180 = fmul float %2178, %2179
  %2181 = fadd float %2177, %2180
  %2182 = call float @llvm.sqrt.f32.162(float %2181)
  %2183 = fneg float %813
  %2184 = fmul float %2182, %2183
  %2185 = bitcast i32 %152 to float
  %2186 = fadd float %2185, %2184
  %2187 = bitcast i32 %152 to float
  %2188 = bitcast i32 %152 to float
  %2189 = fmul float %2187, %2188
  %2190 = fadd float %2189, 0.000000e+00
  %2191 = bitcast i32 %807 to float
  %2192 = bitcast i32 %807 to float
  %2193 = fmul float %2191, %2192
  %2194 = fadd float %2190, %2193
  %2195 = call float @llvm.sqrt.f32.163(float %2194)
  %2196 = fneg float %813
  %2197 = fmul float %2195, %2196
  %2198 = bitcast i32 %152 to float
  %2199 = fadd float %2198, %2197
  %2200 = fmul float %2186, %2199
  %2201 = fadd float %2200, 0.000000e+00
  %2202 = bitcast i32 %152 to float
  %2203 = bitcast i32 %152 to float
  %2204 = fmul float %2202, %2203
  %2205 = fadd float %2204, 0.000000e+00
  %2206 = bitcast i32 %807 to float
  %2207 = bitcast i32 %807 to float
  %2208 = fmul float %2206, %2207
  %2209 = fadd float %2205, %2208
  %2210 = call float @llvm.sqrt.f32.164(float %2209)
  %2211 = fneg float %813
  %2212 = fmul float %2210, %2211
  %2213 = fmul float %2212, 0.000000e+00
  %2214 = bitcast i32 %807 to float
  %2215 = fadd float %2214, %2213
  %2216 = bitcast i32 %152 to float
  %2217 = bitcast i32 %152 to float
  %2218 = fmul float %2216, %2217
  %2219 = fadd float %2218, 0.000000e+00
  %2220 = bitcast i32 %807 to float
  %2221 = bitcast i32 %807 to float
  %2222 = fmul float %2220, %2221
  %2223 = fadd float %2219, %2222
  %2224 = call float @llvm.sqrt.f32.165(float %2223)
  %2225 = fneg float %813
  %2226 = fmul float %2224, %2225
  %2227 = fmul float %2226, 0.000000e+00
  %2228 = bitcast i32 %807 to float
  %2229 = fadd float %2228, %2227
  %2230 = fmul float %2215, %2229
  %2231 = fadd float %2201, %2230
  %2232 = call float @llvm.sqrt.f32.166(float %2231)
  %2233 = fadd float %2232, 0.000000e+00
  %2234 = fdiv float %2173, %2233
  %2235 = fmul float %2159, %2234
  %2236 = fsub float 1.000000e+00, %2235
  %2237 = load float, float* %1274, align 4
  %2238 = fmul float %2236, %2237
  %2239 = fadd float %2083, %2238
  %2240 = insertelement <4 x float> zeroinitializer, float %2239, i32 0
  %2241 = insertelement <4 x float> %2240, float 0.000000e+00, i32 1
  %2242 = insertelement <4 x float> %2241, float 0.000000e+00, i32 2
  %2243 = insertelement <4 x float> %2242, float 0.000000e+00, i32 3
  %2244 = extractelement <4 x float> %2243, i32 0
  store float %2244, float* %1765, align 4
  %2245 = extractelement <4 x float> %2243, i32 1
  %2246 = getelementptr float, float* %2, i32 0
  %2247 = getelementptr inbounds float, float* %2246, i64 3
  store float %2245, float* %2247, align 4
  %2248 = bitcast i32 %152 to float
  %2249 = bitcast i32 %152 to float
  %2250 = fmul float %2248, %2249
  %2251 = fadd float %2250, 0.000000e+00
  %2252 = bitcast i32 %807 to float
  %2253 = bitcast i32 %807 to float
  %2254 = fmul float %2252, %2253
  %2255 = fadd float %2251, %2254
  %2256 = call float @llvm.sqrt.f32.167(float %2255)
  %2257 = fneg float %813
  %2258 = fmul float %2256, %2257
  %2259 = fmul float %2258, 0.000000e+00
  %2260 = bitcast i32 %807 to float
  %2261 = fadd float %2260, %2259
  %2262 = bitcast i32 %152 to float
  %2263 = bitcast i32 %152 to float
  %2264 = fmul float %2262, %2263
  %2265 = fadd float %2264, 0.000000e+00
  %2266 = bitcast i32 %807 to float
  %2267 = bitcast i32 %807 to float
  %2268 = fmul float %2266, %2267
  %2269 = fadd float %2265, %2268
  %2270 = call float @llvm.sqrt.f32.168(float %2269)
  %2271 = fneg float %813
  %2272 = fmul float %2270, %2271
  %2273 = bitcast i32 %152 to float
  %2274 = fadd float %2273, %2272
  %2275 = bitcast i32 %152 to float
  %2276 = bitcast i32 %152 to float
  %2277 = fmul float %2275, %2276
  %2278 = fadd float %2277, 0.000000e+00
  %2279 = bitcast i32 %807 to float
  %2280 = bitcast i32 %807 to float
  %2281 = fmul float %2279, %2280
  %2282 = fadd float %2278, %2281
  %2283 = call float @llvm.sqrt.f32.169(float %2282)
  %2284 = fneg float %813
  %2285 = fmul float %2283, %2284
  %2286 = bitcast i32 %152 to float
  %2287 = fadd float %2286, %2285
  %2288 = fmul float %2274, %2287
  %2289 = fadd float %2288, 0.000000e+00
  %2290 = bitcast i32 %152 to float
  %2291 = bitcast i32 %152 to float
  %2292 = fmul float %2290, %2291
  %2293 = fadd float %2292, 0.000000e+00
  %2294 = bitcast i32 %807 to float
  %2295 = bitcast i32 %807 to float
  %2296 = fmul float %2294, %2295
  %2297 = fadd float %2293, %2296
  %2298 = call float @llvm.sqrt.f32.170(float %2297)
  %2299 = fneg float %813
  %2300 = fmul float %2298, %2299
  %2301 = fmul float %2300, 0.000000e+00
  %2302 = bitcast i32 %807 to float
  %2303 = fadd float %2302, %2301
  %2304 = bitcast i32 %152 to float
  %2305 = bitcast i32 %152 to float
  %2306 = fmul float %2304, %2305
  %2307 = fadd float %2306, 0.000000e+00
  %2308 = bitcast i32 %807 to float
  %2309 = bitcast i32 %807 to float
  %2310 = fmul float %2308, %2309
  %2311 = fadd float %2307, %2310
  %2312 = call float @llvm.sqrt.f32.171(float %2311)
  %2313 = fneg float %813
  %2314 = fmul float %2312, %2313
  %2315 = fmul float %2314, 0.000000e+00
  %2316 = bitcast i32 %807 to float
  %2317 = fadd float %2316, %2315
  %2318 = fmul float %2303, %2317
  %2319 = fadd float %2289, %2318
  %2320 = call float @llvm.sqrt.f32.172(float %2319)
  %2321 = fadd float %2320, 0.000000e+00
  %2322 = fdiv float %2261, %2321
  %2323 = fmul float %2322, 2.000000e+00
  %2324 = bitcast i32 %152 to float
  %2325 = bitcast i32 %152 to float
  %2326 = fmul float %2324, %2325
  %2327 = fadd float %2326, 0.000000e+00
  %2328 = bitcast i32 %807 to float
  %2329 = bitcast i32 %807 to float
  %2330 = fmul float %2328, %2329
  %2331 = fadd float %2327, %2330
  %2332 = call float @llvm.sqrt.f32.173(float %2331)
  %2333 = fneg float %813
  %2334 = fmul float %2332, %2333
  %2335 = bitcast i32 %152 to float
  %2336 = fadd float %2335, %2334
  %2337 = bitcast i32 %152 to float
  %2338 = bitcast i32 %152 to float
  %2339 = fmul float %2337, %2338
  %2340 = fadd float %2339, 0.000000e+00
  %2341 = bitcast i32 %807 to float
  %2342 = bitcast i32 %807 to float
  %2343 = fmul float %2341, %2342
  %2344 = fadd float %2340, %2343
  %2345 = call float @llvm.sqrt.f32.174(float %2344)
  %2346 = fneg float %813
  %2347 = fmul float %2345, %2346
  %2348 = bitcast i32 %152 to float
  %2349 = fadd float %2348, %2347
  %2350 = bitcast i32 %152 to float
  %2351 = bitcast i32 %152 to float
  %2352 = fmul float %2350, %2351
  %2353 = fadd float %2352, 0.000000e+00
  %2354 = bitcast i32 %807 to float
  %2355 = bitcast i32 %807 to float
  %2356 = fmul float %2354, %2355
  %2357 = fadd float %2353, %2356
  %2358 = call float @llvm.sqrt.f32.175(float %2357)
  %2359 = fneg float %813
  %2360 = fmul float %2358, %2359
  %2361 = bitcast i32 %152 to float
  %2362 = fadd float %2361, %2360
  %2363 = fmul float %2349, %2362
  %2364 = fadd float %2363, 0.000000e+00
  %2365 = bitcast i32 %152 to float
  %2366 = bitcast i32 %152 to float
  %2367 = fmul float %2365, %2366
  %2368 = fadd float %2367, 0.000000e+00
  %2369 = bitcast i32 %807 to float
  %2370 = bitcast i32 %807 to float
  %2371 = fmul float %2369, %2370
  %2372 = fadd float %2368, %2371
  %2373 = call float @llvm.sqrt.f32.176(float %2372)
  %2374 = fneg float %813
  %2375 = fmul float %2373, %2374
  %2376 = fmul float %2375, 0.000000e+00
  %2377 = bitcast i32 %807 to float
  %2378 = fadd float %2377, %2376
  %2379 = bitcast i32 %152 to float
  %2380 = bitcast i32 %152 to float
  %2381 = fmul float %2379, %2380
  %2382 = fadd float %2381, 0.000000e+00
  %2383 = bitcast i32 %807 to float
  %2384 = bitcast i32 %807 to float
  %2385 = fmul float %2383, %2384
  %2386 = fadd float %2382, %2385
  %2387 = call float @llvm.sqrt.f32.177(float %2386)
  %2388 = fneg float %813
  %2389 = fmul float %2387, %2388
  %2390 = fmul float %2389, 0.000000e+00
  %2391 = bitcast i32 %807 to float
  %2392 = fadd float %2391, %2390
  %2393 = fmul float %2378, %2392
  %2394 = fadd float %2364, %2393
  %2395 = call float @llvm.sqrt.f32.178(float %2394)
  %2396 = fadd float %2395, 0.000000e+00
  %2397 = fdiv float %2336, %2396
  %2398 = fmul float %2323, %2397
  %2399 = fneg float %2398
  %2400 = insertelement <4 x float> zeroinitializer, float %2399, i32 0
  %2401 = insertelement <4 x float> %2400, float 0.000000e+00, i32 1
  %2402 = insertelement <4 x float> %2401, float 0.000000e+00, i32 2
  %2403 = insertelement <4 x float> %2402, float 0.000000e+00, i32 3
  %2404 = load float, float* %1442, align 4
  %2405 = insertelement <4 x float> zeroinitializer, float %2404, i32 0
  %2406 = insertelement <4 x float> %2405, float 0.000000e+00, i32 1
  %2407 = insertelement <4 x float> %2406, float 0.000000e+00, i32 2
  %2408 = insertelement <4 x float> %2407, float 0.000000e+00, i32 3
  %2409 = call <4 x float> @llvm.fma.f32.179(<4 x float> %2403, <4 x float> %2408, <4 x float> zeroinitializer)
  %2410 = extractelement <4 x float> %2409, i32 0
  store float %2410, float* %2247, align 4
  %2411 = bitcast i32 %152 to float
  %2412 = bitcast i32 %152 to float
  %2413 = fmul float %2411, %2412
  %2414 = fadd float %2413, 0.000000e+00
  %2415 = bitcast i32 %807 to float
  %2416 = bitcast i32 %807 to float
  %2417 = fmul float %2415, %2416
  %2418 = fadd float %2414, %2417
  %2419 = call float @llvm.sqrt.f32.180(float %2418)
  %2420 = fneg float %813
  %2421 = fmul float %2419, %2420
  %2422 = fmul float %2421, 0.000000e+00
  %2423 = bitcast i32 %807 to float
  %2424 = fadd float %2423, %2422
  %2425 = bitcast i32 %152 to float
  %2426 = bitcast i32 %152 to float
  %2427 = fmul float %2425, %2426
  %2428 = fadd float %2427, 0.000000e+00
  %2429 = bitcast i32 %807 to float
  %2430 = bitcast i32 %807 to float
  %2431 = fmul float %2429, %2430
  %2432 = fadd float %2428, %2431
  %2433 = call float @llvm.sqrt.f32.181(float %2432)
  %2434 = fneg float %813
  %2435 = fmul float %2433, %2434
  %2436 = bitcast i32 %152 to float
  %2437 = fadd float %2436, %2435
  %2438 = bitcast i32 %152 to float
  %2439 = bitcast i32 %152 to float
  %2440 = fmul float %2438, %2439
  %2441 = fadd float %2440, 0.000000e+00
  %2442 = bitcast i32 %807 to float
  %2443 = bitcast i32 %807 to float
  %2444 = fmul float %2442, %2443
  %2445 = fadd float %2441, %2444
  %2446 = call float @llvm.sqrt.f32.182(float %2445)
  %2447 = fneg float %813
  %2448 = fmul float %2446, %2447
  %2449 = bitcast i32 %152 to float
  %2450 = fadd float %2449, %2448
  %2451 = fmul float %2437, %2450
  %2452 = fadd float %2451, 0.000000e+00
  %2453 = bitcast i32 %152 to float
  %2454 = bitcast i32 %152 to float
  %2455 = fmul float %2453, %2454
  %2456 = fadd float %2455, 0.000000e+00
  %2457 = bitcast i32 %807 to float
  %2458 = bitcast i32 %807 to float
  %2459 = fmul float %2457, %2458
  %2460 = fadd float %2456, %2459
  %2461 = call float @llvm.sqrt.f32.183(float %2460)
  %2462 = fneg float %813
  %2463 = fmul float %2461, %2462
  %2464 = fmul float %2463, 0.000000e+00
  %2465 = bitcast i32 %807 to float
  %2466 = fadd float %2465, %2464
  %2467 = bitcast i32 %152 to float
  %2468 = bitcast i32 %152 to float
  %2469 = fmul float %2467, %2468
  %2470 = fadd float %2469, 0.000000e+00
  %2471 = bitcast i32 %807 to float
  %2472 = bitcast i32 %807 to float
  %2473 = fmul float %2471, %2472
  %2474 = fadd float %2470, %2473
  %2475 = call float @llvm.sqrt.f32.184(float %2474)
  %2476 = fneg float %813
  %2477 = fmul float %2475, %2476
  %2478 = fmul float %2477, 0.000000e+00
  %2479 = bitcast i32 %807 to float
  %2480 = fadd float %2479, %2478
  %2481 = fmul float %2466, %2480
  %2482 = fadd float %2452, %2481
  %2483 = call float @llvm.sqrt.f32.185(float %2482)
  %2484 = fadd float %2483, 0.000000e+00
  %2485 = fdiv float %2424, %2484
  %2486 = fmul float %2485, 2.000000e+00
  %2487 = bitcast i32 %152 to float
  %2488 = bitcast i32 %152 to float
  %2489 = fmul float %2487, %2488
  %2490 = fadd float %2489, 0.000000e+00
  %2491 = bitcast i32 %807 to float
  %2492 = bitcast i32 %807 to float
  %2493 = fmul float %2491, %2492
  %2494 = fadd float %2490, %2493
  %2495 = call float @llvm.sqrt.f32.186(float %2494)
  %2496 = fneg float %813
  %2497 = fmul float %2495, %2496
  %2498 = bitcast i32 %152 to float
  %2499 = fadd float %2498, %2497
  %2500 = bitcast i32 %152 to float
  %2501 = bitcast i32 %152 to float
  %2502 = fmul float %2500, %2501
  %2503 = fadd float %2502, 0.000000e+00
  %2504 = bitcast i32 %807 to float
  %2505 = bitcast i32 %807 to float
  %2506 = fmul float %2504, %2505
  %2507 = fadd float %2503, %2506
  %2508 = call float @llvm.sqrt.f32.187(float %2507)
  %2509 = fneg float %813
  %2510 = fmul float %2508, %2509
  %2511 = bitcast i32 %152 to float
  %2512 = fadd float %2511, %2510
  %2513 = bitcast i32 %152 to float
  %2514 = bitcast i32 %152 to float
  %2515 = fmul float %2513, %2514
  %2516 = fadd float %2515, 0.000000e+00
  %2517 = bitcast i32 %807 to float
  %2518 = bitcast i32 %807 to float
  %2519 = fmul float %2517, %2518
  %2520 = fadd float %2516, %2519
  %2521 = call float @llvm.sqrt.f32.188(float %2520)
  %2522 = fneg float %813
  %2523 = fmul float %2521, %2522
  %2524 = bitcast i32 %152 to float
  %2525 = fadd float %2524, %2523
  %2526 = fmul float %2512, %2525
  %2527 = fadd float %2526, 0.000000e+00
  %2528 = bitcast i32 %152 to float
  %2529 = bitcast i32 %152 to float
  %2530 = fmul float %2528, %2529
  %2531 = fadd float %2530, 0.000000e+00
  %2532 = bitcast i32 %807 to float
  %2533 = bitcast i32 %807 to float
  %2534 = fmul float %2532, %2533
  %2535 = fadd float %2531, %2534
  %2536 = call float @llvm.sqrt.f32.189(float %2535)
  %2537 = fneg float %813
  %2538 = fmul float %2536, %2537
  %2539 = fmul float %2538, 0.000000e+00
  %2540 = bitcast i32 %807 to float
  %2541 = fadd float %2540, %2539
  %2542 = bitcast i32 %152 to float
  %2543 = bitcast i32 %152 to float
  %2544 = fmul float %2542, %2543
  %2545 = fadd float %2544, 0.000000e+00
  %2546 = bitcast i32 %807 to float
  %2547 = bitcast i32 %807 to float
  %2548 = fmul float %2546, %2547
  %2549 = fadd float %2545, %2548
  %2550 = call float @llvm.sqrt.f32.190(float %2549)
  %2551 = fneg float %813
  %2552 = fmul float %2550, %2551
  %2553 = fmul float %2552, 0.000000e+00
  %2554 = bitcast i32 %807 to float
  %2555 = fadd float %2554, %2553
  %2556 = fmul float %2541, %2555
  %2557 = fadd float %2527, %2556
  %2558 = call float @llvm.sqrt.f32.191(float %2557)
  %2559 = fadd float %2558, 0.000000e+00
  %2560 = fdiv float %2499, %2559
  %2561 = fmul float %2486, %2560
  %2562 = fneg float %2561
  %2563 = fmul float %2562, %2404
  %2564 = fadd float %2563, 0.000000e+00
  %2565 = bitcast i32 %152 to float
  %2566 = bitcast i32 %152 to float
  %2567 = fmul float %2565, %2566
  %2568 = fadd float %2567, 0.000000e+00
  %2569 = bitcast i32 %807 to float
  %2570 = bitcast i32 %807 to float
  %2571 = fmul float %2569, %2570
  %2572 = fadd float %2568, %2571
  %2573 = call float @llvm.sqrt.f32.192(float %2572)
  %2574 = fneg float %813
  %2575 = fmul float %2573, %2574
  %2576 = fmul float %2575, 0.000000e+00
  %2577 = bitcast i32 %807 to float
  %2578 = fadd float %2577, %2576
  %2579 = bitcast i32 %152 to float
  %2580 = bitcast i32 %152 to float
  %2581 = fmul float %2579, %2580
  %2582 = fadd float %2581, 0.000000e+00
  %2583 = bitcast i32 %807 to float
  %2584 = bitcast i32 %807 to float
  %2585 = fmul float %2583, %2584
  %2586 = fadd float %2582, %2585
  %2587 = call float @llvm.sqrt.f32.193(float %2586)
  %2588 = fneg float %813
  %2589 = fmul float %2587, %2588
  %2590 = bitcast i32 %152 to float
  %2591 = fadd float %2590, %2589
  %2592 = bitcast i32 %152 to float
  %2593 = bitcast i32 %152 to float
  %2594 = fmul float %2592, %2593
  %2595 = fadd float %2594, 0.000000e+00
  %2596 = bitcast i32 %807 to float
  %2597 = bitcast i32 %807 to float
  %2598 = fmul float %2596, %2597
  %2599 = fadd float %2595, %2598
  %2600 = call float @llvm.sqrt.f32.194(float %2599)
  %2601 = fneg float %813
  %2602 = fmul float %2600, %2601
  %2603 = bitcast i32 %152 to float
  %2604 = fadd float %2603, %2602
  %2605 = fmul float %2591, %2604
  %2606 = fadd float %2605, 0.000000e+00
  %2607 = bitcast i32 %152 to float
  %2608 = bitcast i32 %152 to float
  %2609 = fmul float %2607, %2608
  %2610 = fadd float %2609, 0.000000e+00
  %2611 = bitcast i32 %807 to float
  %2612 = bitcast i32 %807 to float
  %2613 = fmul float %2611, %2612
  %2614 = fadd float %2610, %2613
  %2615 = call float @llvm.sqrt.f32.195(float %2614)
  %2616 = fneg float %813
  %2617 = fmul float %2615, %2616
  %2618 = fmul float %2617, 0.000000e+00
  %2619 = bitcast i32 %807 to float
  %2620 = fadd float %2619, %2618
  %2621 = bitcast i32 %152 to float
  %2622 = bitcast i32 %152 to float
  %2623 = fmul float %2621, %2622
  %2624 = fadd float %2623, 0.000000e+00
  %2625 = bitcast i32 %807 to float
  %2626 = bitcast i32 %807 to float
  %2627 = fmul float %2625, %2626
  %2628 = fadd float %2624, %2627
  %2629 = call float @llvm.sqrt.f32.196(float %2628)
  %2630 = fneg float %813
  %2631 = fmul float %2629, %2630
  %2632 = fmul float %2631, 0.000000e+00
  %2633 = bitcast i32 %807 to float
  %2634 = fadd float %2633, %2632
  %2635 = fmul float %2620, %2634
  %2636 = fadd float %2606, %2635
  %2637 = call float @llvm.sqrt.f32.197(float %2636)
  %2638 = fadd float %2637, 0.000000e+00
  %2639 = fdiv float %2578, %2638
  %2640 = fmul float %2639, 2.000000e+00
  %2641 = bitcast i32 %152 to float
  %2642 = bitcast i32 %152 to float
  %2643 = fmul float %2641, %2642
  %2644 = fadd float %2643, 0.000000e+00
  %2645 = bitcast i32 %807 to float
  %2646 = bitcast i32 %807 to float
  %2647 = fmul float %2645, %2646
  %2648 = fadd float %2644, %2647
  %2649 = call float @llvm.sqrt.f32.198(float %2648)
  %2650 = fneg float %813
  %2651 = fmul float %2649, %2650
  %2652 = fmul float %2651, 0.000000e+00
  %2653 = bitcast i32 %807 to float
  %2654 = fadd float %2653, %2652
  %2655 = bitcast i32 %152 to float
  %2656 = bitcast i32 %152 to float
  %2657 = fmul float %2655, %2656
  %2658 = fadd float %2657, 0.000000e+00
  %2659 = bitcast i32 %807 to float
  %2660 = bitcast i32 %807 to float
  %2661 = fmul float %2659, %2660
  %2662 = fadd float %2658, %2661
  %2663 = call float @llvm.sqrt.f32.199(float %2662)
  %2664 = fneg float %813
  %2665 = fmul float %2663, %2664
  %2666 = bitcast i32 %152 to float
  %2667 = fadd float %2666, %2665
  %2668 = bitcast i32 %152 to float
  %2669 = bitcast i32 %152 to float
  %2670 = fmul float %2668, %2669
  %2671 = fadd float %2670, 0.000000e+00
  %2672 = bitcast i32 %807 to float
  %2673 = bitcast i32 %807 to float
  %2674 = fmul float %2672, %2673
  %2675 = fadd float %2671, %2674
  %2676 = call float @llvm.sqrt.f32.200(float %2675)
  %2677 = fneg float %813
  %2678 = fmul float %2676, %2677
  %2679 = bitcast i32 %152 to float
  %2680 = fadd float %2679, %2678
  %2681 = fmul float %2667, %2680
  %2682 = fadd float %2681, 0.000000e+00
  %2683 = bitcast i32 %152 to float
  %2684 = bitcast i32 %152 to float
  %2685 = fmul float %2683, %2684
  %2686 = fadd float %2685, 0.000000e+00
  %2687 = bitcast i32 %807 to float
  %2688 = bitcast i32 %807 to float
  %2689 = fmul float %2687, %2688
  %2690 = fadd float %2686, %2689
  %2691 = call float @llvm.sqrt.f32.201(float %2690)
  %2692 = fneg float %813
  %2693 = fmul float %2691, %2692
  %2694 = fmul float %2693, 0.000000e+00
  %2695 = bitcast i32 %807 to float
  %2696 = fadd float %2695, %2694
  %2697 = bitcast i32 %152 to float
  %2698 = bitcast i32 %152 to float
  %2699 = fmul float %2697, %2698
  %2700 = fadd float %2699, 0.000000e+00
  %2701 = bitcast i32 %807 to float
  %2702 = bitcast i32 %807 to float
  %2703 = fmul float %2701, %2702
  %2704 = fadd float %2700, %2703
  %2705 = call float @llvm.sqrt.f32.202(float %2704)
  %2706 = fneg float %813
  %2707 = fmul float %2705, %2706
  %2708 = fmul float %2707, 0.000000e+00
  %2709 = bitcast i32 %807 to float
  %2710 = fadd float %2709, %2708
  %2711 = fmul float %2696, %2710
  %2712 = fadd float %2682, %2711
  %2713 = call float @llvm.sqrt.f32.203(float %2712)
  %2714 = fadd float %2713, 0.000000e+00
  %2715 = fdiv float %2654, %2714
  %2716 = fmul float %2640, %2715
  %2717 = fsub float 1.000000e+00, %2716
  %2718 = load float, float* %144, align 4
  %2719 = fmul float %2717, %2718
  %2720 = fadd float %2564, %2719
  %2721 = insertelement <4 x float> zeroinitializer, float %2720, i32 0
  %2722 = insertelement <4 x float> %2721, float 0.000000e+00, i32 1
  %2723 = insertelement <4 x float> %2722, float 0.000000e+00, i32 2
  %2724 = insertelement <4 x float> %2723, float 0.000000e+00, i32 3
  %2725 = extractelement <4 x float> %2724, i32 0
  store float %2725, float* %2247, align 4
  %2726 = getelementptr float, float* %1, i32 0
  %2727 = getelementptr inbounds float, float* %2726, i64 2
  %2728 = bitcast float* %2727 to i32*
  %2729 = load i32, i32* %2728, align 4
  %2730 = bitcast i32 %2729 to float
  %2731 = insertelement <4 x float> zeroinitializer, float %2730, i32 0
  %2732 = getelementptr float, float* %1, i32 0
  %2733 = getelementptr inbounds float, float* %2732, i64 1
  %2734 = bitcast float* %2733 to i32*
  %2735 = load i32, i32* %2734, align 4
  %2736 = bitcast i32 %2735 to float
  %2737 = insertelement <4 x float> %2731, float %2736, i32 1
  %2738 = insertelement <4 x float> %2737, float 0.000000e+00, i32 2
  %2739 = insertelement <4 x float> %2738, float 0.000000e+00, i32 3
  %2740 = extractelement <4 x float> %2739, i32 0
  %2741 = bitcast i32* %95 to float*
  %2742 = bitcast i32* %2734 to float*
  store float %2740, float* %2742, align 4
  %2743 = extractelement <4 x float> %2739, i32 1
  %2744 = bitcast i32* %98 to float*
  %2745 = bitcast i32* %2728 to float*
  store float %2743, float* %2745, align 4
  ret void
}

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: noinline nounwind ssp uwtable
define void @no_opt_naive_fixed_qr_decomp(float* %0, float* %1, float* %2) #1 {
.preheader13:
  %3 = bitcast float* %2 to i8*
  %4 = bitcast float* %0 to i8*
  %5 = call i64 @llvm.objectsize.i64.p0i8(i8* %3, i1 false, i1 true, i1 false)
  %6 = call i8* @__memcpy_chk(i8* %3, i8* %4, i64 16, i64 %5) #9
  %7 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %8 = bitcast i8* %7 to float*
  store float 1.000000e+00, float* %8, align 4
  %9 = getelementptr inbounds i8, i8* %7, i64 8
  %10 = getelementptr inbounds i8, i8* %7, i64 12
  %11 = bitcast i8* %10 to float*
  store float 1.000000e+00, float* %11, align 4
  %12 = bitcast float* %1 to i8*
  %13 = call i64 @llvm.objectsize.i64.p0i8(i8* %12, i1 false, i1 true, i1 false)
  %14 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %15 = bitcast i8* %14 to float*
  %16 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %17 = bitcast i8* %16 to float*
  %18 = bitcast float* %2 to i32*
  %19 = load i32, i32* %18, align 4
  %20 = bitcast i8* %14 to i32*
  store i32 %19, i32* %20, align 4
  %21 = bitcast i8* %7 to i32*
  %22 = load i32, i32* %21, align 4
  %23 = bitcast i8* %16 to i32*
  store i32 %22, i32* %23, align 4
  %24 = getelementptr inbounds float, float* %2, i64 2
  %25 = bitcast float* %24 to i32*
  %26 = load i32, i32* %25, align 4
  %27 = getelementptr inbounds i8, i8* %14, i64 4
  %28 = bitcast i8* %27 to i32*
  store i32 %26, i32* %28, align 4
  %29 = bitcast i8* %9 to i32*
  %30 = load i32, i32* %29, align 4
  %31 = getelementptr inbounds i8, i8* %16, i64 4
  %32 = bitcast i8* %31 to i32*
  store i32 %30, i32* %32, align 4
  %33 = load float, float* %15, align 4
  %34 = call float @no_opt_sgn(float %33)
  %35 = fneg float %34
  %36 = call float @no_opt_naive_norm(float* nonnull %15, i32 2)
  %37 = fmul float %36, %35
  %38 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %39 = bitcast i8* %38 to float*
  %40 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %41 = load float, float* %15, align 4
  %42 = load float, float* %17, align 4
  %43 = fmul float %37, %42
  %44 = fadd float %41, %43
  store float %44, float* %39, align 4
  %45 = bitcast i8* %27 to float*
  %46 = load float, float* %45, align 4
  %47 = bitcast i8* %31 to float*
  %48 = load float, float* %47, align 4
  %49 = fmul float %37, %48
  %50 = fadd float %46, %49
  %51 = getelementptr inbounds i8, i8* %38, i64 4
  %52 = bitcast i8* %51 to float*
  store float %50, float* %52, align 4
  %53 = bitcast i8* %40 to float*
  %54 = call float @no_opt_naive_norm(float* nonnull %39, i32 2)
  %55 = fadd float %54, 0x3EE4F8B580000000
  %56 = load float, float* %39, align 4
  %57 = fdiv float %56, %55
  store float %57, float* %53, align 4
  %58 = load float, float* %52, align 4
  %59 = fdiv float %58, %55
  %60 = getelementptr inbounds i8, i8* %40, i64 4
  %61 = bitcast i8* %60 to float*
  store float %59, float* %61, align 4
  %62 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %63 = bitcast i8* %62 to float*
  %64 = load float, float* %53, align 4
  %65 = fmul float %64, 2.000000e+00
  %66 = fmul float %65, %64
  %67 = fsub float 1.000000e+00, %66
  store float %67, float* %63, align 4
  %68 = load float, float* %53, align 4
  %69 = fmul float %68, 2.000000e+00
  %70 = load float, float* %61, align 4
  %71 = fmul float %69, %70
  %72 = fsub float 0.000000e+00, %71
  %73 = getelementptr inbounds i8, i8* %62, i64 4
  %74 = bitcast i8* %73 to float*
  store float %72, float* %74, align 4
  %75 = load float, float* %61, align 4
  %76 = fmul float %75, 2.000000e+00
  %77 = load float, float* %53, align 4
  %78 = fmul float %76, %77
  %79 = fsub float 0.000000e+00, %78
  %80 = getelementptr inbounds i8, i8* %62, i64 8
  %81 = bitcast i8* %80 to float*
  store float %79, float* %81, align 4
  %82 = load float, float* %61, align 4
  %83 = fmul float %82, 2.000000e+00
  %84 = fmul float %83, %82
  %85 = fsub float 1.000000e+00, %84
  %86 = getelementptr inbounds i8, i8* %62, i64 12
  %87 = bitcast i8* %86 to float*
  store float %85, float* %87, align 4
  %88 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %89 = bitcast i8* %88 to float*
  %90 = bitcast i8* %62 to i32*
  %91 = load i32, i32* %90, align 4
  %92 = bitcast i8* %88 to i32*
  store i32 %91, i32* %92, align 4
  %93 = bitcast i8* %73 to i32*
  %94 = load i32, i32* %93, align 4
  %95 = getelementptr inbounds i8, i8* %88, i64 4
  %96 = bitcast i8* %95 to i32*
  store i32 %94, i32* %96, align 4
  %97 = bitcast i8* %80 to i32*
  %98 = load i32, i32* %97, align 4
  %99 = getelementptr inbounds i8, i8* %88, i64 8
  %100 = bitcast i8* %99 to i32*
  store i32 %98, i32* %100, align 4
  %101 = bitcast i8* %86 to i32*
  %102 = load i32, i32* %101, align 4
  %103 = getelementptr inbounds i8, i8* %88, i64 12
  %104 = bitcast i8* %103 to i32*
  store i32 %102, i32* %104, align 4
  %105 = call i8* @__memcpy_chk(i8* %12, i8* %88, i64 16, i64 %13) #9
  call void @no_opt_naive_fixed_matrix_multiply(float* %89, float* %0, float* %2)
  call void @free(i8* %14)
  call void @free(i8* %16)
  call void @free(i8* %38)
  call void @free(i8* %40)
  call void @free(i8* %62)
  call void @free(i8* %88)
  call void @no_opt_naive_fixed_transpose(float* %1)
  ret void
}

; Function Attrs: nounwind
declare i8* @__memcpy_chk(i8*, i8*, i64, i64) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare i64 @llvm.objectsize.i64.p0i8(i8*, i1 immarg, i1 immarg, i1 immarg) #2

; Function Attrs: allocsize(0,1)
declare i8* @calloc(i64, i64) #5

declare void @free(i8*) #6

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #1 {
.preheader6:
  %0 = alloca i64, align 8
  %1 = alloca [4 x float], align 16
  %2 = alloca [4 x float], align 16
  %3 = alloca [4 x float], align 16
  %4 = alloca [4 x float], align 16
  %5 = alloca [4 x float], align 16
  %6 = call i64 @time(i64* null) #9
  store i64 %6, i64* %0, align 8
  %7 = call i64 @time(i64* nonnull %0) #9
  %8 = trunc i64 %7 to i32
  call void @srand(i32 %8) #9
  %9 = call i32 @rand() #9
  %10 = sitofp i32 %9 to float
  %11 = fdiv float %10, 0x41747AE140000000
  %12 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 0
  store float %11, float* %12, align 16
  %13 = call i32 @rand() #9
  %14 = sitofp i32 %13 to float
  %15 = fdiv float %14, 0x41747AE140000000
  %16 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 1
  store float %15, float* %16, align 4
  %17 = call i32 @rand() #9
  %18 = sitofp i32 %17 to float
  %19 = fdiv float %18, 0x41747AE140000000
  %20 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 2
  store float %19, float* %20, align 8
  %21 = call i32 @rand() #9
  %22 = sitofp i32 %21 to float
  %23 = fdiv float %22, 0x41747AE140000000
  %24 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 3
  store float %23, float* %24, align 4
  %25 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %25, i8 0, i64 16, i1 false)
  %26 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %26, i8 0, i64 16, i1 false)
  %27 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %28 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  call void @naive_fixed_qr_decomp(float* nonnull %12, float* nonnull %27, float* nonnull %28)
  %29 = bitcast [4 x float]* %4 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %29, i8 0, i64 16, i1 false)
  %30 = bitcast [4 x float]* %5 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %30, i8 0, i64 16, i1 false)
  %31 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 0
  %32 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  call void @no_opt_naive_fixed_qr_decomp(float* nonnull %12, float* nonnull %31, float* nonnull %32)
  %33 = load float, float* %27, align 16
  %34 = fpext float %33 to double
  %35 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i64 0, i64 0), double %34) #9
  %36 = load float, float* %31, align 16
  %37 = fpext float %36 to double
  %38 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.1, i64 0, i64 0), double %37) #9
  %39 = load float, float* %31, align 16
  %40 = load float, float* %27, align 16
  %41 = fsub float %39, %40
  %42 = call float @llvm.fabs.f32(float %41)
  %43 = fcmp uge float %42, 0x3FB99999A0000000
  br i1 %43, label %58, label %44

44:                                               ; preds = %.preheader6
  %45 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 1
  %46 = load float, float* %45, align 4
  %47 = fpext float %46 to double
  %48 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i64 0, i64 0), double %47) #9
  %49 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 1
  %50 = load float, float* %49, align 4
  %51 = fpext float %50 to double
  %52 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.1, i64 0, i64 0), double %51) #9
  %53 = load float, float* %31, align 16
  %54 = load float, float* %27, align 16
  %55 = fsub float %53, %54
  %56 = call float @llvm.fabs.f32(float %55)
  %57 = fcmp uge float %56, 0x3FB99999A0000000
  br i1 %57, label %58, label %.preheader6.1

58:                                               ; preds = %115, %.preheader6.1, %44, %.preheader6
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.2, i64 0, i64 0), i32 300, i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.3, i64 0, i64 0)) #11
  unreachable

59:                                               ; preds = %.preheader5
  %60 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 1
  %61 = load float, float* %60, align 4
  %62 = fpext float %61 to double
  %63 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.4, i64 0, i64 0), double %62) #9
  %64 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 1
  %65 = load float, float* %64, align 4
  %66 = fpext float %65 to double
  %67 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.5, i64 0, i64 0), double %66) #9
  %68 = load float, float* %32, align 16
  %69 = load float, float* %28, align 16
  %70 = fsub float %68, %69
  %71 = call float @llvm.fabs.f32(float %70)
  %72 = fcmp uge float %71, 0x3FB99999A0000000
  br i1 %72, label %73, label %.preheader.1

73:                                               ; preds = %.preheader5, %87, %.preheader.1, %59
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.2, i64 0, i64 0), i32 307, i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.6, i64 0, i64 0)) #11
  unreachable

.preheader.1:                                     ; preds = %59
  %74 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 2
  %75 = load float, float* %74, align 8
  %76 = fpext float %75 to double
  %77 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.4, i64 0, i64 0), double %76) #9
  %78 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 2
  %79 = load float, float* %78, align 8
  %80 = fpext float %79 to double
  %81 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.5, i64 0, i64 0), double %80) #9
  %82 = load float, float* %64, align 4
  %83 = load float, float* %60, align 4
  %84 = fsub float %82, %83
  %85 = call float @llvm.fabs.f32(float %84)
  %86 = fcmp uge float %85, 0x3FB99999A0000000
  br i1 %86, label %73, label %87

87:                                               ; preds = %.preheader.1
  %88 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 3
  %89 = load float, float* %88, align 4
  %90 = fpext float %89 to double
  %91 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.4, i64 0, i64 0), double %90) #9
  %92 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 3
  %93 = load float, float* %92, align 4
  %94 = fpext float %93 to double
  %95 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.5, i64 0, i64 0), double %94) #9
  %96 = load float, float* %64, align 4
  %97 = load float, float* %60, align 4
  %98 = fsub float %96, %97
  %99 = call float @llvm.fabs.f32(float %98)
  %100 = fcmp uge float %99, 0x3FB99999A0000000
  br i1 %100, label %73, label %101

101:                                              ; preds = %87
  ret i32 0

.preheader6.1:                                    ; preds = %44
  %102 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 2
  %103 = load float, float* %102, align 8
  %104 = fpext float %103 to double
  %105 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i64 0, i64 0), double %104) #9
  %106 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 2
  %107 = load float, float* %106, align 8
  %108 = fpext float %107 to double
  %109 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.1, i64 0, i64 0), double %108) #9
  %110 = load float, float* %49, align 4
  %111 = load float, float* %45, align 4
  %112 = fsub float %110, %111
  %113 = call float @llvm.fabs.f32(float %112)
  %114 = fcmp uge float %113, 0x3FB99999A0000000
  br i1 %114, label %58, label %115

115:                                              ; preds = %.preheader6.1
  %116 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 3
  %117 = load float, float* %116, align 4
  %118 = fpext float %117 to double
  %119 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i64 0, i64 0), double %118) #9
  %120 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 3
  %121 = load float, float* %120, align 4
  %122 = fpext float %121 to double
  %123 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.1, i64 0, i64 0), double %122) #9
  %124 = load float, float* %49, align 4
  %125 = load float, float* %45, align 4
  %126 = fsub float %124, %125
  %127 = call float @llvm.fabs.f32(float %126)
  %128 = fcmp uge float %127, 0x3FB99999A0000000
  br i1 %128, label %58, label %.preheader5

.preheader5:                                      ; preds = %115
  %129 = load float, float* %28, align 16
  %130 = fpext float %129 to double
  %131 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.4, i64 0, i64 0), double %130) #9
  %132 = load float, float* %32, align 16
  %133 = fpext float %132 to double
  %134 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.5, i64 0, i64 0), double %133) #9
  %135 = load float, float* %32, align 16
  %136 = load float, float* %28, align 16
  %137 = fsub float %135, %136
  %138 = call float @llvm.fabs.f32(float %137)
  %139 = fcmp uge float %138, 0x3FB99999A0000000
  br i1 %139, label %73, label %59
}

declare i64 @time(i64*) #6

declare void @srand(i32) #6

declare i32 @rand() #6

declare i32 @printf(i8*, ...) #6

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.fabs.f64(double) #2

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #7

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.fabs.f32(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.1(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.2(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.3(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.4(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.5(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.6(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.7(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.8(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.9(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.10(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.11(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.12(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.13(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.14(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.15(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.16(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.17(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.18(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.19(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.20(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.21(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.22(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.23(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.24(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.25(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.26(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.27(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.28(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.29(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.30(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.31(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.32(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.33(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.34(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.35(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.36(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.37(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.38(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.39(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.40(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.41(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.42(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.43(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.44(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.45(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.46(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.47(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.48(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.49(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.50(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.51(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.52(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.53(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.54(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.55(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.56(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.57(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.58(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.59(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.60(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.61(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.62(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.63(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.64(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.65(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.66(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.67(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.68(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.69(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.70(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.71(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.72(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.73(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.74(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.75(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.76(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.77(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.78(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.79(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.80(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.81(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.82(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.83(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.84(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.85(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.86(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.87(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.88(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.89(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.90(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.91(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.92(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.93(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.94(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.95(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.96(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.97(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.98(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.99(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.100(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.101(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.102(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.103(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.104(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.105(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.106(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.107(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.108(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.109(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.110(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.111(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.112(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.113(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.114(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.115(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.116(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.117(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.118(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.119(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.120(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.121(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.122(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.123(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.124(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.125(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.126(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.127(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.128(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.129(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.130(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.131(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.132(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.133(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.134(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.135(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.136(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.137(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.138(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.139(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.140(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.141(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.142(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.143(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.144(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.145(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.146(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.147(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.148(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.149(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.150(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.151(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.152(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.153(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.154(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.155(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.156(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.157(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.158(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.159(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.160(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.161(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.162(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.163(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.164(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.165(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.166(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.167(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.168(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.169(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.170(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.171(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.172(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.173(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.174(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.175(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.176(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.177(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.178(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.179(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.180(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.181(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.182(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.183(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.184(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.185(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.186(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.187(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.188(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.189(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.190(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.191(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.192(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.193(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.194(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.195(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.196(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.197(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.198(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.199(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.200(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.201(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.202(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32.203(float) #2

attributes #0 = { alwaysinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone speculatable willreturn }
attributes #3 = { argmemonly nounwind willreturn writeonly }
attributes #4 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { allocsize(0,1) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { argmemonly nounwind willreturn }
attributes #9 = { nounwind }
attributes #10 = { nounwind allocsize(0,1) }
attributes #11 = { noreturn nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
!3 = distinct !{!3, !4}
!4 = !{!"llvm.loop.unroll.disable"}
!5 = distinct !{!5, !4}
