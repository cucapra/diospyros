; ModuleID = 'build/aa.ll'
source_filename = "fail-tests/qr-decomp-local-arrays.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"Q Output: %f\0A\00", align 1
@.str.2 = private unnamed_addr constant [23 x i8] c"Expected Q Output: %f\0A\00", align 1
@.str.3 = private unnamed_addr constant [14 x i8] c"R Output: %f\0A\00", align 1
@.str.4 = private unnamed_addr constant [23 x i8] c"Expected R Output: %f\0A\00", align 1

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
  %58 = getelementptr float, float* %0, i32 0
  %59 = load float, float* %58, align 4
  %60 = insertelement <4 x float> zeroinitializer, float %59, i32 0
  %61 = insertelement <4 x float> %60, float 1.000000e+00, i32 1
  %62 = insertelement <4 x float> %61, float 1.000000e+00, i32 2
  %63 = insertelement <4 x float> %62, float 1.000000e+00, i32 3
  %64 = insertelement <4 x float> zeroinitializer, float %51, i32 0
  %65 = insertelement <4 x float> %64, float 0.000000e+00, i32 1
  %66 = insertelement <4 x float> %65, float 0.000000e+00, i32 2
  %67 = insertelement <4 x float> %66, float 0.000000e+00, i32 3
  %68 = fmul <4 x float> %63, %67
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
  %110 = insertelement <4 x float> zeroinitializer, float %97, i32 0
  %111 = insertelement <4 x float> %110, float 0.000000e+00, i32 1
  %112 = insertelement <4 x float> %111, float 0.000000e+00, i32 2
  %113 = insertelement <4 x float> %112, float 0.000000e+00, i32 3
  %114 = fmul <4 x float> %109, %113
  %115 = fadd <4 x float> %114, zeroinitializer
  %116 = getelementptr float, float* %0, i32 0
  %117 = getelementptr inbounds float, float* %116, i64 1
  %118 = load float, float* %117, align 4
  %119 = insertelement <4 x float> zeroinitializer, float %118, i32 0
  %120 = insertelement <4 x float> %119, float 0.000000e+00, i32 1
  %121 = insertelement <4 x float> %120, float 0.000000e+00, i32 2
  %122 = insertelement <4 x float> %121, float 0.000000e+00, i32 3
  %123 = getelementptr float, float* %1, i32 0
  %124 = getelementptr inbounds float, float* %123, i64 3
  %125 = load float, float* %124, align 4
  %126 = insertelement <4 x float> zeroinitializer, float %125, i32 0
  %127 = insertelement <4 x float> %126, float 0.000000e+00, i32 1
  %128 = insertelement <4 x float> %127, float 0.000000e+00, i32 2
  %129 = insertelement <4 x float> %128, float 0.000000e+00, i32 3
  %130 = call <4 x float> @llvm.fma.f32.3(<4 x float> %122, <4 x float> %129, <4 x float> %115)
  %131 = extractelement <4 x float> %130, i32 0
  %132 = getelementptr float, float* %2, i32 0
  %133 = getelementptr inbounds float, float* %132, i64 1
  store float %131, float* %133, align 4
  %134 = extractelement <4 x float> %130, i32 1
  %135 = getelementptr float, float* %2, i32 0
  %136 = getelementptr inbounds float, float* %135, i64 2
  store float %134, float* %136, align 4
  %137 = getelementptr float, float* %0, i32 0
  %138 = getelementptr inbounds float, float* %137, i64 2
  %139 = load float, float* %138, align 4
  %140 = insertelement <4 x float> zeroinitializer, float %139, i32 0
  %141 = insertelement <4 x float> %140, float 0.000000e+00, i32 1
  %142 = insertelement <4 x float> %141, float 0.000000e+00, i32 2
  %143 = insertelement <4 x float> %142, float 0.000000e+00, i32 3
  %144 = getelementptr float, float* %1, i32 0
  %145 = load float, float* %144, align 4
  %146 = insertelement <4 x float> zeroinitializer, float %145, i32 0
  %147 = insertelement <4 x float> %146, float 0.000000e+00, i32 1
  %148 = insertelement <4 x float> %147, float 0.000000e+00, i32 2
  %149 = insertelement <4 x float> %148, float 0.000000e+00, i32 3
  %150 = call <4 x float> @llvm.fma.f32.4(<4 x float> %143, <4 x float> %149, <4 x float> zeroinitializer)
  %151 = extractelement <4 x float> %150, i32 0
  %152 = getelementptr float, float* %2, i32 0
  %153 = getelementptr inbounds float, float* %152, i64 2
  store float %151, float* %153, align 4
  %154 = insertelement <4 x float> zeroinitializer, float %139, i32 0
  %155 = insertelement <4 x float> %154, float 1.000000e+00, i32 1
  %156 = insertelement <4 x float> %155, float 1.000000e+00, i32 2
  %157 = insertelement <4 x float> %156, float 1.000000e+00, i32 3
  %158 = insertelement <4 x float> zeroinitializer, float %145, i32 0
  %159 = insertelement <4 x float> %158, float 0.000000e+00, i32 1
  %160 = insertelement <4 x float> %159, float 0.000000e+00, i32 2
  %161 = insertelement <4 x float> %160, float 0.000000e+00, i32 3
  %162 = fmul <4 x float> %157, %161
  %163 = fadd <4 x float> %162, zeroinitializer
  %164 = getelementptr float, float* %0, i32 0
  %165 = getelementptr inbounds float, float* %164, i64 3
  %166 = load float, float* %165, align 4
  %167 = insertelement <4 x float> zeroinitializer, float %166, i32 0
  %168 = insertelement <4 x float> %167, float 0.000000e+00, i32 1
  %169 = insertelement <4 x float> %168, float 0.000000e+00, i32 2
  %170 = insertelement <4 x float> %169, float 0.000000e+00, i32 3
  %171 = getelementptr float, float* %1, i32 0
  %172 = getelementptr inbounds float, float* %171, i64 2
  %173 = load float, float* %172, align 4
  %174 = insertelement <4 x float> zeroinitializer, float %173, i32 0
  %175 = insertelement <4 x float> %174, float 0.000000e+00, i32 1
  %176 = insertelement <4 x float> %175, float 0.000000e+00, i32 2
  %177 = insertelement <4 x float> %176, float 0.000000e+00, i32 3
  %178 = call <4 x float> @llvm.fma.f32.5(<4 x float> %170, <4 x float> %177, <4 x float> %163)
  %179 = extractelement <4 x float> %178, i32 0
  %180 = getelementptr float, float* %2, i32 0
  %181 = getelementptr inbounds float, float* %180, i64 2
  store float %179, float* %181, align 4
  %182 = extractelement <4 x float> %178, i32 1
  %183 = getelementptr float, float* %2, i32 0
  %184 = getelementptr inbounds float, float* %183, i64 3
  store float %182, float* %184, align 4
  %185 = getelementptr float, float* %0, i32 0
  %186 = getelementptr inbounds float, float* %185, i64 2
  %187 = load float, float* %186, align 4
  %188 = insertelement <4 x float> zeroinitializer, float %187, i32 0
  %189 = insertelement <4 x float> %188, float 0.000000e+00, i32 1
  %190 = insertelement <4 x float> %189, float 0.000000e+00, i32 2
  %191 = insertelement <4 x float> %190, float 0.000000e+00, i32 3
  %192 = getelementptr float, float* %1, i32 0
  %193 = getelementptr inbounds float, float* %192, i64 1
  %194 = load float, float* %193, align 4
  %195 = insertelement <4 x float> zeroinitializer, float %194, i32 0
  %196 = insertelement <4 x float> %195, float 0.000000e+00, i32 1
  %197 = insertelement <4 x float> %196, float 0.000000e+00, i32 2
  %198 = insertelement <4 x float> %197, float 0.000000e+00, i32 3
  %199 = call <4 x float> @llvm.fma.f32.6(<4 x float> %191, <4 x float> %198, <4 x float> zeroinitializer)
  %200 = extractelement <4 x float> %199, i32 0
  %201 = getelementptr float, float* %2, i32 0
  %202 = getelementptr inbounds float, float* %201, i64 3
  store float %200, float* %202, align 4
  %203 = insertelement <4 x float> zeroinitializer, float %187, i32 0
  %204 = insertelement <4 x float> %203, float 1.000000e+00, i32 1
  %205 = insertelement <4 x float> %204, float 1.000000e+00, i32 2
  %206 = insertelement <4 x float> %205, float 1.000000e+00, i32 3
  %207 = insertelement <4 x float> zeroinitializer, float %194, i32 0
  %208 = insertelement <4 x float> %207, float 0.000000e+00, i32 1
  %209 = insertelement <4 x float> %208, float 0.000000e+00, i32 2
  %210 = insertelement <4 x float> %209, float 0.000000e+00, i32 3
  %211 = fmul <4 x float> %206, %210
  %212 = fadd <4 x float> %211, zeroinitializer
  %213 = getelementptr float, float* %0, i32 0
  %214 = getelementptr inbounds float, float* %213, i64 3
  %215 = load float, float* %214, align 4
  %216 = insertelement <4 x float> zeroinitializer, float %215, i32 0
  %217 = insertelement <4 x float> %216, float 0.000000e+00, i32 1
  %218 = insertelement <4 x float> %217, float 0.000000e+00, i32 2
  %219 = insertelement <4 x float> %218, float 0.000000e+00, i32 3
  %220 = getelementptr float, float* %1, i32 0
  %221 = getelementptr inbounds float, float* %220, i64 3
  %222 = load float, float* %221, align 4
  %223 = insertelement <4 x float> zeroinitializer, float %222, i32 0
  %224 = insertelement <4 x float> %223, float 0.000000e+00, i32 1
  %225 = insertelement <4 x float> %224, float 0.000000e+00, i32 2
  %226 = insertelement <4 x float> %225, float 0.000000e+00, i32 3
  %227 = call <4 x float> @llvm.fma.f32.7(<4 x float> %219, <4 x float> %226, <4 x float> %212)
  %228 = extractelement <4 x float> %227, i32 0
  %229 = getelementptr float, float* %2, i32 0
  %230 = getelementptr inbounds float, float* %229, i64 3
  store float %228, float* %230, align 4
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
  %35 = call float @llvm.sqrt.f32(float %34) #8
  %36 = fneg float %29
  %37 = fmul float %35, %36
  %38 = fadd float %24, %37
  %39 = fmul float %37, 0.000000e+00
  %40 = fadd float %32, %39
  %41 = fmul float %38, %38
  %42 = fadd float %41, 0.000000e+00
  %43 = fmul float %40, %40
  %44 = fadd float %42, %43
  %45 = call float @llvm.sqrt.f32(float %44) #8
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
  %150 = bitcast i32 %102 to float
  %151 = bitcast i32 %102 to float
  %152 = fmul float %150, %151
  %153 = fadd float %152, 0.000000e+00
  %154 = bitcast i32 %131 to float
  %155 = bitcast i32 %131 to float
  %156 = fmul float %154, %155
  %157 = fadd float %153, %156
  %158 = call float @llvm.sqrt.f32.8(float %157)
  %159 = bitcast i32 %102 to float
  %160 = fcmp olt float %159, 0.000000e+00
  %161 = sext i1 %160 to i32
  %162 = bitcast i32 %102 to float
  %163 = fcmp ogt float %162, 0.000000e+00
  %164 = zext i1 %163 to i32
  %165 = add nsw i32 %161, %164
  %166 = sitofp i32 %165 to float
  %167 = fneg float %166
  %168 = fmul float %158, %167
  %169 = bitcast i32 %102 to float
  %170 = fadd float %169, %168
  %171 = bitcast i32 %102 to float
  %172 = bitcast i32 %102 to float
  %173 = fmul float %171, %172
  %174 = fadd float %173, 0.000000e+00
  %175 = bitcast i32 %131 to float
  %176 = bitcast i32 %131 to float
  %177 = fmul float %175, %176
  %178 = fadd float %174, %177
  %179 = call float @llvm.sqrt.f32.9(float %178)
  %180 = bitcast i32 %102 to float
  %181 = fcmp olt float %180, 0.000000e+00
  %182 = sext i1 %181 to i32
  %183 = bitcast i32 %102 to float
  %184 = fcmp ogt float %183, 0.000000e+00
  %185 = zext i1 %184 to i32
  %186 = add nsw i32 %182, %185
  %187 = sitofp i32 %186 to float
  %188 = fneg float %187
  %189 = fmul float %179, %188
  %190 = bitcast i32 %102 to float
  %191 = fadd float %190, %189
  %192 = bitcast i32 %102 to float
  %193 = bitcast i32 %102 to float
  %194 = fmul float %192, %193
  %195 = fadd float %194, 0.000000e+00
  %196 = bitcast i32 %131 to float
  %197 = bitcast i32 %131 to float
  %198 = fmul float %196, %197
  %199 = fadd float %195, %198
  %200 = call float @llvm.sqrt.f32.10(float %199)
  %201 = bitcast i32 %102 to float
  %202 = fcmp olt float %201, 0.000000e+00
  %203 = sext i1 %202 to i32
  %204 = bitcast i32 %102 to float
  %205 = fcmp ogt float %204, 0.000000e+00
  %206 = zext i1 %205 to i32
  %207 = add nsw i32 %203, %206
  %208 = sitofp i32 %207 to float
  %209 = fneg float %208
  %210 = fmul float %200, %209
  %211 = bitcast i32 %102 to float
  %212 = fadd float %211, %210
  %213 = fmul float %191, %212
  %214 = fadd float %213, 0.000000e+00
  %215 = bitcast i32 %102 to float
  %216 = bitcast i32 %102 to float
  %217 = fmul float %215, %216
  %218 = fadd float %217, 0.000000e+00
  %219 = bitcast i32 %131 to float
  %220 = bitcast i32 %131 to float
  %221 = fmul float %219, %220
  %222 = fadd float %218, %221
  %223 = call float @llvm.sqrt.f32.11(float %222)
  %224 = bitcast i32 %102 to float
  %225 = fcmp olt float %224, 0.000000e+00
  %226 = sext i1 %225 to i32
  %227 = bitcast i32 %102 to float
  %228 = fcmp ogt float %227, 0.000000e+00
  %229 = zext i1 %228 to i32
  %230 = add nsw i32 %226, %229
  %231 = sitofp i32 %230 to float
  %232 = fneg float %231
  %233 = fmul float %223, %232
  %234 = fmul float %233, 0.000000e+00
  %235 = bitcast i32 %131 to float
  %236 = fadd float %235, %234
  %237 = bitcast i32 %102 to float
  %238 = bitcast i32 %102 to float
  %239 = fmul float %237, %238
  %240 = fadd float %239, 0.000000e+00
  %241 = bitcast i32 %131 to float
  %242 = bitcast i32 %131 to float
  %243 = fmul float %241, %242
  %244 = fadd float %240, %243
  %245 = call float @llvm.sqrt.f32.12(float %244)
  %246 = bitcast i32 %102 to float
  %247 = fcmp olt float %246, 0.000000e+00
  %248 = sext i1 %247 to i32
  %249 = bitcast i32 %102 to float
  %250 = fcmp ogt float %249, 0.000000e+00
  %251 = zext i1 %250 to i32
  %252 = add nsw i32 %248, %251
  %253 = sitofp i32 %252 to float
  %254 = fneg float %253
  %255 = fmul float %245, %254
  %256 = fmul float %255, 0.000000e+00
  %257 = bitcast i32 %131 to float
  %258 = fadd float %257, %256
  %259 = fmul float %236, %258
  %260 = fadd float %214, %259
  %261 = call float @llvm.sqrt.f32.13(float %260)
  %262 = fadd float %261, 0.000000e+00
  %263 = fdiv float %170, %262
  %264 = fmul float %263, 2.000000e+00
  %265 = bitcast i32 %102 to float
  %266 = bitcast i32 %102 to float
  %267 = fmul float %265, %266
  %268 = fadd float %267, 0.000000e+00
  %269 = bitcast i32 %131 to float
  %270 = bitcast i32 %131 to float
  %271 = fmul float %269, %270
  %272 = fadd float %268, %271
  %273 = call float @llvm.sqrt.f32.14(float %272)
  %274 = bitcast i32 %102 to float
  %275 = fcmp olt float %274, 0.000000e+00
  %276 = sext i1 %275 to i32
  %277 = bitcast i32 %102 to float
  %278 = fcmp ogt float %277, 0.000000e+00
  %279 = zext i1 %278 to i32
  %280 = add nsw i32 %276, %279
  %281 = sitofp i32 %280 to float
  %282 = fneg float %281
  %283 = fmul float %273, %282
  %284 = bitcast i32 %102 to float
  %285 = fadd float %284, %283
  %286 = bitcast i32 %102 to float
  %287 = bitcast i32 %102 to float
  %288 = fmul float %286, %287
  %289 = fadd float %288, 0.000000e+00
  %290 = bitcast i32 %131 to float
  %291 = bitcast i32 %131 to float
  %292 = fmul float %290, %291
  %293 = fadd float %289, %292
  %294 = call float @llvm.sqrt.f32.15(float %293)
  %295 = bitcast i32 %102 to float
  %296 = fcmp olt float %295, 0.000000e+00
  %297 = sext i1 %296 to i32
  %298 = bitcast i32 %102 to float
  %299 = fcmp ogt float %298, 0.000000e+00
  %300 = zext i1 %299 to i32
  %301 = add nsw i32 %297, %300
  %302 = sitofp i32 %301 to float
  %303 = fneg float %302
  %304 = fmul float %294, %303
  %305 = bitcast i32 %102 to float
  %306 = fadd float %305, %304
  %307 = bitcast i32 %102 to float
  %308 = bitcast i32 %102 to float
  %309 = fmul float %307, %308
  %310 = fadd float %309, 0.000000e+00
  %311 = bitcast i32 %131 to float
  %312 = bitcast i32 %131 to float
  %313 = fmul float %311, %312
  %314 = fadd float %310, %313
  %315 = call float @llvm.sqrt.f32.16(float %314)
  %316 = bitcast i32 %102 to float
  %317 = fcmp olt float %316, 0.000000e+00
  %318 = sext i1 %317 to i32
  %319 = bitcast i32 %102 to float
  %320 = fcmp ogt float %319, 0.000000e+00
  %321 = zext i1 %320 to i32
  %322 = add nsw i32 %318, %321
  %323 = sitofp i32 %322 to float
  %324 = fneg float %323
  %325 = fmul float %315, %324
  %326 = bitcast i32 %102 to float
  %327 = fadd float %326, %325
  %328 = fmul float %306, %327
  %329 = fadd float %328, 0.000000e+00
  %330 = bitcast i32 %102 to float
  %331 = bitcast i32 %102 to float
  %332 = fmul float %330, %331
  %333 = fadd float %332, 0.000000e+00
  %334 = bitcast i32 %131 to float
  %335 = bitcast i32 %131 to float
  %336 = fmul float %334, %335
  %337 = fadd float %333, %336
  %338 = call float @llvm.sqrt.f32.17(float %337)
  %339 = bitcast i32 %102 to float
  %340 = fcmp olt float %339, 0.000000e+00
  %341 = sext i1 %340 to i32
  %342 = bitcast i32 %102 to float
  %343 = fcmp ogt float %342, 0.000000e+00
  %344 = zext i1 %343 to i32
  %345 = add nsw i32 %341, %344
  %346 = sitofp i32 %345 to float
  %347 = fneg float %346
  %348 = fmul float %338, %347
  %349 = fmul float %348, 0.000000e+00
  %350 = bitcast i32 %131 to float
  %351 = fadd float %350, %349
  %352 = bitcast i32 %102 to float
  %353 = bitcast i32 %102 to float
  %354 = fmul float %352, %353
  %355 = fadd float %354, 0.000000e+00
  %356 = bitcast i32 %131 to float
  %357 = bitcast i32 %131 to float
  %358 = fmul float %356, %357
  %359 = fadd float %355, %358
  %360 = call float @llvm.sqrt.f32.18(float %359)
  %361 = bitcast i32 %102 to float
  %362 = fcmp olt float %361, 0.000000e+00
  %363 = sext i1 %362 to i32
  %364 = bitcast i32 %102 to float
  %365 = fcmp ogt float %364, 0.000000e+00
  %366 = zext i1 %365 to i32
  %367 = add nsw i32 %363, %366
  %368 = sitofp i32 %367 to float
  %369 = fneg float %368
  %370 = fmul float %360, %369
  %371 = fmul float %370, 0.000000e+00
  %372 = bitcast i32 %131 to float
  %373 = fadd float %372, %371
  %374 = fmul float %351, %373
  %375 = fadd float %329, %374
  %376 = call float @llvm.sqrt.f32.19(float %375)
  %377 = fadd float %376, 0.000000e+00
  %378 = fdiv float %285, %377
  %379 = fmul float %264, %378
  %380 = insertelement <4 x float> %149, float %379, i32 1
  %381 = bitcast i32 %102 to float
  %382 = bitcast i32 %102 to float
  %383 = fmul float %381, %382
  %384 = fadd float %383, 0.000000e+00
  %385 = bitcast i32 %131 to float
  %386 = bitcast i32 %131 to float
  %387 = fmul float %385, %386
  %388 = fadd float %384, %387
  %389 = call float @llvm.sqrt.f32.20(float %388)
  %390 = bitcast i32 %102 to float
  %391 = fcmp olt float %390, 0.000000e+00
  %392 = sext i1 %391 to i32
  %393 = bitcast i32 %102 to float
  %394 = fcmp ogt float %393, 0.000000e+00
  %395 = zext i1 %394 to i32
  %396 = add nsw i32 %392, %395
  %397 = sitofp i32 %396 to float
  %398 = fneg float %397
  %399 = fmul float %389, %398
  %400 = bitcast i32 %102 to float
  %401 = fadd float %400, %399
  %402 = bitcast i32 %102 to float
  %403 = bitcast i32 %102 to float
  %404 = fmul float %402, %403
  %405 = fadd float %404, 0.000000e+00
  %406 = bitcast i32 %131 to float
  %407 = bitcast i32 %131 to float
  %408 = fmul float %406, %407
  %409 = fadd float %405, %408
  %410 = call float @llvm.sqrt.f32.21(float %409)
  %411 = bitcast i32 %102 to float
  %412 = fcmp olt float %411, 0.000000e+00
  %413 = sext i1 %412 to i32
  %414 = bitcast i32 %102 to float
  %415 = fcmp ogt float %414, 0.000000e+00
  %416 = zext i1 %415 to i32
  %417 = add nsw i32 %413, %416
  %418 = sitofp i32 %417 to float
  %419 = fneg float %418
  %420 = fmul float %410, %419
  %421 = bitcast i32 %102 to float
  %422 = fadd float %421, %420
  %423 = bitcast i32 %102 to float
  %424 = bitcast i32 %102 to float
  %425 = fmul float %423, %424
  %426 = fadd float %425, 0.000000e+00
  %427 = bitcast i32 %131 to float
  %428 = bitcast i32 %131 to float
  %429 = fmul float %427, %428
  %430 = fadd float %426, %429
  %431 = call float @llvm.sqrt.f32.22(float %430)
  %432 = bitcast i32 %102 to float
  %433 = fcmp olt float %432, 0.000000e+00
  %434 = sext i1 %433 to i32
  %435 = bitcast i32 %102 to float
  %436 = fcmp ogt float %435, 0.000000e+00
  %437 = zext i1 %436 to i32
  %438 = add nsw i32 %434, %437
  %439 = sitofp i32 %438 to float
  %440 = fneg float %439
  %441 = fmul float %431, %440
  %442 = bitcast i32 %102 to float
  %443 = fadd float %442, %441
  %444 = fmul float %422, %443
  %445 = fadd float %444, 0.000000e+00
  %446 = bitcast i32 %102 to float
  %447 = bitcast i32 %102 to float
  %448 = fmul float %446, %447
  %449 = fadd float %448, 0.000000e+00
  %450 = bitcast i32 %131 to float
  %451 = bitcast i32 %131 to float
  %452 = fmul float %450, %451
  %453 = fadd float %449, %452
  %454 = call float @llvm.sqrt.f32.23(float %453)
  %455 = bitcast i32 %102 to float
  %456 = fcmp olt float %455, 0.000000e+00
  %457 = sext i1 %456 to i32
  %458 = bitcast i32 %102 to float
  %459 = fcmp ogt float %458, 0.000000e+00
  %460 = zext i1 %459 to i32
  %461 = add nsw i32 %457, %460
  %462 = sitofp i32 %461 to float
  %463 = fneg float %462
  %464 = fmul float %454, %463
  %465 = fmul float %464, 0.000000e+00
  %466 = bitcast i32 %131 to float
  %467 = fadd float %466, %465
  %468 = bitcast i32 %102 to float
  %469 = bitcast i32 %102 to float
  %470 = fmul float %468, %469
  %471 = fadd float %470, 0.000000e+00
  %472 = bitcast i32 %131 to float
  %473 = bitcast i32 %131 to float
  %474 = fmul float %472, %473
  %475 = fadd float %471, %474
  %476 = call float @llvm.sqrt.f32.24(float %475)
  %477 = bitcast i32 %102 to float
  %478 = fcmp olt float %477, 0.000000e+00
  %479 = sext i1 %478 to i32
  %480 = bitcast i32 %102 to float
  %481 = fcmp ogt float %480, 0.000000e+00
  %482 = zext i1 %481 to i32
  %483 = add nsw i32 %479, %482
  %484 = sitofp i32 %483 to float
  %485 = fneg float %484
  %486 = fmul float %476, %485
  %487 = fmul float %486, 0.000000e+00
  %488 = bitcast i32 %131 to float
  %489 = fadd float %488, %487
  %490 = fmul float %467, %489
  %491 = fadd float %445, %490
  %492 = call float @llvm.sqrt.f32.25(float %491)
  %493 = fadd float %492, 0.000000e+00
  %494 = fdiv float %401, %493
  %495 = fmul float %494, 2.000000e+00
  %496 = bitcast i32 %102 to float
  %497 = bitcast i32 %102 to float
  %498 = fmul float %496, %497
  %499 = fadd float %498, 0.000000e+00
  %500 = bitcast i32 %131 to float
  %501 = bitcast i32 %131 to float
  %502 = fmul float %500, %501
  %503 = fadd float %499, %502
  %504 = call float @llvm.sqrt.f32.26(float %503)
  %505 = bitcast i32 %102 to float
  %506 = fcmp olt float %505, 0.000000e+00
  %507 = sext i1 %506 to i32
  %508 = bitcast i32 %102 to float
  %509 = fcmp ogt float %508, 0.000000e+00
  %510 = zext i1 %509 to i32
  %511 = add nsw i32 %507, %510
  %512 = sitofp i32 %511 to float
  %513 = fneg float %512
  %514 = fmul float %504, %513
  %515 = fmul float %514, 0.000000e+00
  %516 = bitcast i32 %131 to float
  %517 = fadd float %516, %515
  %518 = bitcast i32 %102 to float
  %519 = bitcast i32 %102 to float
  %520 = fmul float %518, %519
  %521 = fadd float %520, 0.000000e+00
  %522 = bitcast i32 %131 to float
  %523 = bitcast i32 %131 to float
  %524 = fmul float %522, %523
  %525 = fadd float %521, %524
  %526 = call float @llvm.sqrt.f32.27(float %525)
  %527 = bitcast i32 %102 to float
  %528 = fcmp olt float %527, 0.000000e+00
  %529 = sext i1 %528 to i32
  %530 = bitcast i32 %102 to float
  %531 = fcmp ogt float %530, 0.000000e+00
  %532 = zext i1 %531 to i32
  %533 = add nsw i32 %529, %532
  %534 = sitofp i32 %533 to float
  %535 = fneg float %534
  %536 = fmul float %526, %535
  %537 = bitcast i32 %102 to float
  %538 = fadd float %537, %536
  %539 = bitcast i32 %102 to float
  %540 = bitcast i32 %102 to float
  %541 = fmul float %539, %540
  %542 = fadd float %541, 0.000000e+00
  %543 = bitcast i32 %131 to float
  %544 = bitcast i32 %131 to float
  %545 = fmul float %543, %544
  %546 = fadd float %542, %545
  %547 = call float @llvm.sqrt.f32.28(float %546)
  %548 = bitcast i32 %102 to float
  %549 = fcmp olt float %548, 0.000000e+00
  %550 = sext i1 %549 to i32
  %551 = bitcast i32 %102 to float
  %552 = fcmp ogt float %551, 0.000000e+00
  %553 = zext i1 %552 to i32
  %554 = add nsw i32 %550, %553
  %555 = sitofp i32 %554 to float
  %556 = fneg float %555
  %557 = fmul float %547, %556
  %558 = bitcast i32 %102 to float
  %559 = fadd float %558, %557
  %560 = fmul float %538, %559
  %561 = fadd float %560, 0.000000e+00
  %562 = bitcast i32 %102 to float
  %563 = bitcast i32 %102 to float
  %564 = fmul float %562, %563
  %565 = fadd float %564, 0.000000e+00
  %566 = bitcast i32 %131 to float
  %567 = bitcast i32 %131 to float
  %568 = fmul float %566, %567
  %569 = fadd float %565, %568
  %570 = call float @llvm.sqrt.f32.29(float %569)
  %571 = bitcast i32 %102 to float
  %572 = fcmp olt float %571, 0.000000e+00
  %573 = sext i1 %572 to i32
  %574 = bitcast i32 %102 to float
  %575 = fcmp ogt float %574, 0.000000e+00
  %576 = zext i1 %575 to i32
  %577 = add nsw i32 %573, %576
  %578 = sitofp i32 %577 to float
  %579 = fneg float %578
  %580 = fmul float %570, %579
  %581 = fmul float %580, 0.000000e+00
  %582 = bitcast i32 %131 to float
  %583 = fadd float %582, %581
  %584 = bitcast i32 %102 to float
  %585 = bitcast i32 %102 to float
  %586 = fmul float %584, %585
  %587 = fadd float %586, 0.000000e+00
  %588 = bitcast i32 %131 to float
  %589 = bitcast i32 %131 to float
  %590 = fmul float %588, %589
  %591 = fadd float %587, %590
  %592 = call float @llvm.sqrt.f32.30(float %591)
  %593 = bitcast i32 %102 to float
  %594 = fcmp olt float %593, 0.000000e+00
  %595 = sext i1 %594 to i32
  %596 = bitcast i32 %102 to float
  %597 = fcmp ogt float %596, 0.000000e+00
  %598 = zext i1 %597 to i32
  %599 = add nsw i32 %595, %598
  %600 = sitofp i32 %599 to float
  %601 = fneg float %600
  %602 = fmul float %592, %601
  %603 = fmul float %602, 0.000000e+00
  %604 = bitcast i32 %131 to float
  %605 = fadd float %604, %603
  %606 = fmul float %583, %605
  %607 = fadd float %561, %606
  %608 = call float @llvm.sqrt.f32.31(float %607)
  %609 = fadd float %608, 0.000000e+00
  %610 = fdiv float %517, %609
  %611 = fmul float %495, %610
  %612 = insertelement <4 x float> %380, float %611, i32 2
  %613 = bitcast i32 %102 to float
  %614 = bitcast i32 %102 to float
  %615 = fmul float %613, %614
  %616 = fadd float %615, 0.000000e+00
  %617 = bitcast i32 %131 to float
  %618 = bitcast i32 %131 to float
  %619 = fmul float %617, %618
  %620 = fadd float %616, %619
  %621 = call float @llvm.sqrt.f32.32(float %620)
  %622 = bitcast i32 %102 to float
  %623 = fcmp olt float %622, 0.000000e+00
  %624 = sext i1 %623 to i32
  %625 = bitcast i32 %102 to float
  %626 = fcmp ogt float %625, 0.000000e+00
  %627 = zext i1 %626 to i32
  %628 = add nsw i32 %624, %627
  %629 = sitofp i32 %628 to float
  %630 = fneg float %629
  %631 = fmul float %621, %630
  %632 = fmul float %631, 0.000000e+00
  %633 = bitcast i32 %131 to float
  %634 = fadd float %633, %632
  %635 = bitcast i32 %102 to float
  %636 = bitcast i32 %102 to float
  %637 = fmul float %635, %636
  %638 = fadd float %637, 0.000000e+00
  %639 = bitcast i32 %131 to float
  %640 = bitcast i32 %131 to float
  %641 = fmul float %639, %640
  %642 = fadd float %638, %641
  %643 = call float @llvm.sqrt.f32.33(float %642)
  %644 = bitcast i32 %102 to float
  %645 = fcmp olt float %644, 0.000000e+00
  %646 = sext i1 %645 to i32
  %647 = bitcast i32 %102 to float
  %648 = fcmp ogt float %647, 0.000000e+00
  %649 = zext i1 %648 to i32
  %650 = add nsw i32 %646, %649
  %651 = sitofp i32 %650 to float
  %652 = fneg float %651
  %653 = fmul float %643, %652
  %654 = bitcast i32 %102 to float
  %655 = fadd float %654, %653
  %656 = bitcast i32 %102 to float
  %657 = bitcast i32 %102 to float
  %658 = fmul float %656, %657
  %659 = fadd float %658, 0.000000e+00
  %660 = bitcast i32 %131 to float
  %661 = bitcast i32 %131 to float
  %662 = fmul float %660, %661
  %663 = fadd float %659, %662
  %664 = call float @llvm.sqrt.f32.34(float %663)
  %665 = bitcast i32 %102 to float
  %666 = fcmp olt float %665, 0.000000e+00
  %667 = sext i1 %666 to i32
  %668 = bitcast i32 %102 to float
  %669 = fcmp ogt float %668, 0.000000e+00
  %670 = zext i1 %669 to i32
  %671 = add nsw i32 %667, %670
  %672 = sitofp i32 %671 to float
  %673 = fneg float %672
  %674 = fmul float %664, %673
  %675 = bitcast i32 %102 to float
  %676 = fadd float %675, %674
  %677 = fmul float %655, %676
  %678 = fadd float %677, 0.000000e+00
  %679 = bitcast i32 %102 to float
  %680 = bitcast i32 %102 to float
  %681 = fmul float %679, %680
  %682 = fadd float %681, 0.000000e+00
  %683 = bitcast i32 %131 to float
  %684 = bitcast i32 %131 to float
  %685 = fmul float %683, %684
  %686 = fadd float %682, %685
  %687 = call float @llvm.sqrt.f32.35(float %686)
  %688 = bitcast i32 %102 to float
  %689 = fcmp olt float %688, 0.000000e+00
  %690 = sext i1 %689 to i32
  %691 = bitcast i32 %102 to float
  %692 = fcmp ogt float %691, 0.000000e+00
  %693 = zext i1 %692 to i32
  %694 = add nsw i32 %690, %693
  %695 = sitofp i32 %694 to float
  %696 = fneg float %695
  %697 = fmul float %687, %696
  %698 = fmul float %697, 0.000000e+00
  %699 = bitcast i32 %131 to float
  %700 = fadd float %699, %698
  %701 = bitcast i32 %102 to float
  %702 = bitcast i32 %102 to float
  %703 = fmul float %701, %702
  %704 = fadd float %703, 0.000000e+00
  %705 = bitcast i32 %131 to float
  %706 = bitcast i32 %131 to float
  %707 = fmul float %705, %706
  %708 = fadd float %704, %707
  %709 = call float @llvm.sqrt.f32.36(float %708)
  %710 = bitcast i32 %102 to float
  %711 = fcmp olt float %710, 0.000000e+00
  %712 = sext i1 %711 to i32
  %713 = bitcast i32 %102 to float
  %714 = fcmp ogt float %713, 0.000000e+00
  %715 = zext i1 %714 to i32
  %716 = add nsw i32 %712, %715
  %717 = sitofp i32 %716 to float
  %718 = fneg float %717
  %719 = fmul float %709, %718
  %720 = fmul float %719, 0.000000e+00
  %721 = bitcast i32 %131 to float
  %722 = fadd float %721, %720
  %723 = fmul float %700, %722
  %724 = fadd float %678, %723
  %725 = call float @llvm.sqrt.f32.37(float %724)
  %726 = fadd float %725, 0.000000e+00
  %727 = fdiv float %634, %726
  %728 = fmul float %727, 2.000000e+00
  %729 = bitcast i32 %102 to float
  %730 = bitcast i32 %102 to float
  %731 = fmul float %729, %730
  %732 = fadd float %731, 0.000000e+00
  %733 = bitcast i32 %131 to float
  %734 = bitcast i32 %131 to float
  %735 = fmul float %733, %734
  %736 = fadd float %732, %735
  %737 = call float @llvm.sqrt.f32.38(float %736)
  %738 = bitcast i32 %102 to float
  %739 = fcmp olt float %738, 0.000000e+00
  %740 = sext i1 %739 to i32
  %741 = bitcast i32 %102 to float
  %742 = fcmp ogt float %741, 0.000000e+00
  %743 = zext i1 %742 to i32
  %744 = add nsw i32 %740, %743
  %745 = sitofp i32 %744 to float
  %746 = fneg float %745
  %747 = fmul float %737, %746
  %748 = bitcast i32 %102 to float
  %749 = fadd float %748, %747
  %750 = bitcast i32 %102 to float
  %751 = bitcast i32 %102 to float
  %752 = fmul float %750, %751
  %753 = fadd float %752, 0.000000e+00
  %754 = bitcast i32 %131 to float
  %755 = bitcast i32 %131 to float
  %756 = fmul float %754, %755
  %757 = fadd float %753, %756
  %758 = call float @llvm.sqrt.f32.39(float %757)
  %759 = bitcast i32 %102 to float
  %760 = fcmp olt float %759, 0.000000e+00
  %761 = sext i1 %760 to i32
  %762 = bitcast i32 %102 to float
  %763 = fcmp ogt float %762, 0.000000e+00
  %764 = zext i1 %763 to i32
  %765 = add nsw i32 %761, %764
  %766 = sitofp i32 %765 to float
  %767 = fneg float %766
  %768 = fmul float %758, %767
  %769 = bitcast i32 %102 to float
  %770 = fadd float %769, %768
  %771 = bitcast i32 %102 to float
  %772 = bitcast i32 %102 to float
  %773 = fmul float %771, %772
  %774 = fadd float %773, 0.000000e+00
  %775 = bitcast i32 %131 to float
  %776 = bitcast i32 %131 to float
  %777 = fmul float %775, %776
  %778 = fadd float %774, %777
  %779 = call float @llvm.sqrt.f32.40(float %778)
  %780 = bitcast i32 %102 to float
  %781 = fcmp olt float %780, 0.000000e+00
  %782 = sext i1 %781 to i32
  %783 = bitcast i32 %102 to float
  %784 = fcmp ogt float %783, 0.000000e+00
  %785 = zext i1 %784 to i32
  %786 = add nsw i32 %782, %785
  %787 = sitofp i32 %786 to float
  %788 = fneg float %787
  %789 = fmul float %779, %788
  %790 = bitcast i32 %102 to float
  %791 = fadd float %790, %789
  %792 = fmul float %770, %791
  %793 = fadd float %792, 0.000000e+00
  %794 = bitcast i32 %102 to float
  %795 = bitcast i32 %102 to float
  %796 = fmul float %794, %795
  %797 = fadd float %796, 0.000000e+00
  %798 = bitcast i32 %131 to float
  %799 = bitcast i32 %131 to float
  %800 = fmul float %798, %799
  %801 = fadd float %797, %800
  %802 = call float @llvm.sqrt.f32.41(float %801)
  %803 = bitcast i32 %102 to float
  %804 = fcmp olt float %803, 0.000000e+00
  %805 = sext i1 %804 to i32
  %806 = bitcast i32 %102 to float
  %807 = fcmp ogt float %806, 0.000000e+00
  %808 = zext i1 %807 to i32
  %809 = add nsw i32 %805, %808
  %810 = sitofp i32 %809 to float
  %811 = fneg float %810
  %812 = fmul float %802, %811
  %813 = fmul float %812, 0.000000e+00
  %814 = bitcast i32 %131 to float
  %815 = fadd float %814, %813
  %816 = bitcast i32 %102 to float
  %817 = bitcast i32 %102 to float
  %818 = fmul float %816, %817
  %819 = fadd float %818, 0.000000e+00
  %820 = bitcast i32 %131 to float
  %821 = bitcast i32 %131 to float
  %822 = fmul float %820, %821
  %823 = fadd float %819, %822
  %824 = call float @llvm.sqrt.f32.42(float %823)
  %825 = bitcast i32 %102 to float
  %826 = fcmp olt float %825, 0.000000e+00
  %827 = sext i1 %826 to i32
  %828 = bitcast i32 %102 to float
  %829 = fcmp ogt float %828, 0.000000e+00
  %830 = zext i1 %829 to i32
  %831 = add nsw i32 %827, %830
  %832 = sitofp i32 %831 to float
  %833 = fneg float %832
  %834 = fmul float %824, %833
  %835 = fmul float %834, 0.000000e+00
  %836 = bitcast i32 %131 to float
  %837 = fadd float %836, %835
  %838 = fmul float %815, %837
  %839 = fadd float %793, %838
  %840 = call float @llvm.sqrt.f32.43(float %839)
  %841 = fadd float %840, 0.000000e+00
  %842 = fdiv float %749, %841
  %843 = fmul float %728, %842
  %844 = insertelement <4 x float> %612, float %843, i32 3
  %845 = fsub <4 x float> <float 0.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, %844
  %846 = bitcast i32 %102 to float
  %847 = bitcast i32 %102 to float
  %848 = fmul float %846, %847
  %849 = fadd float %848, 0.000000e+00
  %850 = bitcast i32 %131 to float
  %851 = bitcast i32 %131 to float
  %852 = fmul float %850, %851
  %853 = fadd float %849, %852
  %854 = call float @llvm.sqrt.f32.44(float %853)
  %855 = bitcast i32 %102 to float
  %856 = fcmp olt float %855, 0.000000e+00
  %857 = sext i1 %856 to i32
  %858 = bitcast i32 %102 to float
  %859 = fcmp ogt float %858, 0.000000e+00
  %860 = zext i1 %859 to i32
  %861 = add nsw i32 %857, %860
  %862 = sitofp i32 %861 to float
  %863 = fneg float %862
  %864 = fmul float %854, %863
  %865 = fmul float %864, 0.000000e+00
  %866 = bitcast i32 %131 to float
  %867 = fadd float %866, %865
  %868 = bitcast i32 %102 to float
  %869 = bitcast i32 %102 to float
  %870 = fmul float %868, %869
  %871 = fadd float %870, 0.000000e+00
  %872 = bitcast i32 %131 to float
  %873 = bitcast i32 %131 to float
  %874 = fmul float %872, %873
  %875 = fadd float %871, %874
  %876 = call float @llvm.sqrt.f32.45(float %875)
  %877 = bitcast i32 %102 to float
  %878 = fcmp olt float %877, 0.000000e+00
  %879 = sext i1 %878 to i32
  %880 = bitcast i32 %102 to float
  %881 = fcmp ogt float %880, 0.000000e+00
  %882 = zext i1 %881 to i32
  %883 = add nsw i32 %879, %882
  %884 = sitofp i32 %883 to float
  %885 = fneg float %884
  %886 = fmul float %876, %885
  %887 = bitcast i32 %102 to float
  %888 = fadd float %887, %886
  %889 = bitcast i32 %102 to float
  %890 = bitcast i32 %102 to float
  %891 = fmul float %889, %890
  %892 = fadd float %891, 0.000000e+00
  %893 = bitcast i32 %131 to float
  %894 = bitcast i32 %131 to float
  %895 = fmul float %893, %894
  %896 = fadd float %892, %895
  %897 = call float @llvm.sqrt.f32.46(float %896)
  %898 = bitcast i32 %102 to float
  %899 = fcmp olt float %898, 0.000000e+00
  %900 = sext i1 %899 to i32
  %901 = bitcast i32 %102 to float
  %902 = fcmp ogt float %901, 0.000000e+00
  %903 = zext i1 %902 to i32
  %904 = add nsw i32 %900, %903
  %905 = sitofp i32 %904 to float
  %906 = fneg float %905
  %907 = fmul float %897, %906
  %908 = bitcast i32 %102 to float
  %909 = fadd float %908, %907
  %910 = fmul float %888, %909
  %911 = fadd float %910, 0.000000e+00
  %912 = bitcast i32 %102 to float
  %913 = bitcast i32 %102 to float
  %914 = fmul float %912, %913
  %915 = fadd float %914, 0.000000e+00
  %916 = bitcast i32 %131 to float
  %917 = bitcast i32 %131 to float
  %918 = fmul float %916, %917
  %919 = fadd float %915, %918
  %920 = call float @llvm.sqrt.f32.47(float %919)
  %921 = bitcast i32 %102 to float
  %922 = fcmp olt float %921, 0.000000e+00
  %923 = sext i1 %922 to i32
  %924 = bitcast i32 %102 to float
  %925 = fcmp ogt float %924, 0.000000e+00
  %926 = zext i1 %925 to i32
  %927 = add nsw i32 %923, %926
  %928 = sitofp i32 %927 to float
  %929 = fneg float %928
  %930 = fmul float %920, %929
  %931 = fmul float %930, 0.000000e+00
  %932 = bitcast i32 %131 to float
  %933 = fadd float %932, %931
  %934 = bitcast i32 %102 to float
  %935 = bitcast i32 %102 to float
  %936 = fmul float %934, %935
  %937 = fadd float %936, 0.000000e+00
  %938 = bitcast i32 %131 to float
  %939 = bitcast i32 %131 to float
  %940 = fmul float %938, %939
  %941 = fadd float %937, %940
  %942 = call float @llvm.sqrt.f32.48(float %941)
  %943 = bitcast i32 %102 to float
  %944 = fcmp olt float %943, 0.000000e+00
  %945 = sext i1 %944 to i32
  %946 = bitcast i32 %102 to float
  %947 = fcmp ogt float %946, 0.000000e+00
  %948 = zext i1 %947 to i32
  %949 = add nsw i32 %945, %948
  %950 = sitofp i32 %949 to float
  %951 = fneg float %950
  %952 = fmul float %942, %951
  %953 = fmul float %952, 0.000000e+00
  %954 = bitcast i32 %131 to float
  %955 = fadd float %954, %953
  %956 = fmul float %933, %955
  %957 = fadd float %911, %956
  %958 = call float @llvm.sqrt.f32.49(float %957)
  %959 = fadd float %958, 0.000000e+00
  %960 = fdiv float %867, %959
  %961 = fmul float %960, 2.000000e+00
  %962 = bitcast i32 %102 to float
  %963 = bitcast i32 %102 to float
  %964 = fmul float %962, %963
  %965 = fadd float %964, 0.000000e+00
  %966 = bitcast i32 %131 to float
  %967 = bitcast i32 %131 to float
  %968 = fmul float %966, %967
  %969 = fadd float %965, %968
  %970 = call float @llvm.sqrt.f32.50(float %969)
  %971 = bitcast i32 %102 to float
  %972 = fcmp olt float %971, 0.000000e+00
  %973 = sext i1 %972 to i32
  %974 = bitcast i32 %102 to float
  %975 = fcmp ogt float %974, 0.000000e+00
  %976 = zext i1 %975 to i32
  %977 = add nsw i32 %973, %976
  %978 = sitofp i32 %977 to float
  %979 = fneg float %978
  %980 = fmul float %970, %979
  %981 = fmul float %980, 0.000000e+00
  %982 = bitcast i32 %131 to float
  %983 = fadd float %982, %981
  %984 = bitcast i32 %102 to float
  %985 = bitcast i32 %102 to float
  %986 = fmul float %984, %985
  %987 = fadd float %986, 0.000000e+00
  %988 = bitcast i32 %131 to float
  %989 = bitcast i32 %131 to float
  %990 = fmul float %988, %989
  %991 = fadd float %987, %990
  %992 = call float @llvm.sqrt.f32.51(float %991)
  %993 = bitcast i32 %102 to float
  %994 = fcmp olt float %993, 0.000000e+00
  %995 = sext i1 %994 to i32
  %996 = bitcast i32 %102 to float
  %997 = fcmp ogt float %996, 0.000000e+00
  %998 = zext i1 %997 to i32
  %999 = add nsw i32 %995, %998
  %1000 = sitofp i32 %999 to float
  %1001 = fneg float %1000
  %1002 = fmul float %992, %1001
  %1003 = bitcast i32 %102 to float
  %1004 = fadd float %1003, %1002
  %1005 = bitcast i32 %102 to float
  %1006 = bitcast i32 %102 to float
  %1007 = fmul float %1005, %1006
  %1008 = fadd float %1007, 0.000000e+00
  %1009 = bitcast i32 %131 to float
  %1010 = bitcast i32 %131 to float
  %1011 = fmul float %1009, %1010
  %1012 = fadd float %1008, %1011
  %1013 = call float @llvm.sqrt.f32.52(float %1012)
  %1014 = bitcast i32 %102 to float
  %1015 = fcmp olt float %1014, 0.000000e+00
  %1016 = sext i1 %1015 to i32
  %1017 = bitcast i32 %102 to float
  %1018 = fcmp ogt float %1017, 0.000000e+00
  %1019 = zext i1 %1018 to i32
  %1020 = add nsw i32 %1016, %1019
  %1021 = sitofp i32 %1020 to float
  %1022 = fneg float %1021
  %1023 = fmul float %1013, %1022
  %1024 = bitcast i32 %102 to float
  %1025 = fadd float %1024, %1023
  %1026 = fmul float %1004, %1025
  %1027 = fadd float %1026, 0.000000e+00
  %1028 = bitcast i32 %102 to float
  %1029 = bitcast i32 %102 to float
  %1030 = fmul float %1028, %1029
  %1031 = fadd float %1030, 0.000000e+00
  %1032 = bitcast i32 %131 to float
  %1033 = bitcast i32 %131 to float
  %1034 = fmul float %1032, %1033
  %1035 = fadd float %1031, %1034
  %1036 = call float @llvm.sqrt.f32.53(float %1035)
  %1037 = bitcast i32 %102 to float
  %1038 = fcmp olt float %1037, 0.000000e+00
  %1039 = sext i1 %1038 to i32
  %1040 = bitcast i32 %102 to float
  %1041 = fcmp ogt float %1040, 0.000000e+00
  %1042 = zext i1 %1041 to i32
  %1043 = add nsw i32 %1039, %1042
  %1044 = sitofp i32 %1043 to float
  %1045 = fneg float %1044
  %1046 = fmul float %1036, %1045
  %1047 = fmul float %1046, 0.000000e+00
  %1048 = bitcast i32 %131 to float
  %1049 = fadd float %1048, %1047
  %1050 = bitcast i32 %102 to float
  %1051 = bitcast i32 %102 to float
  %1052 = fmul float %1050, %1051
  %1053 = fadd float %1052, 0.000000e+00
  %1054 = bitcast i32 %131 to float
  %1055 = bitcast i32 %131 to float
  %1056 = fmul float %1054, %1055
  %1057 = fadd float %1053, %1056
  %1058 = call float @llvm.sqrt.f32.54(float %1057)
  %1059 = bitcast i32 %102 to float
  %1060 = fcmp olt float %1059, 0.000000e+00
  %1061 = sext i1 %1060 to i32
  %1062 = bitcast i32 %102 to float
  %1063 = fcmp ogt float %1062, 0.000000e+00
  %1064 = zext i1 %1063 to i32
  %1065 = add nsw i32 %1061, %1064
  %1066 = sitofp i32 %1065 to float
  %1067 = fneg float %1066
  %1068 = fmul float %1058, %1067
  %1069 = fmul float %1068, 0.000000e+00
  %1070 = bitcast i32 %131 to float
  %1071 = fadd float %1070, %1069
  %1072 = fmul float %1049, %1071
  %1073 = fadd float %1027, %1072
  %1074 = call float @llvm.sqrt.f32.55(float %1073)
  %1075 = fadd float %1074, 0.000000e+00
  %1076 = fdiv float %983, %1075
  %1077 = fmul float %961, %1076
  %1078 = fsub float 1.000000e+00, %1077
  %1079 = insertelement <4 x float> zeroinitializer, float %1078, i32 0
  %1080 = insertelement <4 x float> %1079, float 0.000000e+00, i32 1
  %1081 = insertelement <4 x float> %1080, float 0.000000e+00, i32 2
  %1082 = insertelement <4 x float> %1081, float 0.000000e+00, i32 3
  %1083 = shufflevector <4 x float> %845, <4 x float> %1082, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %1084 = extractelement <8 x float> %1083, i32 0
  %1085 = bitcast i32* %23 to float*
  %1086 = getelementptr float, float* %2, i32 0
  %1087 = getelementptr inbounds float, float* %1086, i64 3
  %1088 = bitcast float* %1087 to i32*
  %1089 = bitcast i32* %1088 to float*
  store float %1084, float* %1089, align 4
  %1090 = extractelement <8 x float> %1083, i32 1
  %1091 = bitcast i32* %60 to float*
  %1092 = alloca [4 x float], align 16
  %1093 = bitcast [4 x float]* %1092 to i32*
  %1094 = bitcast i32* %1093 to float*
  store float %1090, float* %1094, align 4
  %1095 = extractelement <8 x float> %1083, i32 2
  %1096 = bitcast i32* %63 to float*
  %1097 = getelementptr inbounds [4 x float], [4 x float]* %1092, i64 0, i64 1
  %1098 = bitcast float* %1097 to i32*
  %1099 = bitcast i32* %1098 to float*
  store float %1095, float* %1099, align 4
  %1100 = extractelement <8 x float> %1083, i32 3
  %1101 = bitcast i32* %66 to float*
  %1102 = getelementptr inbounds [4 x float], [4 x float]* %1092, i64 0, i64 2
  %1103 = bitcast float* %1102 to i32*
  %1104 = bitcast i32* %1103 to float*
  store float %1100, float* %1104, align 4
  %1105 = extractelement <8 x float> %1083, i32 4
  %1106 = bitcast i32* %69 to float*
  %1107 = getelementptr inbounds [4 x float], [4 x float]* %1092, i64 0, i64 3
  %1108 = bitcast float* %1107 to i32*
  %1109 = bitcast i32* %1108 to float*
  store float %1105, float* %1109, align 4
  %1110 = bitcast float* %1 to i8*
  %1111 = alloca [4 x float], align 16
  %1112 = bitcast [4 x float]* %1111 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 4 dereferenceable(16) %1110, i8* nonnull align 16 dereferenceable(16) %1112, i64 16, i1 false)
  store float 0.000000e+00, float* %2, align 4
  %1113 = bitcast i32 %102 to float
  %1114 = bitcast i32 %102 to float
  %1115 = fmul float %1113, %1114
  %1116 = fadd float %1115, 0.000000e+00
  %1117 = bitcast i32 %131 to float
  %1118 = bitcast i32 %131 to float
  %1119 = fmul float %1117, %1118
  %1120 = fadd float %1116, %1119
  %1121 = call float @llvm.sqrt.f32.56(float %1120)
  %1122 = bitcast i32 %102 to float
  %1123 = fcmp olt float %1122, 0.000000e+00
  %1124 = sext i1 %1123 to i32
  %1125 = bitcast i32 %102 to float
  %1126 = fcmp ogt float %1125, 0.000000e+00
  %1127 = zext i1 %1126 to i32
  %1128 = add nsw i32 %1124, %1127
  %1129 = sitofp i32 %1128 to float
  %1130 = fneg float %1129
  %1131 = fmul float %1121, %1130
  %1132 = bitcast i32 %102 to float
  %1133 = fadd float %1132, %1131
  %1134 = bitcast i32 %102 to float
  %1135 = bitcast i32 %102 to float
  %1136 = fmul float %1134, %1135
  %1137 = fadd float %1136, 0.000000e+00
  %1138 = bitcast i32 %131 to float
  %1139 = bitcast i32 %131 to float
  %1140 = fmul float %1138, %1139
  %1141 = fadd float %1137, %1140
  %1142 = call float @llvm.sqrt.f32.57(float %1141)
  %1143 = bitcast i32 %102 to float
  %1144 = fcmp olt float %1143, 0.000000e+00
  %1145 = sext i1 %1144 to i32
  %1146 = bitcast i32 %102 to float
  %1147 = fcmp ogt float %1146, 0.000000e+00
  %1148 = zext i1 %1147 to i32
  %1149 = add nsw i32 %1145, %1148
  %1150 = sitofp i32 %1149 to float
  %1151 = fneg float %1150
  %1152 = fmul float %1142, %1151
  %1153 = bitcast i32 %102 to float
  %1154 = fadd float %1153, %1152
  %1155 = bitcast i32 %102 to float
  %1156 = bitcast i32 %102 to float
  %1157 = fmul float %1155, %1156
  %1158 = fadd float %1157, 0.000000e+00
  %1159 = bitcast i32 %131 to float
  %1160 = bitcast i32 %131 to float
  %1161 = fmul float %1159, %1160
  %1162 = fadd float %1158, %1161
  %1163 = call float @llvm.sqrt.f32.58(float %1162)
  %1164 = bitcast i32 %102 to float
  %1165 = fcmp olt float %1164, 0.000000e+00
  %1166 = sext i1 %1165 to i32
  %1167 = bitcast i32 %102 to float
  %1168 = fcmp ogt float %1167, 0.000000e+00
  %1169 = zext i1 %1168 to i32
  %1170 = add nsw i32 %1166, %1169
  %1171 = sitofp i32 %1170 to float
  %1172 = fneg float %1171
  %1173 = fmul float %1163, %1172
  %1174 = bitcast i32 %102 to float
  %1175 = fadd float %1174, %1173
  %1176 = fmul float %1154, %1175
  %1177 = fadd float %1176, 0.000000e+00
  %1178 = bitcast i32 %102 to float
  %1179 = bitcast i32 %102 to float
  %1180 = fmul float %1178, %1179
  %1181 = fadd float %1180, 0.000000e+00
  %1182 = bitcast i32 %131 to float
  %1183 = bitcast i32 %131 to float
  %1184 = fmul float %1182, %1183
  %1185 = fadd float %1181, %1184
  %1186 = call float @llvm.sqrt.f32.59(float %1185)
  %1187 = bitcast i32 %102 to float
  %1188 = fcmp olt float %1187, 0.000000e+00
  %1189 = sext i1 %1188 to i32
  %1190 = bitcast i32 %102 to float
  %1191 = fcmp ogt float %1190, 0.000000e+00
  %1192 = zext i1 %1191 to i32
  %1193 = add nsw i32 %1189, %1192
  %1194 = sitofp i32 %1193 to float
  %1195 = fneg float %1194
  %1196 = fmul float %1186, %1195
  %1197 = fmul float %1196, 0.000000e+00
  %1198 = bitcast i32 %131 to float
  %1199 = fadd float %1198, %1197
  %1200 = bitcast i32 %102 to float
  %1201 = bitcast i32 %102 to float
  %1202 = fmul float %1200, %1201
  %1203 = fadd float %1202, 0.000000e+00
  %1204 = bitcast i32 %131 to float
  %1205 = bitcast i32 %131 to float
  %1206 = fmul float %1204, %1205
  %1207 = fadd float %1203, %1206
  %1208 = call float @llvm.sqrt.f32.60(float %1207)
  %1209 = bitcast i32 %102 to float
  %1210 = fcmp olt float %1209, 0.000000e+00
  %1211 = sext i1 %1210 to i32
  %1212 = bitcast i32 %102 to float
  %1213 = fcmp ogt float %1212, 0.000000e+00
  %1214 = zext i1 %1213 to i32
  %1215 = add nsw i32 %1211, %1214
  %1216 = sitofp i32 %1215 to float
  %1217 = fneg float %1216
  %1218 = fmul float %1208, %1217
  %1219 = fmul float %1218, 0.000000e+00
  %1220 = bitcast i32 %131 to float
  %1221 = fadd float %1220, %1219
  %1222 = fmul float %1199, %1221
  %1223 = fadd float %1177, %1222
  %1224 = call float @llvm.sqrt.f32.61(float %1223)
  %1225 = fadd float %1224, 0.000000e+00
  %1226 = fdiv float %1133, %1225
  %1227 = fmul float %1226, 2.000000e+00
  %1228 = bitcast i32 %102 to float
  %1229 = bitcast i32 %102 to float
  %1230 = fmul float %1228, %1229
  %1231 = fadd float %1230, 0.000000e+00
  %1232 = bitcast i32 %131 to float
  %1233 = bitcast i32 %131 to float
  %1234 = fmul float %1232, %1233
  %1235 = fadd float %1231, %1234
  %1236 = call float @llvm.sqrt.f32.62(float %1235)
  %1237 = bitcast i32 %102 to float
  %1238 = fcmp olt float %1237, 0.000000e+00
  %1239 = sext i1 %1238 to i32
  %1240 = bitcast i32 %102 to float
  %1241 = fcmp ogt float %1240, 0.000000e+00
  %1242 = zext i1 %1241 to i32
  %1243 = add nsw i32 %1239, %1242
  %1244 = sitofp i32 %1243 to float
  %1245 = fneg float %1244
  %1246 = fmul float %1236, %1245
  %1247 = bitcast i32 %102 to float
  %1248 = fadd float %1247, %1246
  %1249 = bitcast i32 %102 to float
  %1250 = bitcast i32 %102 to float
  %1251 = fmul float %1249, %1250
  %1252 = fadd float %1251, 0.000000e+00
  %1253 = bitcast i32 %131 to float
  %1254 = bitcast i32 %131 to float
  %1255 = fmul float %1253, %1254
  %1256 = fadd float %1252, %1255
  %1257 = call float @llvm.sqrt.f32.63(float %1256)
  %1258 = bitcast i32 %102 to float
  %1259 = fcmp olt float %1258, 0.000000e+00
  %1260 = sext i1 %1259 to i32
  %1261 = bitcast i32 %102 to float
  %1262 = fcmp ogt float %1261, 0.000000e+00
  %1263 = zext i1 %1262 to i32
  %1264 = add nsw i32 %1260, %1263
  %1265 = sitofp i32 %1264 to float
  %1266 = fneg float %1265
  %1267 = fmul float %1257, %1266
  %1268 = bitcast i32 %102 to float
  %1269 = fadd float %1268, %1267
  %1270 = bitcast i32 %102 to float
  %1271 = bitcast i32 %102 to float
  %1272 = fmul float %1270, %1271
  %1273 = fadd float %1272, 0.000000e+00
  %1274 = bitcast i32 %131 to float
  %1275 = bitcast i32 %131 to float
  %1276 = fmul float %1274, %1275
  %1277 = fadd float %1273, %1276
  %1278 = call float @llvm.sqrt.f32.64(float %1277)
  %1279 = bitcast i32 %102 to float
  %1280 = fcmp olt float %1279, 0.000000e+00
  %1281 = sext i1 %1280 to i32
  %1282 = bitcast i32 %102 to float
  %1283 = fcmp ogt float %1282, 0.000000e+00
  %1284 = zext i1 %1283 to i32
  %1285 = add nsw i32 %1281, %1284
  %1286 = sitofp i32 %1285 to float
  %1287 = fneg float %1286
  %1288 = fmul float %1278, %1287
  %1289 = bitcast i32 %102 to float
  %1290 = fadd float %1289, %1288
  %1291 = fmul float %1269, %1290
  %1292 = fadd float %1291, 0.000000e+00
  %1293 = bitcast i32 %102 to float
  %1294 = bitcast i32 %102 to float
  %1295 = fmul float %1293, %1294
  %1296 = fadd float %1295, 0.000000e+00
  %1297 = bitcast i32 %131 to float
  %1298 = bitcast i32 %131 to float
  %1299 = fmul float %1297, %1298
  %1300 = fadd float %1296, %1299
  %1301 = call float @llvm.sqrt.f32.65(float %1300)
  %1302 = bitcast i32 %102 to float
  %1303 = fcmp olt float %1302, 0.000000e+00
  %1304 = sext i1 %1303 to i32
  %1305 = bitcast i32 %102 to float
  %1306 = fcmp ogt float %1305, 0.000000e+00
  %1307 = zext i1 %1306 to i32
  %1308 = add nsw i32 %1304, %1307
  %1309 = sitofp i32 %1308 to float
  %1310 = fneg float %1309
  %1311 = fmul float %1301, %1310
  %1312 = fmul float %1311, 0.000000e+00
  %1313 = bitcast i32 %131 to float
  %1314 = fadd float %1313, %1312
  %1315 = bitcast i32 %102 to float
  %1316 = bitcast i32 %102 to float
  %1317 = fmul float %1315, %1316
  %1318 = fadd float %1317, 0.000000e+00
  %1319 = bitcast i32 %131 to float
  %1320 = bitcast i32 %131 to float
  %1321 = fmul float %1319, %1320
  %1322 = fadd float %1318, %1321
  %1323 = call float @llvm.sqrt.f32.66(float %1322)
  %1324 = bitcast i32 %102 to float
  %1325 = fcmp olt float %1324, 0.000000e+00
  %1326 = sext i1 %1325 to i32
  %1327 = bitcast i32 %102 to float
  %1328 = fcmp ogt float %1327, 0.000000e+00
  %1329 = zext i1 %1328 to i32
  %1330 = add nsw i32 %1326, %1329
  %1331 = sitofp i32 %1330 to float
  %1332 = fneg float %1331
  %1333 = fmul float %1323, %1332
  %1334 = fmul float %1333, 0.000000e+00
  %1335 = bitcast i32 %131 to float
  %1336 = fadd float %1335, %1334
  %1337 = fmul float %1314, %1336
  %1338 = fadd float %1292, %1337
  %1339 = call float @llvm.sqrt.f32.67(float %1338)
  %1340 = fadd float %1339, 0.000000e+00
  %1341 = fdiv float %1248, %1340
  %1342 = fmul float %1227, %1341
  %1343 = fsub float 1.000000e+00, %1342
  %1344 = insertelement <4 x float> zeroinitializer, float %1343, i32 0
  %1345 = insertelement <4 x float> %1344, float 0.000000e+00, i32 1
  %1346 = insertelement <4 x float> %1345, float 0.000000e+00, i32 2
  %1347 = insertelement <4 x float> %1346, float 0.000000e+00, i32 3
  %1348 = getelementptr float, float* %0, i32 0
  %1349 = load float, float* %1348, align 4
  %1350 = insertelement <4 x float> zeroinitializer, float %1349, i32 0
  %1351 = insertelement <4 x float> %1350, float 0.000000e+00, i32 1
  %1352 = insertelement <4 x float> %1351, float 0.000000e+00, i32 2
  %1353 = insertelement <4 x float> %1352, float 0.000000e+00, i32 3
  %1354 = call <4 x float> @llvm.fma.f32.68(<4 x float> %1347, <4 x float> %1353, <4 x float> zeroinitializer)
  %1355 = extractelement <4 x float> %1354, i32 0
  store float %1355, float* %2, align 4
  %1356 = bitcast i32 %102 to float
  %1357 = bitcast i32 %102 to float
  %1358 = fmul float %1356, %1357
  %1359 = fadd float %1358, 0.000000e+00
  %1360 = bitcast i32 %131 to float
  %1361 = bitcast i32 %131 to float
  %1362 = fmul float %1360, %1361
  %1363 = fadd float %1359, %1362
  %1364 = call float @llvm.sqrt.f32.69(float %1363)
  %1365 = bitcast i32 %102 to float
  %1366 = fcmp olt float %1365, 0.000000e+00
  %1367 = sext i1 %1366 to i32
  %1368 = bitcast i32 %102 to float
  %1369 = fcmp ogt float %1368, 0.000000e+00
  %1370 = zext i1 %1369 to i32
  %1371 = add nsw i32 %1367, %1370
  %1372 = sitofp i32 %1371 to float
  %1373 = fneg float %1372
  %1374 = fmul float %1364, %1373
  %1375 = bitcast i32 %102 to float
  %1376 = fadd float %1375, %1374
  %1377 = bitcast i32 %102 to float
  %1378 = bitcast i32 %102 to float
  %1379 = fmul float %1377, %1378
  %1380 = fadd float %1379, 0.000000e+00
  %1381 = bitcast i32 %131 to float
  %1382 = bitcast i32 %131 to float
  %1383 = fmul float %1381, %1382
  %1384 = fadd float %1380, %1383
  %1385 = call float @llvm.sqrt.f32.70(float %1384)
  %1386 = bitcast i32 %102 to float
  %1387 = fcmp olt float %1386, 0.000000e+00
  %1388 = sext i1 %1387 to i32
  %1389 = bitcast i32 %102 to float
  %1390 = fcmp ogt float %1389, 0.000000e+00
  %1391 = zext i1 %1390 to i32
  %1392 = add nsw i32 %1388, %1391
  %1393 = sitofp i32 %1392 to float
  %1394 = fneg float %1393
  %1395 = fmul float %1385, %1394
  %1396 = bitcast i32 %102 to float
  %1397 = fadd float %1396, %1395
  %1398 = bitcast i32 %102 to float
  %1399 = bitcast i32 %102 to float
  %1400 = fmul float %1398, %1399
  %1401 = fadd float %1400, 0.000000e+00
  %1402 = bitcast i32 %131 to float
  %1403 = bitcast i32 %131 to float
  %1404 = fmul float %1402, %1403
  %1405 = fadd float %1401, %1404
  %1406 = call float @llvm.sqrt.f32.71(float %1405)
  %1407 = bitcast i32 %102 to float
  %1408 = fcmp olt float %1407, 0.000000e+00
  %1409 = sext i1 %1408 to i32
  %1410 = bitcast i32 %102 to float
  %1411 = fcmp ogt float %1410, 0.000000e+00
  %1412 = zext i1 %1411 to i32
  %1413 = add nsw i32 %1409, %1412
  %1414 = sitofp i32 %1413 to float
  %1415 = fneg float %1414
  %1416 = fmul float %1406, %1415
  %1417 = bitcast i32 %102 to float
  %1418 = fadd float %1417, %1416
  %1419 = fmul float %1397, %1418
  %1420 = fadd float %1419, 0.000000e+00
  %1421 = bitcast i32 %102 to float
  %1422 = bitcast i32 %102 to float
  %1423 = fmul float %1421, %1422
  %1424 = fadd float %1423, 0.000000e+00
  %1425 = bitcast i32 %131 to float
  %1426 = bitcast i32 %131 to float
  %1427 = fmul float %1425, %1426
  %1428 = fadd float %1424, %1427
  %1429 = call float @llvm.sqrt.f32.72(float %1428)
  %1430 = bitcast i32 %102 to float
  %1431 = fcmp olt float %1430, 0.000000e+00
  %1432 = sext i1 %1431 to i32
  %1433 = bitcast i32 %102 to float
  %1434 = fcmp ogt float %1433, 0.000000e+00
  %1435 = zext i1 %1434 to i32
  %1436 = add nsw i32 %1432, %1435
  %1437 = sitofp i32 %1436 to float
  %1438 = fneg float %1437
  %1439 = fmul float %1429, %1438
  %1440 = fmul float %1439, 0.000000e+00
  %1441 = bitcast i32 %131 to float
  %1442 = fadd float %1441, %1440
  %1443 = bitcast i32 %102 to float
  %1444 = bitcast i32 %102 to float
  %1445 = fmul float %1443, %1444
  %1446 = fadd float %1445, 0.000000e+00
  %1447 = bitcast i32 %131 to float
  %1448 = bitcast i32 %131 to float
  %1449 = fmul float %1447, %1448
  %1450 = fadd float %1446, %1449
  %1451 = call float @llvm.sqrt.f32.73(float %1450)
  %1452 = bitcast i32 %102 to float
  %1453 = fcmp olt float %1452, 0.000000e+00
  %1454 = sext i1 %1453 to i32
  %1455 = bitcast i32 %102 to float
  %1456 = fcmp ogt float %1455, 0.000000e+00
  %1457 = zext i1 %1456 to i32
  %1458 = add nsw i32 %1454, %1457
  %1459 = sitofp i32 %1458 to float
  %1460 = fneg float %1459
  %1461 = fmul float %1451, %1460
  %1462 = fmul float %1461, 0.000000e+00
  %1463 = bitcast i32 %131 to float
  %1464 = fadd float %1463, %1462
  %1465 = fmul float %1442, %1464
  %1466 = fadd float %1420, %1465
  %1467 = call float @llvm.sqrt.f32.74(float %1466)
  %1468 = fadd float %1467, 0.000000e+00
  %1469 = fdiv float %1376, %1468
  %1470 = fmul float %1469, 2.000000e+00
  %1471 = bitcast i32 %102 to float
  %1472 = bitcast i32 %102 to float
  %1473 = fmul float %1471, %1472
  %1474 = fadd float %1473, 0.000000e+00
  %1475 = bitcast i32 %131 to float
  %1476 = bitcast i32 %131 to float
  %1477 = fmul float %1475, %1476
  %1478 = fadd float %1474, %1477
  %1479 = call float @llvm.sqrt.f32.75(float %1478)
  %1480 = bitcast i32 %102 to float
  %1481 = fcmp olt float %1480, 0.000000e+00
  %1482 = sext i1 %1481 to i32
  %1483 = bitcast i32 %102 to float
  %1484 = fcmp ogt float %1483, 0.000000e+00
  %1485 = zext i1 %1484 to i32
  %1486 = add nsw i32 %1482, %1485
  %1487 = sitofp i32 %1486 to float
  %1488 = fneg float %1487
  %1489 = fmul float %1479, %1488
  %1490 = bitcast i32 %102 to float
  %1491 = fadd float %1490, %1489
  %1492 = bitcast i32 %102 to float
  %1493 = bitcast i32 %102 to float
  %1494 = fmul float %1492, %1493
  %1495 = fadd float %1494, 0.000000e+00
  %1496 = bitcast i32 %131 to float
  %1497 = bitcast i32 %131 to float
  %1498 = fmul float %1496, %1497
  %1499 = fadd float %1495, %1498
  %1500 = call float @llvm.sqrt.f32.76(float %1499)
  %1501 = bitcast i32 %102 to float
  %1502 = fcmp olt float %1501, 0.000000e+00
  %1503 = sext i1 %1502 to i32
  %1504 = bitcast i32 %102 to float
  %1505 = fcmp ogt float %1504, 0.000000e+00
  %1506 = zext i1 %1505 to i32
  %1507 = add nsw i32 %1503, %1506
  %1508 = sitofp i32 %1507 to float
  %1509 = fneg float %1508
  %1510 = fmul float %1500, %1509
  %1511 = bitcast i32 %102 to float
  %1512 = fadd float %1511, %1510
  %1513 = bitcast i32 %102 to float
  %1514 = bitcast i32 %102 to float
  %1515 = fmul float %1513, %1514
  %1516 = fadd float %1515, 0.000000e+00
  %1517 = bitcast i32 %131 to float
  %1518 = bitcast i32 %131 to float
  %1519 = fmul float %1517, %1518
  %1520 = fadd float %1516, %1519
  %1521 = call float @llvm.sqrt.f32.77(float %1520)
  %1522 = bitcast i32 %102 to float
  %1523 = fcmp olt float %1522, 0.000000e+00
  %1524 = sext i1 %1523 to i32
  %1525 = bitcast i32 %102 to float
  %1526 = fcmp ogt float %1525, 0.000000e+00
  %1527 = zext i1 %1526 to i32
  %1528 = add nsw i32 %1524, %1527
  %1529 = sitofp i32 %1528 to float
  %1530 = fneg float %1529
  %1531 = fmul float %1521, %1530
  %1532 = bitcast i32 %102 to float
  %1533 = fadd float %1532, %1531
  %1534 = fmul float %1512, %1533
  %1535 = fadd float %1534, 0.000000e+00
  %1536 = bitcast i32 %102 to float
  %1537 = bitcast i32 %102 to float
  %1538 = fmul float %1536, %1537
  %1539 = fadd float %1538, 0.000000e+00
  %1540 = bitcast i32 %131 to float
  %1541 = bitcast i32 %131 to float
  %1542 = fmul float %1540, %1541
  %1543 = fadd float %1539, %1542
  %1544 = call float @llvm.sqrt.f32.78(float %1543)
  %1545 = bitcast i32 %102 to float
  %1546 = fcmp olt float %1545, 0.000000e+00
  %1547 = sext i1 %1546 to i32
  %1548 = bitcast i32 %102 to float
  %1549 = fcmp ogt float %1548, 0.000000e+00
  %1550 = zext i1 %1549 to i32
  %1551 = add nsw i32 %1547, %1550
  %1552 = sitofp i32 %1551 to float
  %1553 = fneg float %1552
  %1554 = fmul float %1544, %1553
  %1555 = fmul float %1554, 0.000000e+00
  %1556 = bitcast i32 %131 to float
  %1557 = fadd float %1556, %1555
  %1558 = bitcast i32 %102 to float
  %1559 = bitcast i32 %102 to float
  %1560 = fmul float %1558, %1559
  %1561 = fadd float %1560, 0.000000e+00
  %1562 = bitcast i32 %131 to float
  %1563 = bitcast i32 %131 to float
  %1564 = fmul float %1562, %1563
  %1565 = fadd float %1561, %1564
  %1566 = call float @llvm.sqrt.f32.79(float %1565)
  %1567 = bitcast i32 %102 to float
  %1568 = fcmp olt float %1567, 0.000000e+00
  %1569 = sext i1 %1568 to i32
  %1570 = bitcast i32 %102 to float
  %1571 = fcmp ogt float %1570, 0.000000e+00
  %1572 = zext i1 %1571 to i32
  %1573 = add nsw i32 %1569, %1572
  %1574 = sitofp i32 %1573 to float
  %1575 = fneg float %1574
  %1576 = fmul float %1566, %1575
  %1577 = fmul float %1576, 0.000000e+00
  %1578 = bitcast i32 %131 to float
  %1579 = fadd float %1578, %1577
  %1580 = fmul float %1557, %1579
  %1581 = fadd float %1535, %1580
  %1582 = call float @llvm.sqrt.f32.80(float %1581)
  %1583 = fadd float %1582, 0.000000e+00
  %1584 = fdiv float %1491, %1583
  %1585 = fmul float %1470, %1584
  %1586 = fsub float 1.000000e+00, %1585
  %1587 = fmul float %1586, %1349
  %1588 = fadd float %1587, 0.000000e+00
  %1589 = bitcast i32 %102 to float
  %1590 = bitcast i32 %102 to float
  %1591 = fmul float %1589, %1590
  %1592 = fadd float %1591, 0.000000e+00
  %1593 = bitcast i32 %131 to float
  %1594 = bitcast i32 %131 to float
  %1595 = fmul float %1593, %1594
  %1596 = fadd float %1592, %1595
  %1597 = call float @llvm.sqrt.f32.81(float %1596)
  %1598 = bitcast i32 %102 to float
  %1599 = fcmp olt float %1598, 0.000000e+00
  %1600 = sext i1 %1599 to i32
  %1601 = bitcast i32 %102 to float
  %1602 = fcmp ogt float %1601, 0.000000e+00
  %1603 = zext i1 %1602 to i32
  %1604 = add nsw i32 %1600, %1603
  %1605 = sitofp i32 %1604 to float
  %1606 = fneg float %1605
  %1607 = fmul float %1597, %1606
  %1608 = bitcast i32 %102 to float
  %1609 = fadd float %1608, %1607
  %1610 = bitcast i32 %102 to float
  %1611 = bitcast i32 %102 to float
  %1612 = fmul float %1610, %1611
  %1613 = fadd float %1612, 0.000000e+00
  %1614 = bitcast i32 %131 to float
  %1615 = bitcast i32 %131 to float
  %1616 = fmul float %1614, %1615
  %1617 = fadd float %1613, %1616
  %1618 = call float @llvm.sqrt.f32.82(float %1617)
  %1619 = bitcast i32 %102 to float
  %1620 = fcmp olt float %1619, 0.000000e+00
  %1621 = sext i1 %1620 to i32
  %1622 = bitcast i32 %102 to float
  %1623 = fcmp ogt float %1622, 0.000000e+00
  %1624 = zext i1 %1623 to i32
  %1625 = add nsw i32 %1621, %1624
  %1626 = sitofp i32 %1625 to float
  %1627 = fneg float %1626
  %1628 = fmul float %1618, %1627
  %1629 = bitcast i32 %102 to float
  %1630 = fadd float %1629, %1628
  %1631 = bitcast i32 %102 to float
  %1632 = bitcast i32 %102 to float
  %1633 = fmul float %1631, %1632
  %1634 = fadd float %1633, 0.000000e+00
  %1635 = bitcast i32 %131 to float
  %1636 = bitcast i32 %131 to float
  %1637 = fmul float %1635, %1636
  %1638 = fadd float %1634, %1637
  %1639 = call float @llvm.sqrt.f32.83(float %1638)
  %1640 = bitcast i32 %102 to float
  %1641 = fcmp olt float %1640, 0.000000e+00
  %1642 = sext i1 %1641 to i32
  %1643 = bitcast i32 %102 to float
  %1644 = fcmp ogt float %1643, 0.000000e+00
  %1645 = zext i1 %1644 to i32
  %1646 = add nsw i32 %1642, %1645
  %1647 = sitofp i32 %1646 to float
  %1648 = fneg float %1647
  %1649 = fmul float %1639, %1648
  %1650 = bitcast i32 %102 to float
  %1651 = fadd float %1650, %1649
  %1652 = fmul float %1630, %1651
  %1653 = fadd float %1652, 0.000000e+00
  %1654 = bitcast i32 %102 to float
  %1655 = bitcast i32 %102 to float
  %1656 = fmul float %1654, %1655
  %1657 = fadd float %1656, 0.000000e+00
  %1658 = bitcast i32 %131 to float
  %1659 = bitcast i32 %131 to float
  %1660 = fmul float %1658, %1659
  %1661 = fadd float %1657, %1660
  %1662 = call float @llvm.sqrt.f32.84(float %1661)
  %1663 = bitcast i32 %102 to float
  %1664 = fcmp olt float %1663, 0.000000e+00
  %1665 = sext i1 %1664 to i32
  %1666 = bitcast i32 %102 to float
  %1667 = fcmp ogt float %1666, 0.000000e+00
  %1668 = zext i1 %1667 to i32
  %1669 = add nsw i32 %1665, %1668
  %1670 = sitofp i32 %1669 to float
  %1671 = fneg float %1670
  %1672 = fmul float %1662, %1671
  %1673 = fmul float %1672, 0.000000e+00
  %1674 = bitcast i32 %131 to float
  %1675 = fadd float %1674, %1673
  %1676 = bitcast i32 %102 to float
  %1677 = bitcast i32 %102 to float
  %1678 = fmul float %1676, %1677
  %1679 = fadd float %1678, 0.000000e+00
  %1680 = bitcast i32 %131 to float
  %1681 = bitcast i32 %131 to float
  %1682 = fmul float %1680, %1681
  %1683 = fadd float %1679, %1682
  %1684 = call float @llvm.sqrt.f32.85(float %1683)
  %1685 = bitcast i32 %102 to float
  %1686 = fcmp olt float %1685, 0.000000e+00
  %1687 = sext i1 %1686 to i32
  %1688 = bitcast i32 %102 to float
  %1689 = fcmp ogt float %1688, 0.000000e+00
  %1690 = zext i1 %1689 to i32
  %1691 = add nsw i32 %1687, %1690
  %1692 = sitofp i32 %1691 to float
  %1693 = fneg float %1692
  %1694 = fmul float %1684, %1693
  %1695 = fmul float %1694, 0.000000e+00
  %1696 = bitcast i32 %131 to float
  %1697 = fadd float %1696, %1695
  %1698 = fmul float %1675, %1697
  %1699 = fadd float %1653, %1698
  %1700 = call float @llvm.sqrt.f32.86(float %1699)
  %1701 = fadd float %1700, 0.000000e+00
  %1702 = fdiv float %1609, %1701
  %1703 = fmul float %1702, 2.000000e+00
  %1704 = bitcast i32 %102 to float
  %1705 = bitcast i32 %102 to float
  %1706 = fmul float %1704, %1705
  %1707 = fadd float %1706, 0.000000e+00
  %1708 = bitcast i32 %131 to float
  %1709 = bitcast i32 %131 to float
  %1710 = fmul float %1708, %1709
  %1711 = fadd float %1707, %1710
  %1712 = call float @llvm.sqrt.f32.87(float %1711)
  %1713 = bitcast i32 %102 to float
  %1714 = fcmp olt float %1713, 0.000000e+00
  %1715 = sext i1 %1714 to i32
  %1716 = bitcast i32 %102 to float
  %1717 = fcmp ogt float %1716, 0.000000e+00
  %1718 = zext i1 %1717 to i32
  %1719 = add nsw i32 %1715, %1718
  %1720 = sitofp i32 %1719 to float
  %1721 = fneg float %1720
  %1722 = fmul float %1712, %1721
  %1723 = fmul float %1722, 0.000000e+00
  %1724 = bitcast i32 %131 to float
  %1725 = fadd float %1724, %1723
  %1726 = bitcast i32 %102 to float
  %1727 = bitcast i32 %102 to float
  %1728 = fmul float %1726, %1727
  %1729 = fadd float %1728, 0.000000e+00
  %1730 = bitcast i32 %131 to float
  %1731 = bitcast i32 %131 to float
  %1732 = fmul float %1730, %1731
  %1733 = fadd float %1729, %1732
  %1734 = call float @llvm.sqrt.f32.88(float %1733)
  %1735 = bitcast i32 %102 to float
  %1736 = fcmp olt float %1735, 0.000000e+00
  %1737 = sext i1 %1736 to i32
  %1738 = bitcast i32 %102 to float
  %1739 = fcmp ogt float %1738, 0.000000e+00
  %1740 = zext i1 %1739 to i32
  %1741 = add nsw i32 %1737, %1740
  %1742 = sitofp i32 %1741 to float
  %1743 = fneg float %1742
  %1744 = fmul float %1734, %1743
  %1745 = bitcast i32 %102 to float
  %1746 = fadd float %1745, %1744
  %1747 = bitcast i32 %102 to float
  %1748 = bitcast i32 %102 to float
  %1749 = fmul float %1747, %1748
  %1750 = fadd float %1749, 0.000000e+00
  %1751 = bitcast i32 %131 to float
  %1752 = bitcast i32 %131 to float
  %1753 = fmul float %1751, %1752
  %1754 = fadd float %1750, %1753
  %1755 = call float @llvm.sqrt.f32.89(float %1754)
  %1756 = bitcast i32 %102 to float
  %1757 = fcmp olt float %1756, 0.000000e+00
  %1758 = sext i1 %1757 to i32
  %1759 = bitcast i32 %102 to float
  %1760 = fcmp ogt float %1759, 0.000000e+00
  %1761 = zext i1 %1760 to i32
  %1762 = add nsw i32 %1758, %1761
  %1763 = sitofp i32 %1762 to float
  %1764 = fneg float %1763
  %1765 = fmul float %1755, %1764
  %1766 = bitcast i32 %102 to float
  %1767 = fadd float %1766, %1765
  %1768 = fmul float %1746, %1767
  %1769 = fadd float %1768, 0.000000e+00
  %1770 = bitcast i32 %102 to float
  %1771 = bitcast i32 %102 to float
  %1772 = fmul float %1770, %1771
  %1773 = fadd float %1772, 0.000000e+00
  %1774 = bitcast i32 %131 to float
  %1775 = bitcast i32 %131 to float
  %1776 = fmul float %1774, %1775
  %1777 = fadd float %1773, %1776
  %1778 = call float @llvm.sqrt.f32.90(float %1777)
  %1779 = bitcast i32 %102 to float
  %1780 = fcmp olt float %1779, 0.000000e+00
  %1781 = sext i1 %1780 to i32
  %1782 = bitcast i32 %102 to float
  %1783 = fcmp ogt float %1782, 0.000000e+00
  %1784 = zext i1 %1783 to i32
  %1785 = add nsw i32 %1781, %1784
  %1786 = sitofp i32 %1785 to float
  %1787 = fneg float %1786
  %1788 = fmul float %1778, %1787
  %1789 = fmul float %1788, 0.000000e+00
  %1790 = bitcast i32 %131 to float
  %1791 = fadd float %1790, %1789
  %1792 = bitcast i32 %102 to float
  %1793 = bitcast i32 %102 to float
  %1794 = fmul float %1792, %1793
  %1795 = fadd float %1794, 0.000000e+00
  %1796 = bitcast i32 %131 to float
  %1797 = bitcast i32 %131 to float
  %1798 = fmul float %1796, %1797
  %1799 = fadd float %1795, %1798
  %1800 = call float @llvm.sqrt.f32.91(float %1799)
  %1801 = bitcast i32 %102 to float
  %1802 = fcmp olt float %1801, 0.000000e+00
  %1803 = sext i1 %1802 to i32
  %1804 = bitcast i32 %102 to float
  %1805 = fcmp ogt float %1804, 0.000000e+00
  %1806 = zext i1 %1805 to i32
  %1807 = add nsw i32 %1803, %1806
  %1808 = sitofp i32 %1807 to float
  %1809 = fneg float %1808
  %1810 = fmul float %1800, %1809
  %1811 = fmul float %1810, 0.000000e+00
  %1812 = bitcast i32 %131 to float
  %1813 = fadd float %1812, %1811
  %1814 = fmul float %1791, %1813
  %1815 = fadd float %1769, %1814
  %1816 = call float @llvm.sqrt.f32.92(float %1815)
  %1817 = fadd float %1816, 0.000000e+00
  %1818 = fdiv float %1725, %1817
  %1819 = fmul float %1703, %1818
  %1820 = fneg float %1819
  %1821 = getelementptr float, float* %0, i32 0
  %1822 = getelementptr inbounds float, float* %1821, i64 2
  %1823 = load float, float* %1822, align 4
  %1824 = fmul float %1820, %1823
  %1825 = fadd float %1588, %1824
  %1826 = insertelement <4 x float> zeroinitializer, float %1825, i32 0
  %1827 = insertelement <4 x float> %1826, float 0.000000e+00, i32 1
  %1828 = insertelement <4 x float> %1827, float 0.000000e+00, i32 2
  %1829 = insertelement <4 x float> %1828, float 0.000000e+00, i32 3
  %1830 = extractelement <4 x float> %1829, i32 0
  store float %1830, float* %2, align 4
  %1831 = extractelement <4 x float> %1829, i32 1
  %1832 = getelementptr float, float* %2, i32 0
  %1833 = getelementptr inbounds float, float* %1832, i64 1
  store float %1831, float* %1833, align 4
  %1834 = bitcast i32 %102 to float
  %1835 = bitcast i32 %102 to float
  %1836 = fmul float %1834, %1835
  %1837 = fadd float %1836, 0.000000e+00
  %1838 = bitcast i32 %131 to float
  %1839 = bitcast i32 %131 to float
  %1840 = fmul float %1838, %1839
  %1841 = fadd float %1837, %1840
  %1842 = call float @llvm.sqrt.f32.93(float %1841)
  %1843 = bitcast i32 %102 to float
  %1844 = fcmp olt float %1843, 0.000000e+00
  %1845 = sext i1 %1844 to i32
  %1846 = bitcast i32 %102 to float
  %1847 = fcmp ogt float %1846, 0.000000e+00
  %1848 = zext i1 %1847 to i32
  %1849 = add nsw i32 %1845, %1848
  %1850 = sitofp i32 %1849 to float
  %1851 = fneg float %1850
  %1852 = fmul float %1842, %1851
  %1853 = bitcast i32 %102 to float
  %1854 = fadd float %1853, %1852
  %1855 = bitcast i32 %102 to float
  %1856 = bitcast i32 %102 to float
  %1857 = fmul float %1855, %1856
  %1858 = fadd float %1857, 0.000000e+00
  %1859 = bitcast i32 %131 to float
  %1860 = bitcast i32 %131 to float
  %1861 = fmul float %1859, %1860
  %1862 = fadd float %1858, %1861
  %1863 = call float @llvm.sqrt.f32.94(float %1862)
  %1864 = bitcast i32 %102 to float
  %1865 = fcmp olt float %1864, 0.000000e+00
  %1866 = sext i1 %1865 to i32
  %1867 = bitcast i32 %102 to float
  %1868 = fcmp ogt float %1867, 0.000000e+00
  %1869 = zext i1 %1868 to i32
  %1870 = add nsw i32 %1866, %1869
  %1871 = sitofp i32 %1870 to float
  %1872 = fneg float %1871
  %1873 = fmul float %1863, %1872
  %1874 = bitcast i32 %102 to float
  %1875 = fadd float %1874, %1873
  %1876 = bitcast i32 %102 to float
  %1877 = bitcast i32 %102 to float
  %1878 = fmul float %1876, %1877
  %1879 = fadd float %1878, 0.000000e+00
  %1880 = bitcast i32 %131 to float
  %1881 = bitcast i32 %131 to float
  %1882 = fmul float %1880, %1881
  %1883 = fadd float %1879, %1882
  %1884 = call float @llvm.sqrt.f32.95(float %1883)
  %1885 = bitcast i32 %102 to float
  %1886 = fcmp olt float %1885, 0.000000e+00
  %1887 = sext i1 %1886 to i32
  %1888 = bitcast i32 %102 to float
  %1889 = fcmp ogt float %1888, 0.000000e+00
  %1890 = zext i1 %1889 to i32
  %1891 = add nsw i32 %1887, %1890
  %1892 = sitofp i32 %1891 to float
  %1893 = fneg float %1892
  %1894 = fmul float %1884, %1893
  %1895 = bitcast i32 %102 to float
  %1896 = fadd float %1895, %1894
  %1897 = fmul float %1875, %1896
  %1898 = fadd float %1897, 0.000000e+00
  %1899 = bitcast i32 %102 to float
  %1900 = bitcast i32 %102 to float
  %1901 = fmul float %1899, %1900
  %1902 = fadd float %1901, 0.000000e+00
  %1903 = bitcast i32 %131 to float
  %1904 = bitcast i32 %131 to float
  %1905 = fmul float %1903, %1904
  %1906 = fadd float %1902, %1905
  %1907 = call float @llvm.sqrt.f32.96(float %1906)
  %1908 = bitcast i32 %102 to float
  %1909 = fcmp olt float %1908, 0.000000e+00
  %1910 = sext i1 %1909 to i32
  %1911 = bitcast i32 %102 to float
  %1912 = fcmp ogt float %1911, 0.000000e+00
  %1913 = zext i1 %1912 to i32
  %1914 = add nsw i32 %1910, %1913
  %1915 = sitofp i32 %1914 to float
  %1916 = fneg float %1915
  %1917 = fmul float %1907, %1916
  %1918 = fmul float %1917, 0.000000e+00
  %1919 = bitcast i32 %131 to float
  %1920 = fadd float %1919, %1918
  %1921 = bitcast i32 %102 to float
  %1922 = bitcast i32 %102 to float
  %1923 = fmul float %1921, %1922
  %1924 = fadd float %1923, 0.000000e+00
  %1925 = bitcast i32 %131 to float
  %1926 = bitcast i32 %131 to float
  %1927 = fmul float %1925, %1926
  %1928 = fadd float %1924, %1927
  %1929 = call float @llvm.sqrt.f32.97(float %1928)
  %1930 = bitcast i32 %102 to float
  %1931 = fcmp olt float %1930, 0.000000e+00
  %1932 = sext i1 %1931 to i32
  %1933 = bitcast i32 %102 to float
  %1934 = fcmp ogt float %1933, 0.000000e+00
  %1935 = zext i1 %1934 to i32
  %1936 = add nsw i32 %1932, %1935
  %1937 = sitofp i32 %1936 to float
  %1938 = fneg float %1937
  %1939 = fmul float %1929, %1938
  %1940 = fmul float %1939, 0.000000e+00
  %1941 = bitcast i32 %131 to float
  %1942 = fadd float %1941, %1940
  %1943 = fmul float %1920, %1942
  %1944 = fadd float %1898, %1943
  %1945 = call float @llvm.sqrt.f32.98(float %1944)
  %1946 = fadd float %1945, 0.000000e+00
  %1947 = fdiv float %1854, %1946
  %1948 = fmul float %1947, 2.000000e+00
  %1949 = bitcast i32 %102 to float
  %1950 = bitcast i32 %102 to float
  %1951 = fmul float %1949, %1950
  %1952 = fadd float %1951, 0.000000e+00
  %1953 = bitcast i32 %131 to float
  %1954 = bitcast i32 %131 to float
  %1955 = fmul float %1953, %1954
  %1956 = fadd float %1952, %1955
  %1957 = call float @llvm.sqrt.f32.99(float %1956)
  %1958 = bitcast i32 %102 to float
  %1959 = fcmp olt float %1958, 0.000000e+00
  %1960 = sext i1 %1959 to i32
  %1961 = bitcast i32 %102 to float
  %1962 = fcmp ogt float %1961, 0.000000e+00
  %1963 = zext i1 %1962 to i32
  %1964 = add nsw i32 %1960, %1963
  %1965 = sitofp i32 %1964 to float
  %1966 = fneg float %1965
  %1967 = fmul float %1957, %1966
  %1968 = bitcast i32 %102 to float
  %1969 = fadd float %1968, %1967
  %1970 = bitcast i32 %102 to float
  %1971 = bitcast i32 %102 to float
  %1972 = fmul float %1970, %1971
  %1973 = fadd float %1972, 0.000000e+00
  %1974 = bitcast i32 %131 to float
  %1975 = bitcast i32 %131 to float
  %1976 = fmul float %1974, %1975
  %1977 = fadd float %1973, %1976
  %1978 = call float @llvm.sqrt.f32.100(float %1977)
  %1979 = bitcast i32 %102 to float
  %1980 = fcmp olt float %1979, 0.000000e+00
  %1981 = sext i1 %1980 to i32
  %1982 = bitcast i32 %102 to float
  %1983 = fcmp ogt float %1982, 0.000000e+00
  %1984 = zext i1 %1983 to i32
  %1985 = add nsw i32 %1981, %1984
  %1986 = sitofp i32 %1985 to float
  %1987 = fneg float %1986
  %1988 = fmul float %1978, %1987
  %1989 = bitcast i32 %102 to float
  %1990 = fadd float %1989, %1988
  %1991 = bitcast i32 %102 to float
  %1992 = bitcast i32 %102 to float
  %1993 = fmul float %1991, %1992
  %1994 = fadd float %1993, 0.000000e+00
  %1995 = bitcast i32 %131 to float
  %1996 = bitcast i32 %131 to float
  %1997 = fmul float %1995, %1996
  %1998 = fadd float %1994, %1997
  %1999 = call float @llvm.sqrt.f32.101(float %1998)
  %2000 = bitcast i32 %102 to float
  %2001 = fcmp olt float %2000, 0.000000e+00
  %2002 = sext i1 %2001 to i32
  %2003 = bitcast i32 %102 to float
  %2004 = fcmp ogt float %2003, 0.000000e+00
  %2005 = zext i1 %2004 to i32
  %2006 = add nsw i32 %2002, %2005
  %2007 = sitofp i32 %2006 to float
  %2008 = fneg float %2007
  %2009 = fmul float %1999, %2008
  %2010 = bitcast i32 %102 to float
  %2011 = fadd float %2010, %2009
  %2012 = fmul float %1990, %2011
  %2013 = fadd float %2012, 0.000000e+00
  %2014 = bitcast i32 %102 to float
  %2015 = bitcast i32 %102 to float
  %2016 = fmul float %2014, %2015
  %2017 = fadd float %2016, 0.000000e+00
  %2018 = bitcast i32 %131 to float
  %2019 = bitcast i32 %131 to float
  %2020 = fmul float %2018, %2019
  %2021 = fadd float %2017, %2020
  %2022 = call float @llvm.sqrt.f32.102(float %2021)
  %2023 = bitcast i32 %102 to float
  %2024 = fcmp olt float %2023, 0.000000e+00
  %2025 = sext i1 %2024 to i32
  %2026 = bitcast i32 %102 to float
  %2027 = fcmp ogt float %2026, 0.000000e+00
  %2028 = zext i1 %2027 to i32
  %2029 = add nsw i32 %2025, %2028
  %2030 = sitofp i32 %2029 to float
  %2031 = fneg float %2030
  %2032 = fmul float %2022, %2031
  %2033 = fmul float %2032, 0.000000e+00
  %2034 = bitcast i32 %131 to float
  %2035 = fadd float %2034, %2033
  %2036 = bitcast i32 %102 to float
  %2037 = bitcast i32 %102 to float
  %2038 = fmul float %2036, %2037
  %2039 = fadd float %2038, 0.000000e+00
  %2040 = bitcast i32 %131 to float
  %2041 = bitcast i32 %131 to float
  %2042 = fmul float %2040, %2041
  %2043 = fadd float %2039, %2042
  %2044 = call float @llvm.sqrt.f32.103(float %2043)
  %2045 = bitcast i32 %102 to float
  %2046 = fcmp olt float %2045, 0.000000e+00
  %2047 = sext i1 %2046 to i32
  %2048 = bitcast i32 %102 to float
  %2049 = fcmp ogt float %2048, 0.000000e+00
  %2050 = zext i1 %2049 to i32
  %2051 = add nsw i32 %2047, %2050
  %2052 = sitofp i32 %2051 to float
  %2053 = fneg float %2052
  %2054 = fmul float %2044, %2053
  %2055 = fmul float %2054, 0.000000e+00
  %2056 = bitcast i32 %131 to float
  %2057 = fadd float %2056, %2055
  %2058 = fmul float %2035, %2057
  %2059 = fadd float %2013, %2058
  %2060 = call float @llvm.sqrt.f32.104(float %2059)
  %2061 = fadd float %2060, 0.000000e+00
  %2062 = fdiv float %1969, %2061
  %2063 = fmul float %1948, %2062
  %2064 = fsub float 1.000000e+00, %2063
  %2065 = insertelement <4 x float> zeroinitializer, float %2064, i32 0
  %2066 = insertelement <4 x float> %2065, float 0.000000e+00, i32 1
  %2067 = insertelement <4 x float> %2066, float 0.000000e+00, i32 2
  %2068 = insertelement <4 x float> %2067, float 0.000000e+00, i32 3
  %2069 = getelementptr float, float* %0, i32 0
  %2070 = getelementptr inbounds float, float* %2069, i64 1
  %2071 = load float, float* %2070, align 4
  %2072 = insertelement <4 x float> zeroinitializer, float %2071, i32 0
  %2073 = insertelement <4 x float> %2072, float 0.000000e+00, i32 1
  %2074 = insertelement <4 x float> %2073, float 0.000000e+00, i32 2
  %2075 = insertelement <4 x float> %2074, float 0.000000e+00, i32 3
  %2076 = call <4 x float> @llvm.fma.f32.105(<4 x float> %2068, <4 x float> %2075, <4 x float> zeroinitializer)
  %2077 = extractelement <4 x float> %2076, i32 0
  %2078 = getelementptr float, float* %2, i32 0
  %2079 = getelementptr inbounds float, float* %2078, i64 1
  store float %2077, float* %2079, align 4
  %2080 = bitcast i32 %102 to float
  %2081 = bitcast i32 %102 to float
  %2082 = fmul float %2080, %2081
  %2083 = fadd float %2082, 0.000000e+00
  %2084 = bitcast i32 %131 to float
  %2085 = bitcast i32 %131 to float
  %2086 = fmul float %2084, %2085
  %2087 = fadd float %2083, %2086
  %2088 = call float @llvm.sqrt.f32.106(float %2087)
  %2089 = bitcast i32 %102 to float
  %2090 = fcmp olt float %2089, 0.000000e+00
  %2091 = sext i1 %2090 to i32
  %2092 = bitcast i32 %102 to float
  %2093 = fcmp ogt float %2092, 0.000000e+00
  %2094 = zext i1 %2093 to i32
  %2095 = add nsw i32 %2091, %2094
  %2096 = sitofp i32 %2095 to float
  %2097 = fneg float %2096
  %2098 = fmul float %2088, %2097
  %2099 = bitcast i32 %102 to float
  %2100 = fadd float %2099, %2098
  %2101 = bitcast i32 %102 to float
  %2102 = bitcast i32 %102 to float
  %2103 = fmul float %2101, %2102
  %2104 = fadd float %2103, 0.000000e+00
  %2105 = bitcast i32 %131 to float
  %2106 = bitcast i32 %131 to float
  %2107 = fmul float %2105, %2106
  %2108 = fadd float %2104, %2107
  %2109 = call float @llvm.sqrt.f32.107(float %2108)
  %2110 = bitcast i32 %102 to float
  %2111 = fcmp olt float %2110, 0.000000e+00
  %2112 = sext i1 %2111 to i32
  %2113 = bitcast i32 %102 to float
  %2114 = fcmp ogt float %2113, 0.000000e+00
  %2115 = zext i1 %2114 to i32
  %2116 = add nsw i32 %2112, %2115
  %2117 = sitofp i32 %2116 to float
  %2118 = fneg float %2117
  %2119 = fmul float %2109, %2118
  %2120 = bitcast i32 %102 to float
  %2121 = fadd float %2120, %2119
  %2122 = bitcast i32 %102 to float
  %2123 = bitcast i32 %102 to float
  %2124 = fmul float %2122, %2123
  %2125 = fadd float %2124, 0.000000e+00
  %2126 = bitcast i32 %131 to float
  %2127 = bitcast i32 %131 to float
  %2128 = fmul float %2126, %2127
  %2129 = fadd float %2125, %2128
  %2130 = call float @llvm.sqrt.f32.108(float %2129)
  %2131 = bitcast i32 %102 to float
  %2132 = fcmp olt float %2131, 0.000000e+00
  %2133 = sext i1 %2132 to i32
  %2134 = bitcast i32 %102 to float
  %2135 = fcmp ogt float %2134, 0.000000e+00
  %2136 = zext i1 %2135 to i32
  %2137 = add nsw i32 %2133, %2136
  %2138 = sitofp i32 %2137 to float
  %2139 = fneg float %2138
  %2140 = fmul float %2130, %2139
  %2141 = bitcast i32 %102 to float
  %2142 = fadd float %2141, %2140
  %2143 = fmul float %2121, %2142
  %2144 = fadd float %2143, 0.000000e+00
  %2145 = bitcast i32 %102 to float
  %2146 = bitcast i32 %102 to float
  %2147 = fmul float %2145, %2146
  %2148 = fadd float %2147, 0.000000e+00
  %2149 = bitcast i32 %131 to float
  %2150 = bitcast i32 %131 to float
  %2151 = fmul float %2149, %2150
  %2152 = fadd float %2148, %2151
  %2153 = call float @llvm.sqrt.f32.109(float %2152)
  %2154 = bitcast i32 %102 to float
  %2155 = fcmp olt float %2154, 0.000000e+00
  %2156 = sext i1 %2155 to i32
  %2157 = bitcast i32 %102 to float
  %2158 = fcmp ogt float %2157, 0.000000e+00
  %2159 = zext i1 %2158 to i32
  %2160 = add nsw i32 %2156, %2159
  %2161 = sitofp i32 %2160 to float
  %2162 = fneg float %2161
  %2163 = fmul float %2153, %2162
  %2164 = fmul float %2163, 0.000000e+00
  %2165 = bitcast i32 %131 to float
  %2166 = fadd float %2165, %2164
  %2167 = bitcast i32 %102 to float
  %2168 = bitcast i32 %102 to float
  %2169 = fmul float %2167, %2168
  %2170 = fadd float %2169, 0.000000e+00
  %2171 = bitcast i32 %131 to float
  %2172 = bitcast i32 %131 to float
  %2173 = fmul float %2171, %2172
  %2174 = fadd float %2170, %2173
  %2175 = call float @llvm.sqrt.f32.110(float %2174)
  %2176 = bitcast i32 %102 to float
  %2177 = fcmp olt float %2176, 0.000000e+00
  %2178 = sext i1 %2177 to i32
  %2179 = bitcast i32 %102 to float
  %2180 = fcmp ogt float %2179, 0.000000e+00
  %2181 = zext i1 %2180 to i32
  %2182 = add nsw i32 %2178, %2181
  %2183 = sitofp i32 %2182 to float
  %2184 = fneg float %2183
  %2185 = fmul float %2175, %2184
  %2186 = fmul float %2185, 0.000000e+00
  %2187 = bitcast i32 %131 to float
  %2188 = fadd float %2187, %2186
  %2189 = fmul float %2166, %2188
  %2190 = fadd float %2144, %2189
  %2191 = call float @llvm.sqrt.f32.111(float %2190)
  %2192 = fadd float %2191, 0.000000e+00
  %2193 = fdiv float %2100, %2192
  %2194 = fmul float %2193, 2.000000e+00
  %2195 = bitcast i32 %102 to float
  %2196 = bitcast i32 %102 to float
  %2197 = fmul float %2195, %2196
  %2198 = fadd float %2197, 0.000000e+00
  %2199 = bitcast i32 %131 to float
  %2200 = bitcast i32 %131 to float
  %2201 = fmul float %2199, %2200
  %2202 = fadd float %2198, %2201
  %2203 = call float @llvm.sqrt.f32.112(float %2202)
  %2204 = bitcast i32 %102 to float
  %2205 = fcmp olt float %2204, 0.000000e+00
  %2206 = sext i1 %2205 to i32
  %2207 = bitcast i32 %102 to float
  %2208 = fcmp ogt float %2207, 0.000000e+00
  %2209 = zext i1 %2208 to i32
  %2210 = add nsw i32 %2206, %2209
  %2211 = sitofp i32 %2210 to float
  %2212 = fneg float %2211
  %2213 = fmul float %2203, %2212
  %2214 = bitcast i32 %102 to float
  %2215 = fadd float %2214, %2213
  %2216 = bitcast i32 %102 to float
  %2217 = bitcast i32 %102 to float
  %2218 = fmul float %2216, %2217
  %2219 = fadd float %2218, 0.000000e+00
  %2220 = bitcast i32 %131 to float
  %2221 = bitcast i32 %131 to float
  %2222 = fmul float %2220, %2221
  %2223 = fadd float %2219, %2222
  %2224 = call float @llvm.sqrt.f32.113(float %2223)
  %2225 = bitcast i32 %102 to float
  %2226 = fcmp olt float %2225, 0.000000e+00
  %2227 = sext i1 %2226 to i32
  %2228 = bitcast i32 %102 to float
  %2229 = fcmp ogt float %2228, 0.000000e+00
  %2230 = zext i1 %2229 to i32
  %2231 = add nsw i32 %2227, %2230
  %2232 = sitofp i32 %2231 to float
  %2233 = fneg float %2232
  %2234 = fmul float %2224, %2233
  %2235 = bitcast i32 %102 to float
  %2236 = fadd float %2235, %2234
  %2237 = bitcast i32 %102 to float
  %2238 = bitcast i32 %102 to float
  %2239 = fmul float %2237, %2238
  %2240 = fadd float %2239, 0.000000e+00
  %2241 = bitcast i32 %131 to float
  %2242 = bitcast i32 %131 to float
  %2243 = fmul float %2241, %2242
  %2244 = fadd float %2240, %2243
  %2245 = call float @llvm.sqrt.f32.114(float %2244)
  %2246 = bitcast i32 %102 to float
  %2247 = fcmp olt float %2246, 0.000000e+00
  %2248 = sext i1 %2247 to i32
  %2249 = bitcast i32 %102 to float
  %2250 = fcmp ogt float %2249, 0.000000e+00
  %2251 = zext i1 %2250 to i32
  %2252 = add nsw i32 %2248, %2251
  %2253 = sitofp i32 %2252 to float
  %2254 = fneg float %2253
  %2255 = fmul float %2245, %2254
  %2256 = bitcast i32 %102 to float
  %2257 = fadd float %2256, %2255
  %2258 = fmul float %2236, %2257
  %2259 = fadd float %2258, 0.000000e+00
  %2260 = bitcast i32 %102 to float
  %2261 = bitcast i32 %102 to float
  %2262 = fmul float %2260, %2261
  %2263 = fadd float %2262, 0.000000e+00
  %2264 = bitcast i32 %131 to float
  %2265 = bitcast i32 %131 to float
  %2266 = fmul float %2264, %2265
  %2267 = fadd float %2263, %2266
  %2268 = call float @llvm.sqrt.f32.115(float %2267)
  %2269 = bitcast i32 %102 to float
  %2270 = fcmp olt float %2269, 0.000000e+00
  %2271 = sext i1 %2270 to i32
  %2272 = bitcast i32 %102 to float
  %2273 = fcmp ogt float %2272, 0.000000e+00
  %2274 = zext i1 %2273 to i32
  %2275 = add nsw i32 %2271, %2274
  %2276 = sitofp i32 %2275 to float
  %2277 = fneg float %2276
  %2278 = fmul float %2268, %2277
  %2279 = fmul float %2278, 0.000000e+00
  %2280 = bitcast i32 %131 to float
  %2281 = fadd float %2280, %2279
  %2282 = bitcast i32 %102 to float
  %2283 = bitcast i32 %102 to float
  %2284 = fmul float %2282, %2283
  %2285 = fadd float %2284, 0.000000e+00
  %2286 = bitcast i32 %131 to float
  %2287 = bitcast i32 %131 to float
  %2288 = fmul float %2286, %2287
  %2289 = fadd float %2285, %2288
  %2290 = call float @llvm.sqrt.f32.116(float %2289)
  %2291 = bitcast i32 %102 to float
  %2292 = fcmp olt float %2291, 0.000000e+00
  %2293 = sext i1 %2292 to i32
  %2294 = bitcast i32 %102 to float
  %2295 = fcmp ogt float %2294, 0.000000e+00
  %2296 = zext i1 %2295 to i32
  %2297 = add nsw i32 %2293, %2296
  %2298 = sitofp i32 %2297 to float
  %2299 = fneg float %2298
  %2300 = fmul float %2290, %2299
  %2301 = fmul float %2300, 0.000000e+00
  %2302 = bitcast i32 %131 to float
  %2303 = fadd float %2302, %2301
  %2304 = fmul float %2281, %2303
  %2305 = fadd float %2259, %2304
  %2306 = call float @llvm.sqrt.f32.117(float %2305)
  %2307 = fadd float %2306, 0.000000e+00
  %2308 = fdiv float %2215, %2307
  %2309 = fmul float %2194, %2308
  %2310 = fsub float 1.000000e+00, %2309
  %2311 = fmul float %2310, %2071
  %2312 = fadd float %2311, 0.000000e+00
  %2313 = bitcast i32 %102 to float
  %2314 = bitcast i32 %102 to float
  %2315 = fmul float %2313, %2314
  %2316 = fadd float %2315, 0.000000e+00
  %2317 = bitcast i32 %131 to float
  %2318 = bitcast i32 %131 to float
  %2319 = fmul float %2317, %2318
  %2320 = fadd float %2316, %2319
  %2321 = call float @llvm.sqrt.f32.118(float %2320)
  %2322 = bitcast i32 %102 to float
  %2323 = fcmp olt float %2322, 0.000000e+00
  %2324 = sext i1 %2323 to i32
  %2325 = bitcast i32 %102 to float
  %2326 = fcmp ogt float %2325, 0.000000e+00
  %2327 = zext i1 %2326 to i32
  %2328 = add nsw i32 %2324, %2327
  %2329 = sitofp i32 %2328 to float
  %2330 = fneg float %2329
  %2331 = fmul float %2321, %2330
  %2332 = bitcast i32 %102 to float
  %2333 = fadd float %2332, %2331
  %2334 = bitcast i32 %102 to float
  %2335 = bitcast i32 %102 to float
  %2336 = fmul float %2334, %2335
  %2337 = fadd float %2336, 0.000000e+00
  %2338 = bitcast i32 %131 to float
  %2339 = bitcast i32 %131 to float
  %2340 = fmul float %2338, %2339
  %2341 = fadd float %2337, %2340
  %2342 = call float @llvm.sqrt.f32.119(float %2341)
  %2343 = bitcast i32 %102 to float
  %2344 = fcmp olt float %2343, 0.000000e+00
  %2345 = sext i1 %2344 to i32
  %2346 = bitcast i32 %102 to float
  %2347 = fcmp ogt float %2346, 0.000000e+00
  %2348 = zext i1 %2347 to i32
  %2349 = add nsw i32 %2345, %2348
  %2350 = sitofp i32 %2349 to float
  %2351 = fneg float %2350
  %2352 = fmul float %2342, %2351
  %2353 = bitcast i32 %102 to float
  %2354 = fadd float %2353, %2352
  %2355 = bitcast i32 %102 to float
  %2356 = bitcast i32 %102 to float
  %2357 = fmul float %2355, %2356
  %2358 = fadd float %2357, 0.000000e+00
  %2359 = bitcast i32 %131 to float
  %2360 = bitcast i32 %131 to float
  %2361 = fmul float %2359, %2360
  %2362 = fadd float %2358, %2361
  %2363 = call float @llvm.sqrt.f32.120(float %2362)
  %2364 = bitcast i32 %102 to float
  %2365 = fcmp olt float %2364, 0.000000e+00
  %2366 = sext i1 %2365 to i32
  %2367 = bitcast i32 %102 to float
  %2368 = fcmp ogt float %2367, 0.000000e+00
  %2369 = zext i1 %2368 to i32
  %2370 = add nsw i32 %2366, %2369
  %2371 = sitofp i32 %2370 to float
  %2372 = fneg float %2371
  %2373 = fmul float %2363, %2372
  %2374 = bitcast i32 %102 to float
  %2375 = fadd float %2374, %2373
  %2376 = fmul float %2354, %2375
  %2377 = fadd float %2376, 0.000000e+00
  %2378 = bitcast i32 %102 to float
  %2379 = bitcast i32 %102 to float
  %2380 = fmul float %2378, %2379
  %2381 = fadd float %2380, 0.000000e+00
  %2382 = bitcast i32 %131 to float
  %2383 = bitcast i32 %131 to float
  %2384 = fmul float %2382, %2383
  %2385 = fadd float %2381, %2384
  %2386 = call float @llvm.sqrt.f32.121(float %2385)
  %2387 = bitcast i32 %102 to float
  %2388 = fcmp olt float %2387, 0.000000e+00
  %2389 = sext i1 %2388 to i32
  %2390 = bitcast i32 %102 to float
  %2391 = fcmp ogt float %2390, 0.000000e+00
  %2392 = zext i1 %2391 to i32
  %2393 = add nsw i32 %2389, %2392
  %2394 = sitofp i32 %2393 to float
  %2395 = fneg float %2394
  %2396 = fmul float %2386, %2395
  %2397 = fmul float %2396, 0.000000e+00
  %2398 = bitcast i32 %131 to float
  %2399 = fadd float %2398, %2397
  %2400 = bitcast i32 %102 to float
  %2401 = bitcast i32 %102 to float
  %2402 = fmul float %2400, %2401
  %2403 = fadd float %2402, 0.000000e+00
  %2404 = bitcast i32 %131 to float
  %2405 = bitcast i32 %131 to float
  %2406 = fmul float %2404, %2405
  %2407 = fadd float %2403, %2406
  %2408 = call float @llvm.sqrt.f32.122(float %2407)
  %2409 = bitcast i32 %102 to float
  %2410 = fcmp olt float %2409, 0.000000e+00
  %2411 = sext i1 %2410 to i32
  %2412 = bitcast i32 %102 to float
  %2413 = fcmp ogt float %2412, 0.000000e+00
  %2414 = zext i1 %2413 to i32
  %2415 = add nsw i32 %2411, %2414
  %2416 = sitofp i32 %2415 to float
  %2417 = fneg float %2416
  %2418 = fmul float %2408, %2417
  %2419 = fmul float %2418, 0.000000e+00
  %2420 = bitcast i32 %131 to float
  %2421 = fadd float %2420, %2419
  %2422 = fmul float %2399, %2421
  %2423 = fadd float %2377, %2422
  %2424 = call float @llvm.sqrt.f32.123(float %2423)
  %2425 = fadd float %2424, 0.000000e+00
  %2426 = fdiv float %2333, %2425
  %2427 = fmul float %2426, 2.000000e+00
  %2428 = bitcast i32 %102 to float
  %2429 = bitcast i32 %102 to float
  %2430 = fmul float %2428, %2429
  %2431 = fadd float %2430, 0.000000e+00
  %2432 = bitcast i32 %131 to float
  %2433 = bitcast i32 %131 to float
  %2434 = fmul float %2432, %2433
  %2435 = fadd float %2431, %2434
  %2436 = call float @llvm.sqrt.f32.124(float %2435)
  %2437 = bitcast i32 %102 to float
  %2438 = fcmp olt float %2437, 0.000000e+00
  %2439 = sext i1 %2438 to i32
  %2440 = bitcast i32 %102 to float
  %2441 = fcmp ogt float %2440, 0.000000e+00
  %2442 = zext i1 %2441 to i32
  %2443 = add nsw i32 %2439, %2442
  %2444 = sitofp i32 %2443 to float
  %2445 = fneg float %2444
  %2446 = fmul float %2436, %2445
  %2447 = fmul float %2446, 0.000000e+00
  %2448 = bitcast i32 %131 to float
  %2449 = fadd float %2448, %2447
  %2450 = bitcast i32 %102 to float
  %2451 = bitcast i32 %102 to float
  %2452 = fmul float %2450, %2451
  %2453 = fadd float %2452, 0.000000e+00
  %2454 = bitcast i32 %131 to float
  %2455 = bitcast i32 %131 to float
  %2456 = fmul float %2454, %2455
  %2457 = fadd float %2453, %2456
  %2458 = call float @llvm.sqrt.f32.125(float %2457)
  %2459 = bitcast i32 %102 to float
  %2460 = fcmp olt float %2459, 0.000000e+00
  %2461 = sext i1 %2460 to i32
  %2462 = bitcast i32 %102 to float
  %2463 = fcmp ogt float %2462, 0.000000e+00
  %2464 = zext i1 %2463 to i32
  %2465 = add nsw i32 %2461, %2464
  %2466 = sitofp i32 %2465 to float
  %2467 = fneg float %2466
  %2468 = fmul float %2458, %2467
  %2469 = bitcast i32 %102 to float
  %2470 = fadd float %2469, %2468
  %2471 = bitcast i32 %102 to float
  %2472 = bitcast i32 %102 to float
  %2473 = fmul float %2471, %2472
  %2474 = fadd float %2473, 0.000000e+00
  %2475 = bitcast i32 %131 to float
  %2476 = bitcast i32 %131 to float
  %2477 = fmul float %2475, %2476
  %2478 = fadd float %2474, %2477
  %2479 = call float @llvm.sqrt.f32.126(float %2478)
  %2480 = bitcast i32 %102 to float
  %2481 = fcmp olt float %2480, 0.000000e+00
  %2482 = sext i1 %2481 to i32
  %2483 = bitcast i32 %102 to float
  %2484 = fcmp ogt float %2483, 0.000000e+00
  %2485 = zext i1 %2484 to i32
  %2486 = add nsw i32 %2482, %2485
  %2487 = sitofp i32 %2486 to float
  %2488 = fneg float %2487
  %2489 = fmul float %2479, %2488
  %2490 = bitcast i32 %102 to float
  %2491 = fadd float %2490, %2489
  %2492 = fmul float %2470, %2491
  %2493 = fadd float %2492, 0.000000e+00
  %2494 = bitcast i32 %102 to float
  %2495 = bitcast i32 %102 to float
  %2496 = fmul float %2494, %2495
  %2497 = fadd float %2496, 0.000000e+00
  %2498 = bitcast i32 %131 to float
  %2499 = bitcast i32 %131 to float
  %2500 = fmul float %2498, %2499
  %2501 = fadd float %2497, %2500
  %2502 = call float @llvm.sqrt.f32.127(float %2501)
  %2503 = bitcast i32 %102 to float
  %2504 = fcmp olt float %2503, 0.000000e+00
  %2505 = sext i1 %2504 to i32
  %2506 = bitcast i32 %102 to float
  %2507 = fcmp ogt float %2506, 0.000000e+00
  %2508 = zext i1 %2507 to i32
  %2509 = add nsw i32 %2505, %2508
  %2510 = sitofp i32 %2509 to float
  %2511 = fneg float %2510
  %2512 = fmul float %2502, %2511
  %2513 = fmul float %2512, 0.000000e+00
  %2514 = bitcast i32 %131 to float
  %2515 = fadd float %2514, %2513
  %2516 = bitcast i32 %102 to float
  %2517 = bitcast i32 %102 to float
  %2518 = fmul float %2516, %2517
  %2519 = fadd float %2518, 0.000000e+00
  %2520 = bitcast i32 %131 to float
  %2521 = bitcast i32 %131 to float
  %2522 = fmul float %2520, %2521
  %2523 = fadd float %2519, %2522
  %2524 = call float @llvm.sqrt.f32.128(float %2523)
  %2525 = bitcast i32 %102 to float
  %2526 = fcmp olt float %2525, 0.000000e+00
  %2527 = sext i1 %2526 to i32
  %2528 = bitcast i32 %102 to float
  %2529 = fcmp ogt float %2528, 0.000000e+00
  %2530 = zext i1 %2529 to i32
  %2531 = add nsw i32 %2527, %2530
  %2532 = sitofp i32 %2531 to float
  %2533 = fneg float %2532
  %2534 = fmul float %2524, %2533
  %2535 = fmul float %2534, 0.000000e+00
  %2536 = bitcast i32 %131 to float
  %2537 = fadd float %2536, %2535
  %2538 = fmul float %2515, %2537
  %2539 = fadd float %2493, %2538
  %2540 = call float @llvm.sqrt.f32.129(float %2539)
  %2541 = fadd float %2540, 0.000000e+00
  %2542 = fdiv float %2449, %2541
  %2543 = fmul float %2427, %2542
  %2544 = fneg float %2543
  %2545 = getelementptr float, float* %0, i32 0
  %2546 = getelementptr inbounds float, float* %2545, i64 3
  %2547 = load float, float* %2546, align 4
  %2548 = fmul float %2544, %2547
  %2549 = fadd float %2312, %2548
  %2550 = insertelement <4 x float> zeroinitializer, float %2549, i32 0
  %2551 = insertelement <4 x float> %2550, float 0.000000e+00, i32 1
  %2552 = insertelement <4 x float> %2551, float 0.000000e+00, i32 2
  %2553 = insertelement <4 x float> %2552, float 0.000000e+00, i32 3
  %2554 = extractelement <4 x float> %2553, i32 0
  %2555 = getelementptr float, float* %2, i32 0
  %2556 = getelementptr inbounds float, float* %2555, i64 1
  store float %2554, float* %2556, align 4
  %2557 = extractelement <4 x float> %2553, i32 1
  %2558 = getelementptr float, float* %2, i32 0
  %2559 = getelementptr inbounds float, float* %2558, i64 2
  store float %2557, float* %2559, align 4
  %2560 = bitcast i32 %102 to float
  %2561 = bitcast i32 %102 to float
  %2562 = fmul float %2560, %2561
  %2563 = fadd float %2562, 0.000000e+00
  %2564 = bitcast i32 %131 to float
  %2565 = bitcast i32 %131 to float
  %2566 = fmul float %2564, %2565
  %2567 = fadd float %2563, %2566
  %2568 = call float @llvm.sqrt.f32.130(float %2567)
  %2569 = bitcast i32 %102 to float
  %2570 = fcmp olt float %2569, 0.000000e+00
  %2571 = sext i1 %2570 to i32
  %2572 = bitcast i32 %102 to float
  %2573 = fcmp ogt float %2572, 0.000000e+00
  %2574 = zext i1 %2573 to i32
  %2575 = add nsw i32 %2571, %2574
  %2576 = sitofp i32 %2575 to float
  %2577 = fneg float %2576
  %2578 = fmul float %2568, %2577
  %2579 = fmul float %2578, 0.000000e+00
  %2580 = bitcast i32 %131 to float
  %2581 = fadd float %2580, %2579
  %2582 = bitcast i32 %102 to float
  %2583 = bitcast i32 %102 to float
  %2584 = fmul float %2582, %2583
  %2585 = fadd float %2584, 0.000000e+00
  %2586 = bitcast i32 %131 to float
  %2587 = bitcast i32 %131 to float
  %2588 = fmul float %2586, %2587
  %2589 = fadd float %2585, %2588
  %2590 = call float @llvm.sqrt.f32.131(float %2589)
  %2591 = bitcast i32 %102 to float
  %2592 = fcmp olt float %2591, 0.000000e+00
  %2593 = sext i1 %2592 to i32
  %2594 = bitcast i32 %102 to float
  %2595 = fcmp ogt float %2594, 0.000000e+00
  %2596 = zext i1 %2595 to i32
  %2597 = add nsw i32 %2593, %2596
  %2598 = sitofp i32 %2597 to float
  %2599 = fneg float %2598
  %2600 = fmul float %2590, %2599
  %2601 = bitcast i32 %102 to float
  %2602 = fadd float %2601, %2600
  %2603 = bitcast i32 %102 to float
  %2604 = bitcast i32 %102 to float
  %2605 = fmul float %2603, %2604
  %2606 = fadd float %2605, 0.000000e+00
  %2607 = bitcast i32 %131 to float
  %2608 = bitcast i32 %131 to float
  %2609 = fmul float %2607, %2608
  %2610 = fadd float %2606, %2609
  %2611 = call float @llvm.sqrt.f32.132(float %2610)
  %2612 = bitcast i32 %102 to float
  %2613 = fcmp olt float %2612, 0.000000e+00
  %2614 = sext i1 %2613 to i32
  %2615 = bitcast i32 %102 to float
  %2616 = fcmp ogt float %2615, 0.000000e+00
  %2617 = zext i1 %2616 to i32
  %2618 = add nsw i32 %2614, %2617
  %2619 = sitofp i32 %2618 to float
  %2620 = fneg float %2619
  %2621 = fmul float %2611, %2620
  %2622 = bitcast i32 %102 to float
  %2623 = fadd float %2622, %2621
  %2624 = fmul float %2602, %2623
  %2625 = fadd float %2624, 0.000000e+00
  %2626 = bitcast i32 %102 to float
  %2627 = bitcast i32 %102 to float
  %2628 = fmul float %2626, %2627
  %2629 = fadd float %2628, 0.000000e+00
  %2630 = bitcast i32 %131 to float
  %2631 = bitcast i32 %131 to float
  %2632 = fmul float %2630, %2631
  %2633 = fadd float %2629, %2632
  %2634 = call float @llvm.sqrt.f32.133(float %2633)
  %2635 = bitcast i32 %102 to float
  %2636 = fcmp olt float %2635, 0.000000e+00
  %2637 = sext i1 %2636 to i32
  %2638 = bitcast i32 %102 to float
  %2639 = fcmp ogt float %2638, 0.000000e+00
  %2640 = zext i1 %2639 to i32
  %2641 = add nsw i32 %2637, %2640
  %2642 = sitofp i32 %2641 to float
  %2643 = fneg float %2642
  %2644 = fmul float %2634, %2643
  %2645 = fmul float %2644, 0.000000e+00
  %2646 = bitcast i32 %131 to float
  %2647 = fadd float %2646, %2645
  %2648 = bitcast i32 %102 to float
  %2649 = bitcast i32 %102 to float
  %2650 = fmul float %2648, %2649
  %2651 = fadd float %2650, 0.000000e+00
  %2652 = bitcast i32 %131 to float
  %2653 = bitcast i32 %131 to float
  %2654 = fmul float %2652, %2653
  %2655 = fadd float %2651, %2654
  %2656 = call float @llvm.sqrt.f32.134(float %2655)
  %2657 = bitcast i32 %102 to float
  %2658 = fcmp olt float %2657, 0.000000e+00
  %2659 = sext i1 %2658 to i32
  %2660 = bitcast i32 %102 to float
  %2661 = fcmp ogt float %2660, 0.000000e+00
  %2662 = zext i1 %2661 to i32
  %2663 = add nsw i32 %2659, %2662
  %2664 = sitofp i32 %2663 to float
  %2665 = fneg float %2664
  %2666 = fmul float %2656, %2665
  %2667 = fmul float %2666, 0.000000e+00
  %2668 = bitcast i32 %131 to float
  %2669 = fadd float %2668, %2667
  %2670 = fmul float %2647, %2669
  %2671 = fadd float %2625, %2670
  %2672 = call float @llvm.sqrt.f32.135(float %2671)
  %2673 = fadd float %2672, 0.000000e+00
  %2674 = fdiv float %2581, %2673
  %2675 = fmul float %2674, 2.000000e+00
  %2676 = bitcast i32 %102 to float
  %2677 = bitcast i32 %102 to float
  %2678 = fmul float %2676, %2677
  %2679 = fadd float %2678, 0.000000e+00
  %2680 = bitcast i32 %131 to float
  %2681 = bitcast i32 %131 to float
  %2682 = fmul float %2680, %2681
  %2683 = fadd float %2679, %2682
  %2684 = call float @llvm.sqrt.f32.136(float %2683)
  %2685 = bitcast i32 %102 to float
  %2686 = fcmp olt float %2685, 0.000000e+00
  %2687 = sext i1 %2686 to i32
  %2688 = bitcast i32 %102 to float
  %2689 = fcmp ogt float %2688, 0.000000e+00
  %2690 = zext i1 %2689 to i32
  %2691 = add nsw i32 %2687, %2690
  %2692 = sitofp i32 %2691 to float
  %2693 = fneg float %2692
  %2694 = fmul float %2684, %2693
  %2695 = bitcast i32 %102 to float
  %2696 = fadd float %2695, %2694
  %2697 = bitcast i32 %102 to float
  %2698 = bitcast i32 %102 to float
  %2699 = fmul float %2697, %2698
  %2700 = fadd float %2699, 0.000000e+00
  %2701 = bitcast i32 %131 to float
  %2702 = bitcast i32 %131 to float
  %2703 = fmul float %2701, %2702
  %2704 = fadd float %2700, %2703
  %2705 = call float @llvm.sqrt.f32.137(float %2704)
  %2706 = bitcast i32 %102 to float
  %2707 = fcmp olt float %2706, 0.000000e+00
  %2708 = sext i1 %2707 to i32
  %2709 = bitcast i32 %102 to float
  %2710 = fcmp ogt float %2709, 0.000000e+00
  %2711 = zext i1 %2710 to i32
  %2712 = add nsw i32 %2708, %2711
  %2713 = sitofp i32 %2712 to float
  %2714 = fneg float %2713
  %2715 = fmul float %2705, %2714
  %2716 = bitcast i32 %102 to float
  %2717 = fadd float %2716, %2715
  %2718 = bitcast i32 %102 to float
  %2719 = bitcast i32 %102 to float
  %2720 = fmul float %2718, %2719
  %2721 = fadd float %2720, 0.000000e+00
  %2722 = bitcast i32 %131 to float
  %2723 = bitcast i32 %131 to float
  %2724 = fmul float %2722, %2723
  %2725 = fadd float %2721, %2724
  %2726 = call float @llvm.sqrt.f32.138(float %2725)
  %2727 = bitcast i32 %102 to float
  %2728 = fcmp olt float %2727, 0.000000e+00
  %2729 = sext i1 %2728 to i32
  %2730 = bitcast i32 %102 to float
  %2731 = fcmp ogt float %2730, 0.000000e+00
  %2732 = zext i1 %2731 to i32
  %2733 = add nsw i32 %2729, %2732
  %2734 = sitofp i32 %2733 to float
  %2735 = fneg float %2734
  %2736 = fmul float %2726, %2735
  %2737 = bitcast i32 %102 to float
  %2738 = fadd float %2737, %2736
  %2739 = fmul float %2717, %2738
  %2740 = fadd float %2739, 0.000000e+00
  %2741 = bitcast i32 %102 to float
  %2742 = bitcast i32 %102 to float
  %2743 = fmul float %2741, %2742
  %2744 = fadd float %2743, 0.000000e+00
  %2745 = bitcast i32 %131 to float
  %2746 = bitcast i32 %131 to float
  %2747 = fmul float %2745, %2746
  %2748 = fadd float %2744, %2747
  %2749 = call float @llvm.sqrt.f32.139(float %2748)
  %2750 = bitcast i32 %102 to float
  %2751 = fcmp olt float %2750, 0.000000e+00
  %2752 = sext i1 %2751 to i32
  %2753 = bitcast i32 %102 to float
  %2754 = fcmp ogt float %2753, 0.000000e+00
  %2755 = zext i1 %2754 to i32
  %2756 = add nsw i32 %2752, %2755
  %2757 = sitofp i32 %2756 to float
  %2758 = fneg float %2757
  %2759 = fmul float %2749, %2758
  %2760 = fmul float %2759, 0.000000e+00
  %2761 = bitcast i32 %131 to float
  %2762 = fadd float %2761, %2760
  %2763 = bitcast i32 %102 to float
  %2764 = bitcast i32 %102 to float
  %2765 = fmul float %2763, %2764
  %2766 = fadd float %2765, 0.000000e+00
  %2767 = bitcast i32 %131 to float
  %2768 = bitcast i32 %131 to float
  %2769 = fmul float %2767, %2768
  %2770 = fadd float %2766, %2769
  %2771 = call float @llvm.sqrt.f32.140(float %2770)
  %2772 = bitcast i32 %102 to float
  %2773 = fcmp olt float %2772, 0.000000e+00
  %2774 = sext i1 %2773 to i32
  %2775 = bitcast i32 %102 to float
  %2776 = fcmp ogt float %2775, 0.000000e+00
  %2777 = zext i1 %2776 to i32
  %2778 = add nsw i32 %2774, %2777
  %2779 = sitofp i32 %2778 to float
  %2780 = fneg float %2779
  %2781 = fmul float %2771, %2780
  %2782 = fmul float %2781, 0.000000e+00
  %2783 = bitcast i32 %131 to float
  %2784 = fadd float %2783, %2782
  %2785 = fmul float %2762, %2784
  %2786 = fadd float %2740, %2785
  %2787 = call float @llvm.sqrt.f32.141(float %2786)
  %2788 = fadd float %2787, 0.000000e+00
  %2789 = fdiv float %2696, %2788
  %2790 = fmul float %2675, %2789
  %2791 = fneg float %2790
  %2792 = insertelement <4 x float> zeroinitializer, float %2791, i32 0
  %2793 = insertelement <4 x float> %2792, float 0.000000e+00, i32 1
  %2794 = insertelement <4 x float> %2793, float 0.000000e+00, i32 2
  %2795 = insertelement <4 x float> %2794, float 0.000000e+00, i32 3
  %2796 = getelementptr float, float* %0, i32 0
  %2797 = load float, float* %2796, align 4
  %2798 = insertelement <4 x float> zeroinitializer, float %2797, i32 0
  %2799 = insertelement <4 x float> %2798, float 0.000000e+00, i32 1
  %2800 = insertelement <4 x float> %2799, float 0.000000e+00, i32 2
  %2801 = insertelement <4 x float> %2800, float 0.000000e+00, i32 3
  %2802 = call <4 x float> @llvm.fma.f32.142(<4 x float> %2795, <4 x float> %2801, <4 x float> zeroinitializer)
  %2803 = extractelement <4 x float> %2802, i32 0
  %2804 = getelementptr float, float* %2, i32 0
  %2805 = getelementptr inbounds float, float* %2804, i64 2
  store float %2803, float* %2805, align 4
  %2806 = bitcast i32 %102 to float
  %2807 = bitcast i32 %102 to float
  %2808 = fmul float %2806, %2807
  %2809 = fadd float %2808, 0.000000e+00
  %2810 = bitcast i32 %131 to float
  %2811 = bitcast i32 %131 to float
  %2812 = fmul float %2810, %2811
  %2813 = fadd float %2809, %2812
  %2814 = call float @llvm.sqrt.f32.143(float %2813)
  %2815 = bitcast i32 %102 to float
  %2816 = fcmp olt float %2815, 0.000000e+00
  %2817 = sext i1 %2816 to i32
  %2818 = bitcast i32 %102 to float
  %2819 = fcmp ogt float %2818, 0.000000e+00
  %2820 = zext i1 %2819 to i32
  %2821 = add nsw i32 %2817, %2820
  %2822 = sitofp i32 %2821 to float
  %2823 = fneg float %2822
  %2824 = fmul float %2814, %2823
  %2825 = fmul float %2824, 0.000000e+00
  %2826 = bitcast i32 %131 to float
  %2827 = fadd float %2826, %2825
  %2828 = bitcast i32 %102 to float
  %2829 = bitcast i32 %102 to float
  %2830 = fmul float %2828, %2829
  %2831 = fadd float %2830, 0.000000e+00
  %2832 = bitcast i32 %131 to float
  %2833 = bitcast i32 %131 to float
  %2834 = fmul float %2832, %2833
  %2835 = fadd float %2831, %2834
  %2836 = call float @llvm.sqrt.f32.144(float %2835)
  %2837 = bitcast i32 %102 to float
  %2838 = fcmp olt float %2837, 0.000000e+00
  %2839 = sext i1 %2838 to i32
  %2840 = bitcast i32 %102 to float
  %2841 = fcmp ogt float %2840, 0.000000e+00
  %2842 = zext i1 %2841 to i32
  %2843 = add nsw i32 %2839, %2842
  %2844 = sitofp i32 %2843 to float
  %2845 = fneg float %2844
  %2846 = fmul float %2836, %2845
  %2847 = bitcast i32 %102 to float
  %2848 = fadd float %2847, %2846
  %2849 = bitcast i32 %102 to float
  %2850 = bitcast i32 %102 to float
  %2851 = fmul float %2849, %2850
  %2852 = fadd float %2851, 0.000000e+00
  %2853 = bitcast i32 %131 to float
  %2854 = bitcast i32 %131 to float
  %2855 = fmul float %2853, %2854
  %2856 = fadd float %2852, %2855
  %2857 = call float @llvm.sqrt.f32.145(float %2856)
  %2858 = bitcast i32 %102 to float
  %2859 = fcmp olt float %2858, 0.000000e+00
  %2860 = sext i1 %2859 to i32
  %2861 = bitcast i32 %102 to float
  %2862 = fcmp ogt float %2861, 0.000000e+00
  %2863 = zext i1 %2862 to i32
  %2864 = add nsw i32 %2860, %2863
  %2865 = sitofp i32 %2864 to float
  %2866 = fneg float %2865
  %2867 = fmul float %2857, %2866
  %2868 = bitcast i32 %102 to float
  %2869 = fadd float %2868, %2867
  %2870 = fmul float %2848, %2869
  %2871 = fadd float %2870, 0.000000e+00
  %2872 = bitcast i32 %102 to float
  %2873 = bitcast i32 %102 to float
  %2874 = fmul float %2872, %2873
  %2875 = fadd float %2874, 0.000000e+00
  %2876 = bitcast i32 %131 to float
  %2877 = bitcast i32 %131 to float
  %2878 = fmul float %2876, %2877
  %2879 = fadd float %2875, %2878
  %2880 = call float @llvm.sqrt.f32.146(float %2879)
  %2881 = bitcast i32 %102 to float
  %2882 = fcmp olt float %2881, 0.000000e+00
  %2883 = sext i1 %2882 to i32
  %2884 = bitcast i32 %102 to float
  %2885 = fcmp ogt float %2884, 0.000000e+00
  %2886 = zext i1 %2885 to i32
  %2887 = add nsw i32 %2883, %2886
  %2888 = sitofp i32 %2887 to float
  %2889 = fneg float %2888
  %2890 = fmul float %2880, %2889
  %2891 = fmul float %2890, 0.000000e+00
  %2892 = bitcast i32 %131 to float
  %2893 = fadd float %2892, %2891
  %2894 = bitcast i32 %102 to float
  %2895 = bitcast i32 %102 to float
  %2896 = fmul float %2894, %2895
  %2897 = fadd float %2896, 0.000000e+00
  %2898 = bitcast i32 %131 to float
  %2899 = bitcast i32 %131 to float
  %2900 = fmul float %2898, %2899
  %2901 = fadd float %2897, %2900
  %2902 = call float @llvm.sqrt.f32.147(float %2901)
  %2903 = bitcast i32 %102 to float
  %2904 = fcmp olt float %2903, 0.000000e+00
  %2905 = sext i1 %2904 to i32
  %2906 = bitcast i32 %102 to float
  %2907 = fcmp ogt float %2906, 0.000000e+00
  %2908 = zext i1 %2907 to i32
  %2909 = add nsw i32 %2905, %2908
  %2910 = sitofp i32 %2909 to float
  %2911 = fneg float %2910
  %2912 = fmul float %2902, %2911
  %2913 = fmul float %2912, 0.000000e+00
  %2914 = bitcast i32 %131 to float
  %2915 = fadd float %2914, %2913
  %2916 = fmul float %2893, %2915
  %2917 = fadd float %2871, %2916
  %2918 = call float @llvm.sqrt.f32.148(float %2917)
  %2919 = fadd float %2918, 0.000000e+00
  %2920 = fdiv float %2827, %2919
  %2921 = fmul float %2920, 2.000000e+00
  %2922 = bitcast i32 %102 to float
  %2923 = bitcast i32 %102 to float
  %2924 = fmul float %2922, %2923
  %2925 = fadd float %2924, 0.000000e+00
  %2926 = bitcast i32 %131 to float
  %2927 = bitcast i32 %131 to float
  %2928 = fmul float %2926, %2927
  %2929 = fadd float %2925, %2928
  %2930 = call float @llvm.sqrt.f32.149(float %2929)
  %2931 = bitcast i32 %102 to float
  %2932 = fcmp olt float %2931, 0.000000e+00
  %2933 = sext i1 %2932 to i32
  %2934 = bitcast i32 %102 to float
  %2935 = fcmp ogt float %2934, 0.000000e+00
  %2936 = zext i1 %2935 to i32
  %2937 = add nsw i32 %2933, %2936
  %2938 = sitofp i32 %2937 to float
  %2939 = fneg float %2938
  %2940 = fmul float %2930, %2939
  %2941 = bitcast i32 %102 to float
  %2942 = fadd float %2941, %2940
  %2943 = bitcast i32 %102 to float
  %2944 = bitcast i32 %102 to float
  %2945 = fmul float %2943, %2944
  %2946 = fadd float %2945, 0.000000e+00
  %2947 = bitcast i32 %131 to float
  %2948 = bitcast i32 %131 to float
  %2949 = fmul float %2947, %2948
  %2950 = fadd float %2946, %2949
  %2951 = call float @llvm.sqrt.f32.150(float %2950)
  %2952 = bitcast i32 %102 to float
  %2953 = fcmp olt float %2952, 0.000000e+00
  %2954 = sext i1 %2953 to i32
  %2955 = bitcast i32 %102 to float
  %2956 = fcmp ogt float %2955, 0.000000e+00
  %2957 = zext i1 %2956 to i32
  %2958 = add nsw i32 %2954, %2957
  %2959 = sitofp i32 %2958 to float
  %2960 = fneg float %2959
  %2961 = fmul float %2951, %2960
  %2962 = bitcast i32 %102 to float
  %2963 = fadd float %2962, %2961
  %2964 = bitcast i32 %102 to float
  %2965 = bitcast i32 %102 to float
  %2966 = fmul float %2964, %2965
  %2967 = fadd float %2966, 0.000000e+00
  %2968 = bitcast i32 %131 to float
  %2969 = bitcast i32 %131 to float
  %2970 = fmul float %2968, %2969
  %2971 = fadd float %2967, %2970
  %2972 = call float @llvm.sqrt.f32.151(float %2971)
  %2973 = bitcast i32 %102 to float
  %2974 = fcmp olt float %2973, 0.000000e+00
  %2975 = sext i1 %2974 to i32
  %2976 = bitcast i32 %102 to float
  %2977 = fcmp ogt float %2976, 0.000000e+00
  %2978 = zext i1 %2977 to i32
  %2979 = add nsw i32 %2975, %2978
  %2980 = sitofp i32 %2979 to float
  %2981 = fneg float %2980
  %2982 = fmul float %2972, %2981
  %2983 = bitcast i32 %102 to float
  %2984 = fadd float %2983, %2982
  %2985 = fmul float %2963, %2984
  %2986 = fadd float %2985, 0.000000e+00
  %2987 = bitcast i32 %102 to float
  %2988 = bitcast i32 %102 to float
  %2989 = fmul float %2987, %2988
  %2990 = fadd float %2989, 0.000000e+00
  %2991 = bitcast i32 %131 to float
  %2992 = bitcast i32 %131 to float
  %2993 = fmul float %2991, %2992
  %2994 = fadd float %2990, %2993
  %2995 = call float @llvm.sqrt.f32.152(float %2994)
  %2996 = bitcast i32 %102 to float
  %2997 = fcmp olt float %2996, 0.000000e+00
  %2998 = sext i1 %2997 to i32
  %2999 = bitcast i32 %102 to float
  %3000 = fcmp ogt float %2999, 0.000000e+00
  %3001 = zext i1 %3000 to i32
  %3002 = add nsw i32 %2998, %3001
  %3003 = sitofp i32 %3002 to float
  %3004 = fneg float %3003
  %3005 = fmul float %2995, %3004
  %3006 = fmul float %3005, 0.000000e+00
  %3007 = bitcast i32 %131 to float
  %3008 = fadd float %3007, %3006
  %3009 = bitcast i32 %102 to float
  %3010 = bitcast i32 %102 to float
  %3011 = fmul float %3009, %3010
  %3012 = fadd float %3011, 0.000000e+00
  %3013 = bitcast i32 %131 to float
  %3014 = bitcast i32 %131 to float
  %3015 = fmul float %3013, %3014
  %3016 = fadd float %3012, %3015
  %3017 = call float @llvm.sqrt.f32.153(float %3016)
  %3018 = bitcast i32 %102 to float
  %3019 = fcmp olt float %3018, 0.000000e+00
  %3020 = sext i1 %3019 to i32
  %3021 = bitcast i32 %102 to float
  %3022 = fcmp ogt float %3021, 0.000000e+00
  %3023 = zext i1 %3022 to i32
  %3024 = add nsw i32 %3020, %3023
  %3025 = sitofp i32 %3024 to float
  %3026 = fneg float %3025
  %3027 = fmul float %3017, %3026
  %3028 = fmul float %3027, 0.000000e+00
  %3029 = bitcast i32 %131 to float
  %3030 = fadd float %3029, %3028
  %3031 = fmul float %3008, %3030
  %3032 = fadd float %2986, %3031
  %3033 = call float @llvm.sqrt.f32.154(float %3032)
  %3034 = fadd float %3033, 0.000000e+00
  %3035 = fdiv float %2942, %3034
  %3036 = fmul float %2921, %3035
  %3037 = fneg float %3036
  %3038 = fmul float %3037, %2797
  %3039 = fadd float %3038, 0.000000e+00
  %3040 = bitcast i32 %102 to float
  %3041 = bitcast i32 %102 to float
  %3042 = fmul float %3040, %3041
  %3043 = fadd float %3042, 0.000000e+00
  %3044 = bitcast i32 %131 to float
  %3045 = bitcast i32 %131 to float
  %3046 = fmul float %3044, %3045
  %3047 = fadd float %3043, %3046
  %3048 = call float @llvm.sqrt.f32.155(float %3047)
  %3049 = bitcast i32 %102 to float
  %3050 = fcmp olt float %3049, 0.000000e+00
  %3051 = sext i1 %3050 to i32
  %3052 = bitcast i32 %102 to float
  %3053 = fcmp ogt float %3052, 0.000000e+00
  %3054 = zext i1 %3053 to i32
  %3055 = add nsw i32 %3051, %3054
  %3056 = sitofp i32 %3055 to float
  %3057 = fneg float %3056
  %3058 = fmul float %3048, %3057
  %3059 = fmul float %3058, 0.000000e+00
  %3060 = bitcast i32 %131 to float
  %3061 = fadd float %3060, %3059
  %3062 = bitcast i32 %102 to float
  %3063 = bitcast i32 %102 to float
  %3064 = fmul float %3062, %3063
  %3065 = fadd float %3064, 0.000000e+00
  %3066 = bitcast i32 %131 to float
  %3067 = bitcast i32 %131 to float
  %3068 = fmul float %3066, %3067
  %3069 = fadd float %3065, %3068
  %3070 = call float @llvm.sqrt.f32.156(float %3069)
  %3071 = bitcast i32 %102 to float
  %3072 = fcmp olt float %3071, 0.000000e+00
  %3073 = sext i1 %3072 to i32
  %3074 = bitcast i32 %102 to float
  %3075 = fcmp ogt float %3074, 0.000000e+00
  %3076 = zext i1 %3075 to i32
  %3077 = add nsw i32 %3073, %3076
  %3078 = sitofp i32 %3077 to float
  %3079 = fneg float %3078
  %3080 = fmul float %3070, %3079
  %3081 = bitcast i32 %102 to float
  %3082 = fadd float %3081, %3080
  %3083 = bitcast i32 %102 to float
  %3084 = bitcast i32 %102 to float
  %3085 = fmul float %3083, %3084
  %3086 = fadd float %3085, 0.000000e+00
  %3087 = bitcast i32 %131 to float
  %3088 = bitcast i32 %131 to float
  %3089 = fmul float %3087, %3088
  %3090 = fadd float %3086, %3089
  %3091 = call float @llvm.sqrt.f32.157(float %3090)
  %3092 = bitcast i32 %102 to float
  %3093 = fcmp olt float %3092, 0.000000e+00
  %3094 = sext i1 %3093 to i32
  %3095 = bitcast i32 %102 to float
  %3096 = fcmp ogt float %3095, 0.000000e+00
  %3097 = zext i1 %3096 to i32
  %3098 = add nsw i32 %3094, %3097
  %3099 = sitofp i32 %3098 to float
  %3100 = fneg float %3099
  %3101 = fmul float %3091, %3100
  %3102 = bitcast i32 %102 to float
  %3103 = fadd float %3102, %3101
  %3104 = fmul float %3082, %3103
  %3105 = fadd float %3104, 0.000000e+00
  %3106 = bitcast i32 %102 to float
  %3107 = bitcast i32 %102 to float
  %3108 = fmul float %3106, %3107
  %3109 = fadd float %3108, 0.000000e+00
  %3110 = bitcast i32 %131 to float
  %3111 = bitcast i32 %131 to float
  %3112 = fmul float %3110, %3111
  %3113 = fadd float %3109, %3112
  %3114 = call float @llvm.sqrt.f32.158(float %3113)
  %3115 = bitcast i32 %102 to float
  %3116 = fcmp olt float %3115, 0.000000e+00
  %3117 = sext i1 %3116 to i32
  %3118 = bitcast i32 %102 to float
  %3119 = fcmp ogt float %3118, 0.000000e+00
  %3120 = zext i1 %3119 to i32
  %3121 = add nsw i32 %3117, %3120
  %3122 = sitofp i32 %3121 to float
  %3123 = fneg float %3122
  %3124 = fmul float %3114, %3123
  %3125 = fmul float %3124, 0.000000e+00
  %3126 = bitcast i32 %131 to float
  %3127 = fadd float %3126, %3125
  %3128 = bitcast i32 %102 to float
  %3129 = bitcast i32 %102 to float
  %3130 = fmul float %3128, %3129
  %3131 = fadd float %3130, 0.000000e+00
  %3132 = bitcast i32 %131 to float
  %3133 = bitcast i32 %131 to float
  %3134 = fmul float %3132, %3133
  %3135 = fadd float %3131, %3134
  %3136 = call float @llvm.sqrt.f32.159(float %3135)
  %3137 = bitcast i32 %102 to float
  %3138 = fcmp olt float %3137, 0.000000e+00
  %3139 = sext i1 %3138 to i32
  %3140 = bitcast i32 %102 to float
  %3141 = fcmp ogt float %3140, 0.000000e+00
  %3142 = zext i1 %3141 to i32
  %3143 = add nsw i32 %3139, %3142
  %3144 = sitofp i32 %3143 to float
  %3145 = fneg float %3144
  %3146 = fmul float %3136, %3145
  %3147 = fmul float %3146, 0.000000e+00
  %3148 = bitcast i32 %131 to float
  %3149 = fadd float %3148, %3147
  %3150 = fmul float %3127, %3149
  %3151 = fadd float %3105, %3150
  %3152 = call float @llvm.sqrt.f32.160(float %3151)
  %3153 = fadd float %3152, 0.000000e+00
  %3154 = fdiv float %3061, %3153
  %3155 = fmul float %3154, 2.000000e+00
  %3156 = bitcast i32 %102 to float
  %3157 = bitcast i32 %102 to float
  %3158 = fmul float %3156, %3157
  %3159 = fadd float %3158, 0.000000e+00
  %3160 = bitcast i32 %131 to float
  %3161 = bitcast i32 %131 to float
  %3162 = fmul float %3160, %3161
  %3163 = fadd float %3159, %3162
  %3164 = call float @llvm.sqrt.f32.161(float %3163)
  %3165 = bitcast i32 %102 to float
  %3166 = fcmp olt float %3165, 0.000000e+00
  %3167 = sext i1 %3166 to i32
  %3168 = bitcast i32 %102 to float
  %3169 = fcmp ogt float %3168, 0.000000e+00
  %3170 = zext i1 %3169 to i32
  %3171 = add nsw i32 %3167, %3170
  %3172 = sitofp i32 %3171 to float
  %3173 = fneg float %3172
  %3174 = fmul float %3164, %3173
  %3175 = fmul float %3174, 0.000000e+00
  %3176 = bitcast i32 %131 to float
  %3177 = fadd float %3176, %3175
  %3178 = bitcast i32 %102 to float
  %3179 = bitcast i32 %102 to float
  %3180 = fmul float %3178, %3179
  %3181 = fadd float %3180, 0.000000e+00
  %3182 = bitcast i32 %131 to float
  %3183 = bitcast i32 %131 to float
  %3184 = fmul float %3182, %3183
  %3185 = fadd float %3181, %3184
  %3186 = call float @llvm.sqrt.f32.162(float %3185)
  %3187 = bitcast i32 %102 to float
  %3188 = fcmp olt float %3187, 0.000000e+00
  %3189 = sext i1 %3188 to i32
  %3190 = bitcast i32 %102 to float
  %3191 = fcmp ogt float %3190, 0.000000e+00
  %3192 = zext i1 %3191 to i32
  %3193 = add nsw i32 %3189, %3192
  %3194 = sitofp i32 %3193 to float
  %3195 = fneg float %3194
  %3196 = fmul float %3186, %3195
  %3197 = bitcast i32 %102 to float
  %3198 = fadd float %3197, %3196
  %3199 = bitcast i32 %102 to float
  %3200 = bitcast i32 %102 to float
  %3201 = fmul float %3199, %3200
  %3202 = fadd float %3201, 0.000000e+00
  %3203 = bitcast i32 %131 to float
  %3204 = bitcast i32 %131 to float
  %3205 = fmul float %3203, %3204
  %3206 = fadd float %3202, %3205
  %3207 = call float @llvm.sqrt.f32.163(float %3206)
  %3208 = bitcast i32 %102 to float
  %3209 = fcmp olt float %3208, 0.000000e+00
  %3210 = sext i1 %3209 to i32
  %3211 = bitcast i32 %102 to float
  %3212 = fcmp ogt float %3211, 0.000000e+00
  %3213 = zext i1 %3212 to i32
  %3214 = add nsw i32 %3210, %3213
  %3215 = sitofp i32 %3214 to float
  %3216 = fneg float %3215
  %3217 = fmul float %3207, %3216
  %3218 = bitcast i32 %102 to float
  %3219 = fadd float %3218, %3217
  %3220 = fmul float %3198, %3219
  %3221 = fadd float %3220, 0.000000e+00
  %3222 = bitcast i32 %102 to float
  %3223 = bitcast i32 %102 to float
  %3224 = fmul float %3222, %3223
  %3225 = fadd float %3224, 0.000000e+00
  %3226 = bitcast i32 %131 to float
  %3227 = bitcast i32 %131 to float
  %3228 = fmul float %3226, %3227
  %3229 = fadd float %3225, %3228
  %3230 = call float @llvm.sqrt.f32.164(float %3229)
  %3231 = bitcast i32 %102 to float
  %3232 = fcmp olt float %3231, 0.000000e+00
  %3233 = sext i1 %3232 to i32
  %3234 = bitcast i32 %102 to float
  %3235 = fcmp ogt float %3234, 0.000000e+00
  %3236 = zext i1 %3235 to i32
  %3237 = add nsw i32 %3233, %3236
  %3238 = sitofp i32 %3237 to float
  %3239 = fneg float %3238
  %3240 = fmul float %3230, %3239
  %3241 = fmul float %3240, 0.000000e+00
  %3242 = bitcast i32 %131 to float
  %3243 = fadd float %3242, %3241
  %3244 = bitcast i32 %102 to float
  %3245 = bitcast i32 %102 to float
  %3246 = fmul float %3244, %3245
  %3247 = fadd float %3246, 0.000000e+00
  %3248 = bitcast i32 %131 to float
  %3249 = bitcast i32 %131 to float
  %3250 = fmul float %3248, %3249
  %3251 = fadd float %3247, %3250
  %3252 = call float @llvm.sqrt.f32.165(float %3251)
  %3253 = bitcast i32 %102 to float
  %3254 = fcmp olt float %3253, 0.000000e+00
  %3255 = sext i1 %3254 to i32
  %3256 = bitcast i32 %102 to float
  %3257 = fcmp ogt float %3256, 0.000000e+00
  %3258 = zext i1 %3257 to i32
  %3259 = add nsw i32 %3255, %3258
  %3260 = sitofp i32 %3259 to float
  %3261 = fneg float %3260
  %3262 = fmul float %3252, %3261
  %3263 = fmul float %3262, 0.000000e+00
  %3264 = bitcast i32 %131 to float
  %3265 = fadd float %3264, %3263
  %3266 = fmul float %3243, %3265
  %3267 = fadd float %3221, %3266
  %3268 = call float @llvm.sqrt.f32.166(float %3267)
  %3269 = fadd float %3268, 0.000000e+00
  %3270 = fdiv float %3177, %3269
  %3271 = fmul float %3155, %3270
  %3272 = fsub float 1.000000e+00, %3271
  %3273 = getelementptr float, float* %0, i32 0
  %3274 = getelementptr inbounds float, float* %3273, i64 2
  %3275 = load float, float* %3274, align 4
  %3276 = fmul float %3272, %3275
  %3277 = fadd float %3039, %3276
  %3278 = insertelement <4 x float> zeroinitializer, float %3277, i32 0
  %3279 = insertelement <4 x float> %3278, float 0.000000e+00, i32 1
  %3280 = insertelement <4 x float> %3279, float 0.000000e+00, i32 2
  %3281 = insertelement <4 x float> %3280, float 0.000000e+00, i32 3
  %3282 = extractelement <4 x float> %3281, i32 0
  %3283 = getelementptr float, float* %2, i32 0
  %3284 = getelementptr inbounds float, float* %3283, i64 2
  store float %3282, float* %3284, align 4
  %3285 = extractelement <4 x float> %3281, i32 1
  %3286 = getelementptr float, float* %2, i32 0
  %3287 = getelementptr inbounds float, float* %3286, i64 3
  store float %3285, float* %3287, align 4
  %3288 = bitcast i32 %102 to float
  %3289 = bitcast i32 %102 to float
  %3290 = fmul float %3288, %3289
  %3291 = fadd float %3290, 0.000000e+00
  %3292 = bitcast i32 %131 to float
  %3293 = bitcast i32 %131 to float
  %3294 = fmul float %3292, %3293
  %3295 = fadd float %3291, %3294
  %3296 = call float @llvm.sqrt.f32.167(float %3295)
  %3297 = bitcast i32 %102 to float
  %3298 = fcmp olt float %3297, 0.000000e+00
  %3299 = sext i1 %3298 to i32
  %3300 = bitcast i32 %102 to float
  %3301 = fcmp ogt float %3300, 0.000000e+00
  %3302 = zext i1 %3301 to i32
  %3303 = add nsw i32 %3299, %3302
  %3304 = sitofp i32 %3303 to float
  %3305 = fneg float %3304
  %3306 = fmul float %3296, %3305
  %3307 = fmul float %3306, 0.000000e+00
  %3308 = bitcast i32 %131 to float
  %3309 = fadd float %3308, %3307
  %3310 = bitcast i32 %102 to float
  %3311 = bitcast i32 %102 to float
  %3312 = fmul float %3310, %3311
  %3313 = fadd float %3312, 0.000000e+00
  %3314 = bitcast i32 %131 to float
  %3315 = bitcast i32 %131 to float
  %3316 = fmul float %3314, %3315
  %3317 = fadd float %3313, %3316
  %3318 = call float @llvm.sqrt.f32.168(float %3317)
  %3319 = bitcast i32 %102 to float
  %3320 = fcmp olt float %3319, 0.000000e+00
  %3321 = sext i1 %3320 to i32
  %3322 = bitcast i32 %102 to float
  %3323 = fcmp ogt float %3322, 0.000000e+00
  %3324 = zext i1 %3323 to i32
  %3325 = add nsw i32 %3321, %3324
  %3326 = sitofp i32 %3325 to float
  %3327 = fneg float %3326
  %3328 = fmul float %3318, %3327
  %3329 = bitcast i32 %102 to float
  %3330 = fadd float %3329, %3328
  %3331 = bitcast i32 %102 to float
  %3332 = bitcast i32 %102 to float
  %3333 = fmul float %3331, %3332
  %3334 = fadd float %3333, 0.000000e+00
  %3335 = bitcast i32 %131 to float
  %3336 = bitcast i32 %131 to float
  %3337 = fmul float %3335, %3336
  %3338 = fadd float %3334, %3337
  %3339 = call float @llvm.sqrt.f32.169(float %3338)
  %3340 = bitcast i32 %102 to float
  %3341 = fcmp olt float %3340, 0.000000e+00
  %3342 = sext i1 %3341 to i32
  %3343 = bitcast i32 %102 to float
  %3344 = fcmp ogt float %3343, 0.000000e+00
  %3345 = zext i1 %3344 to i32
  %3346 = add nsw i32 %3342, %3345
  %3347 = sitofp i32 %3346 to float
  %3348 = fneg float %3347
  %3349 = fmul float %3339, %3348
  %3350 = bitcast i32 %102 to float
  %3351 = fadd float %3350, %3349
  %3352 = fmul float %3330, %3351
  %3353 = fadd float %3352, 0.000000e+00
  %3354 = bitcast i32 %102 to float
  %3355 = bitcast i32 %102 to float
  %3356 = fmul float %3354, %3355
  %3357 = fadd float %3356, 0.000000e+00
  %3358 = bitcast i32 %131 to float
  %3359 = bitcast i32 %131 to float
  %3360 = fmul float %3358, %3359
  %3361 = fadd float %3357, %3360
  %3362 = call float @llvm.sqrt.f32.170(float %3361)
  %3363 = bitcast i32 %102 to float
  %3364 = fcmp olt float %3363, 0.000000e+00
  %3365 = sext i1 %3364 to i32
  %3366 = bitcast i32 %102 to float
  %3367 = fcmp ogt float %3366, 0.000000e+00
  %3368 = zext i1 %3367 to i32
  %3369 = add nsw i32 %3365, %3368
  %3370 = sitofp i32 %3369 to float
  %3371 = fneg float %3370
  %3372 = fmul float %3362, %3371
  %3373 = fmul float %3372, 0.000000e+00
  %3374 = bitcast i32 %131 to float
  %3375 = fadd float %3374, %3373
  %3376 = bitcast i32 %102 to float
  %3377 = bitcast i32 %102 to float
  %3378 = fmul float %3376, %3377
  %3379 = fadd float %3378, 0.000000e+00
  %3380 = bitcast i32 %131 to float
  %3381 = bitcast i32 %131 to float
  %3382 = fmul float %3380, %3381
  %3383 = fadd float %3379, %3382
  %3384 = call float @llvm.sqrt.f32.171(float %3383)
  %3385 = bitcast i32 %102 to float
  %3386 = fcmp olt float %3385, 0.000000e+00
  %3387 = sext i1 %3386 to i32
  %3388 = bitcast i32 %102 to float
  %3389 = fcmp ogt float %3388, 0.000000e+00
  %3390 = zext i1 %3389 to i32
  %3391 = add nsw i32 %3387, %3390
  %3392 = sitofp i32 %3391 to float
  %3393 = fneg float %3392
  %3394 = fmul float %3384, %3393
  %3395 = fmul float %3394, 0.000000e+00
  %3396 = bitcast i32 %131 to float
  %3397 = fadd float %3396, %3395
  %3398 = fmul float %3375, %3397
  %3399 = fadd float %3353, %3398
  %3400 = call float @llvm.sqrt.f32.172(float %3399)
  %3401 = fadd float %3400, 0.000000e+00
  %3402 = fdiv float %3309, %3401
  %3403 = fmul float %3402, 2.000000e+00
  %3404 = bitcast i32 %102 to float
  %3405 = bitcast i32 %102 to float
  %3406 = fmul float %3404, %3405
  %3407 = fadd float %3406, 0.000000e+00
  %3408 = bitcast i32 %131 to float
  %3409 = bitcast i32 %131 to float
  %3410 = fmul float %3408, %3409
  %3411 = fadd float %3407, %3410
  %3412 = call float @llvm.sqrt.f32.173(float %3411)
  %3413 = bitcast i32 %102 to float
  %3414 = fcmp olt float %3413, 0.000000e+00
  %3415 = sext i1 %3414 to i32
  %3416 = bitcast i32 %102 to float
  %3417 = fcmp ogt float %3416, 0.000000e+00
  %3418 = zext i1 %3417 to i32
  %3419 = add nsw i32 %3415, %3418
  %3420 = sitofp i32 %3419 to float
  %3421 = fneg float %3420
  %3422 = fmul float %3412, %3421
  %3423 = bitcast i32 %102 to float
  %3424 = fadd float %3423, %3422
  %3425 = bitcast i32 %102 to float
  %3426 = bitcast i32 %102 to float
  %3427 = fmul float %3425, %3426
  %3428 = fadd float %3427, 0.000000e+00
  %3429 = bitcast i32 %131 to float
  %3430 = bitcast i32 %131 to float
  %3431 = fmul float %3429, %3430
  %3432 = fadd float %3428, %3431
  %3433 = call float @llvm.sqrt.f32.174(float %3432)
  %3434 = bitcast i32 %102 to float
  %3435 = fcmp olt float %3434, 0.000000e+00
  %3436 = sext i1 %3435 to i32
  %3437 = bitcast i32 %102 to float
  %3438 = fcmp ogt float %3437, 0.000000e+00
  %3439 = zext i1 %3438 to i32
  %3440 = add nsw i32 %3436, %3439
  %3441 = sitofp i32 %3440 to float
  %3442 = fneg float %3441
  %3443 = fmul float %3433, %3442
  %3444 = bitcast i32 %102 to float
  %3445 = fadd float %3444, %3443
  %3446 = bitcast i32 %102 to float
  %3447 = bitcast i32 %102 to float
  %3448 = fmul float %3446, %3447
  %3449 = fadd float %3448, 0.000000e+00
  %3450 = bitcast i32 %131 to float
  %3451 = bitcast i32 %131 to float
  %3452 = fmul float %3450, %3451
  %3453 = fadd float %3449, %3452
  %3454 = call float @llvm.sqrt.f32.175(float %3453)
  %3455 = bitcast i32 %102 to float
  %3456 = fcmp olt float %3455, 0.000000e+00
  %3457 = sext i1 %3456 to i32
  %3458 = bitcast i32 %102 to float
  %3459 = fcmp ogt float %3458, 0.000000e+00
  %3460 = zext i1 %3459 to i32
  %3461 = add nsw i32 %3457, %3460
  %3462 = sitofp i32 %3461 to float
  %3463 = fneg float %3462
  %3464 = fmul float %3454, %3463
  %3465 = bitcast i32 %102 to float
  %3466 = fadd float %3465, %3464
  %3467 = fmul float %3445, %3466
  %3468 = fadd float %3467, 0.000000e+00
  %3469 = bitcast i32 %102 to float
  %3470 = bitcast i32 %102 to float
  %3471 = fmul float %3469, %3470
  %3472 = fadd float %3471, 0.000000e+00
  %3473 = bitcast i32 %131 to float
  %3474 = bitcast i32 %131 to float
  %3475 = fmul float %3473, %3474
  %3476 = fadd float %3472, %3475
  %3477 = call float @llvm.sqrt.f32.176(float %3476)
  %3478 = bitcast i32 %102 to float
  %3479 = fcmp olt float %3478, 0.000000e+00
  %3480 = sext i1 %3479 to i32
  %3481 = bitcast i32 %102 to float
  %3482 = fcmp ogt float %3481, 0.000000e+00
  %3483 = zext i1 %3482 to i32
  %3484 = add nsw i32 %3480, %3483
  %3485 = sitofp i32 %3484 to float
  %3486 = fneg float %3485
  %3487 = fmul float %3477, %3486
  %3488 = fmul float %3487, 0.000000e+00
  %3489 = bitcast i32 %131 to float
  %3490 = fadd float %3489, %3488
  %3491 = bitcast i32 %102 to float
  %3492 = bitcast i32 %102 to float
  %3493 = fmul float %3491, %3492
  %3494 = fadd float %3493, 0.000000e+00
  %3495 = bitcast i32 %131 to float
  %3496 = bitcast i32 %131 to float
  %3497 = fmul float %3495, %3496
  %3498 = fadd float %3494, %3497
  %3499 = call float @llvm.sqrt.f32.177(float %3498)
  %3500 = bitcast i32 %102 to float
  %3501 = fcmp olt float %3500, 0.000000e+00
  %3502 = sext i1 %3501 to i32
  %3503 = bitcast i32 %102 to float
  %3504 = fcmp ogt float %3503, 0.000000e+00
  %3505 = zext i1 %3504 to i32
  %3506 = add nsw i32 %3502, %3505
  %3507 = sitofp i32 %3506 to float
  %3508 = fneg float %3507
  %3509 = fmul float %3499, %3508
  %3510 = fmul float %3509, 0.000000e+00
  %3511 = bitcast i32 %131 to float
  %3512 = fadd float %3511, %3510
  %3513 = fmul float %3490, %3512
  %3514 = fadd float %3468, %3513
  %3515 = call float @llvm.sqrt.f32.178(float %3514)
  %3516 = fadd float %3515, 0.000000e+00
  %3517 = fdiv float %3424, %3516
  %3518 = fmul float %3403, %3517
  %3519 = fneg float %3518
  %3520 = insertelement <4 x float> zeroinitializer, float %3519, i32 0
  %3521 = insertelement <4 x float> %3520, float 0.000000e+00, i32 1
  %3522 = insertelement <4 x float> %3521, float 0.000000e+00, i32 2
  %3523 = insertelement <4 x float> %3522, float 0.000000e+00, i32 3
  %3524 = getelementptr float, float* %0, i32 0
  %3525 = getelementptr inbounds float, float* %3524, i64 1
  %3526 = load float, float* %3525, align 4
  %3527 = insertelement <4 x float> zeroinitializer, float %3526, i32 0
  %3528 = insertelement <4 x float> %3527, float 0.000000e+00, i32 1
  %3529 = insertelement <4 x float> %3528, float 0.000000e+00, i32 2
  %3530 = insertelement <4 x float> %3529, float 0.000000e+00, i32 3
  %3531 = call <4 x float> @llvm.fma.f32.179(<4 x float> %3523, <4 x float> %3530, <4 x float> zeroinitializer)
  %3532 = extractelement <4 x float> %3531, i32 0
  %3533 = getelementptr float, float* %2, i32 0
  %3534 = getelementptr inbounds float, float* %3533, i64 3
  store float %3532, float* %3534, align 4
  %3535 = bitcast i32 %102 to float
  %3536 = bitcast i32 %102 to float
  %3537 = fmul float %3535, %3536
  %3538 = fadd float %3537, 0.000000e+00
  %3539 = bitcast i32 %131 to float
  %3540 = bitcast i32 %131 to float
  %3541 = fmul float %3539, %3540
  %3542 = fadd float %3538, %3541
  %3543 = call float @llvm.sqrt.f32.180(float %3542)
  %3544 = bitcast i32 %102 to float
  %3545 = fcmp olt float %3544, 0.000000e+00
  %3546 = sext i1 %3545 to i32
  %3547 = bitcast i32 %102 to float
  %3548 = fcmp ogt float %3547, 0.000000e+00
  %3549 = zext i1 %3548 to i32
  %3550 = add nsw i32 %3546, %3549
  %3551 = sitofp i32 %3550 to float
  %3552 = fneg float %3551
  %3553 = fmul float %3543, %3552
  %3554 = fmul float %3553, 0.000000e+00
  %3555 = bitcast i32 %131 to float
  %3556 = fadd float %3555, %3554
  %3557 = bitcast i32 %102 to float
  %3558 = bitcast i32 %102 to float
  %3559 = fmul float %3557, %3558
  %3560 = fadd float %3559, 0.000000e+00
  %3561 = bitcast i32 %131 to float
  %3562 = bitcast i32 %131 to float
  %3563 = fmul float %3561, %3562
  %3564 = fadd float %3560, %3563
  %3565 = call float @llvm.sqrt.f32.181(float %3564)
  %3566 = bitcast i32 %102 to float
  %3567 = fcmp olt float %3566, 0.000000e+00
  %3568 = sext i1 %3567 to i32
  %3569 = bitcast i32 %102 to float
  %3570 = fcmp ogt float %3569, 0.000000e+00
  %3571 = zext i1 %3570 to i32
  %3572 = add nsw i32 %3568, %3571
  %3573 = sitofp i32 %3572 to float
  %3574 = fneg float %3573
  %3575 = fmul float %3565, %3574
  %3576 = bitcast i32 %102 to float
  %3577 = fadd float %3576, %3575
  %3578 = bitcast i32 %102 to float
  %3579 = bitcast i32 %102 to float
  %3580 = fmul float %3578, %3579
  %3581 = fadd float %3580, 0.000000e+00
  %3582 = bitcast i32 %131 to float
  %3583 = bitcast i32 %131 to float
  %3584 = fmul float %3582, %3583
  %3585 = fadd float %3581, %3584
  %3586 = call float @llvm.sqrt.f32.182(float %3585)
  %3587 = bitcast i32 %102 to float
  %3588 = fcmp olt float %3587, 0.000000e+00
  %3589 = sext i1 %3588 to i32
  %3590 = bitcast i32 %102 to float
  %3591 = fcmp ogt float %3590, 0.000000e+00
  %3592 = zext i1 %3591 to i32
  %3593 = add nsw i32 %3589, %3592
  %3594 = sitofp i32 %3593 to float
  %3595 = fneg float %3594
  %3596 = fmul float %3586, %3595
  %3597 = bitcast i32 %102 to float
  %3598 = fadd float %3597, %3596
  %3599 = fmul float %3577, %3598
  %3600 = fadd float %3599, 0.000000e+00
  %3601 = bitcast i32 %102 to float
  %3602 = bitcast i32 %102 to float
  %3603 = fmul float %3601, %3602
  %3604 = fadd float %3603, 0.000000e+00
  %3605 = bitcast i32 %131 to float
  %3606 = bitcast i32 %131 to float
  %3607 = fmul float %3605, %3606
  %3608 = fadd float %3604, %3607
  %3609 = call float @llvm.sqrt.f32.183(float %3608)
  %3610 = bitcast i32 %102 to float
  %3611 = fcmp olt float %3610, 0.000000e+00
  %3612 = sext i1 %3611 to i32
  %3613 = bitcast i32 %102 to float
  %3614 = fcmp ogt float %3613, 0.000000e+00
  %3615 = zext i1 %3614 to i32
  %3616 = add nsw i32 %3612, %3615
  %3617 = sitofp i32 %3616 to float
  %3618 = fneg float %3617
  %3619 = fmul float %3609, %3618
  %3620 = fmul float %3619, 0.000000e+00
  %3621 = bitcast i32 %131 to float
  %3622 = fadd float %3621, %3620
  %3623 = bitcast i32 %102 to float
  %3624 = bitcast i32 %102 to float
  %3625 = fmul float %3623, %3624
  %3626 = fadd float %3625, 0.000000e+00
  %3627 = bitcast i32 %131 to float
  %3628 = bitcast i32 %131 to float
  %3629 = fmul float %3627, %3628
  %3630 = fadd float %3626, %3629
  %3631 = call float @llvm.sqrt.f32.184(float %3630)
  %3632 = bitcast i32 %102 to float
  %3633 = fcmp olt float %3632, 0.000000e+00
  %3634 = sext i1 %3633 to i32
  %3635 = bitcast i32 %102 to float
  %3636 = fcmp ogt float %3635, 0.000000e+00
  %3637 = zext i1 %3636 to i32
  %3638 = add nsw i32 %3634, %3637
  %3639 = sitofp i32 %3638 to float
  %3640 = fneg float %3639
  %3641 = fmul float %3631, %3640
  %3642 = fmul float %3641, 0.000000e+00
  %3643 = bitcast i32 %131 to float
  %3644 = fadd float %3643, %3642
  %3645 = fmul float %3622, %3644
  %3646 = fadd float %3600, %3645
  %3647 = call float @llvm.sqrt.f32.185(float %3646)
  %3648 = fadd float %3647, 0.000000e+00
  %3649 = fdiv float %3556, %3648
  %3650 = fmul float %3649, 2.000000e+00
  %3651 = bitcast i32 %102 to float
  %3652 = bitcast i32 %102 to float
  %3653 = fmul float %3651, %3652
  %3654 = fadd float %3653, 0.000000e+00
  %3655 = bitcast i32 %131 to float
  %3656 = bitcast i32 %131 to float
  %3657 = fmul float %3655, %3656
  %3658 = fadd float %3654, %3657
  %3659 = call float @llvm.sqrt.f32.186(float %3658)
  %3660 = bitcast i32 %102 to float
  %3661 = fcmp olt float %3660, 0.000000e+00
  %3662 = sext i1 %3661 to i32
  %3663 = bitcast i32 %102 to float
  %3664 = fcmp ogt float %3663, 0.000000e+00
  %3665 = zext i1 %3664 to i32
  %3666 = add nsw i32 %3662, %3665
  %3667 = sitofp i32 %3666 to float
  %3668 = fneg float %3667
  %3669 = fmul float %3659, %3668
  %3670 = bitcast i32 %102 to float
  %3671 = fadd float %3670, %3669
  %3672 = bitcast i32 %102 to float
  %3673 = bitcast i32 %102 to float
  %3674 = fmul float %3672, %3673
  %3675 = fadd float %3674, 0.000000e+00
  %3676 = bitcast i32 %131 to float
  %3677 = bitcast i32 %131 to float
  %3678 = fmul float %3676, %3677
  %3679 = fadd float %3675, %3678
  %3680 = call float @llvm.sqrt.f32.187(float %3679)
  %3681 = bitcast i32 %102 to float
  %3682 = fcmp olt float %3681, 0.000000e+00
  %3683 = sext i1 %3682 to i32
  %3684 = bitcast i32 %102 to float
  %3685 = fcmp ogt float %3684, 0.000000e+00
  %3686 = zext i1 %3685 to i32
  %3687 = add nsw i32 %3683, %3686
  %3688 = sitofp i32 %3687 to float
  %3689 = fneg float %3688
  %3690 = fmul float %3680, %3689
  %3691 = bitcast i32 %102 to float
  %3692 = fadd float %3691, %3690
  %3693 = bitcast i32 %102 to float
  %3694 = bitcast i32 %102 to float
  %3695 = fmul float %3693, %3694
  %3696 = fadd float %3695, 0.000000e+00
  %3697 = bitcast i32 %131 to float
  %3698 = bitcast i32 %131 to float
  %3699 = fmul float %3697, %3698
  %3700 = fadd float %3696, %3699
  %3701 = call float @llvm.sqrt.f32.188(float %3700)
  %3702 = bitcast i32 %102 to float
  %3703 = fcmp olt float %3702, 0.000000e+00
  %3704 = sext i1 %3703 to i32
  %3705 = bitcast i32 %102 to float
  %3706 = fcmp ogt float %3705, 0.000000e+00
  %3707 = zext i1 %3706 to i32
  %3708 = add nsw i32 %3704, %3707
  %3709 = sitofp i32 %3708 to float
  %3710 = fneg float %3709
  %3711 = fmul float %3701, %3710
  %3712 = bitcast i32 %102 to float
  %3713 = fadd float %3712, %3711
  %3714 = fmul float %3692, %3713
  %3715 = fadd float %3714, 0.000000e+00
  %3716 = bitcast i32 %102 to float
  %3717 = bitcast i32 %102 to float
  %3718 = fmul float %3716, %3717
  %3719 = fadd float %3718, 0.000000e+00
  %3720 = bitcast i32 %131 to float
  %3721 = bitcast i32 %131 to float
  %3722 = fmul float %3720, %3721
  %3723 = fadd float %3719, %3722
  %3724 = call float @llvm.sqrt.f32.189(float %3723)
  %3725 = bitcast i32 %102 to float
  %3726 = fcmp olt float %3725, 0.000000e+00
  %3727 = sext i1 %3726 to i32
  %3728 = bitcast i32 %102 to float
  %3729 = fcmp ogt float %3728, 0.000000e+00
  %3730 = zext i1 %3729 to i32
  %3731 = add nsw i32 %3727, %3730
  %3732 = sitofp i32 %3731 to float
  %3733 = fneg float %3732
  %3734 = fmul float %3724, %3733
  %3735 = fmul float %3734, 0.000000e+00
  %3736 = bitcast i32 %131 to float
  %3737 = fadd float %3736, %3735
  %3738 = bitcast i32 %102 to float
  %3739 = bitcast i32 %102 to float
  %3740 = fmul float %3738, %3739
  %3741 = fadd float %3740, 0.000000e+00
  %3742 = bitcast i32 %131 to float
  %3743 = bitcast i32 %131 to float
  %3744 = fmul float %3742, %3743
  %3745 = fadd float %3741, %3744
  %3746 = call float @llvm.sqrt.f32.190(float %3745)
  %3747 = bitcast i32 %102 to float
  %3748 = fcmp olt float %3747, 0.000000e+00
  %3749 = sext i1 %3748 to i32
  %3750 = bitcast i32 %102 to float
  %3751 = fcmp ogt float %3750, 0.000000e+00
  %3752 = zext i1 %3751 to i32
  %3753 = add nsw i32 %3749, %3752
  %3754 = sitofp i32 %3753 to float
  %3755 = fneg float %3754
  %3756 = fmul float %3746, %3755
  %3757 = fmul float %3756, 0.000000e+00
  %3758 = bitcast i32 %131 to float
  %3759 = fadd float %3758, %3757
  %3760 = fmul float %3737, %3759
  %3761 = fadd float %3715, %3760
  %3762 = call float @llvm.sqrt.f32.191(float %3761)
  %3763 = fadd float %3762, 0.000000e+00
  %3764 = fdiv float %3671, %3763
  %3765 = fmul float %3650, %3764
  %3766 = fneg float %3765
  %3767 = fmul float %3766, %3526
  %3768 = fadd float %3767, 0.000000e+00
  %3769 = bitcast i32 %102 to float
  %3770 = bitcast i32 %102 to float
  %3771 = fmul float %3769, %3770
  %3772 = fadd float %3771, 0.000000e+00
  %3773 = bitcast i32 %131 to float
  %3774 = bitcast i32 %131 to float
  %3775 = fmul float %3773, %3774
  %3776 = fadd float %3772, %3775
  %3777 = call float @llvm.sqrt.f32.192(float %3776)
  %3778 = bitcast i32 %102 to float
  %3779 = fcmp olt float %3778, 0.000000e+00
  %3780 = sext i1 %3779 to i32
  %3781 = bitcast i32 %102 to float
  %3782 = fcmp ogt float %3781, 0.000000e+00
  %3783 = zext i1 %3782 to i32
  %3784 = add nsw i32 %3780, %3783
  %3785 = sitofp i32 %3784 to float
  %3786 = fneg float %3785
  %3787 = fmul float %3777, %3786
  %3788 = fmul float %3787, 0.000000e+00
  %3789 = bitcast i32 %131 to float
  %3790 = fadd float %3789, %3788
  %3791 = bitcast i32 %102 to float
  %3792 = bitcast i32 %102 to float
  %3793 = fmul float %3791, %3792
  %3794 = fadd float %3793, 0.000000e+00
  %3795 = bitcast i32 %131 to float
  %3796 = bitcast i32 %131 to float
  %3797 = fmul float %3795, %3796
  %3798 = fadd float %3794, %3797
  %3799 = call float @llvm.sqrt.f32.193(float %3798)
  %3800 = bitcast i32 %102 to float
  %3801 = fcmp olt float %3800, 0.000000e+00
  %3802 = sext i1 %3801 to i32
  %3803 = bitcast i32 %102 to float
  %3804 = fcmp ogt float %3803, 0.000000e+00
  %3805 = zext i1 %3804 to i32
  %3806 = add nsw i32 %3802, %3805
  %3807 = sitofp i32 %3806 to float
  %3808 = fneg float %3807
  %3809 = fmul float %3799, %3808
  %3810 = bitcast i32 %102 to float
  %3811 = fadd float %3810, %3809
  %3812 = bitcast i32 %102 to float
  %3813 = bitcast i32 %102 to float
  %3814 = fmul float %3812, %3813
  %3815 = fadd float %3814, 0.000000e+00
  %3816 = bitcast i32 %131 to float
  %3817 = bitcast i32 %131 to float
  %3818 = fmul float %3816, %3817
  %3819 = fadd float %3815, %3818
  %3820 = call float @llvm.sqrt.f32.194(float %3819)
  %3821 = bitcast i32 %102 to float
  %3822 = fcmp olt float %3821, 0.000000e+00
  %3823 = sext i1 %3822 to i32
  %3824 = bitcast i32 %102 to float
  %3825 = fcmp ogt float %3824, 0.000000e+00
  %3826 = zext i1 %3825 to i32
  %3827 = add nsw i32 %3823, %3826
  %3828 = sitofp i32 %3827 to float
  %3829 = fneg float %3828
  %3830 = fmul float %3820, %3829
  %3831 = bitcast i32 %102 to float
  %3832 = fadd float %3831, %3830
  %3833 = fmul float %3811, %3832
  %3834 = fadd float %3833, 0.000000e+00
  %3835 = bitcast i32 %102 to float
  %3836 = bitcast i32 %102 to float
  %3837 = fmul float %3835, %3836
  %3838 = fadd float %3837, 0.000000e+00
  %3839 = bitcast i32 %131 to float
  %3840 = bitcast i32 %131 to float
  %3841 = fmul float %3839, %3840
  %3842 = fadd float %3838, %3841
  %3843 = call float @llvm.sqrt.f32.195(float %3842)
  %3844 = bitcast i32 %102 to float
  %3845 = fcmp olt float %3844, 0.000000e+00
  %3846 = sext i1 %3845 to i32
  %3847 = bitcast i32 %102 to float
  %3848 = fcmp ogt float %3847, 0.000000e+00
  %3849 = zext i1 %3848 to i32
  %3850 = add nsw i32 %3846, %3849
  %3851 = sitofp i32 %3850 to float
  %3852 = fneg float %3851
  %3853 = fmul float %3843, %3852
  %3854 = fmul float %3853, 0.000000e+00
  %3855 = bitcast i32 %131 to float
  %3856 = fadd float %3855, %3854
  %3857 = bitcast i32 %102 to float
  %3858 = bitcast i32 %102 to float
  %3859 = fmul float %3857, %3858
  %3860 = fadd float %3859, 0.000000e+00
  %3861 = bitcast i32 %131 to float
  %3862 = bitcast i32 %131 to float
  %3863 = fmul float %3861, %3862
  %3864 = fadd float %3860, %3863
  %3865 = call float @llvm.sqrt.f32.196(float %3864)
  %3866 = bitcast i32 %102 to float
  %3867 = fcmp olt float %3866, 0.000000e+00
  %3868 = sext i1 %3867 to i32
  %3869 = bitcast i32 %102 to float
  %3870 = fcmp ogt float %3869, 0.000000e+00
  %3871 = zext i1 %3870 to i32
  %3872 = add nsw i32 %3868, %3871
  %3873 = sitofp i32 %3872 to float
  %3874 = fneg float %3873
  %3875 = fmul float %3865, %3874
  %3876 = fmul float %3875, 0.000000e+00
  %3877 = bitcast i32 %131 to float
  %3878 = fadd float %3877, %3876
  %3879 = fmul float %3856, %3878
  %3880 = fadd float %3834, %3879
  %3881 = call float @llvm.sqrt.f32.197(float %3880)
  %3882 = fadd float %3881, 0.000000e+00
  %3883 = fdiv float %3790, %3882
  %3884 = fmul float %3883, 2.000000e+00
  %3885 = bitcast i32 %102 to float
  %3886 = bitcast i32 %102 to float
  %3887 = fmul float %3885, %3886
  %3888 = fadd float %3887, 0.000000e+00
  %3889 = bitcast i32 %131 to float
  %3890 = bitcast i32 %131 to float
  %3891 = fmul float %3889, %3890
  %3892 = fadd float %3888, %3891
  %3893 = call float @llvm.sqrt.f32.198(float %3892)
  %3894 = bitcast i32 %102 to float
  %3895 = fcmp olt float %3894, 0.000000e+00
  %3896 = sext i1 %3895 to i32
  %3897 = bitcast i32 %102 to float
  %3898 = fcmp ogt float %3897, 0.000000e+00
  %3899 = zext i1 %3898 to i32
  %3900 = add nsw i32 %3896, %3899
  %3901 = sitofp i32 %3900 to float
  %3902 = fneg float %3901
  %3903 = fmul float %3893, %3902
  %3904 = fmul float %3903, 0.000000e+00
  %3905 = bitcast i32 %131 to float
  %3906 = fadd float %3905, %3904
  %3907 = bitcast i32 %102 to float
  %3908 = bitcast i32 %102 to float
  %3909 = fmul float %3907, %3908
  %3910 = fadd float %3909, 0.000000e+00
  %3911 = bitcast i32 %131 to float
  %3912 = bitcast i32 %131 to float
  %3913 = fmul float %3911, %3912
  %3914 = fadd float %3910, %3913
  %3915 = call float @llvm.sqrt.f32.199(float %3914)
  %3916 = bitcast i32 %102 to float
  %3917 = fcmp olt float %3916, 0.000000e+00
  %3918 = sext i1 %3917 to i32
  %3919 = bitcast i32 %102 to float
  %3920 = fcmp ogt float %3919, 0.000000e+00
  %3921 = zext i1 %3920 to i32
  %3922 = add nsw i32 %3918, %3921
  %3923 = sitofp i32 %3922 to float
  %3924 = fneg float %3923
  %3925 = fmul float %3915, %3924
  %3926 = bitcast i32 %102 to float
  %3927 = fadd float %3926, %3925
  %3928 = bitcast i32 %102 to float
  %3929 = bitcast i32 %102 to float
  %3930 = fmul float %3928, %3929
  %3931 = fadd float %3930, 0.000000e+00
  %3932 = bitcast i32 %131 to float
  %3933 = bitcast i32 %131 to float
  %3934 = fmul float %3932, %3933
  %3935 = fadd float %3931, %3934
  %3936 = call float @llvm.sqrt.f32.200(float %3935)
  %3937 = bitcast i32 %102 to float
  %3938 = fcmp olt float %3937, 0.000000e+00
  %3939 = sext i1 %3938 to i32
  %3940 = bitcast i32 %102 to float
  %3941 = fcmp ogt float %3940, 0.000000e+00
  %3942 = zext i1 %3941 to i32
  %3943 = add nsw i32 %3939, %3942
  %3944 = sitofp i32 %3943 to float
  %3945 = fneg float %3944
  %3946 = fmul float %3936, %3945
  %3947 = bitcast i32 %102 to float
  %3948 = fadd float %3947, %3946
  %3949 = fmul float %3927, %3948
  %3950 = fadd float %3949, 0.000000e+00
  %3951 = bitcast i32 %102 to float
  %3952 = bitcast i32 %102 to float
  %3953 = fmul float %3951, %3952
  %3954 = fadd float %3953, 0.000000e+00
  %3955 = bitcast i32 %131 to float
  %3956 = bitcast i32 %131 to float
  %3957 = fmul float %3955, %3956
  %3958 = fadd float %3954, %3957
  %3959 = call float @llvm.sqrt.f32.201(float %3958)
  %3960 = bitcast i32 %102 to float
  %3961 = fcmp olt float %3960, 0.000000e+00
  %3962 = sext i1 %3961 to i32
  %3963 = bitcast i32 %102 to float
  %3964 = fcmp ogt float %3963, 0.000000e+00
  %3965 = zext i1 %3964 to i32
  %3966 = add nsw i32 %3962, %3965
  %3967 = sitofp i32 %3966 to float
  %3968 = fneg float %3967
  %3969 = fmul float %3959, %3968
  %3970 = fmul float %3969, 0.000000e+00
  %3971 = bitcast i32 %131 to float
  %3972 = fadd float %3971, %3970
  %3973 = bitcast i32 %102 to float
  %3974 = bitcast i32 %102 to float
  %3975 = fmul float %3973, %3974
  %3976 = fadd float %3975, 0.000000e+00
  %3977 = bitcast i32 %131 to float
  %3978 = bitcast i32 %131 to float
  %3979 = fmul float %3977, %3978
  %3980 = fadd float %3976, %3979
  %3981 = call float @llvm.sqrt.f32.202(float %3980)
  %3982 = bitcast i32 %102 to float
  %3983 = fcmp olt float %3982, 0.000000e+00
  %3984 = sext i1 %3983 to i32
  %3985 = bitcast i32 %102 to float
  %3986 = fcmp ogt float %3985, 0.000000e+00
  %3987 = zext i1 %3986 to i32
  %3988 = add nsw i32 %3984, %3987
  %3989 = sitofp i32 %3988 to float
  %3990 = fneg float %3989
  %3991 = fmul float %3981, %3990
  %3992 = fmul float %3991, 0.000000e+00
  %3993 = bitcast i32 %131 to float
  %3994 = fadd float %3993, %3992
  %3995 = fmul float %3972, %3994
  %3996 = fadd float %3950, %3995
  %3997 = call float @llvm.sqrt.f32.203(float %3996)
  %3998 = fadd float %3997, 0.000000e+00
  %3999 = fdiv float %3906, %3998
  %4000 = fmul float %3884, %3999
  %4001 = fsub float 1.000000e+00, %4000
  %4002 = getelementptr float, float* %0, i32 0
  %4003 = getelementptr inbounds float, float* %4002, i64 3
  %4004 = load float, float* %4003, align 4
  %4005 = fmul float %4001, %4004
  %4006 = fadd float %3768, %4005
  %4007 = insertelement <4 x float> zeroinitializer, float %4006, i32 0
  %4008 = insertelement <4 x float> %4007, float 0.000000e+00, i32 1
  %4009 = insertelement <4 x float> %4008, float 0.000000e+00, i32 2
  %4010 = insertelement <4 x float> %4009, float 0.000000e+00, i32 3
  %4011 = extractelement <4 x float> %4010, i32 0
  %4012 = getelementptr float, float* %2, i32 0
  %4013 = getelementptr inbounds float, float* %4012, i64 3
  store float %4011, float* %4013, align 4
  %4014 = getelementptr float, float* %1, i32 0
  %4015 = getelementptr inbounds float, float* %4014, i64 2
  %4016 = bitcast float* %4015 to i32*
  %4017 = load i32, i32* %4016, align 4
  %4018 = bitcast i32 %4017 to float
  %4019 = insertelement <4 x float> zeroinitializer, float %4018, i32 0
  %4020 = getelementptr float, float* %1, i32 0
  %4021 = getelementptr inbounds float, float* %4020, i64 1
  %4022 = bitcast float* %4021 to i32*
  %4023 = load i32, i32* %4022, align 4
  %4024 = bitcast i32 %4023 to float
  %4025 = insertelement <4 x float> %4019, float %4024, i32 1
  %4026 = insertelement <4 x float> %4025, float 0.000000e+00, i32 2
  %4027 = insertelement <4 x float> %4026, float 0.000000e+00, i32 3
  %4028 = extractelement <4 x float> %4027, i32 0
  %4029 = bitcast i32* %95 to float*
  %4030 = getelementptr float, float* %1, i32 0
  %4031 = getelementptr inbounds float, float* %4030, i64 1
  %4032 = bitcast float* %4031 to i32*
  %4033 = bitcast i32* %4032 to float*
  store float %4028, float* %4033, align 4
  %4034 = extractelement <4 x float> %4027, i32 1
  %4035 = bitcast i32* %98 to float*
  %4036 = getelementptr float, float* %1, i32 0
  %4037 = getelementptr inbounds float, float* %4036, i64 2
  %4038 = bitcast float* %4037 to i32*
  %4039 = bitcast i32* %4038 to float*
  store float %4034, float* %4039, align 4
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
  %6 = call i8* @__memcpy_chk(i8* %3, i8* %4, i64 16, i64 %5) #8
  %7 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
  %8 = bitcast i8* %7 to float*
  store float 1.000000e+00, float* %8, align 4
  %9 = getelementptr inbounds i8, i8* %7, i64 8
  %10 = getelementptr inbounds i8, i8* %7, i64 12
  %11 = bitcast i8* %10 to float*
  store float 1.000000e+00, float* %11, align 4
  %12 = bitcast float* %1 to i8*
  %13 = call i64 @llvm.objectsize.i64.p0i8(i8* %12, i1 false, i1 true, i1 false)
  %14 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
  %15 = bitcast i8* %14 to float*
  %16 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
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
  %38 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
  %39 = bitcast i8* %38 to float*
  %40 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
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
  %62 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
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
  %88 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
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
  %105 = call i8* @__memcpy_chk(i8* %12, i8* %88, i64 16, i64 %13) #8
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
  %6 = call i64 @time(i64* null) #8
  store i64 %6, i64* %0, align 8
  %7 = call i64 @time(i64* nonnull %0) #8
  %8 = trunc i64 %7 to i32
  call void @srand(i32 %8) #8
  %9 = call i32 @rand() #8
  %10 = sitofp i32 %9 to float
  %11 = fdiv float %10, 0x41747AE140000000
  %12 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 0
  store float %11, float* %12, align 16
  %13 = fpext float %11 to double
  %14 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %13) #8
  %15 = call i32 @rand() #8
  %16 = sitofp i32 %15 to float
  %17 = fdiv float %16, 0x41747AE140000000
  %18 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 1
  store float %17, float* %18, align 4
  %19 = fpext float %17 to double
  %20 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %19) #8
  %21 = call i32 @rand() #8
  %22 = sitofp i32 %21 to float
  %23 = fdiv float %22, 0x41747AE140000000
  %24 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 2
  store float %23, float* %24, align 8
  %25 = fpext float %23 to double
  %26 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %25) #8
  %27 = call i32 @rand() #8
  %28 = sitofp i32 %27 to float
  %29 = fdiv float %28, 0x41747AE140000000
  %30 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 3
  store float %29, float* %30, align 4
  %31 = fpext float %29 to double
  %32 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %31) #8
  %33 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %33, i8 0, i64 16, i1 false)
  %34 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %34, i8 0, i64 16, i1 false)
  %35 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %36 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  call void @naive_fixed_qr_decomp(float* nonnull %12, float* nonnull %35, float* nonnull %36)
  %37 = bitcast [4 x float]* %4 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %37, i8 0, i64 16, i1 false)
  %38 = bitcast [4 x float]* %5 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %38, i8 0, i64 16, i1 false)
  %39 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 0
  %40 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  call void @no_opt_naive_fixed_qr_decomp(float* nonnull %12, float* nonnull %39, float* nonnull %40)
  %41 = load float, float* %35, align 16
  %42 = fpext float %41 to double
  %43 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i64 0, i64 0), double %42) #8
  %44 = load float, float* %39, align 16
  %45 = fpext float %44 to double
  %46 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.2, i64 0, i64 0), double %45) #8
  %47 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 1
  %48 = load float, float* %47, align 4
  %49 = fpext float %48 to double
  %50 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i64 0, i64 0), double %49) #8
  %51 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 1
  %52 = load float, float* %51, align 4
  %53 = fpext float %52 to double
  %54 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.2, i64 0, i64 0), double %53) #8
  %55 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 2
  %56 = load float, float* %55, align 8
  %57 = fpext float %56 to double
  %58 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i64 0, i64 0), double %57) #8
  %59 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 2
  %60 = load float, float* %59, align 8
  %61 = fpext float %60 to double
  %62 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.2, i64 0, i64 0), double %61) #8
  %63 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 3
  %64 = load float, float* %63, align 4
  %65 = fpext float %64 to double
  %66 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i64 0, i64 0), double %65) #8
  %67 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 3
  %68 = load float, float* %67, align 4
  %69 = fpext float %68 to double
  %70 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.2, i64 0, i64 0), double %69) #8
  %71 = load float, float* %36, align 16
  %72 = fpext float %71 to double
  %73 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.3, i64 0, i64 0), double %72) #8
  %74 = load float, float* %40, align 16
  %75 = fpext float %74 to double
  %76 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.4, i64 0, i64 0), double %75) #8
  %77 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 1
  %78 = load float, float* %77, align 4
  %79 = fpext float %78 to double
  %80 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.3, i64 0, i64 0), double %79) #8
  %81 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 1
  %82 = load float, float* %81, align 4
  %83 = fpext float %82 to double
  %84 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.4, i64 0, i64 0), double %83) #8
  %85 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 2
  %86 = load float, float* %85, align 8
  %87 = fpext float %86 to double
  %88 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.3, i64 0, i64 0), double %87) #8
  %89 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 2
  %90 = load float, float* %89, align 8
  %91 = fpext float %90 to double
  %92 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.4, i64 0, i64 0), double %91) #8
  %93 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 3
  %94 = load float, float* %93, align 4
  %95 = fpext float %94 to double
  %96 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str.3, i64 0, i64 0), double %95) #8
  %97 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 3
  %98 = load float, float* %97, align 4
  %99 = fpext float %98 to double
  %100 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.4, i64 0, i64 0), double %99) #8
  ret i32 0
}

declare i64 @time(i64*) #6

declare void @srand(i32) #6

declare i32 @rand() #6

declare i32 @printf(i8*, ...) #6

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #7

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
attributes #7 = { argmemonly nounwind willreturn }
attributes #8 = { nounwind }
attributes #9 = { nounwind allocsize(0,1) }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
!3 = distinct !{!3, !4}
!4 = !{!"llvm.loop.unroll.disable"}
!5 = distinct !{!5, !4}
