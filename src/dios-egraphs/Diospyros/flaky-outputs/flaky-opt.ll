; ModuleID = 'build/clang.ll'
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
  store i32 %7, i32* %8, align 4
  %9 = getelementptr inbounds float, float* %0, i64 1
  %10 = bitcast float* %9 to i32*
  %11 = load i32, i32* %10, align 4
  %12 = getelementptr inbounds float, float* %2, i64 1
  %13 = bitcast float* %12 to i32*
  store i32 %11, i32* %13, align 4
  %14 = getelementptr inbounds float, float* %0, i64 2
  %15 = bitcast float* %14 to i32*
  %16 = load i32, i32* %15, align 4
  %17 = getelementptr inbounds float, float* %2, i64 2
  %18 = bitcast float* %17 to i32*
  store i32 %16, i32* %18, align 4
  %19 = getelementptr inbounds float, float* %0, i64 3
  %20 = bitcast float* %19 to i32*
  %21 = load i32, i32* %20, align 4
  %22 = getelementptr inbounds float, float* %2, i64 3
  %23 = bitcast float* %22 to i32*
  store i32 %21, i32* %23, align 4
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
  store i32 %59, i32* %60, align 16
  %61 = bitcast float %53 to i32
  %62 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 1
  %63 = bitcast float* %62 to i32*
  store i32 %61, i32* %63, align 4
  %64 = bitcast float %56 to i32
  %65 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 2
  %66 = bitcast float* %65 to i32*
  store i32 %64, i32* %66, align 8
  %67 = bitcast float %58 to i32
  %68 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 3
  %69 = bitcast float* %68 to i32*
  store i32 %67, i32* %69, align 4
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 4 dereferenceable(16) %3, i8* nonnull align 16 dereferenceable(16) %5, i64 16, i1 false)
  store float 0.000000e+00, float* %2, align 4
  %70 = load float, float* %0, align 4
  %71 = fmul float %51, %70
  %72 = fadd float %71, 0.000000e+00
  store float %72, float* %2, align 4
  %73 = load float, float* %14, align 4
  %74 = fmul float %53, %73
  %75 = fadd float %72, %74
  store float %75, float* %2, align 4
  store float 0.000000e+00, float* %12, align 4
  %76 = load float, float* %9, align 4
  %77 = fmul float %51, %76
  %78 = fadd float %77, 0.000000e+00
  store float %78, float* %12, align 4
  %79 = load float, float* %19, align 4
  %80 = fmul float %53, %79
  %81 = fadd float %78, %80
  store float %81, float* %12, align 4
  store float 0.000000e+00, float* %17, align 4
  %82 = load float, float* %0, align 4
  %83 = fmul float %56, %82
  %84 = fadd float %83, 0.000000e+00
  store float %84, float* %17, align 4
  %85 = load float, float* %14, align 4
  %86 = fmul float %58, %85
  %87 = fadd float %84, %86
  store float %87, float* %17, align 4
  store float 0.000000e+00, float* %22, align 4
  %88 = load float, float* %9, align 4
  %89 = fmul float %56, %88
  %90 = fadd float %89, 0.000000e+00
  store float %90, float* %22, align 4
  %91 = load float, float* %19, align 4
  %92 = fmul float %58, %91
  %93 = fadd float %90, %92
  store float %93, float* %22, align 4
  %94 = getelementptr inbounds float, float* %1, i64 1
  %95 = bitcast float* %94 to i32*
  %96 = load i32, i32* %95, align 4
  %97 = getelementptr inbounds float, float* %1, i64 2
  %98 = bitcast float* %97 to i32*
  %99 = load i32, i32* %98, align 4
  store i32 %99, i32* %95, align 4
  store i32 %96, i32* %98, align 4
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

73:                                               ; preds = %87, %.preheader.1, %59, %.preheader5
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
